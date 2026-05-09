import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/conversation_model.dart';
import '../../domain/repositories/message_repository.dart';
import 'conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final MessageRepository _repo;
  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 15);

  ConversationsCubit(this._repo) : super(const ConversationsState());

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  Future<void> loadConversations() async {
    emit(state.copyWith(status: ConversationsStatus.loading));
    try {
      final list = await _repo.getConversations();
      list.sort((ConversationModel a, ConversationModel b) =>
          b.lastMessageTime.compareTo(a.lastMessageTime));
      emit(state.copyWith(
        status: ConversationsStatus.success,
        conversations: list,
      ));
      _startPolling();
    } catch (e) {
      emit(state.copyWith(
        status: ConversationsStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// Silent background refresh — updates list without showing loading indicator.
  Future<void> _silentRefresh() async {
    if (isClosed) return;
    try {
      final list = await _repo.getConversations();
      list.sort((ConversationModel a, ConversationModel b) =>
          b.lastMessageTime.compareTo(a.lastMessageTime));
      if (!isClosed) {
        emit(state.copyWith(
          status: ConversationsStatus.success,
          conversations: list,
        ));
      }
    } catch (_) {}
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _silentRefresh());
  }

  Future<void> loadFavorites() async {
    try {
      final favs = await _repo.getFavorites();
      if (!isClosed) emit(state.copyWith(favorites: favs));
    } catch (_) {}
  }

  Future<void> toggleFavorite(String conversationId) async {
    try {
      final isFav = await _repo.toggleFavorite(conversationId);
      final updated = state.conversations.map((c) {
        if (c.conversationId == conversationId) {
          return c.copyWith(isFavorite: isFav);
        }
        return c;
      }).toList();
      if (!isClosed) emit(state.copyWith(conversations: updated));
      loadFavorites();
    } catch (_) {}
  }
}
