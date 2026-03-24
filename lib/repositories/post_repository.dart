import 'package:ehnama3ak/models/post_model.dart';

abstract class PostRepository {
  Future<List<PostModel>> getPosts();
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<void> addComment(String postId, String text);
  Future<void> createPost(PostModel post);
}
