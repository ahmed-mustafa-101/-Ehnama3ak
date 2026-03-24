import 'package:ehnama3ak/models/post_model.dart';
import 'package:ehnama3ak/repositories/post_repository.dart';

class MockPostRepository implements PostRepository {
  final List<PostModel> _posts = [
    PostModel(
      postId: '1',
      userId: 'u1',
      userName: 'Ahmed Mohamed',
      userRole: 'Patient',
      userProfileImage: 'assets/images/image_patient.png',
      postText: "I feel exhausted and unable to get through my day...",
      likesCount: 1,
      commentsCount: 22,
      isLikedByMe: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    PostModel(
      postId: '2',
      userId: 'u2',
      userName: 'Dr. Sara Ahmed',
      userRole: 'Doctor',
      userProfileImage: 'assets/images/image_patient.png',
      postText: "Remember to take deep breaths and stay hydrated! 🧘‍♀️",
      likesCount: 15,
      commentsCount: 3,
      isLikedByMe: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  @override
  Future<List<PostModel>> getPosts() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return List.from(_posts);
  }

  @override
  Future<void> likePost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> unlikePost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> addComment(String postId, String text) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> createPost(PostModel post) async {
    await Future.delayed(const Duration(seconds: 1));
    _posts.insert(0, post); // Add to top
  }
}
