import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/diary.dart';
import '../models/chat.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Change this to your backend URL
  
  static String? _token;
  
  static String? get token => _token;
  
  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }
  
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }
  
  // Authentication API calls
  static Future<AuthToken> register(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    
    if (response.statusCode == 200) {
      // After successful registration, log in automatically
      final loginRequest = LoginRequest(
        username: request.username,
        password: request.password,
      );
      return await login(loginRequest);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }
  
  static Future<AuthToken> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'username=${request.username}&password=${request.password}',
    );
    
    if (response.statusCode == 200) {
      final token = AuthToken.fromJson(jsonDecode(response.body));
      await setToken(token.accessToken);
      return token;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }
  
  static Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user info: ${response.body}');
    }
  }
  
  // Diary API calls
  static Future<DiaryEntry> createDiaryEntry(DiaryEntryCreate entry) async {
    final response = await http.post(
      Uri.parse('$baseUrl/diary'),
      headers: _headers,
      body: jsonEncode(entry.toJson()),
    );
    
    if (response.statusCode == 200) {
      return DiaryEntry.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create diary entry: ${response.body}');
    }
  }
  
  static Future<List<DiaryEntry>> getDiaryEntries({int skip = 0, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/diary?skip=$skip&limit=$limit'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DiaryEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get diary entries: ${response.body}');
    }
  }
  
  static Future<DiaryEntry> getDiaryEntry(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/diary/$id'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return DiaryEntry.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get diary entry: ${response.body}');
    }
  }
  
  static Future<DiaryEntry> updateDiaryEntry(int id, DiaryEntryUpdate update) async {
    final response = await http.put(
      Uri.parse('$baseUrl/diary/$id'),
      headers: _headers,
      body: jsonEncode(update.toJson()),
    );
    
    if (response.statusCode == 200) {
      return DiaryEntry.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update diary entry: ${response.body}');
    }
  }
  
  static Future<void> deleteDiaryEntry(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/diary/$id'),
      headers: _headers,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete diary entry: ${response.body}');
    }
  }
  
  // Chat API calls
  static Future<ChatResponse> sendChatMessage(ChatMessageCreate message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: _headers,
      body: jsonEncode(message.toJson()),
    );
    
    if (response.statusCode == 200) {
      return ChatResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send chat message: ${response.body}');
    }
  }
  
  static Future<List<ChatMessage>> getChatHistory({int skip = 0, int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/history?skip=$skip&limit=$limit'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get chat history: ${response.body}');
    }
  }
  
  // Emotion tracking API calls
  static Future<EmotionTrend> getEmotionTrend({int days = 30}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/emotions/trend?days=$days'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return EmotionTrend.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get emotion trend: ${response.body}');
    }
  }
  
  static Future<SentimentAnalysis> analyzeTextSentiment(String text) async {
    final response = await http.get(
      Uri.parse('$baseUrl/emotions/analyze?text=${Uri.encodeComponent(text)}'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return SentimentAnalysis.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to analyze sentiment: ${response.body}');
    }
  }
  
  // Mental health resources
  static Future<Map<String, dynamic>> getMentalHealthResources() async {
    final response = await http.get(
      Uri.parse('$baseUrl/resources'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get mental health resources: ${response.body}');
    }
  }
}