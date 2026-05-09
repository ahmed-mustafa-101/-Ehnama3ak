import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ehnama3ak/core/network/dio_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Full production-ready service for all /api/Messages/* endpoints.
/// Auth token is automatically attached by DioClient._AuthInterceptor.
class MessageApiService {
  final Dio _dio;

  MessageApiService({required DioClient dioClient}) : _dio = dioClient.dio;

  // ── 1. GET /api/Messages/conversations ──────────────────────────────
  Future<List<ConversationModel>> getConversations() async {
    try {
      final res = await _dio.get('/api/Messages/conversations');
      return _list(res.data, ConversationModel.fromJson);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── 2. GET /api/Messages/conversations/{conversationId} ─────────────
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final res = await _dio.get('/api/Messages/conversations/$conversationId');
      return _list(res.data, MessageModel.fromJson);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── 3. POST /api/Messages/send & /api/Messages/send-file ──────────
  Future<MessageModel> sendMessage({
    required String receiverId,
    required String message,
    int messageType = 0,
    File? attachment,
  }) async {
    try {
      if (attachment != null) {
        // Use dedicated send-file endpoint for attachments
        final map = <String, dynamic>{
          'receiverId': receiverId,
          'message': message,
          'messageType': messageType,
          'attachment': await MultipartFile.fromFile(
            attachment.path,
            filename: attachment.path.split(Platform.pathSeparator).last,
          ),
        };
        final res = await _dio.post(
          '/api/Messages/send-file',
          data: FormData.fromMap(map),
          options: Options(contentType: 'multipart/form-data'),
        );
        return MessageModel.fromJson(Map<String, dynamic>.from(res.data as Map));
      } else {
        // Use standard send endpoint for text-only messages
        final res = await _dio.post(
          '/api/Messages/send',
          data: {
            'receiverId': receiverId,
            'message': message,
            'messageType': messageType,
          },
        );
        return MessageModel.fromJson(Map<String, dynamic>.from(res.data as Map));
      }
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── 4. POST /api/Messages/read ──────────────────────────────────────
  Future<void> markAsRead(String conversationId) async {
    try {
      await _dio.post(
        '/api/Messages/read',
        data: {'conversationId': conversationId},
      );
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── 5. GET /api/Messages/unread-count ───────────────────────────────
  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get('/api/Messages/unread-count');
      final data = res.data;
      if (data is Map) {
        final v = data['unread'] ?? data['count'] ?? data['unreadCount'];
        if (v is int) return v;
        if (v != null) return int.tryParse(v.toString()) ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── 6. POST /api/Messages/{messageId}/pin ───────────────────────────
  Future<void> pinMessage(int messageId) async {
    try {
      await _dio.post('/api/Messages/$messageId/pin');
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── 7. POST /api/Messages/{messageId}/unpin ─────────────────────────
  Future<void> unpinMessage(int messageId) async {
    try {
      await _dio.post('/api/Messages/$messageId/unpin');
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── 8. GET /api/Messages/conversations/{conversationId}/pinned ───────
  Future<List<MessageModel>> getPinnedMessages(String conversationId) async {
    try {
      final res = await _dio.get(
          '/api/Messages/conversations/$conversationId/pinned');
      return _list(res.data, MessageModel.fromJson);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── 9. POST /api/Messages/conversations/{conversationId}/favorite ────
  Future<bool> toggleFavorite(String conversationId) async {
    try {
      final res = await _dio
          .post('/api/Messages/conversations/$conversationId/favorite');
      final data = res.data;
      if (data is Map) return data['isFavorite'] == true;
      return false;
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── 10. GET /api/Messages/favorites ─────────────────────────────────
  Future<List<ConversationModel>> getFavorites() async {
    try {
      final res = await _dio.get('/api/Messages/favorites');
      return _list(res.data, ConversationModel.fromJson);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    Iterable? items;
    if (data is List) {
      items = data;
    } else if (data is Map) {
      final v = data['items'] ?? data['data'] ?? data['conversations'] ??
          data['messages'] ?? data['favorites'];
      if (v is List) items = v;
    }
    return (items ?? [])
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Exception _err(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401) return Exception('Unauthorized. Please log in again.');
    if (code == 403) return Exception('You are not allowed to do this.');
    if (code == 404) return Exception('Resource not found.');
    if (code == 500) return Exception('Server error. Please try again later.');
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception('Connection timed out. Check your internet.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return Exception('No internet connection.');
    }
    final d = e.response?.data;
    final msg = d is Map
        ? (d['message'] ?? d['Message'] ?? d['title'])?.toString()
        : (d is String && d.isNotEmpty ? d : null);
    return Exception(msg ?? e.message ?? 'An unexpected error occurred.');
  }
}
