import 'package:ehnama3ak/screens_app/chatbot/chat_message.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  final List<ChatMessage> messages;
  const ChatState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatInitial extends ChatState {
  const ChatInitial() : super(const []);
}

class ChatLoading extends ChatState {
  const ChatLoading(super.messages);
}

class ChatLoaded extends ChatState {
  const ChatLoaded(super.messages);
}

class ChatError extends ChatState {
  final String error;
  const ChatError(super.messages, this.error);

  @override
  List<Object?> get props => [messages, error];
}
