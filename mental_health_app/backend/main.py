from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import timedelta
from typing import List

# Import local modules
from database import get_db, create_tables, User, DiaryEntry, ChatMessage, EmotionScore
from auth import (
    verify_password, get_password_hash, create_access_token, 
    get_current_user, ACCESS_TOKEN_EXPIRE_MINUTES
)
from schemas import (
    UserCreate, UserLogin, UserResponse, Token, DiaryEntryCreate, 
    DiaryEntryUpdate, DiaryEntryResponse, ChatMessageCreate, 
    ChatMessageResponse, ChatResponse, EmotionTrendResponse, EmotionScoreResponse,
    SentimentAnalysisResponse, MentalHealthResources
)
from gemini_service import gemini_service
from sentiment_analysis import sentiment_analyzer

# Create FastAPI app
app = FastAPI(
    title="Mental Health App API",
    description="A comprehensive mental health support application with chatbot, diary, and emotion tracking",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create database tables on startup
@app.on_event("startup")
def startup_event():
    create_tables()

# Root endpoint
@app.get("/")
def read_root():
    return {"message": "Mental Health App API", "version": "1.0.0"}

# Authentication endpoints
@app.post("/auth/register", response_model=UserResponse)
def register(user: UserCreate, db: Session = Depends(get_db)):
    # Check if user already exists
    db_user = db.query(User).filter(
        (User.username == user.username) | (User.email == user.email)
    ).first()
    if db_user:
        raise HTTPException(
            status_code=400, 
            detail="Username or email already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user.password)
    db_user = User(
        username=user.username,
        email=user.email,
        hashed_password=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return db_user

@app.post("/auth/login", response_model=Token)
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.username == user.username).first()
    if not db_user or not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": db_user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/auth/me", response_model=UserResponse)
def get_current_user_info(current_user: User = Depends(get_current_user)):
    return current_user

# Diary endpoints
@app.post("/diary", response_model=DiaryEntryResponse)
def create_diary_entry(
    entry: DiaryEntryCreate, 
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    db_entry = DiaryEntry(
        title=entry.title,
        content=entry.content,
        user_id=current_user.id
    )
    db.add(db_entry)
    db.commit()
    db.refresh(db_entry)
    
    # Analyze sentiment and store emotion score
    sentiment_result = sentiment_analyzer.analyze_sentiment(entry.content)
    emotion_score = EmotionScore(
        score=sentiment_result["score"],
        content_type="diary",
        content_id=db_entry.id,
        user_id=current_user.id
    )
    db.add(emotion_score)
    db.commit()
    
    return db_entry

@app.get("/diary", response_model=List[DiaryEntryResponse])
def get_diary_entries(
    skip: int = 0,
    limit: int = 10,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    entries = db.query(DiaryEntry).filter(
        DiaryEntry.user_id == current_user.id
    ).offset(skip).limit(limit).all()
    return entries

@app.get("/diary/{entry_id}", response_model=DiaryEntryResponse)
def get_diary_entry(
    entry_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    entry = db.query(DiaryEntry).filter(
        DiaryEntry.id == entry_id,
        DiaryEntry.user_id == current_user.id
    ).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Diary entry not found")
    return entry

@app.put("/diary/{entry_id}", response_model=DiaryEntryResponse)
def update_diary_entry(
    entry_id: int,
    entry_update: DiaryEntryUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    entry = db.query(DiaryEntry).filter(
        DiaryEntry.id == entry_id,
        DiaryEntry.user_id == current_user.id
    ).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Diary entry not found")
    
    if entry_update.title is not None:
        entry.title = entry_update.title
    if entry_update.content is not None:
        entry.content = entry_update.content
        # Re-analyze sentiment for updated content
        sentiment_result = sentiment_analyzer.analyze_sentiment(entry.content)
        # Update existing emotion score
        emotion_score = db.query(EmotionScore).filter(
            EmotionScore.content_type == "diary",
            EmotionScore.content_id == entry_id,
            EmotionScore.user_id == current_user.id
        ).first()
        if emotion_score:
            emotion_score.score = sentiment_result["score"]
    
    db.commit()
    db.refresh(entry)
    return entry

@app.delete("/diary/{entry_id}")
def delete_diary_entry(
    entry_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    entry = db.query(DiaryEntry).filter(
        DiaryEntry.id == entry_id,
        DiaryEntry.user_id == current_user.id
    ).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Diary entry not found")
    
    # Delete associated emotion score
    db.query(EmotionScore).filter(
        EmotionScore.content_type == "diary",
        EmotionScore.content_id == entry_id,
        EmotionScore.user_id == current_user.id
    ).delete()
    
    db.delete(entry)
    db.commit()
    return {"message": "Diary entry deleted successfully"}

# Chat endpoints
@app.post("/chat", response_model=ChatResponse)
async def chat_with_bot(
    message: ChatMessageCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Get recent chat history for context
    recent_chats = db.query(ChatMessage).filter(
        ChatMessage.user_id == current_user.id
    ).order_by(ChatMessage.created_at.desc()).limit(5).all()
    
    conversation_history = [
        {"message": chat.message, "response": chat.response}
        for chat in reversed(recent_chats)
    ]
    
    # Get response from Gemini
    bot_response = await gemini_service.get_response(
        message.message, conversation_history
    )
    
    # Save chat message
    chat_message = ChatMessage(
        message=message.message,
        response=bot_response,
        user_id=current_user.id
    )
    db.add(chat_message)
    db.commit()
    db.refresh(chat_message)
    
    # Analyze sentiment of user's message
    sentiment_result = sentiment_analyzer.analyze_sentiment(message.message)
    emotion_score = EmotionScore(
        score=sentiment_result["sentiment_score"],
        content_type="chat",
        content_id=chat_message.id,
        user_id=current_user.id
    )
    db.add(emotion_score)
    db.commit()
    
    return ChatResponse(
        response=bot_response,
        sentiment_analysis=SentimentAnalysisResponse(**sentiment_result),
        chat_id=chat_message.id
    )

@app.get("/chat/history", response_model=List[ChatMessageResponse])
def get_chat_history(
    skip: int = 0,
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    messages = db.query(ChatMessage).filter(
        ChatMessage.user_id == current_user.id
    ).order_by(ChatMessage.created_at.desc()).offset(skip).limit(limit).all()
    return messages

# Emotion tracking endpoints
@app.get("/emotions/trend", response_model=EmotionTrendResponse)
def get_emotion_trend(
    days: int = 30,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Get emotion scores from the last N days
    emotion_scores = db.query(EmotionScore).filter(
        EmotionScore.user_id == current_user.id
    ).order_by(EmotionScore.created_at.desc()).limit(days * 5).all()  # Estimate 5 entries per day
    
    scores = [score.score for score in emotion_scores]
    insights = sentiment_analyzer.get_emotion_insights(scores)
    
    # Format scores with metadata
    formatted_scores = [
        {
            "score": score.score,
            "date": score.created_at.isoformat(),
            "content_type": score.content_type,
            "content_id": score.content_id
        }
        for score in emotion_scores
    ]
    
    return EmotionTrendResponse(
        trend=insights["trend"],
        average=insights["average"],
        volatility=insights["volatility"],
        total_entries=insights["total_entries"],
        classification=insights["classification"],
        scores=formatted_scores
    )

@app.get("/emotions/analyze")
def analyze_text_sentiment(text: str):
    """Endpoint to analyze sentiment of any text"""
    result = sentiment_analyzer.analyze_sentiment(text)
    return SentimentAnalysisResponse(**result)

# Mental health resources
@app.get("/resources", response_model=MentalHealthResources)
def get_mental_health_resources():
    resources = gemini_service.get_mental_health_tips()
    return MentalHealthResources(**resources)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)