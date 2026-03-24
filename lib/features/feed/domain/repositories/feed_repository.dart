import '../../data/models/comment_model.dart';
import '../../data/models/post_model.dart';

abstract class FeedRepository {
  Future<List<PostModel>> getPosts({int page = 1, int pageSize = 10});
  Future<PostModel> createPost({
    required String content,
    String? imagePath,
    required String userId,
  });
  Future<PostModel> updatePost({
    required String postId,
    required String content,
    required String userId,
  });
  Future<void> deletePost(String postId);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId, {String? likeId});
  Future<List<CommentModel>> getComments({
    required String postId,
    int page = 1,
    int pageSize = 10,
  });
  Future<CommentModel> addComment({
    required String postId,
    required String text,
    required String userId,
  });
}
