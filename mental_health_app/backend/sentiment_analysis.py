from textblob import TextBlob
from typing import Dict, Any
import re

class SentimentAnalyzer:
    def __init__(self):
        self.positive_keywords = [
            'happy', 'joy', 'excited', 'grateful', 'peaceful', 'calm', 'content',
            'satisfied', 'optimistic', 'hopeful', 'love', 'amazing', 'wonderful',
            'fantastic', 'great', 'good', 'pleased', 'delighted', 'cheerful',
            'blessed', 'lucky', 'proud', 'confident', 'successful', 'accomplished'
        ]
        
        self.negative_keywords = [
            'sad', 'depressed', 'anxious', 'worried', 'scared', 'angry', 'frustrated',
            'upset', 'disappointed', 'lonely', 'stressed', 'overwhelmed', 'tired',
            'exhausted', 'hopeless', 'worthless', 'terrible', 'awful', 'horrible',
            'miserable', 'devastated', 'broken', 'lost', 'confused', 'hurt'
        ]
    
    def analyze_sentiment(self, text: str) -> Dict[str, Any]:
        """
        Analyze sentiment of text and return detailed results
        Returns sentiment score between -1 (very negative) and 1 (very positive)
        """
        if not text or text.strip() == "":
            return {
                "score": 0.0,
                "polarity": 0.0,
                "subjectivity": 0.0,
                "classification": "neutral",
                "confidence": 0.0,
                "keywords_found": []
            }
        
        # Clean and prepare text
        cleaned_text = self._clean_text(text)
        
        # TextBlob analysis
        blob = TextBlob(cleaned_text)
        polarity = blob.sentiment.polarity
        subjectivity = blob.sentiment.subjectivity
        
        # Keyword analysis for additional context
        keyword_score, keywords_found = self._analyze_keywords(cleaned_text.lower())
        
        # Combine TextBlob score with keyword analysis
        # Weight: 70% TextBlob, 30% keyword analysis
        combined_score = (polarity * 0.7) + (keyword_score * 0.3)
        
        # Normalize score to ensure it stays within -1 to 1
        final_score = max(-1.0, min(1.0, combined_score))
        
        # Classify sentiment
        classification = self._classify_sentiment(final_score)
        
        # Calculate confidence based on subjectivity and keyword presence
        confidence = self._calculate_confidence(subjectivity, len(keywords_found), len(cleaned_text.split()))
        
        return {
            "score": round(final_score, 3),
            "polarity": round(polarity, 3),
            "subjectivity": round(subjectivity, 3),
            "classification": classification,
            "confidence": round(confidence, 3),
            "keywords_found": keywords_found
        }
    
    def _clean_text(self, text: str) -> str:
        """Clean and preprocess text"""
        # Remove URLs, mentions, hashtags
        text = re.sub(r'http\S+|www\S+|@\w+|#\w+', '', text)
        # Remove extra whitespace
        text = re.sub(r'\s+', ' ', text).strip()
        return text
    
    def _analyze_keywords(self, text: str) -> tuple:
        """Analyze sentiment based on keywords"""
        positive_count = sum(1 for word in self.positive_keywords if word in text)
        negative_count = sum(1 for word in self.negative_keywords if word in text)
        
        keywords_found = []
        for word in self.positive_keywords:
            if word in text:
                keywords_found.append(f"+{word}")
        for word in self.negative_keywords:
            if word in text:
                keywords_found.append(f"-{word}")
        
        if positive_count == 0 and negative_count == 0:
            return 0.0, keywords_found
        
        # Calculate keyword-based score
        total_keywords = positive_count + negative_count
        keyword_score = (positive_count - negative_count) / max(total_keywords, 1)
        
        return keyword_score, keywords_found
    
    def _classify_sentiment(self, score: float) -> str:
        """Classify sentiment based on score"""
        if score >= 0.5:
            return "very_positive"
        elif score >= 0.1:
            return "positive"
        elif score >= -0.1:
            return "neutral"
        elif score >= -0.5:
            return "negative"
        else:
            return "very_negative"
    
    def _calculate_confidence(self, subjectivity: float, keyword_count: int, word_count: int) -> float:
        """Calculate confidence in sentiment analysis"""
        # Higher subjectivity usually means more reliable sentiment
        # More keywords found increases confidence
        # Longer text generally provides more reliable analysis
        
        subjectivity_factor = subjectivity
        keyword_factor = min(keyword_count / 5, 1.0)  # Cap at 5 keywords
        length_factor = min(word_count / 50, 1.0)  # Cap at 50 words
        
        confidence = (subjectivity_factor * 0.5) + (keyword_factor * 0.3) + (length_factor * 0.2)
        return min(confidence, 1.0)
    
    def get_emotion_insights(self, scores: list) -> Dict[str, Any]:
        """Analyze emotion trends from a list of sentiment scores"""
        if not scores:
            return {"trend": "insufficient_data", "average": 0.0, "volatility": 0.0}
        
        average_score = sum(scores) / len(scores)
        
        # Calculate volatility (standard deviation)
        if len(scores) > 1:
            variance = sum((score - average_score) ** 2 for score in scores) / len(scores)
            volatility = variance ** 0.5
        else:
            volatility = 0.0
        
        # Determine trend (comparing first half with second half)
        if len(scores) >= 4:
            first_half = scores[:len(scores)//2]
            second_half = scores[len(scores)//2:]
            first_avg = sum(first_half) / len(first_half)
            second_avg = sum(second_half) / len(second_half)
            
            if second_avg > first_avg + 0.1:
                trend = "improving"
            elif second_avg < first_avg - 0.1:
                trend = "declining"
            else:
                trend = "stable"
        else:
            trend = "insufficient_data"
        
        return {
            "trend": trend,
            "average": round(average_score, 3),
            "volatility": round(volatility, 3),
            "total_entries": len(scores),
            "classification": self._classify_sentiment(average_score)
        }

sentiment_analyzer = SentimentAnalyzer()