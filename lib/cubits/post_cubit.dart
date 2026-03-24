// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ehnama3ak/models/post_model.dart';
// import 'package:ehnama3ak/repositories/post_repository.dart';
// import 'package:ehnama3ak/cubits/post_state.dart';
// import 'package:ehnama3ak/core/storage/pref_manager.dart';

// class PostCubit extends Cubit<PostState> {
//   final PostRepository _postRepository;

//   PostCubit(this._postRepository) : super(const PostState());

//   Future<void> loadPosts() async {
//     // Only show loading indicator if we don't have posts yet
//     if (state.posts.isEmpty) {
//       emit(state.copyWith(status: PostStatus.loading));
//     }
    
//     try {
//       final posts = await _postRepository.getPosts();
//       emit(state.copyWith(status: PostStatus.success, posts: posts, clearError: true));
//     } catch (e) {
//       emit(
//         state.copyWith(status: PostStatus.failure, errorMessage: e.toString()),
//       );
//     }
//   }

//   Future<void> likePost(String postId) async {
//     // Optimistic update
//     final updatedPosts = state.posts.map((post) {
//       if (post.postId == postId) {
//         final isLiked = post.isLikedByMe;
//         return post.copyWith(
//           isLikedByMe: !isLiked,
//           likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
//         );
//       }
//       return post;
//     }).toList();

//     emit(state.copyWith(posts: updatedPosts));

//     try {
//       final post = updatedPosts.firstWhere((p) => p.postId == postId);
//       if (post.isLikedByMe) {
//         await _postRepository.likePost(postId);
//       } else {
//         await _postRepository.unlikePost(postId);
//       }
//     } catch (e) {
//       // Opting not to revert for better UX, but real apps should handle it
//     }
//   }

//   Future<void> addComment(String postId, String text) async {
//     final updatedPosts = state.posts.map((post) {
//       if (post.postId == postId) {
//         return post.copyWith(commentsCount: post.commentsCount + 1);
//       }
//       return post;
//     }).toList();

//     emit(state.copyWith(posts: updatedPosts));

//     try {
//       await _postRepository.addComment(postId, text);
//     } catch (e) {
//       final revertedPosts = state.posts.map((post) {
//         if (post.postId == postId) {
//           return post.copyWith(commentsCount: post.commentsCount - 1);
//         }
//         return post;
//       }).toList();
//       emit(state.copyWith(posts: revertedPosts, errorMessage: "Failed to add comment"));
//     }
//   }

//   Future<void> createPost(String text, {String? imagePath}) async {
//     if (text.trim().isEmpty && imagePath == null) return;

//     // Get real user data from preferences
//     final userId = await PrefManager.getUserId() ?? 'unknown_user';
//     final role = await PrefManager.getUserRole();
    
//     final newPost = PostModel(
//       postId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
//       userId: userId,
//       userName: 'Me', // We could get real name from PrefManager too if saved
//       userRole: role.name,
//       userProfileImage: 'assets/images/image_patient.png',
//       postText: text,
//       postImage: imagePath,
//       likesCount: 0,
//       commentsCount: 0,
//       isLikedByMe: false,
//       createdAt: DateTime.now(),
//     );

//     // Optimistic Update
//     final currentStatePosts = List<PostModel>.from(state.posts);
//     final updatedPosts = List<PostModel>.from(state.posts)..insert(0, newPost);
//     emit(state.copyWith(posts: updatedPosts));

//     try {
//       print("Cubit: Sending post to repository...");
//       await _postRepository.createPost(newPost);
//       print("Cubit: Post created successfully in backend.");
//     } catch (e) {
//       print("Cubit: Server returned error, but keeping post locally for preview: $e");
//       // We do NOT revert the optimistic update here.
//       // This allows the user to see their post in the UI even if the backend fails.
//       // We can show a small message or just let it stay there.
//       emit(state.copyWith(
//         errorMessage: "Post kept locally (Server error: 500)", 
//         clearError: false
//       ));
//       // Optionally clear error after a delay if needed, but we have a clearError method.
//     }
//   }

//   void clearError() {
//     emit(state.copyWith(clearError: true));
//   }
// }
