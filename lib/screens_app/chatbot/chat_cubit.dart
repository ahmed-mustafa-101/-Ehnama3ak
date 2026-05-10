import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'package:ehnama3ak/screens_app/chatbot/chat_message.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_service.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_state.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_models.dart';

import 'package:ehnama3ak/core/storage/pref_manager.dart';
import 'package:ehnama3ak/core/models/user_role.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService;

  ChatCubit(this._chatService) : super(const ChatInitial()) {
    loadSessions();
  }

  Future<String> _getCurrentSenderRole() async {
    // Backend expects 'Patient' for the user or 'Depo' for the chatbot
    return 'Patient';
  }

  Future<void> loadSessions() async {

    try {
      final sessionsResponse = await _chatService.getSessions();
      emit(ChatLoaded(
        messages: state.messages,
        sessions: sessionsResponse.items,
        currentSession: state.currentSession,
      ));
    } catch (e) {
      emit(ChatError(
        messages: state.messages,
        sessions: state.sessions,
        currentSession: state.currentSession,
        error: e.toString().replaceAll("Exception: ", ""),
      ));
    }
  }

  Future<void> selectSession(ChatSession session) async {
    emit(ChatLoading(
      messages: const [],
      sessions: state.sessions,
      currentSession: session,
    ));

    try {
      final messagesResponse = await _chatService.getSessionMessages(session.id);
      dev.log('Loaded ${messagesResponse.items.length} messages for session ${session.id}', name: 'ChatCubit');
      
      // Sort messages by timestamp: oldest first (so newest is at the bottom of the list)
      final sortedMessages = messagesResponse.items.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      emit(ChatLoaded(
        messages: sortedMessages,
        sessions: state.sessions,
        currentSession: session,
      ));
    } catch (e) {
      emit(ChatError(
        messages: const [],
        sessions: state.sessions,
        currentSession: session,
        error: e.toString().replaceAll("Exception: ", ""),
      ));
    }
  }

  Future<void> createNewSession(String title) async {
    emit(ChatLoading(
      messages: const [],
      sessions: state.sessions,
      currentSession: null,
    ));

    try {
      final session = await _chatService.createSession(title);
      final updatedSessions = [session, ...state.sessions];
      emit(ChatLoaded(
        messages: const [],
        sessions: updatedSessions,
        currentSession: session,
      ));
    } catch (e) {
      emit(ChatError(
        messages: const [],
        sessions: state.sessions,
        currentSession: null,
        error: e.toString().replaceAll("Exception: ", ""),
      ));
    }
  }

  Future<void> deleteSession(int sessionId) async {
    try {
      await _chatService.deleteSession(sessionId);
      final updatedSessions = state.sessions.where((s) => s.id != sessionId).toList();
      ChatSession? nextSession = state.currentSession;
      List<ChatMessage> nextMessages = state.messages;

      if (state.currentSession?.id == sessionId) {
        nextSession = null;
        nextMessages = const [];
      }

      emit(ChatLoaded(
        messages: nextMessages,
        sessions: updatedSessions,
        currentSession: nextSession,
      ));
    } catch (e) {
      emit(ChatError(
        messages: state.messages,
        sessions: state.sessions,
        currentSession: state.currentSession,
        error: e.toString().replaceAll("Exception: ", ""),
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // If no session, create one first
    if (state.currentSession == null) {
      await createNewSession(text.length > 20 ? "${text.substring(0, 20)}..." : text);
      if (state is ChatError) return;
    }

    final currentSessionId = state.currentSession!.id;

    final userMessage = ChatMessage(
      message: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMessage);

    emit(ChatLoading(
      messages: updatedMessages,
      sessions: state.sessions,
      currentSession: state.currentSession,
    ));

    try {
      // 1. Get AI Response
      final response = await _chatService.sendMessage(text);

      final botMessage = ChatMessage(
        message: response.message,
        isUser: false,
        timestamp: DateTime.now(),
        emotion: response.emotion,
        confidence: response.confidence,
        aiModel: response.aiModel,
        language: response.language,
      );

      final finalMessages = List<ChatMessage>.from(updatedMessages)..add(botMessage);
      
      // 2. Save messages to backend
      try {
        final senderRole = await _getCurrentSenderRole();
        
        // User message
        await _chatService.saveMessage(
          sessionId: currentSessionId,
          message: text,
          sender: senderRole,
          messageType: 0, // Text = 0
        );

        // Bot message
        await _chatService.saveMessage(
          sessionId: currentSessionId,
          message: response.message,
          sender: 'Depo',
          messageType: 0,
          emotion: response.emotion,
        );
      } catch (saveError) {
        dev.log('Failed to save messages: $saveError', name: 'ChatCubit');
        // We don't rethrow here so the user can still see the AI response
      }

      emit(ChatLoaded(
        messages: finalMessages,
        sessions: state.sessions,
        currentSession: state.currentSession,
      ));

      // 3. Refresh sessions list to update message counts
      loadSessions();
    } catch (e) {
      emit(ChatError(
        messages: updatedMessages,
        sessions: state.sessions,
        currentSession: state.currentSession,
        error: e.toString().replaceAll("Exception: ", ""),
      ));
    }
  }

  Future<void> sendVoiceMessage(String filePath) async {
    if (state.currentSession == null) {
      await createNewSession("Voice Session");
      if (state is ChatError) return;
    }
    final currentSessionId = state.currentSession!.id;

    final userMessage = ChatMessage(
      message: "Voice Message",
      isUser: true,
      timestamp: DateTime.now(),
      audioPath: filePath,
    );
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMessage);

    emit(ChatLoading(
      messages: updatedMessages,
      sessions: state.sessions,
      currentSession: state.currentSession,
    ));

    try {
      final response = await _chatService.sendVoiceMessage(filePath);

      final botMessage = ChatMessage(
        message: response.message,
        isUser: false,
        timestamp: DateTime.now(),
        emotion: response.emotion,
        confidence: response.confidence,
        aiModel: response.aiModel,
        language: response.language,
      );

      final finalMessages = List<ChatMessage>.from(updatedMessages)..add(botMessage);

      // Save to backend
      try {
        final senderRole = await _getCurrentSenderRole();
        await _chatService.saveMessage(
          sessionId: currentSessionId,
          message: "Voice Message",
          sender: senderRole,
          messageType: 2, // Audio = 2
          attachmentPath: filePath,
        );

        await _chatService.saveMessage(
          sessionId: currentSessionId,
          message: response.message,
          sender: 'Depo',
          messageType: 0,
          emotion: response.emotion,
        );
      } catch (saveError) {
        dev.log('Failed to save voice messages: $saveError', name: 'ChatCubit');
      }

      emit(ChatLoaded(
        messages: finalMessages,
        sessions: state.sessions,
        currentSession: state.currentSession,
      ));

      // 3. Refresh sessions list to update message counts
      loadSessions();
    } catch (e) {
      emit(ChatError(
        messages: updatedMessages,
        sessions: state.sessions,
        currentSession: state.currentSession,
        error: e.toString().replaceAll("Exception: ", ""),
      ));
    }
  }

  Future<void> sendImageMessage(String imagePath, {String? text}) async {
    if (state.currentSession == null) {
      await createNewSession(text ?? "Image Session");
      if (state is ChatError) return;
    }
    final currentSessionId = state.currentSession!.id;

    final userMessage = ChatMessage(
      message: text ?? "Image Message",
      isUser: true,
      timestamp: DateTime.now(),
      imagePath: imagePath,
    );
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMessage);

    emit(ChatLoading(
      messages: updatedMessages,
      sessions: state.sessions,
      currentSession: state.currentSession,
    ));

    try {
      final response = await _chatService.sendImageMessage(imagePath, text: text);

      final botMessage = ChatMessage(
        message: response.message,
        isUser: false,
        timestamp: DateTime.now(),
        emotion: response.emotion,
        confidence: response.confidence,
        aiModel: response.aiModel,
        language: response.language,
      );

      final finalMessages = List<ChatMessage>.from(updatedMessages)..add(botMessage);

      // Save to backend
      try {
        final senderRole = await _getCurrentSenderRole();
        await _chatService.saveMessage(
          sessionId: currentSessionId,
          message: text ?? "Image Message",
          sender: senderRole,
          messageType: 1, // Image = 1
          attachmentPath: imagePath,
        );

        await _chatService.saveMessage(
          sessionId: currentSessionId,
          message: response.message,
          sender: 'Depo',
          messageType: 0,
          emotion: response.emotion,
        );
      } catch (saveError) {
        dev.log('Failed to save image messages: $saveError', name: 'ChatCubit');
      }

      emit(ChatLoaded(
        messages: finalMessages,
        sessions: state.sessions,
        currentSession: state.currentSession,
      ));

      // 3. Refresh sessions list to update message counts
      loadSessions();
    } catch (e) {
      emit(ChatError(
        messages: updatedMessages,
        sessions: state.sessions,
        currentSession: state.currentSession,
        error: e.toString().replaceAll("Exception: ", ""),
      ));
    }
  }

  void clearChat() {
    emit(ChatInitial(sessions: state.sessions));
  }
}

