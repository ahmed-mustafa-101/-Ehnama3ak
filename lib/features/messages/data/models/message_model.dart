/// MessageType mirrors backend: 0=text, 1=image, 2=voice, 3=file
enum MessageType { text, image, voice, file }

/// Represents a single chat message from the API.
class MessageModel {
  final int id;
  final String senderId;
  final String receiverId;
  final String message;       // text content or filename for non-text
  final int messageTypeRaw;   // raw int from API
  final String? attachmentUrl;
  final String? attachmentName;
  final bool isPinned;
  final bool isRead;
  final DateTime sentAt;

  static const String _baseUrl = 'http://e7nama3ak.runasp.net';

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.messageTypeRaw,
    this.attachmentUrl,
    this.attachmentName,
    required this.isPinned,
    required this.isRead,
    required this.sentAt,
  });

  MessageType get type {
    if (messageTypeRaw >= 0 && messageTypeRaw < MessageType.values.length) {
      return MessageType.values[messageTypeRaw];
    }
    return MessageType.text;
  }

  bool get isText  => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isVoice => type == MessageType.voice;
  bool get isFile  => type == MessageType.file;

  /// Returns the full URL for attachment (prepends base if relative path).
  String get fullAttachmentUrl {
    if (attachmentUrl == null || attachmentUrl!.isEmpty) return '';
    if (attachmentUrl!.startsWith('http')) return attachmentUrl!;
    return '$_baseUrl$attachmentUrl';
  }

  bool isMine(String currentUserId) => senderId == currentUserId;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: _i(json['id']),
      senderId: _s(json['senderId']),
      receiverId: _s(json['receiverId']),
      message: _s(json['message'] ?? json['content'] ?? ''),
      messageTypeRaw: _i(json['messageType']),
      attachmentUrl: _ns(json['attachmentUrl']),
      attachmentName: _ns(json['attachmentName']),
      isPinned: json['isPinned'] == true,
      isRead: json['isRead'] == true || json['read'] == true,
      sentAt: _dt(json['sentAt'] ?? json['createdAt'] ?? json['timestamp']),
    );
  }

  MessageModel copyWith({bool? isPinned, bool? isRead}) => MessageModel(
        id: id,
        senderId: senderId,
        receiverId: receiverId,
        message: message,
        messageTypeRaw: messageTypeRaw,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
        isPinned: isPinned ?? this.isPinned,
        isRead: isRead ?? this.isRead,
        sentAt: sentAt,
      );

  static String _s(dynamic v) => v?.toString() ?? '';
  static String? _ns(dynamic v) {
    final s = v?.toString();
    if (s == null || s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  static int _i(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static DateTime _dt(dynamic v) {
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}
