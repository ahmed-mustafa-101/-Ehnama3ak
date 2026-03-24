import 'package:equatable/equatable.dart';
import '../../data/models/conversation_model.dart';

enum MessageStatus { initial, loading, success, error, sending }

class MessageState extends Equatable {
  final MessageStatus status;
  final List<ConversationModel> conversations;
  final int unreadCount;
  final String? errorMessage;

  const MessageState({
    this.status = MessageStatus.initial,
    this.conversations = const [],
    this.unreadCount = 0,
    this.errorMessage,
  });

  MessageState copyWith({
    MessageStatus? status,
    List<ConversationModel>? conversations,
    int? unreadCount,
    String? errorMessage,
  }) {
    return MessageState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, conversations, unreadCount, errorMessage];
}
