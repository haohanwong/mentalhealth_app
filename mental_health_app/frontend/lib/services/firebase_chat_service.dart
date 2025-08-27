import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseChatService {
  final FirebaseFirestore _firestore;

  FirebaseChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messagesCollection(int userId) {
    return _firestore
        .collection('chats')
        .doc(userId.toString())
        .collection('messages');
  }

  Future<void> saveUserMessage({
    required int userId,
    required String message,
    required DateTime createdAt,
  }) async {
    await _messagesCollection(userId).add({
      'role': 'user',
      'message': message,
      'created_at': createdAt.toIso8601String(),
    });
  }

  Future<void> saveAssistantMessage({
    required int userId,
    required String message,
    required DateTime createdAt,
    required int chatId,
    required Map<String, dynamic> sentiment,
  }) async {
    await _messagesCollection(userId).add({
      'role': 'assistant',
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'chat_id': chatId,
      'sentiment': sentiment,
    });
  }
}

