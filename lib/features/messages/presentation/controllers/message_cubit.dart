import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/message_repository.dart';
import '../../data/models/message_model.dart';
import 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final MessageRepository _repository;

  MessageCubit(this._repository) : super(const MessageState());

  Future<void> loadConversations() async {
    emit(state.copyWith(status: MessageStatus.loading));
    try {
      final conversations = await _repository.getConversations();
      // Sort: Newest message first
      conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      emit(state.copyWith(
        status: MessageStatus.success,
        conversations: conversations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MessageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMessages(String otherUserId) async {
    emit(state.copyWith(status: MessageStatus.loadingMessages, messages: []));
    try {
      final messages = await _repository.getMessages(otherUserId);
      // Sort by time: oldest first for chat list
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      emit(state.copyWith(
        status: MessageStatus.success,
        messages: messages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MessageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> sendMessage({required String receiverId, required String message, String? currentUserId}) async {
    // Optimistic update
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final tempMessage = MessageModel(
      id: tempId,
      senderId: currentUserId ?? '',
      receiverId: receiverId,
      content: message,
      createdAt: DateTime.now(),
      isRead: false,
    );

    final updatedMessages = List<MessageModel>.from(state.messages)..add(tempMessage);
    emit(state.copyWith(status: MessageStatus.sending, messages: updatedMessages));

    try {
      await _repository.sendMessage(receiverId: receiverId, message: message);
      // Reload messages to get real IDs and timestamps
      await loadMessages(receiverId);
      // Refresh conversations list in background
      loadConversations();
    } catch (e) {
      // Revert optimistic update or show error
      emit(state.copyWith(
        status: MessageStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (_) {
      // Fail silently for background badge updates
    }
  }
}
