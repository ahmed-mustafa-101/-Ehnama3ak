import 'package:equatable/equatable.dart';
import '../../data/models/message_model.dart';

enum ChatStatus { initial, loading, success, error, sending }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<MessageModel> messages;
  final List<MessageModel> pinnedMessages;
  final String? errorMessage;
  final bool isRecording;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.pinnedMessages = const [],
    this.errorMessage,
    this.isRecording = false,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<MessageModel>? messages,
    List<MessageModel>? pinnedMessages,
    String? errorMessage,
    bool? isRecording,
  }) =>
      ChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        pinnedMessages: pinnedMessages ?? this.pinnedMessages,
        errorMessage: errorMessage ?? this.errorMessage,
        isRecording: isRecording ?? this.isRecording,
      );

  @override
  List<Object?> get props =>
      [status, messages, pinnedMessages, errorMessage, isRecording];
}
