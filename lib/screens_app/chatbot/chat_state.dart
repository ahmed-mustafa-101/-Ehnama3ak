import 'package:ehnama3ak/screens_app/chatbot/chat_message.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_models.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final List<ChatSession> sessions;
  final ChatSession? currentSession;
  
  const ChatState({
    this.messages = const [],
    this.sessions = const [],
    this.currentSession,
  });

  @override
  List<Object?> get props => [messages, sessions, currentSession];
}

class ChatInitial extends ChatState {
  const ChatInitial({super.sessions}) : super();
}

class ChatLoading extends ChatState {
  const ChatLoading({
    super.messages,
    super.sessions,
    super.currentSession,
  });
}

class ChatLoaded extends ChatState {
  const ChatLoaded({
    super.messages,
    super.sessions,
    super.currentSession,
  });
}

class ChatError extends ChatState {
  final String error;
  const ChatError({
    super.messages,
    super.sessions,
    super.currentSession,
    required this.error,
  });

  @override
  List<Object?> get props => [messages, sessions, currentSession, error];
}

