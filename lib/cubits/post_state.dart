// import 'package:ehnama3ak/models/post_model.dart';
// import 'package:equatable/equatable.dart';

// enum PostStatus { initial, loading, success, failure }

// class PostState extends Equatable {
//   final PostStatus status;
//   final List<PostModel> posts;
//   final String? errorMessage;

//   const PostState({
//     this.status = PostStatus.initial,
//     this.posts = const [],
//     this.errorMessage,
//   });

//   PostState copyWith({
//     PostStatus? status,
//     List<PostModel>? posts,
//     String? errorMessage,
//     bool clearError = false,
//   }) {
//     return PostState(
//       status: status ?? this.status,
//       posts: posts ?? this.posts,
//       errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
//     );
//   }

//   @override
//   List<Object?> get props => [status, posts, errorMessage];
// }
