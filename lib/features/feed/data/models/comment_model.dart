import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userProfileImage;
  final String text;
  final DateTime createdAt;
  final String? parentId;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.text,
    required this.createdAt,
    this.parentId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Helper to find a value by case-insensitive key or a list of keys
    dynamic findValue(Map<String, dynamic>? data, List<String> keys) {
      if (data == null) return null;
      for (final key in keys) {
        if (data.containsKey(key) && data[key] != null) return data[key];
      }
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
    final List<String> userObjectKeys = [
      'user', 'User', 'author', 'Author', 'doctor', 'Doctor', 'patient', 'Patient', 
      'creator', 'Creator', 'owner', 'Owner', 'applicationUser', 'ApplicationUser', 
      'appUser', 'AppUser'
    ];
    final dynamic userRaw = findValue(json, userObjectKeys);
    final Map<String, dynamic>? userMap = userRaw is Map ? Map<String, dynamic>.from(userRaw) : null;

    final List<String> nameKeys = [
      'userName', 'UserName', 'fullName', 'FullName', 'displayName', 'DisplayName', 
      'name', 'Name', 'userFullName', 'UserFullName', 'firstName', 'FirstName',
      'authorName', 'AuthorName', 'doctorName', 'DoctorName', 'patientName', 'PatientName'
    ];

    final List<String> imageKeys = [
      'userProfileImage', 'profileImageUrl', 'ProfileImageUrl', 'profileImage', 'ProfileImage',
      'avatarUrl', 'AvatarUrl', 'photoUrl', 'PhotoUrl', 'picture', 'Picture', 'photoPath',
      'avatar', 'profilePicture', 'profileurl', 'profile', 'userImage', 'UserImage',
      'authorImage', 'AuthorImage', 'doctorImage', 'DoctorImage', 'patientImage', 'PatientImage',
      'userPhoto', 'UserPhoto', 'authorPhoto', 'AuthorPhoto', 'doctorPhoto', 'DoctorPhoto',
      'patientPhoto', 'PatientPhoto', 'profile_picture', 'profile_photo', 'avatar_url', 'image_url',
      'uImage', 'uPhoto', 'uAvatar', 'uPicture', 'imageUrl', 'ImageUrl', 'image', 'Image', 'url', 'photo'
    ];

    return CommentModel(
      id: findValue(json, ['id', 'commentId', 'commentID', 'Id']).toString(),
      postId: findValue(json, ['postId', 'PostId', 'postid', 'postIDs']).toString(),
      userId: (findValue(json, ['userId', 'uId', 'uid']) ?? userMap?['id'] ?? userMap?['userId'] ?? '').toString(),
      userName: pick(userMap, nameKeys, defaultValue: pick(json, nameKeys, defaultValue: 'Unknown User')),
      userProfileImage: pick(userMap, imageKeys, defaultValue: pick(json, imageKeys, defaultValue: '')),
      text: findValue(json, ['text', 'content', 'Text', 'Content', 'body', 'Body']).toString(),
      createdAt: json['createdAt'] != null || json['CreatedAt'] != null
          ? DateTime.tryParse((json['createdAt'] ?? json['CreatedAt']).toString()) ?? DateTime.now()
          : DateTime.now(),
      parentId: (findValue(json, ['parentId', 'parentCommentId', 'replyToId', 'ParentId']))?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, postId, userId, text, parentId];
}
  @override
  List<Object?> get props => [id, postId, userId, text, parentId];
}
