import 'package:flutter/material.dart';
import 'chatbot_intro.dart';
import 'chatbot_screen.dart';

import 'package:ehnama3ak/core/storage/pref_manager.dart';

/// Wrapper that shows ChatbotIntro first, then ChatbotScreen
class ChatbotWrapper extends StatefulWidget {
  const ChatbotWrapper({super.key});

  @override
  State<ChatbotWrapper> createState() => _ChatbotWrapperState();
}

class _ChatbotWrapperState extends State<ChatbotWrapper> {
  bool _showIntro = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkIntroStatus();
  }

  Future<void> _checkIntroStatus() async {
    final hasSeen = await PrefManager.getHasSeenChatbotIntro();
    setState(() {
      _showIntro = !hasSeen;
      _isLoading = false;
    });
  }

  void _startChat() async {
    await PrefManager.setHasSeenChatbotIntro(true);
    setState(() {
      _showIntro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_showIntro) {
      return ChatbotIntroScreen(
        onStart: _startChat,
      );
    } else {
      return const ChatbotScreen();
    }
  }
}
