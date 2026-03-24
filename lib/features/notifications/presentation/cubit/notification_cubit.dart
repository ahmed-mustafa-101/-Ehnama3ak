import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(const NotificationState());

  /// Fetch the full notification list.
  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationStatus.loading, clearError: true));
    try {
      final notifications = await _repository.getNotifications();
      // Ensure newest first
      final sorted = List.of(notifications)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(state.copyWith(
        status: NotificationStatus.loaded,
        notifications: sorted,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: _extractMessage(e),
      ));
    }
  }

  /// Fetch unread notification count for the bell badge.
  Future<void> loadUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (_) {
      // Silent fail – badge simply stays as-is
    }
  }

  /// Mark all notifications as read and reset badge to zero.
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      // Immediately reflect isRead=true in the local list
      final updated = state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      emit(state.copyWith(notifications: updated, unreadCount: 0));
    } catch (_) {
      // Silent fail – does not block UI
    }
  }

  /// Delete all notifications then refresh the list.
  Future<void> clearAllNotifications() async {
    try {
      await _repository.clearNotifications();
      emit(state.copyWith(
        notifications: [],
        unreadCount: 0,
        status: NotificationStatus.loaded,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: _extractMessage(e)));
    }
  }

  void clearError() => emit(state.copyWith(clearError: true));

  String _extractMessage(Object e) {
    final msg = e.toString();
    // Strip the leading "Exception: " prefix added by Dart
    if (msg.startsWith('Exception: ')) {
      return msg.replaceFirst('Exception: ', '');
    }
    return msg;
  }
}
