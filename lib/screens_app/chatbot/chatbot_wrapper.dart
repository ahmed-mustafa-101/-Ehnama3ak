import 'package:flutter/material.dart';
import 'chatbot_intro.dart';
import 'chatbot_screen.dart';

/// Wrapper that shows ChatbotIntro first, then ChatbotScreen
class ChatbotWrapper extends StatefulWidget {
  const ChatbotWrapper({super.key});

  @override
  State<ChatbotWrapper> createState() => _ChatbotWrapperState();
}

class _ChatbotWrapperState extends State<ChatbotWrapper> {
  bool _showIntro = true;

  void _startChat() {
    setState(() {
      _showIntro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro) {
      return ChatbotIntroScreen(
        onStart: _startChat,
      );
    } else {
      return const ChatbotScreen();
    }
  }
}
