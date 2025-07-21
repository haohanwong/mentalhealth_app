# Mental Health Mobile App

A comprehensive mental health support application built with Flutter frontend and Python FastAPI backend, featuring AI-powered chatbot, diary functionality, and emotion tracking.

## Features

### 🤖 AI Chatbot
- Powered by Google's Gemini LLM
- Specialized in mental health support and guidance
- Contextual conversations with chat history
- Empathetic responses and coping strategies

### 📔 Digital Diary
- Personal journal for daily thoughts and experiences
- Create, read, update, and delete diary entries
- Automatic sentiment analysis of entries
- Secure and private storage

### 📊 Emotion Tracking
- Real-time sentiment analysis using TextBlob and custom algorithms
- Emotional trend visualization with line charts
- Track mood patterns over time
- Insights into emotional well-being

### 🔐 User Authentication
- Secure user registration and login
- JWT token-based authentication
- Password hashing with bcrypt

## Technology Stack

### Backend (Python)
- **FastAPI**: Modern, fast web framework
- **SQLAlchemy**: SQL toolkit and ORM
- **SQLite**: Lightweight database
- **Google Generative AI (Gemini)**: LLM for chatbot
- **TextBlob**: Natural language processing for sentiment analysis
- **Passlib**: Password hashing
- **Python-Jose**: JWT token handling

### Frontend (Flutter)
- **Flutter**: Cross-platform mobile development
- **Provider**: State management
- **HTTP**: API communication
- **FL Chart**: Data visualization
- **Shared Preferences**: Local storage
- **JSON Annotation**: Serialization

## Project Structure

```
mental_health_app/
├── backend/
│   ├── main.py                 # FastAPI application entry point
│   ├── database.py             # Database models and configuration
│   ├── auth.py                 # Authentication utilities
│   ├── gemini_service.py       # AI chatbot service
│   ├── sentiment_analysis.py   # Emotion analysis engine
│   ├── schemas.py              # Pydantic models
│   ├── requirements.txt        # Python dependencies
│   └── .env.example           # Environment variables template
└── frontend/
    ├── lib/
    │   ├── main.dart          # App entry point
    │   ├── models/            # Data models
    │   ├── providers/         # State management
    │   ├── services/          # API services
    │   └── screens/           # UI screens
    ├── pubspec.yaml           # Flutter dependencies
    └── assets/                # App assets
```

## Setup Instructions

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd mental_health_app/backend
   ```

2. **Create and activate virtual environment:**
   ```bash
   python3 -m venv venv
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
   
   Edit `.env` file and add your API keys:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   SECRET_KEY=your_secret_key_here
   ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=30
   DATABASE_URL=sqlite:///./mental_health_app.db
   ```

5. **Get Gemini API Key:**
   - Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Create a new API key
   - Copy the key to your `.env` file

6. **Run the backend server:**
   ```bash
   uvicorn main:app --reload
   ```
   
   The API will be available at `http://localhost:8000`
   API documentation: `http://localhost:8000/docs`

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd mental_health_app/frontend
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate model files:**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Update API URL (if needed):**
   Edit `lib/services/api_service.dart` and update the `baseUrl` to match your backend URL.

5. **Run the Flutter app:**
   ```bash
   flutter run
   ```

## API Endpoints

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /auth/me` - Get current user info

### Diary
- `POST /diary` - Create diary entry
- `GET /diary` - Get diary entries
- `GET /diary/{id}` - Get specific diary entry
- `PUT /diary/{id}` - Update diary entry
- `DELETE /diary/{id}` - Delete diary entry

### Chat
- `POST /chat` - Send message to AI chatbot
- `GET /chat/history` - Get chat history

### Emotions
- `GET /emotions/trend` - Get emotion trend analysis
- `GET /emotions/analyze` - Analyze text sentiment

### Resources
- `GET /resources` - Get mental health resources

## Features in Detail

### Sentiment Analysis
The app uses a hybrid approach for sentiment analysis:
- **TextBlob**: Provides polarity and subjectivity scores
- **Keyword Analysis**: Custom positive/negative keyword matching
- **Combined Scoring**: Weighted combination of both methods
- **Confidence Metrics**: Reliability scoring for analysis results

### Emotion Tracking
- **Trend Analysis**: Compares mood over time periods
- **Volatility Measurement**: Tracks emotional stability
- **Visual Charts**: Line graphs showing mood progression
- **Classification**: Categorizes emotions into 5 levels

### AI Chatbot
- **Mental Health Focus**: Specialized prompts for therapy-like conversations
- **Context Awareness**: Maintains conversation history
- **Safety Guidelines**: Encourages professional help when needed
- **Coping Strategies**: Provides evidence-based mental health tips

## Security Features

- **Password Hashing**: Bcrypt encryption for user passwords
- **JWT Authentication**: Secure token-based authentication
- **Input Validation**: Pydantic models for request validation
- **CORS Protection**: Configurable cross-origin resource sharing
- **Private Data**: User data isolation and protection

## Development Notes

### Adding New Features
1. **Backend**: Add new endpoints in `main.py`, create schemas in `schemas.py`
2. **Frontend**: Create new screens, update navigation, add API calls
3. **Models**: Update both backend and frontend models for data consistency

### Database Migrations
The app uses SQLite with SQLAlchemy. To modify the database schema:
1. Update models in `database.py`
2. Delete the existing database file
3. Restart the server to recreate tables

### Styling Guidelines
- **Material Design**: Follows Material Design 3 principles
- **Color Scheme**: Blue primary color with semantic colors for emotions
- **Typography**: Roboto font family
- **Responsive Design**: Adapts to different screen sizes

## Mental Health Resources

The app includes emergency mental health resources:
- **Crisis Hotline**: 988 (Suicide & Crisis Lifeline)
- **Text Support**: Text HOME to 741741
- **Emergency**: 911 or nearest emergency room

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is intended for educational and personal use. Please ensure compliance with healthcare regulations in your jurisdiction if deploying for real users.

## Disclaimer

This application is not a replacement for professional mental health care. Users experiencing mental health crises should contact emergency services or mental health professionals immediately.

## Support

For issues and questions:
1. Check the API documentation at `/docs`
2. Review the error logs in the backend console
3. Ensure all environment variables are properly set
4. Verify API connectivity between frontend and backend