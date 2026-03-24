/// Represents a conversation between two users (doctor ↔ patient).
class ConversationModel {
  final String conversationId;
  final String senderName;
  final String receiverName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String? profileImage;

  /// The ID of the other participant (used to send replies).
  final String otherUserId;

  const ConversationModel({
    required this.conversationId,
    required this.senderName,
    required this.receiverName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    this.profileImage,
    required this.otherUserId,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversationId: _str(json['conversationId'] ?? json['id']),
      senderName: _str(json['senderName'] ?? json['sender']),
      receiverName: _str(json['receiverName'] ?? json['receiver']),
      lastMessage: _str(json['lastMessage'] ?? json['message'] ?? json['content']),
      lastMessageTime: _date(json['lastMessageTime'] ?? json['lastMessageAt'] ?? json['createdAt']),
      unreadCount: _int(json['unreadCount'] ?? json['unread']),
      profileImage: _nullableStr(json['profileImage'] ?? json['profileImageUrl'] ?? json['avatar']),
      otherUserId: _str(json['otherUserId'] ?? json['receiverId'] ?? json['userId'] ?? ''),
    );
  }

  // ──── Helpers ────
  static String _str(dynamic v) => v?.toString() ?? '';

  static String? _nullableStr(dynamic v) {
    final s = v?.toString();
    if (s == null || s.isEmpty || s.toLowerCase() == 'string') return null;
    return s;
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime _date(dynamic v) {
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}
