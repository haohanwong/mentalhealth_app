import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String apiBaseUrl;

  const ChatScreen({super.key, required this.apiBaseUrl});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _conversationId;
  late final ChatService _chatService;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(baseUrl: widget.apiBaseUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final user = FirebaseAuth.instance.currentUser;
    final text = _controller.text.trim();
    if (user == null || text.isEmpty) return;

    // Optimistic scroll to bottom
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    try {
      final reply = await _chatService.sendMessage(
        userId: user.uid,
        message: text,
        conversationId: _conversationId,
      );
      setState(() {
        _conversationId = reply.conversationId;
      });
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发送失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('未登录')),
      );
    }

    final messagesQuery = _conversationId == null
        ? null
        : FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('conversations')
            .doc(_conversationId)
            .collection('messages')
            .orderBy('createdAt');

    return Scaffold(
      appBar: AppBar(
        title: const Text('心理健康陪伴'),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesQuery == null
                ? const Center(child: Text('开始新的对话吧'))
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: messagesQuery.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data?.docs ?? [];
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data();
                          final role = (data['role'] as String?) ?? 'user';
                          final content = (data['content'] as String?) ?? '';
                          final isUser = role == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.blue[500] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                content,
                                style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: '输入消息…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

