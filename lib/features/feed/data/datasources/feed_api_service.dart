import 'package:dio/dio.dart';
import 'package:ehnama3ak/core/network/dio_client.dart';
import 'package:ehnama3ak/core/storage/secure_token_storage.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

class FeedApiService {
  final Dio _dio;
  final SecureTokenStorage _tokenStorage;

  FeedApiService({DioClient? dioClient, SecureTokenStorage? tokenStorage})
    : _dio =
          (dioClient ??
                  DioClient(tokenStorage: tokenStorage ?? SecureTokenStorage()))
              .dio,
      _tokenStorage = tokenStorage ?? SecureTokenStorage();

  static String parseError(dynamic error) {
    if (error is DioException) {
      final code = error.response?.statusCode;
      if (code == 400) {
        return _parseValidationError(error.response?.data) ?? 'طلب غير صالح';
      }
      if (code == 401) return 'يجب تسجيل الدخول للمتابعة';
      if (code == 403) return 'غير مصرح لك بهذا الإجراء';
      if (code == 500) return 'خطأ في السيرفر. يرجى المحاولة لاحقاً';

      if (error.response?.data != null) {
        final msg = _parseValidationError(error.response!.data);
        if (msg != null && msg.isNotEmpty) return msg;
      }
      return error.message ?? 'خطأ في الاتصال';
    }
    return error.toString();
  }

  static String? _parseValidationError(dynamic data) {
    if (data == null) return null;
    try {
      if (data is Map) {
        if (data['errors'] != null) {
          final errors = data['errors'];
          if (errors is Map) {
            final parts = <String>[];
            errors.forEach((k, v) {
              if (v is List) {
                parts.add(v.join(', '));
              } else {
                parts.add(v.toString());
              }
            });
            return parts.join('\n');
          }
        }
        final msg =
            data['message'] ??
            data['Message'] ??
            data['title'] ??
            data['detail'];
        if (msg != null) return msg.toString();
      }
      if (data is String) return data;
      return data.toString();
    } catch (_) {
      return null;
    }
  }

  Future<List<PostModel>> getPosts({int page = 1, int pageSize = 10}) async {
    final response = await _dio.get(
      '/api/Posts',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return _parsePostsResponse(response.data);
  }

  List<PostModel> _parsePostsResponse(dynamic data) {
    if (data is Map) {
      final items = data['items'] ?? data['data'] ?? data['posts'];
      if (items is List) {
        return items.map((e) {
          final map = _toMap(e);
          _normalizeImageUrl(map);
          return PostModel.fromJson(map);
        }).toList();
      }
    }

    if (data is List) {
      return data.map((e) {
        final map = _toMap(e);
        _normalizeImageUrl(map);
        return PostModel.fromJson(map);
      }).toList();
    }
    return [];
  }

  void _normalizeImageUrl(Map<String, dynamic> map) {
    // Backend uses 'imageUrl', some old code might use 'image'
    dynamic imgValue = map['imageUrl'] ?? map['image'];
    if (imgValue != null && imgValue is String && imgValue.isNotEmpty) {
      String img = imgValue.trim();
      // Ignore Swagger/placeholder values
      if (img.toLowerCase() == 'string' || img.toLowerCase() == 'null' || img.isEmpty) {
        map['imageUrl'] = null;
        map['image'] = null;
        return;
      }
      
      if (!img.startsWith('http')) {
        const String baseUrl = 'http://e7nama3ak.runasp.net';
        final normalized =
            img.startsWith('/') ? '$baseUrl$img' : '$baseUrl/$img';
        map['imageUrl'] = normalized;
        map['image'] = normalized;
      }
    }
  }

  static Map<String, dynamic> _toMap(dynamic e) =>
      (e is Map) ? Map<String, dynamic>.from(e) : {};

  Future<PostModel> createPost({
    required String content,
    String? imagePath,
    required String userId,
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw Exception('محتوى المنشور لا يمكن أن يكون فارغاً');
    }

    if (userId.isEmpty) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    try {
      final Map<String, dynamic> data = {
        'content': trimmedContent,
        'userId': userId,
      };

      if (imagePath != null &&
          imagePath.isNotEmpty &&
          !imagePath.startsWith('assets/')) {
        final multipartFile = await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        );
        // Added 'Image' (capitalized) which is very common in .NET backends
        data['Image'] = multipartFile;
        data['imageUrl'] = multipartFile;
        data['image'] = multipartFile;
      }

      final formData = FormData.fromMap(data);

      final response = await _dio.post(
        '/api/Posts',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final responseData = _toMap(response.data);
      _normalizeImageUrl(responseData);

      return PostModel.fromJson(responseData);
    } on DioException catch (e) {
      throw Exception(parseError(e));
    } catch (e) {
      throw Exception('حدث خطأ أثناء إنشاء المنشور: ${e.toString()}');
    }
  }

  Future<PostModel> updatePost({
    required String postId,
    required String content,
    required String userId,
  }) async {
    final response = await _dio.put(
      '/api/Posts/$postId',
      data: {'content': content, 'userId': userId},
    );
    final data = _toMap(response.data);
    _normalizeImageUrl(data);
    return PostModel.fromJson(data);
  }

  Future<void> deletePost(String postId) async {
    await _dio.delete('/api/Posts/$postId');
  }

  Future<void> likePost(String postId) async {
    try {
      await _dio.post('/api/Likes/$postId');
    } catch (_) {
    }
  }

  Future<void> unlikePost(String postId, {String? likeId}) async {
    try {
      await _dio.post('/api/Likes/$postId');
    } catch (_) {
    }
  }

  Future<List<CommentModel>> getComments({
    required String postId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get('/api/Posts');
      
      dynamic postsList = response.data;
      if (postsList is Map) {
        postsList = postsList['items'] ?? postsList['data'] ?? postsList['posts'] ?? [];
      }
      
      if (postsList is List) {
        for (var postJson in postsList) {
          if (postJson['id']?.toString() == postId.toString() ||
              postJson['postId']?.toString() == postId.toString()) {
            return _parseCommentsResponse(postJson['comments'] ?? []);
          }
        }
      }
    } catch (_) {}
    return [];
  }

  List<CommentModel> _parseCommentsResponse(dynamic data) {
    if (data is List) {
      return data.map((e) => CommentModel.fromJson(_toMap(e))).toList();
    }
    if (data is Map) {
      final items = data['items'] ?? data['data'] ?? data['comments'];
      if (items is List) {
        return items.map((e) => CommentModel.fromJson(_toMap(e))).toList();
      }
    }
    return [];
  }

  Future<CommentModel> addComment({
    required String postId,
    required String text,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/Comments',
        data: {
          'id': 0,
          'content': text,
          'userId': userId,
          'postId': int.tryParse(postId) ?? 0,
          'createdAt': DateTime.now().toUtc().toIso8601String()
        },
      );
      return CommentModel.fromJson(_toMap(response.data));
    } on DioException catch (e) {
      throw Exception(parseError(e));
    }
  }
}
