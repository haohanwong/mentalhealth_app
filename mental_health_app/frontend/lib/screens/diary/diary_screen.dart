import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Diary'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigate to add diary entry
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Diary Screen\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}