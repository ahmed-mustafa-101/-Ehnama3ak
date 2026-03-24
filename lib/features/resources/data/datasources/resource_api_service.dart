import 'package:dio/dio.dart';
import 'package:ehnama3ak/core/network/dio_client.dart';
import 'package:ehnama3ak/core/storage/secure_token_storage.dart';
import '../models/resource_model.dart';

class ResourceApiService {
  final Dio _dio;

  ResourceApiService({DioClient? dioClient, SecureTokenStorage? tokenStorage})
      : _dio = (dioClient ??
                DioClient(tokenStorage: tokenStorage ?? SecureTokenStorage()))
            .dio;

  // ─── GET /api/Resources ──────────────────────────────────────────────────────

  Future<List<ResourceModel>> getResources() async {
    try {
      final response = await _dio.get('/api/Resources');
      return _parseList(response.data);
    } on DioException catch (e) {
      throw Exception(parseError(e));
    } catch (e) {
      throw Exception('Failed to fetch resources: ${e.toString()}');
    }
  }

  // ─── POST /api/Resources ─────────────────────────────────────────────────────

  Future<ResourceModel> createResource({
    required String title,
    required String description,
    required String type,   // 'Article' | 'Video' | 'Pdf'
    required String url,
    String? coverImageUrl,
    int duration = 0,
    int fileSize = 0,
  }) async {
    try {
      final response = await _dio.post(
        '/api/Resources',
        data: {
          'title': title,
          'description': description,
          'type': type,
          'url': url,
          if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
          'duration': duration,
          'fileSize': fileSize,
        },
      );
      return ResourceModel.fromJson(_toMap(response.data));
    } on DioException catch (e) {
      throw Exception(parseError(e));
    } catch (e) {
      throw Exception('Failed to create resource: ${e.toString()}');
    }
  }

  // ─── Response parsing ────────────────────────────────────────────────────────

  List<ResourceModel> _parseList(dynamic data) {
    if (data is List) {
      return data.map((e) => ResourceModel.fromJson(_toMap(e))).toList();
    }
    if (data is Map) {
      final items =
          data['items'] ?? data['data'] ?? data['resources'] ?? data['results'];
      if (items is List) {
        return items.map((e) => ResourceModel.fromJson(_toMap(e))).toList();
      }
    }
    return [];
  }

  static Map<String, dynamic> _toMap(dynamic e) =>
      (e is Map) ? Map<String, dynamic>.from(e) : {};

  // ─── Error parsing ───────────────────────────────────────────────────────────

  static String parseError(dynamic error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      if (code == 401) return 'Authentication required. Please log in.';
      if (code == 403) return 'You are not authorized for this action.';
      if (code == 404) return 'Resources not found.';
      if (code == 500) return 'Server error. Please try again later.';

      if (error.response?.data != null) {
        final msg = _extractMessage(error.response!.data);
        if (msg != null && msg.isNotEmpty) return msg;
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Check your internet.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection. Check your network.';
      }
      return error.message ?? 'Connection error.';
    }
    return error.toString();
  }

  static String? _extractMessage(dynamic data) {
    try {
      if (data is Map) {
        if (data['errors'] is Map) {
          final parts = <String>[];
          (data['errors'] as Map).forEach((_, v) {
            if (v is List) {
              parts.add(v.join(', '));
            } else {
              parts.add(v.toString());
            }
          });
          return parts.join('\n');
        }
        final msg = data['message'] ?? data['Message'] ??
            data['title'] ?? data['detail'] ?? data['error'];
        if (msg != null) return msg.toString();
      }
      if (data is String) return data;
    } catch (_) {}
    return null;
  }
}
