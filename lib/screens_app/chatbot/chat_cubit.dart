import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_message.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_service.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService;

  ChatCubit(this._chatService) : super(const ChatInitial());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      message: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(userMessage);

    emit(ChatLoading(updatedMessages));

    try {
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

      final finalMessages = List<ChatMessage>.from(updatedMessages)
        ..add(botMessage);
      emit(ChatLoaded(finalMessages));
    } catch (e) {
      emit(
        ChatError(updatedMessages, e.toString().replaceAll("Exception: ", "")),
      );
    }
  }

  Future<void> sendVoiceMessage(String filePath) async {
    final userMessage = ChatMessage(
      message: "🎤 Voice Message",
      isUser: true,
      timestamp: DateTime.now(),
    );
    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(userMessage);

    emit(ChatLoading(updatedMessages));

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

      final finalMessages = List<ChatMessage>.from(updatedMessages)
        ..add(botMessage);
      emit(ChatLoaded(finalMessages));
    } catch (e) {
      emit(
        ChatError(updatedMessages, e.toString().replaceAll("Exception: ", "")),
      );
    }
  }

  void clearChat() {
    emit(const ChatInitial());
  }
}
