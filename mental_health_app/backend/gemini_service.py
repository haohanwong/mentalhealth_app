import google.generativeai as genai
import os
from dotenv import load_dotenv
from typing import Dict, Any

load_dotenv()

class GeminiService:
    def __init__(self):
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("GEMINI_API_KEY not found in environment variables")
        
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-pro')
        
        self.system_prompt = """
        You are a compassionate and professional mental health support chatbot. Your role is to:
        
        1. Provide emotional support and empathetic responses
        2. Offer evidence-based coping strategies and mental health tips
        3. Help users process their feelings and thoughts
        4. Encourage professional help when needed
        5. Maintain confidentiality and non-judgmental approach
        
        Important guidelines:
        - Always be supportive and understanding
        - Never provide medical diagnoses or replace professional therapy
        - Encourage users to seek professional help for serious mental health concerns
        - Use active listening techniques in your responses
        - Provide practical coping strategies when appropriate
        - Maintain appropriate boundaries
        
        Remember: You are a supportive companion, not a replacement for professional mental health care.
        """
    
    async def get_response(self, user_message: str, conversation_history: list = None) -> str:
        try:
            # Prepare the conversation context
            full_prompt = self.system_prompt + "\n\n"
            
            if conversation_history:
                for msg in conversation_history[-5:]:  # Last 5 messages for context
                    full_prompt += f"User: {msg.get('message', '')}\n"
                    full_prompt += f"Assistant: {msg.get('response', '')}\n"
            
            full_prompt += f"User: {user_message}\nAssistant:"
            
            response = self.model.generate_content(full_prompt)
            return response.text
            
        except Exception as e:
            print(f"Error generating response: {e}")
            return "I apologize, but I'm having trouble responding right now. Please try again later, and remember that if you're in crisis, please contact a mental health professional or emergency services."
    
    def get_mental_health_tips(self) -> Dict[str, Any]:
        """Return general mental health tips and resources"""
        return {
            "daily_tips": [
                "Practice deep breathing exercises for 5 minutes",
                "Take a short walk outside if possible",
                "Write down three things you're grateful for",
                "Stay hydrated and eat nutritious meals",
                "Connect with a friend or family member"
            ],
            "coping_strategies": [
                "Progressive muscle relaxation",
                "Mindfulness meditation",
                "Journaling your thoughts and feelings",
                "Regular exercise or movement",
                "Establishing a consistent sleep routine"
            ],
            "emergency_resources": {
                "crisis_hotline": "988 (Suicide & Crisis Lifeline)",
                "text_line": "Text HOME to 741741",
                "emergency": "Call 911 or go to nearest emergency room"
            }
        }

gemini_service = GeminiService()