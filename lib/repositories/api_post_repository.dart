import 'package:dio/dio.dart';
import 'package:ehnama3ak/models/post_model.dart';
import 'package:ehnama3ak/repositories/post_repository.dart';
import 'package:ehnama3ak/core/storage/pref_manager.dart';
import 'package:flutter/foundation.dart';

class APIPostRepository implements PostRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://e7na-ma3ak-test.runasp.net',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  Future<Options> _getOptions() async {
    final token = await PrefManager.getToken();
    return Options(
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _dio.get('/api/Posts', options: await _getOptions());
      if (response.data is List) {
        return (response.data as List)
            .map((json) => PostModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching posts: $e');
      return [];
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      await _dio.post('/api/Posts/$postId/like', options: await _getOptions());
    } catch (e) {
      debugPrint('Error liking post: $e');
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    try {
      await _dio.delete('/api/Posts/$postId/like', options: await _getOptions());
    } catch (e) {
      debugPrint('Error unliking post: $e');
    }
  }

  @override
  Future<void> addComment(String postId, String text) async {
    try {
      final userId = await PrefManager.getUserId() ?? 'unknown_user';
      await _dio.post(
        '/api/Posts/add-comment',
        data: {
          'postId': postId,
          'userId': userId,
          'Text': text, // Backend expects 'Text' with capital T
        },
        options: await _getOptions(),
      );
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  @override
  Future<void> createPost(PostModel post) async {
    try {
      if (post.userId.isEmpty || post.userId == 'unknown_user') {
        throw Exception('User ID is missing. Please log in again.');
      }

      debugPrint('Repo: Creating post for userId: ${post.userId}');
      debugPrint('Repo: Content: ${post.postText}');
      
      // We use lowercase for field names to fix the backend validation error.
      Map<String, dynamic> data = {
        'userId': post.userId,
        'content': post.postText,
      };

      if (post.postImage != null && !post.postImage!.startsWith('assets/')) {
        debugPrint('Repo: Attaching image: ${post.postImage}');
        data['image'] = await MultipartFile.fromFile(post.postImage!);
      }

      final formData = FormData.fromMap(data);
      
      final response = await _dio.post(
        '/api/Posts', 
        data: formData, 
        options: await _getOptions()
      );
      
      debugPrint('Repo: Post response status: ${response.statusCode}');
    } catch (e) {
      if (e is DioException) {
        debugPrint('Repo: DioError creating post: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        debugPrint('Repo: Error creating post: $e');
      }
      rethrow;
    }
  }
}
