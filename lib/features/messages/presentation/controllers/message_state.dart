import 'package:equatable/equatable.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';

enum MessageStatus { initial, loading, success, error, sending, loadingMessages }

class MessageState extends Equatable {
  final MessageStatus status;
  final List<ConversationModel> conversations;
  final List<MessageModel> messages;
  final int unreadCount;
  final String? errorMessage;

  const MessageState({
    this.status = MessageStatus.initial,
    this.conversations = const [],
    this.messages = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  MessageState copyWith({
    MessageStatus? status,
    List<ConversationModel>? conversations,
    List<MessageModel>? messages,
    int? unreadCount,
    String? errorMessage,
  }) {
    return MessageState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, conversations, messages, unreadCount, errorMessage];
}
