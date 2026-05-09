import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/message_model.dart';
import '../../domain/repositories/message_repository.dart';
import 'chat_state.dart';

/// Per-conversation cubit.
/// Polls every [_pollInterval] so both parties see new messages automatically.
class ChatCubit extends Cubit<ChatState> {
  final MessageRepository _repo;
  final String conversationId;
  final String receiverId;

  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 8);

  ChatCubit({
    required MessageRepository repo,
    required this.conversationId,
    required this.receiverId,
  })  : _repo = repo,
        super(const ChatState());

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  // ── Load messages (initial) ───────────────────────────────────────────
  Future<void> loadMessages() async {
    emit(state.copyWith(status: ChatStatus.loading, messages: []));
    try {
      final msgs = await _repo.getMessages(conversationId);
      msgs.sort((MessageModel a, MessageModel b) => a.sentAt.compareTo(b.sentAt));
      emit(state.copyWith(status: ChatStatus.success, messages: msgs));
      _repo.markAsRead(conversationId).catchError((_) {});
      loadPinnedMessages();
      _startPolling();
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  // ── Silent background refresh (polling) ──────────────────────────────
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _silentRefresh());
  }

  Future<void> _silentRefresh() async {
    if (isClosed) return;
    try {
      final msgs = await _repo.getMessages(conversationId);
      msgs.sort((MessageModel a, MessageModel b) => a.sentAt.compareTo(b.sentAt));
      // Only emit if something changed
      final currentIds = state.messages.map((m) => m.id).toSet();
      final newIds = msgs.map((m) => m.id).toSet();
      if (!currentIds.containsAll(newIds) || !newIds.containsAll(currentIds)) {
        if (!isClosed) {
          emit(state.copyWith(status: ChatStatus.success, messages: msgs));
        }
      }
    } catch (_) {} // fail silently
  }

  Future<void> refreshMessages() => _silentRefresh();

  // ── Send text ─────────────────────────────────────────────────────────
  Future<void> sendText(String text, String currentUserId) async {
    if (text.trim().isEmpty) return;
    _addOptimistic(currentUserId, text.trim(), 0);
    await _doSend(text: text.trim(), type: 0);
  }

  // ── Send image ────────────────────────────────────────────────────────
  Future<void> sendImage(File file, String currentUserId) async {
    _addOptimistic(currentUserId, file.path.split(Platform.pathSeparator).last, 1);
    await _doSend(text: '', type: 1, attachment: file);
  }

  // ── Send voice ────────────────────────────────────────────────────────
  Future<void> sendVoice(File file, String currentUserId) async {
    _addOptimistic(currentUserId, 'Voice message', 2);
    await _doSend(text: 'Voice message', type: 2, attachment: file);
  }

  // ── Send file ─────────────────────────────────────────────────────────
  Future<void> sendFile(File file, String currentUserId) async {
    final name = file.path.split(Platform.pathSeparator).last;
    _addOptimistic(currentUserId, name, 3);
    await _doSend(text: name, type: 3, attachment: file);
  }

  // ── Pin / Unpin ───────────────────────────────────────────────────────
  Future<void> pinMessage(int messageId) async {
    try {
      await _repo.pinMessage(messageId);
      final updated = state.messages
          .map((m) => m.id == messageId ? m.copyWith(isPinned: true) : m)
          .toList();
      if (!isClosed) emit(state.copyWith(messages: updated));
      loadPinnedMessages();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
            errorMessage: e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  Future<void> unpinMessage(int messageId) async {
    try {
      await _repo.unpinMessage(messageId);
      final updated = state.messages
          .map((m) => m.id == messageId ? m.copyWith(isPinned: false) : m)
          .toList();
      final pinned =
          state.pinnedMessages.where((m) => m.id != messageId).toList();
      if (!isClosed) {
        emit(state.copyWith(messages: updated, pinnedMessages: pinned));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
            errorMessage: e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  Future<void> loadPinnedMessages() async {
    try {
      final pinned = await _repo.getPinnedMessages(conversationId);
      if (!isClosed) emit(state.copyWith(pinnedMessages: pinned));
    } catch (_) {}
  }

  // ── Internal helpers ──────────────────────────────────────────────────

  void _addOptimistic(String senderId, String text, int type) {
    final temp = MessageModel(
      id: -(DateTime.now().millisecondsSinceEpoch),
      senderId: senderId,
      receiverId: receiverId,
      message: text,
      messageTypeRaw: type,
      isPinned: false,
      isRead: false,
      sentAt: DateTime.now(),
    );
    if (!isClosed) {
      emit(state.copyWith(
        status: ChatStatus.sending,
        messages: [...state.messages, temp],
      ));
    }
  }

  Future<void> _doSend({
    required String text,
    required int type,
    File? attachment,
  }) async {
    try {
      final sent = await _repo.sendMessage(
        receiverId: receiverId,
        message: text,
        messageType: type,
        attachment: attachment,
      );
      if (isClosed) return;

      // Replace the optimistic (negative id) message with the real server response
      final msgs = state.messages.toList();
      final idx = msgs.indexWhere((m) => m.id < 0);
      if (idx != -1) {
        msgs[idx] = sent;
      } else {
        msgs.add(sent);
      }
      emit(state.copyWith(status: ChatStatus.success, messages: msgs));

      // Reload from server after short delay to confirm delivery
      Future.delayed(const Duration(seconds: 2), _silentRefresh);
    } catch (e) {
      if (isClosed) return;
      // Remove the optimistic message on failure
      final cleaned = state.messages.where((m) => m.id >= 0).toList();
      emit(state.copyWith(
        status: ChatStatus.error,
        messages: cleaned,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
