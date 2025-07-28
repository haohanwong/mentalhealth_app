from pydantic import BaseModel, EmailStr, ConfigDict
from typing import Optional, List
from datetime import datetime

# User schemas
class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    username: str
    email: str
    created_at: datetime

# Token schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

# Diary schemas
class DiaryEntryCreate(BaseModel):
    title: str
    content: str

class DiaryEntryUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None

class DiaryEntryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    title: str
    content: str
    created_at: datetime
    user_id: int

# Chat schemas
class ChatMessageCreate(BaseModel):
    message: str

class ChatMessageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    message: str
    response: str
    created_at: datetime
    user_id: int

class ChatResponse(BaseModel):
    response: str
    sentiment_analysis: 'SentimentAnalysisResponse'
    chat_id: int

# Sentiment analysis schemas
class SentimentAnalysisResponse(BaseModel):
    sentiment_score: float
    sentiment_label: str
    confidence: float
    emotion_keywords: List[str]

# Emotion tracking schemas
class EmotionScoreResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: int
    score: float
    date: datetime
    content_type: str
    content_id: int

class EmotionTrendResponse(BaseModel):
    trend: str
    average: float
    volatility: float
    total_entries: int
    classification: str
    scores: List[EmotionScoreResponse]

# Mental health resources
class MentalHealthResourceResponse(BaseModel):
    title: str
    description: str
    category: str
    url: Optional[str] = None
    phone: Optional[str] = None

class EmergencyResource(BaseModel):
    crisis_hotline: str
    text_line: str
    emergency: str

class MentalHealthResources(BaseModel):
    daily_tips: List[str]
    coping_strategies: List[str]
    emergency_resources: EmergencyResource