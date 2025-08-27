import os
import uuid
from typing import List, Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from google.cloud import firestore

from .providers import AIResponder, get_system_prompt


class ChatRequest(BaseModel):
    user_id: str = Field(..., description="Firebase Auth user uid")
    message: str = Field(..., min_length=1)
    conversation_id: Optional[str] = None


class ChatResponse(BaseModel):
    reply: str
    conversation_id: str


def _get_firestore_client() -> firestore.Client:
    project_id = os.getenv("FIREBASE_PROJECT_ID")
    try:
        # If GOOGLE_APPLICATION_CREDENTIALS is set, the client will pick it up.
        return firestore.Client(project=project_id) if project_id else firestore.Client()
    except Exception as exc:
        raise RuntimeError(
            "Failed to initialize Firestore client. Ensure GOOGLE_APPLICATION_CREDENTIALS and FIREBASE_PROJECT_ID are configured."
        ) from exc


db: firestore.Client = _get_firestore_client()

app = FastAPI(title="AI Chat Companion API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def _conversation_ref(user_id: str, conversation_id: str):
    return (
        db.collection("users")
        .document(user_id)
        .collection("conversations")
        .document(conversation_id)
    )


def _messages_ref(user_id: str, conversation_id: str):
    return _conversation_ref(user_id, conversation_id).collection("messages")


def _ensure_conversation(user_id: str, conversation_id: Optional[str], title_hint: str) -> str:
    if conversation_id:
        return conversation_id

    new_id = uuid.uuid4().hex
    conv_ref = _conversation_ref(user_id, new_id)
    conv_ref.set(
        {
            "title": (title_hint[:48] + "…") if len(title_hint) > 48 else title_hint,
            "createdAt": firestore.SERVER_TIMESTAMP,
            "updatedAt": firestore.SERVER_TIMESTAMP,
        }
    )
    return new_id


def _load_recent_messages(user_id: str, conversation_id: str, limit: int = 20) -> List[dict]:
    # Pull last N messages as history in chronological order
    query = (
        _messages_ref(user_id, conversation_id)
        .order_by("createdAt", direction=firestore.Query.DESCENDING)
        .limit(limit)
    )
    docs = list(query.stream())
    history = []
    for doc in reversed(docs):  # chronological
        data = doc.to_dict() or {}
        role = data.get("role", "user")
        content = data.get("content", "")
        if not content:
            continue
        history.append({"role": role, "content": content})
    return history


@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest) -> ChatResponse:
    if not req.message.strip():
        raise HTTPException(status_code=400, detail="Message must not be empty")

    conversation_id = _ensure_conversation(req.user_id, req.conversation_id, title_hint=req.message.strip())

    # Compose context
    system_prompt = get_system_prompt()
    history = _load_recent_messages(req.user_id, conversation_id)
    messages: List[dict] = [{"role": "system", "content": system_prompt}] + history + [
        {"role": "user", "content": req.message.strip()}
    ]

    # Persist user message first
    _messages_ref(req.user_id, conversation_id).add(
        {
            "role": "user",
            "content": req.message.strip(),
            "createdAt": firestore.SERVER_TIMESTAMP,
        }
    )

    # Generate reply
    try:
        responder = AIResponder()
        reply_text = responder.generate_reply(messages)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"AI provider error: {exc}")

    # Persist assistant reply
    _messages_ref(req.user_id, conversation_id).add(
        {
            "role": "assistant",
            "content": reply_text,
            "createdAt": firestore.SERVER_TIMESTAMP,
        }
    )

    # Touch conversation updatedAt
    _conversation_ref(req.user_id, conversation_id).set(
        {"updatedAt": firestore.SERVER_TIMESTAMP}, merge=True
    )

    return ChatResponse(reply=reply_text, conversation_id=conversation_id)


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}

