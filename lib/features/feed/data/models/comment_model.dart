import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userProfileImage;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: (json['id'] ?? json['commentId'] ?? '').toString(),
      postId: (json['postId'] ?? json['postIDs'] ?? '').toString(),
      userId: (json['userId'] ?? json['uId'] ?? '').toString(),
      userName: (json['userName'] ?? json['name'] ?? 'Unknown').toString(),
      userProfileImage: (json['userProfileImage'] ?? json['profileImage'] ?? '').toString(),
      text: (json['text'] ?? json['content'] ?? json['Text'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, postId, userId, text];
}
