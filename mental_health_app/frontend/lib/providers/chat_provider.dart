import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  
  // 加载聊天历史
  Future<void> loadChatHistory({int skip = 0, int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final history = await ApiService.getChatHistory(skip: skip, limit: limit);
      if (skip == 0) {
        _messages = history.reversed.toList(); // 反转顺序，最新消息在底部
      } else {
        _messages.insertAll(0, history.reversed);
      }
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // 发送消息
  Future<ChatResponse?> sendMessage(String message) async {
    if (message.trim().isEmpty) return null;
    
    _isSending = true;
    _error = null;
    notifyListeners();
    
    try {
      final chatMessage = ChatMessageCreate(message: message);
      final response = await ApiService.sendChatMessage(chatMessage);
      
      // 创建用户消息和AI回复的ChatMessage对象
      final userMessage = ChatMessage(
        id: response.chatId,
        message: message,
        response: response.response,
        createdAt: DateTime.now(),
        userId: 0, // 这将从后端获取实际的用户ID
      );
      
      // 添加到消息列表
      _messages.add(userMessage);
      
      _isSending = false;
      notifyListeners();
      
      return response;
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return null;
    }
  }
  
  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // 清空聊天记录（仅本地）
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
  
  // 重新加载聊天历史
  Future<void> refresh() async {
    await loadChatHistory();
  }
}