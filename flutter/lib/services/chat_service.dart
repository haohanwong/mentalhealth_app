import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl;

  ChatService({required this.baseUrl});

  Future<ChatReply> sendMessage({
    required String userId,
    required String message,
    String? conversationId,
  }) async {
    final url = Uri.parse('$baseUrl/chat');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'message': message,
        'conversation_id': conversationId,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Chat failed: ${resp.statusCode} ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return ChatReply(
      reply: data['reply'] as String? ?? '',
      conversationId: data['conversation_id'] as String,
    );
  }
}

class ChatReply {
  final String reply;
  final String conversationId;

  ChatReply({required this.reply, required this.conversationId});
}

