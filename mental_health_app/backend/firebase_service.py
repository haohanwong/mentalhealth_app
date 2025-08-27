import firebase_admin
from firebase_admin import credentials, firestore
import os
from datetime import datetime
from typing import Dict, List, Optional
import json
from dotenv import load_dotenv

load_dotenv()

class FirebaseService:
    def __init__(self):
        # Initialize Firebase Admin SDK
        if not firebase_admin._apps:
            # Check if we have a service account key file
            service_account_path = os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH")
            if service_account_path and os.path.exists(service_account_path):
                cred = credentials.Certificate(service_account_path)
            else:
                # Try to use service account key from environment variable
                service_account_key = os.getenv("FIREBASE_SERVICE_ACCOUNT_KEY")
                if service_account_key:
                    service_account_data = json.loads(service_account_key)
                    cred = credentials.Certificate(service_account_data)
                else:
                    # Use default credentials (if running on Google Cloud)
                    cred = credentials.ApplicationDefault()
            
            firebase_admin.initialize_app(cred)
        
        self.db = firestore.client()
    
    # Chat Messages
    async def save_chat_message(self, user_id: int, message: str, response: str, sentiment_data: dict = None) -> str:
        """Save a chat message to Firebase Firestore"""
        try:
            doc_data = {
                'user_id': user_id,
                'message': message,
                'response': response,
                'timestamp': firestore.SERVER_TIMESTAMP,
                'created_at': datetime.utcnow().isoformat()
            }
            
            if sentiment_data:
                doc_data['sentiment_analysis'] = sentiment_data
            
            # Add to chat_messages collection
            doc_ref = self.db.collection('chat_messages').add(doc_data)
            return doc_ref[1].id  # Return document ID
        except Exception as e:
            print(f"Error saving chat message to Firebase: {e}")
            raise e
    
    async def get_chat_history(self, user_id: int, limit: int = 20, last_doc_id: str = None) -> List[Dict]:
        """Get chat history for a user from Firebase Firestore"""
        try:
            query = self.db.collection('chat_messages').where('user_id', '==', user_id)
            query = query.order_by('timestamp', direction=firestore.Query.DESCENDING)
            query = query.limit(limit)
            
            if last_doc_id:
                # For pagination
                last_doc = self.db.collection('chat_messages').document(last_doc_id).get()
                if last_doc.exists:
                    query = query.start_after(last_doc)
            
            docs = query.stream()
            
            messages = []
            for doc in docs:
                data = doc.to_dict()
                data['id'] = doc.id
                # Convert timestamp to ISO format if it exists
                if 'timestamp' in data and data['timestamp']:
                    data['timestamp'] = data['timestamp'].isoformat()
                messages.append(data)
            
            return messages
        except Exception as e:
            print(f"Error getting chat history from Firebase: {e}")
            return []
    
    # User Data
    async def save_user_data(self, user_id: int, user_data: dict) -> str:
        """Save or update user data in Firebase"""
        try:
            doc_ref = self.db.collection('users').document(str(user_id))
            user_data['updated_at'] = firestore.SERVER_TIMESTAMP
            doc_ref.set(user_data, merge=True)
            return str(user_id)
        except Exception as e:
            print(f"Error saving user data to Firebase: {e}")
            raise e
    
    async def get_user_data(self, user_id: int) -> Optional[Dict]:
        """Get user data from Firebase"""
        try:
            doc_ref = self.db.collection('users').document(str(user_id))
            doc = doc_ref.get()
            if doc.exists:
                return doc.to_dict()
            return None
        except Exception as e:
            print(f"Error getting user data from Firebase: {e}")
            return None
    
    # Emotion Scores
    async def save_emotion_score(self, user_id: int, score: float, content_type: str, content_id: str, analysis_data: dict = None) -> str:
        """Save emotion score to Firebase"""
        try:
            doc_data = {
                'user_id': user_id,
                'score': score,
                'content_type': content_type,
                'content_id': content_id,
                'timestamp': firestore.SERVER_TIMESTAMP,
                'created_at': datetime.utcnow().isoformat()
            }
            
            if analysis_data:
                doc_data['analysis_data'] = analysis_data
            
            doc_ref = self.db.collection('emotion_scores').add(doc_data)
            return doc_ref[1].id
        except Exception as e:
            print(f"Error saving emotion score to Firebase: {e}")
            raise e
    
    async def get_emotion_scores(self, user_id: int, days: int = 30) -> List[Dict]:
        """Get emotion scores for a user from the last N days"""
        try:
            # Calculate date range
            from datetime import timedelta
            start_date = datetime.utcnow() - timedelta(days=days)
            
            query = self.db.collection('emotion_scores').where('user_id', '==', user_id)
            query = query.where('timestamp', '>=', start_date)
            query = query.order_by('timestamp', direction=firestore.Query.DESCENDING)
            
            docs = query.stream()
            
            scores = []
            for doc in docs:
                data = doc.to_dict()
                data['id'] = doc.id
                if 'timestamp' in data and data['timestamp']:
                    data['timestamp'] = data['timestamp'].isoformat()
                scores.append(data)
            
            return scores
        except Exception as e:
            print(f"Error getting emotion scores from Firebase: {e}")
            return []
    
    # Diary Entries
    async def save_diary_entry(self, user_id: int, title: str, content: str, sentiment_data: dict = None) -> str:
        """Save diary entry to Firebase"""
        try:
            doc_data = {
                'user_id': user_id,
                'title': title,
                'content': content,
                'timestamp': firestore.SERVER_TIMESTAMP,
                'created_at': datetime.utcnow().isoformat()
            }
            
            if sentiment_data:
                doc_data['sentiment_analysis'] = sentiment_data
            
            doc_ref = self.db.collection('diary_entries').add(doc_data)
            return doc_ref[1].id
        except Exception as e:
            print(f"Error saving diary entry to Firebase: {e}")
            raise e
    
    async def get_diary_entries(self, user_id: int, limit: int = 20) -> List[Dict]:
        """Get diary entries for a user"""
        try:
            query = self.db.collection('diary_entries').where('user_id', '==', user_id)
            query = query.order_by('timestamp', direction=firestore.Query.DESCENDING)
            query = query.limit(limit)
            
            docs = query.stream()
            
            entries = []
            for doc in docs:
                data = doc.to_dict()
                data['id'] = doc.id
                if 'timestamp' in data and data['timestamp']:
                    data['timestamp'] = data['timestamp'].isoformat()
                entries.append(data)
            
            return entries
        except Exception as e:
            print(f"Error getting diary entries from Firebase: {e}")
            return []
    
    # Analytics and Insights
    async def get_user_analytics(self, user_id: int, days: int = 30) -> Dict:
        """Get user analytics and insights"""
        try:
            # Get emotion scores
            emotion_scores = await self.get_emotion_scores(user_id, days)
            
            # Get chat message count
            chat_query = self.db.collection('chat_messages').where('user_id', '==', user_id)
            chat_docs = list(chat_query.stream())
            
            # Get diary entry count
            diary_query = self.db.collection('diary_entries').where('user_id', '==', user_id)
            diary_docs = list(diary_query.stream())
            
            analytics = {
                'total_chat_messages': len(chat_docs),
                'total_diary_entries': len(diary_docs),
                'emotion_scores_count': len(emotion_scores),
                'average_emotion_score': 0,
                'days_analyzed': days
            }
            
            if emotion_scores:
                scores = [score.get('score', 0) for score in emotion_scores]
                analytics['average_emotion_score'] = sum(scores) / len(scores)
            
            return analytics
        except Exception as e:
            print(f"Error getting user analytics from Firebase: {e}")
            return {}

# Global Firebase service instance
firebase_service = None

def get_firebase_service():
    global firebase_service
    if firebase_service is None:
        firebase_service = FirebaseService()
    return firebase_service