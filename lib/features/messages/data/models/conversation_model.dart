/// Represents a conversation entry from GET /api/Messages/conversations
class ConversationModel {
  final String conversationId; // e.g. "7_ec87199d-4c41-4327-8cc6-650760321c23"
  final String userId;         // The other participant's ID (used as ReceiverId)
  final String userName;       // Display name of the other participant
  final String userImage;      // Profile image URL path
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isFavorite;

  const ConversationModel({
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isFavorite,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversationId: _s(json['conversationId'] ?? json['id']),
      userId: _s(json['userId'] ?? json['otherUserId'] ?? ''),
      userName: _s(json['userName'] ?? json['name'] ?? 'Unknown'),
      userImage: _s(json['userImage'] ?? json['image'] ?? ''),
      lastMessage: _s(json['lastMessage'] ?? json['message'] ?? ''),
      lastMessageTime: _dt(json['lastMessageTime'] ?? json['lastMessageAt']),
      unreadCount: _i(json['unreadCount'] ?? json['unread']),
      isFavorite: json['isFavorite'] == true,
    );
  }

  ConversationModel copyWith({bool? isFavorite}) => ConversationModel(
        conversationId: conversationId,
        userId: userId,
        userName: userName,
        userImage: userImage,
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        unreadCount: unreadCount,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  static String _s(dynamic v) => v?.toString() ?? '';
  static int _i(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime _dt(dynamic v) {
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}
