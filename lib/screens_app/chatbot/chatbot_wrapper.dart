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
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkIntroStatus();
  }

  Future<void> _checkIntroStatus() async {
    final userId = await PrefManager.getUserId();
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _showIntro = true; // Fallback or handle as guest
      });
      return;
    }
    
    final hasSeen = await PrefManager.getHasSeenChatbotIntro(userId);
    setState(() {
      _userId = userId;
      _showIntro = !hasSeen;
      _isLoading = false;
    });
  }

  void _startChat() async {
    if (_userId != null) {
      await PrefManager.setHasSeenChatbotIntro(_userId!, true);
    }
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
