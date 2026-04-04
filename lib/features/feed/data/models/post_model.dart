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
  final int sharesCount;
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
    required this.sharesCount,
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
    int? sharesCount,
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
      sharesCount: sharesCount ?? this.sharesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
      likeId: likeId ?? this.likeId,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Helper to find a value by case-insensitive key or a list of keys
    dynamic findValue(Map<String, dynamic>? data, List<String> keys) {
      if (data == null) return null;
      // 1. Try exact matches first
      for (final key in keys) {
        if (data.containsKey(key) && data[key] != null) return data[key];
      }
      // 2. Try case-insensitive matches if not found
      final lowerKeys = keys.map((k) => k.toLowerCase()).toSet();
      for (final entry in data.entries) {
        if (lowerKeys.contains(entry.key.toLowerCase()) && entry.value != null) {
          return entry.value;
        }
      }
      return null;
    }

    // Helper to pick the first non-null/non-empty string value
    String pick(Map<String, dynamic>? data, List<String> keys, {String defaultValue = ''}) {
      final value = findValue(data, keys);
      if (value == null) return defaultValue;
      final s = value.toString().trim();
      return (s.isNotEmpty && s.toLowerCase() != 'null' && s.toLowerCase() != 'string') ? s : defaultValue;
    }

    // Try to find user info in various possible nested objects
    final List<String> userObjectKeys = ['user', 'User', 'author', 'Author', 'doctor', 'Doctor', 'patient', 'Patient', 'creator', 'Creator', 'owner', 'Owner'];
    final dynamic userRaw = findValue(json, userObjectKeys);
    final Map<String, dynamic>? userMap = userRaw is Map ? Map<String, dynamic>.from(userRaw) : null;
    
    // Derived counts from lists if needed
    int likesCount = _toInt(json['likesCount'] ?? json['likes'] ?? 0);
    if (json['likes'] is List && (json['likesCount'] == null)) {
      likesCount = (json['likes'] as List).length;
    }
    
    int commentsCount = _toInt(json['commentsCount'] ?? json['comments'] ?? 0);
    if (json['comments'] is List && (json['commentsCount'] == null)) {
      commentsCount = (json['comments'] as List).length;
    }

    int sharesCount = _toInt(json['sharesCount'] ?? json['shares'] ?? 0);
    if (json['shares'] is List && (json['sharesCount'] == null)) {
      sharesCount = (json['shares'] as List).length;
    }

    final List<String> nameKeys = [
      'userName', 'UserName', 'fullName', 'FullName', 'displayName', 'DisplayName', 
      'name', 'Name', 'userFullName', 'UserFullName', 'firstName', 'FirstName',
      'authorName', 'AuthorName', 'doctorName', 'DoctorName', 'patientName', 'PatientName'
    ];

    final List<String> userImageOnlyKeys = [
      'userProfileImage', 'profileImageUrl', 'ProfileImageUrl', 'profileImage', 'ProfileImage',
      'avatarUrl', 'AvatarUrl', 'photoUrl', 'PhotoUrl', 'picture', 'Picture', 'photoPath',
      'avatar', 'profilePicture', 'profileurl', 'profile', 'userImage', 'UserImage',
      'authorImage', 'AuthorImage', 'doctorImage', 'DoctorImage', 'patientImage', 'PatientImage',
      'userPhoto', 'UserPhoto', 'authorPhoto', 'AuthorPhoto', 'doctorPhoto', 'DoctorPhoto',
      'patientPhoto', 'PatientPhoto', 'profile_picture', 'profile_photo', 'avatar_url', 'image_url',
      'uImage', 'uPhoto', 'uAvatar', 'uPicture'
    ];

    final List<String> commonImageKeys = [
      'imageUrl', 'ImageUrl', 'image', 'Image', 'url', 'photo', 'img'
    ];

    // Separate user info extraction to avoid collision with post image
    String profileImg = '';
    if (userMap != null) {
      // Inside user object, we can trust common keys like 'image' or 'url'
      profileImg = pick(userMap, [...userImageOnlyKeys, ...commonImageKeys]);
    }
    
    if (profileImg.isEmpty) {
      // At root level (post itself), ONLY trust user-specific keys
      profileImg = pick(json, userImageOnlyKeys);
    }

    return PostModel(
      id: (json['id'] ?? json['postId'] ?? '').toString(),
      userId: (json['userId'] ?? json['uId'] ?? json['userIds'] ?? json['uid'] ?? userMap?['id'] ?? userMap?['userId'] ?? '').toString(),
      userName: pick(userMap, nameKeys, defaultValue: pick(json, nameKeys, defaultValue: 'Unknown')),
      userRole: (json['userRole'] ?? json['role'] ?? userMap?['role'] ?? 'User').toString(),
      userProfileImage: profileImg,
      content: (json['content'] ?? json['postText'] ?? json['text'] ?? '').toString(),
      imageUrl: json['imageUrl'] ?? json['postImage'] ?? json['image'],
      likesCount: likesCount,
      commentsCount: commentsCount,
      sharesCount: sharesCount,
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
  List<Object?> get props => [id, userId, content, likesCount, commentsCount, sharesCount, isLikedByMe];
}
