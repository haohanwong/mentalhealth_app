import 'package:flutter/material.dart';

class EmotionTrackingScreen extends StatelessWidget {
  const EmotionTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Tracking'),
      ),
      body: const Center(
        child: Text(
          'Emotion Tracking Screen\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}