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
    const String baseUrl = 'http://e7nama3ak.runasp.net';

    void normalizeKeys(Map<String, dynamic> m, List<String> keys) {
      for (final key in keys) {
        dynamic val = m[key];
        if (val != null && val is String && val.trim().isNotEmpty) {
          String img = val.trim();
          if (img.toLowerCase() == 'string' || img.toLowerCase() == 'null') {
            m[key] = null;
            continue;
          }
          if (!img.startsWith('http') && !img.startsWith('assets/')) {
            m[key] = img.startsWith('/') ? '$baseUrl$img' : '$baseUrl/$img';
          }
        }
      }
    }

    // 1. Normalize post content images
    normalizeKeys(map, [
      'imageUrl',
      'image',
      'postImage',
      'PostImage',
      'ImageUrl',
    ]);

    // 2. Normalize root-level user images
    normalizeKeys(map, [
      'userProfileImage',
      'profileImageUrl',
      'avatarUrl',
      'userImage',
      'authorImage',
      'doctorImage',
      'patientImage',
      'photoPath',
    ]);

    // 3. Normalize nested user/author object images
    final userKeys = [
      'user',
      'User',
      'author',
      'Author',
      'doctor',
      'Doctor',
      'patient',
      'Patient',
      'creator',
      'Creator',
    ];
    for (final key in userKeys) {
      if (map[key] is Map) {
        final userMap = Map<String, dynamic>.from(map[key]);
        normalizeKeys(userMap, [
          'profileImageUrl',
          'ProfileImageUrl',
          'imageUrl',
          'image',
          'avatarUrl',
          'photoUrl',
          'ProfileImage',
          'photoPath',
          'avatar',
          'picture',
        ]);
        map[key] = userMap;
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
        // Handle both / and \ in path for filename
        final fileName = imagePath.replaceAll('\\', '/').split('/').last;
        final multipartFile = await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        );
        // Per user curl: -F 'image=...'
        data['image'] = multipartFile;
      }

      final formData = FormData.fromMap(data);

      final response = await _dio.post('/api/Posts', data: formData);

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
    } catch (_) {}
  }

  Future<void> unlikePost(String postId, {String? likeId}) async {
    try {
      await _dio.post('/api/Likes/$postId');
    } catch (_) {}
  }

  Future<List<CommentModel>> getComments({
    required String postId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      try {
        // We'll try several common REST patterns for comments
        final List<String> variants = [
          '/api/Comments?postId=$postId',
          '/api/Comments?PostId=$postId',
          '/api/Comments/$postId',
          '/api/Posts/$postId/comments',
          '/api/Posts/$postId/Comments',
        ];

        for (final url in variants) {
          try {
            final response = await _dio.get(url);
            if (response.data != null) {
              final results = _parseCommentsResponse(response.data);
              if (results.isNotEmpty) return results;
            }
          } catch (_) {}
        }

        // 2. Try to get the specific post (might contain comments nested inside)
        try {
          final response = await _dio.get('/api/Posts/$postId');
          if (response.data != null) {
            final data = _toMap(response.data);
            final nested = data['comments'] ?? 
                           data['Comments'] ?? 
                           data['items'] ?? 
                           data['data'] ?? 
                           data['results'];
            if (nested != null) {
              final results = _parseCommentsResponse(nested);
              if (results.isNotEmpty) return results;
            }
          }
        } catch (_) {}
      } catch (_) {}

      // 3. Fallback: Search in the general posts list
      final response = await _dio.get('/api/Posts');
      dynamic postsList = response.data;
      if (postsList is Map) {
        postsList =
            postsList['items'] ?? postsList['data'] ?? postsList['posts'] ?? [];
      }

      if (postsList is List) {
        for (var postJson in postsList) {
          final currentPostId = (postJson['id'] ?? postJson['postId'])
              ?.toString();
          if (currentPostId == postId.toString()) {
            final comments = postJson['comments'] ?? postJson['Comments'] ?? [];
            return _parseCommentsResponse(comments);
          }
        }
      }
    } catch (_) {}
    return [];
  }

  List<CommentModel> _parseCommentsResponse(dynamic data) {
    if (data == null) return [];
    
    if (data is List) {
      return data.map((e) => CommentModel.fromJson(_toMap(e))).toList();
    }
    
    if (data is Map) {
      final items = data['items'] ?? 
                    data['data'] ?? 
                    data['comments'] ?? 
                    data['Comments'] ?? 
                    data['item'] ?? 
                    data['List'] ?? 
                    data['list'];
      if (items is List) {
        return items.map((e) => CommentModel.fromJson(_toMap(e))).toList();
      }
      
      // If the map itself looks like a single comment, wrap it (though unlikely for a list endpoint)
      if (data.containsKey('id') || data.containsKey('text') || data.containsKey('content')) {
        return [CommentModel.fromJson(Map<String, dynamic>.from(data))];
      }
    }
    return [];
  }

  Future<CommentModel> addComment({
    required String postId,
    required String text,
    required String userId,
    String? parentId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/Comments',
        data: {
          'id': 0,
          'content': text,
          'userId': userId,
          'postId': int.tryParse(postId) ?? postId,
          if (parentId != null) 'parentId': int.tryParse(parentId) ?? parentId,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        },
      );
      return CommentModel.fromJson(_toMap(response.data));
    } on DioException catch (e) {
      throw Exception(parseError(e));
    }
  }

  Future<CommentModel> updateComment({
    required String commentId,
    required String text,
    required String userId,
  }) async {
    try {
      final response = await _dio.put(
        '/api/Comments/$commentId',
        data: {
          'id': int.tryParse(commentId) ?? 0,
          'content': text,
          'userId': userId,
        },
      );
      return CommentModel.fromJson(_toMap(response.data));
    } on DioException catch (e) {
      throw Exception(parseError(e));
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _dio.delete('/api/Comments/$commentId');
    } on DioException catch (e) {
      throw Exception(parseError(e));
    }
  }
}
