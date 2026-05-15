import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userProfileImage;
  final String userAvatar;
  final String text;
  final DateTime createdAt;
  final String? parentId;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userProfileImage,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
    this.parentId,
  });

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? userAvatar,
    String? text,
    DateTime? createdAt,
    String? parentId,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      userAvatar: userAvatar ?? this.userAvatar,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
    );
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Helper to find a value by case-insensitive key or a list of keys
    dynamic findValue(Map<String, dynamic>? data, List<String> keys) {
      if (data == null) return null;
      for (final key in keys) {
        if (data.containsKey(key) && data[key] != null) return data[key];
      }
      final lowerKeys = keys.map((k) => k.toLowerCase()).toSet();
      for (final entry in data.entries) {
        if (lowerKeys.contains(entry.key.toLowerCase()) &&
            entry.value != null) {
          return entry.value;
        }
      }
      return null;
    }

    // Helper to pick the first non-null/non-empty string value
    String pick(
      Map<String, dynamic>? data,
      List<String> keys, {
      String defaultValue = '',
    }) {
      final value = findValue(data, keys);
      if (value == null) return defaultValue;
      final s = value.toString().trim();
      return (s.isNotEmpty &&
              s.toLowerCase() != 'null' &&
              s.toLowerCase() != 'string')
          ? s
          : defaultValue;
    }

    // Try to find user info in various possible nested objects
    final List<String> userObjectKeys = [
      'user',
      'User',
      'doctor',
      'Doctor',
      'patient',
      'Patient',
    ];
    final dynamic userRaw = findValue(json, userObjectKeys);
    final Map<String, dynamic>? userMap = userRaw is Map
        ? Map<String, dynamic>.from(userRaw)
        : null;

    final List<String> nameKeys = [
      'userName',
      'name',
      'fullName',
      'displayName',
      'Name',
      'UserName',
    ];

    final List<String> imageKeys = ['userAvatar'];

    return CommentModel(
      id: findValue(json, ['id', 'commentId', 'commentID', 'Id']).toString(),
      postId: findValue(json, [
        'postId',
        'PostId',
        'postid',
        'postIDs',
      ]).toString(),
      userId:
          (findValue(json, ['userId', 'uId', 'uid']) ??
                  userMap?['id'] ??
                  userMap?['userId'] ??
                  '')
              .toString(),
      userName: pick(
        userMap,
        nameKeys,
        defaultValue: pick(json, nameKeys, defaultValue: 'Unknown User'),
      ),
      userProfileImage: pick(
        userMap,
        imageKeys,
        defaultValue: pick(json, imageKeys, defaultValue: ''),
      ),
      userAvatar: pick(
        userMap,
        imageKeys,
        defaultValue: pick(json, imageKeys, defaultValue: ''),
      ),
      text: findValue(json, ['content']).toString(),
      createdAt: json['createdAt'] != null || json['CreatedAt'] != null
          ? DateTime.tryParse(
                  (json['createdAt'] ?? json['CreatedAt']).toString(),
                ) ??
                DateTime.now()
          : DateTime.now(),
      parentId: (findValue(json, [
        'parentId',
        'parentCommentId',
        'replyToId',
        'ParentId',
      ]))?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, postId, userId, text, parentId, userAvatar];
}

//   @override
//   List<Object?> get props => [id, postId, userId, text, parentId];
// }
