import 'package:dio/dio.dart';
import 'package:ehnama3ak/core/network/dio_client.dart';
import '../models/notification_model.dart';

/// Handles all notification-related API calls.
/// Uses the shared [DioClient] which auto-attaches the Bearer token.
class NotificationApiService {
  final Dio _dio;

  NotificationApiService({required DioClient dioClient})
      : _dio = dioClient.dio;

  /// GET /api/Notifications
  /// Returns notifications sorted newest first.
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('/api/Notifications');
      return _parseList(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// GET /api/Notifications/unread-count
  /// Returns the count of unread notifications.
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/api/Notifications/unread-count');
      return _parseCount(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// DELETE /api/Notifications/clear
  /// Deletes all notifications.
  Future<void> clearNotifications() async {
    try {
      await _dio.delete('/api/Notifications/clear');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// POST /api/Notifications/read-all
  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    try {
      await _dio.post('/api/Notifications/read-all');
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // --------------- Helpers ---------------

  List<NotificationModel> _parseList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (data is Map) {
      final items = data['items'] ?? data['data'] ?? data['notifications'];
      if (items is List) {
        return items
            .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }
    return [];
  }

  int _parseCount(dynamic data) {
    if (data is int) return data;
    if (data is Map) {
      final v = data['count'] ?? data['unreadCount'] ?? data['value'] ?? data['data'];
      if (v is int) return v;
      if (v != null) return int.tryParse(v.toString()) ?? 0;
    }
    if (data != null) return int.tryParse(data.toString()) ?? 0;
    return 0;
  }

  Exception _mapError(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401) return Exception('Unauthorized. Please log in again.');
    if (code == 403) return Exception('You are not allowed to perform this action.');
    if (code == 500) return Exception('Server error. Please try again later.');
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception('Connection timed out. Check your internet connection.');
    }
    final msg = _extractMessage(e.response?.data);
    return Exception(msg ?? e.message ?? 'An unexpected error occurred.');
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      return (data['message'] ?? data['Message'] ?? data['title'])?.toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }
}
