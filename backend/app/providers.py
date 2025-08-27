import os
from typing import List


def get_system_prompt() -> str:
    return (
        "You are a supportive, empathetic mental-health chat companion. "
        "You are not a doctor and cannot provide medical advice or diagnosis. "
        "Focus on active listening, validation, and gentle guidance. "
        "Encourage professional help when appropriate. "
        "If a user expresses intent to harm themselves or others, "
        "respond with care, suggest reaching out to local emergency services, "
        "and share crisis resources relevant to their region if known."
    )


class AIResponder:
    def __init__(self) -> None:
        self.provider = os.getenv("AI_PROVIDER", "gemini").lower()
        if self.provider not in {"gemini", "openai"}:
            raise ValueError("AI_PROVIDER must be 'gemini' or 'openai'")

        if self.provider == "gemini":
            import google.generativeai as genai  # type: ignore

            api_key = os.getenv("GEMINI_API_KEY")
            if not api_key:
                raise ValueError("GEMINI_API_KEY is required for Gemini provider")
            genai.configure(api_key=api_key)
            self._gemini = genai
            self.gemini_model = os.getenv("GEMINI_MODEL", "gemini-1.5-pro")
        else:
            from openai import OpenAI  # type: ignore

            api_key = os.getenv("OPENAI_API_KEY")
            if not api_key:
                raise ValueError("OPENAI_API_KEY is required for OpenAI provider")
            self._openai_client = OpenAI(api_key=api_key)
            self.openai_model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

    def generate_reply(self, messages: List[dict]) -> str:
        if self.provider == "gemini":
            return self._generate_with_gemini(messages)
        return self._generate_with_openai(messages)

    def _generate_with_openai(self, messages: List[dict]) -> str:
        # messages are OpenAI-style already
        result = self._openai_client.chat.completions.create(
            model=self.openai_model,
            messages=messages,
            temperature=0.7,
            max_tokens=800,
        )
        content = result.choices[0].message.content or ""
        return content.strip()

    def _generate_with_gemini(self, messages: List[dict]) -> str:
        # Convert OpenAI-style messages to Gemini contents
        contents = []
        for m in messages:
            role = m.get("role", "user")
            text = m.get("content", "")
            if not text:
                continue
            gemini_role = "user" if role in {"user", "system"} else "model"
            contents.append({"role": gemini_role, "parts": [text]})

        model = self._gemini.GenerativeModel(self.gemini_model)
        resp = model.generate_content(contents)
        # google-generativeai returns candidates; take the first
        text = resp.text or ""
        return text.strip()

