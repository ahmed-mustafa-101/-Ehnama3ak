class PostModel {
  final String postId;
  final String userId;
  final String userName;
  final String userRole;
  final String userProfileImage;
  final String userAvatar;
  final String postText;
  final String? postImage;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  PostModel({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.userProfileImage,
    required this.userAvatar,
    required this.postText,
    this.postImage,
    required this.likesCount,
    required this.commentsCount,
    required this.isLikedByMe,
    required this.createdAt,
  });

  PostModel copyWith({
    String? postId,
    String? userId,
    String? userName,
    String? userRole,
    String? userProfileImage,
    String? userAvatar,
    String? postText,
    String? postImage,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
    DateTime? createdAt,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      userAvatar: userAvatar ?? this.userAvatar,
      postText: postText ?? this.postText,
      postImage: postImage ?? this.postImage,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: (json['postId'] ?? json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['uId'] ?? '').toString(),
      userName: json['userName'] ?? json['name'] ?? 'Unknown',
      userRole: json['userRole'] ?? json['role'] ?? 'User',
      userProfileImage: json['userProfileImage'] ?? json['userAvatar'] ?? json['profilePlaceholder'] ?? '',
      userAvatar: json['userAvatar'] ?? json['userProfileImage'] ?? '',
      postText: json['postText'] ?? json['content'] ?? '',
      postImage: json['postImage'],
      likesCount: json['likesCount'] ?? json['likes'] ?? 0,
      commentsCount: json['commentsCount'] ?? json['comments'] ?? 0,
      isLikedByMe: json['isLikedByMe'] ?? json['liked'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'userProfileImage': userProfileImage,
      'postText': postText,
      'postImage': postImage,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLikedByMe': isLikedByMe,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

