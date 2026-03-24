import '../../data/models/notification_model.dart';

/// Abstract contract for notification operations.
abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> clearNotifications();
  Future<void> markAllAsRead();
}
