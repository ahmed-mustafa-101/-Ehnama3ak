import 'package:dio/dio.dart';
import 'package:ehnama3ak/core/network/dio_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Handles all message-related API calls.
/// The shared [DioClient] auto-attaches the Bearer token on every request.
/// senderId is NEVER sent manually — backend extracts it from the JWT.
class MessageApiService {
  final Dio _dio;

  MessageApiService({required DioClient dioClient}) : _dio = dioClient.dio;

  // ─────────────────────────────────────────
  // GET /api/Messages/conversations
  // ─────────────────────────────────────────
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _dio.get('/api/Messages/conversations');
      return _parseConversations(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ─────────────────────────────────────────
  // GET /api/Messages/conversation/{receiverId}
  // ─────────────────────────────────────────
  Future<List<MessageModel>> getMessages(String otherUserId) async {
    try {
      final response = await _dio.get('/api/Messages/conversation/$otherUserId');
      return _parseMessages(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ─────────────────────────────────────────
  // POST /api/Messages/send
  // Body: { "receiverId": "...", "message": "..." }
  // ─────────────────────────────────────────
  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    try {
      await _dio.post(
        '/api/Messages/send',
        data: {
          'receiverId': receiverId,
          'message': message,
        },
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ─────────────────────────────────────────
  // GET /api/Messages/unread-count
  // ─────────────────────────────────────────
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/api/Messages/unread-count');
      return _parseCount(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ─────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────

  List<ConversationModel> _parseConversations(dynamic data) {
    if (data is List) {
      return data
          .map((e) => ConversationModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (data is Map) {
      final items = data['items'] ?? data['data'] ?? data['conversations'];
      if (items is List) {
        return items
            .map((e) => ConversationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    }
    return [];
  }

  List<MessageModel> _parseMessages(dynamic data) {
    if (data is List) {
      return data
          .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (data is Map) {
      final items = data['items'] ?? data['data'] ?? data['messages'];
      if (items is List) {
        return items
            .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
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
    final msg = _extractMsg(e.response?.data);
    return Exception(msg ?? e.message ?? 'An unexpected error occurred.');
  }

  String? _extractMsg(dynamic data) {
    if (data is Map) {
      return (data['message'] ?? data['Message'] ?? data['title'])?.toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }
}
