import '../../data/datasources/notification_api_service.dart';
import '../../data/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

/// Concrete implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApiService _apiService;

  const NotificationRepositoryImpl(this._apiService);

  @override
  Future<List<NotificationModel>> getNotifications() =>
      _apiService.getNotifications();

  @override
  Future<int> getUnreadCount() => _apiService.getUnreadCount();

  @override
  Future<void> clearNotifications() => _apiService.clearNotifications();

  @override
  Future<void> markAllAsRead() => _apiService.markAllAsRead();
}
