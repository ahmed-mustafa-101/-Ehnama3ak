class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      content: json['content']?.toString() ?? json['message'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isRead: json['isRead'] == true || json['read'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  bool isMine(String currentUserId) => senderId == currentUserId;
}
