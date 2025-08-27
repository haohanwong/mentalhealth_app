import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../services/api_service.dart';
import '../services/firebase_chat_service.dart';
import 'auth_provider.dart';

class ChatMessageUi {
  final String role; // 'user' or 'assistant'
  final String text;
  final DateTime createdAt;

  ChatMessageUi({required this.role, required this.text, required this.createdAt});
}

class ChatProvider with ChangeNotifier {
  final List<ChatMessageUi> _messages = [];
  final FirebaseChatService _firebaseChatService = FirebaseChatService();
  bool _isSending = false;
  String? _error;

  List<ChatMessageUi> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  String? get error => _error;

  void clear() {
    _messages.clear();
    notifyListeners();
  }

  Future<void> sendMessage({
    required String text,
    required AuthProvider authProvider,
  }) async {
    if (text.trim().isEmpty || authProvider.user == null) return;
    _error = null;
    _isSending = true;
    final now = DateTime.now();
    _messages.add(ChatMessageUi(role: 'user', text: text, createdAt: now));
    notifyListeners();

    final userId = authProvider.user!.id;

    try {
      // Save user's message to Firestore immediately
      await _firebaseChatService.saveUserMessage(
        userId: userId,
        message: text,
        createdAt: now,
      );

      // Call backend AI chat
      final response = await ApiService.sendChatMessage(ChatMessageCreate(message: text));

      final botNow = DateTime.now();
      _messages.add(ChatMessageUi(role: 'assistant', text: response.response, createdAt: botNow));
      notifyListeners();

      // Save assistant response with sentiment and chatId
      await _firebaseChatService.saveAssistantMessage(
        userId: userId,
        message: response.response,
        createdAt: botNow,
        chatId: response.chatId,
        sentiment: response.sentimentAnalysis.toJson(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}

