import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/message_repository.dart';
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

  Future<void> sendMessage({required String receiverId, required String message}) async {
    emit(state.copyWith(status: MessageStatus.sending));
    try {
      await _repository.sendMessage(receiverId: receiverId, message: message);
      // Immediately refresh conversations to show last message
      await loadConversations();
    } catch (e) {
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
