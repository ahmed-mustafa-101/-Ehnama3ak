import 'package:dio/dio.dart';
import 'package:ehnama3ak/core/network/dio_client.dart';
import 'package:ehnama3ak/core/storage/secure_token_storage.dart';
import '../models/podcast_model.dart';

class PodcastApiService {
  final Dio _dio;

  PodcastApiService({DioClient? dioClient, SecureTokenStorage? tokenStorage})
      : _dio = (dioClient ??
                DioClient(tokenStorage: tokenStorage ?? SecureTokenStorage()))
            .dio;

  // ─── API calls ──────────────────────────────────────────────────────────────

  Future<List<PodcastModel>> getPodcasts() async {
    try {
      final response = await _dio.get('/api/Podcasts');
      return _parsePodcastsResponse(response.data);
    } on DioException catch (e) {
      throw Exception(parseError(e));
    } catch (e) {
      throw Exception('Failed to fetch podcasts: ${e.toString()}');
    }
  }

  // ─── Response parsing ────────────────────────────────────────────────────────

  List<PodcastModel> _parsePodcastsResponse(dynamic data) {
    if (data is List) {
      return data
          .map((e) => PodcastModel.fromJson(_toMap(e)))
          .toList();
    }
    if (data is Map) {
      // Handle wrapped responses: { "items": [...] }, { "data": [...] }, etc.
      final items =
          data['items'] ?? data['data'] ?? data['podcasts'] ?? data['results'];
      if (items is List) {
        return items
            .map((e) => PodcastModel.fromJson(_toMap(e)))
            .toList();
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
      if (code == 403) return 'You are not authorized to access this resource.';
      if (code == 404) return 'Podcasts not found.';
      if (code == 500) return 'Server error. Please try again later.';

      if (error.response?.data != null) {
        final msg = _parseMessageFromData(error.response!.data);
        if (msg != null && msg.isNotEmpty) return msg;
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Connection timed out. Check your internet connection.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection. Please check your network.';
      }
      return error.message ?? 'Connection error. Please try again.';
    }
    return error.toString();
  }

  static String? _parseMessageFromData(dynamic data) {
    if (data == null) return null;
    try {
      if (data is Map) {
        final msg = data['message'] ??
            data['Message'] ??
            data['title'] ??
            data['detail'] ??
            data['error'];
        if (msg != null) return msg.toString();
      }
      if (data is String) return data;
    } catch (_) {}
    return null;
  }
}
