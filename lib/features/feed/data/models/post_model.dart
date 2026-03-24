import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String userProfileImage;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;
  final DateTime createdAt;
  final String? likeId;

  const PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.userProfileImage,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.isLikedByMe,
    required this.createdAt,
    this.likeId,
  });

  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    String? userProfileImage,
    String? content,
    String? imageUrl,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
    DateTime? createdAt,
    String? likeId,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
      likeId: likeId ?? this.likeId,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map ? json['user'] as Map<String, dynamic> : null;
    
    // Derived counts from lists if needed
    int likesCount = _toInt(json['likesCount'] ?? json['likes'] ?? 0);
    if (json['likes'] is List && (json['likesCount'] == null)) {
      likesCount = (json['likes'] as List).length;
    }
    
    int commentsCount = _toInt(json['commentsCount'] ?? json['comments'] ?? 0);
    if (json['comments'] is List && (json['commentsCount'] == null)) {
      commentsCount = (json['comments'] as List).length;
    }

    return PostModel(
      id: (json['id'] ?? json['postId'] ?? '').toString(),
      userId: (json['userId'] ?? json['uId'] ?? json['userIds'] ?? '').toString(),
      userName: (json['userName'] ?? userMap?['fullName'] ?? userMap?['userName'] ?? json['name'] ?? 'Unknown').toString(),
      userRole: (json['userRole'] ?? json['role'] ?? 'User').toString(),
      userProfileImage: (json['userProfileImage'] ?? userMap?['avatarUrl'] ?? userMap?['profileImage'] ?? '').toString(),
      content: (json['content'] ?? json['postText'] ?? json['text'] ?? '').toString(),
      imageUrl: json['imageUrl'] ?? json['postImage'] ?? json['image'],
      likesCount: likesCount,
      commentsCount: commentsCount,
      isLikedByMe: json['isLikedByMe'] == true || json['liked'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      likeId: json['likeId']?.toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'content': content,
        'imageUrl': imageUrl,
      };

  bool isOwnedBy(String? currentUserId) =>
      currentUserId != null && currentUserId.isNotEmpty && userId == currentUserId;

  @override
  List<Object?> get props => [id, userId, content, likesCount, commentsCount, isLikedByMe];
}
