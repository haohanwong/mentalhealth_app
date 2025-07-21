# Mental Health App Setup Guide

This guide will help you set up and run the Mental Health Mobile App with a Flutter frontend and Python FastAPI backend.

## Prerequisites

- Python 3.11+ (Python 3.13 may have some dependency issues)
- Flutter SDK 3.27.1+
- Git

## Backend Setup

1. **Navigate to the backend directory:**
   ```bash
   cd mental_health_app/backend
   ```

2. **Create and activate a virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```
   Edit the `.env` file and add your Google Gemini API key:
   ```
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   SECRET_KEY=your_super_secret_jwt_key_here
   ```

5. **Run the backend server:**
   ```bash
   python main.py
   ```
   The backend will be available at `http://localhost:8000`

## Frontend Setup

1. **Navigate to the frontend directory:**
   ```bash
   cd mental_health_app/frontend
   ```

2. **Get Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate JSON serialization code:**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app:**
   
   For web:
   ```bash
   flutter run -d web-server --web-port 3000
   ```
   
   For mobile (requires Android/iOS setup):
   ```bash
   flutter run
   ```

## Features

### Backend API (FastAPI)
- **User Authentication**: Registration, login with JWT tokens
- **Diary Management**: CRUD operations for diary entries
- **AI Chatbot**: Google Gemini-powered mental health chatbot
- **Sentiment Analysis**: TextBlob + keyword analysis for emotional tracking
- **Emotion Trends**: Historical emotion data and insights
- **Mental Health Resources**: Tips and emergency resources

### Frontend (Flutter)
- **Cross-platform**: Runs on Web, Android, iOS
- **Authentication UI**: Login and registration screens
- **Dashboard**: Overview of mental health metrics
- **Chat Interface**: Conversation with AI chatbot
- **Diary Writing**: Create and manage diary entries
- **Emotion Tracking**: Visualize emotional trends over time

## API Endpoints

- `POST /register` - User registration
- `POST /login` - User login
- `GET /users/me` - Get current user info
- `POST /diary` - Create diary entry
- `GET /diary` - Get user's diary entries
- `POST /chat` - Chat with AI bot
- `GET /emotions/trends` - Get emotion trends
- `GET /resources` - Get mental health resources

## Development Notes

1. **CORS**: The backend includes CORS middleware for web development
2. **Database**: Uses SQLite for simplicity (can be changed to PostgreSQL/MySQL)
3. **Security**: JWT tokens for authentication, password hashing with bcrypt
4. **AI Integration**: Google Gemini API for intelligent responses
5. **Sentiment Analysis**: Combines TextBlob polarity with custom keyword analysis

## Troubleshooting

### Backend Issues
- **Pydantic build errors**: Use Python 3.11 instead of 3.13
- **Missing Gemini API key**: Make sure to set GEMINI_API_KEY in .env
- **Database errors**: Delete `mental_health.db` to reset the database

### Frontend Issues
- **Build errors**: Run `flutter clean` then `flutter pub get`
- **JSON serialization**: Run `flutter packages pub run build_runner build --delete-conflicting-outputs`
- **Web CORS errors**: Make sure backend is running on port 8000

## Next Steps

1. **Set up real Gemini API key** for full AI functionality
2. **Implement emotion chart visualization** with fl_chart
3. **Add more comprehensive diary features**
4. **Implement push notifications**
5. **Add data export functionality**
6. **Deploy to production** (backend to cloud, frontend to web/app stores)

## Contributing

This project demonstrates integration of:
- Modern Flutter UI development
- FastAPI backend architecture
- AI/ML integration with Google Gemini
- Sentiment analysis and emotional tracking
- JWT authentication
- Cross-platform mobile development