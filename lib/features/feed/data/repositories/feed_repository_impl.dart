import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_api_service.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedApiService _api;

  FeedRepositoryImpl(FeedApiService api) : _api = api;

  @override
  Future<List<PostModel>> getPosts({int page = 1, int pageSize = 10}) =>
      _api.getPosts(page: page, pageSize: pageSize);

  @override
  Future<PostModel> createPost({
    required String content,
    String? imagePath,
    required String userId,
  }) =>
      _api.createPost(content: content, imagePath: imagePath, userId: userId);

  @override
  Future<PostModel> updatePost({
    required String postId,
    required String content,
    required String userId,
  }) =>
      _api.updatePost(postId: postId, content: content, userId: userId);

  @override
  Future<void> deletePost(String postId) => _api.deletePost(postId);

  @override
  Future<void> likePost(String postId) => _api.likePost(postId);

  @override
  Future<void> unlikePost(String postId, {String? likeId}) =>
      _api.unlikePost(postId, likeId: likeId);

  @override
  Future<List<CommentModel>> getComments({
    required String postId,
    int page = 1,
    int pageSize = 10,
  }) =>
      _api.getComments(postId: postId, page: page, pageSize: pageSize);

  @override
  Future<CommentModel> addComment({
    required String postId,
    required String text,
    required String userId,
    String? parentId,
  }) =>
      _api.addComment(
        postId: postId,
        text: text,
        userId: userId,
        parentId: parentId,
      );

  @override
  Future<CommentModel> updateComment({
    required String commentId,
    required String text,
    required String userId,
  }) =>
      _api.updateComment(commentId: commentId, text: text, userId: userId);

  @override
  Future<void> deleteComment(String commentId) => _api.deleteComment(commentId);
}
