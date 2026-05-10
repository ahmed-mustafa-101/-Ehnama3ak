import 'package:ehnama3ak/screens_app/chatbot/chat_message.dart';

class ChatSession {
  final int id;
  final String title;
  final bool isTitleGenerated;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;

  ChatSession({
    required this.id,
    required this.title,
    required this.isTitleGenerated,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      isTitleGenerated: json['isTitleGenerated'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      messageCount: json['messageCount'] ?? 0,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }
}

class SaveMessageResponse {
  final int id;
  final String message;
  final String sender;
  final int messageType;
  final String? attachmentUrl;
  final DateTime createdAt;

  SaveMessageResponse({
    required this.id,
    required this.message,
    required this.sender,
    required this.messageType,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory SaveMessageResponse.fromJson(Map<String, dynamic> json) {
    return SaveMessageResponse(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      sender: json['sender'] ?? '',
      messageType: json['messageType'] ?? 1,
      attachmentUrl: json['attachmentUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  ChatMessage toChatMessage() {
    return ChatMessage(
      message: message,
      isUser: sender.toLowerCase() == 'patient',
      timestamp: createdAt,
      imagePath: messageType == 2 ? attachmentUrl : null, // Assuming 2 is image
      // audioPath can be handled similarly if we know the type
    );
  }
}
