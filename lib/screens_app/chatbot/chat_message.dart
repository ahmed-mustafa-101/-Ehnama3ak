class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  // Fields from the /chat API response (null for user messages)
  final String? emotion;
  final double? confidence;
  final String? aiModel;
  final String? language;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.emotion,
    this.confidence,
    this.aiModel,
    this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      if (emotion != null) 'emotion': emotion,
      if (confidence != null) 'confidence': confidence,
      if (aiModel != null) 'ai': aiModel,
      if (language != null) 'language': language,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      emotion: json['emotion'],
      confidence: (json['confidence'] as num?)?.toDouble(),
      aiModel: json['ai'],
      language: json['language'],
    );
  }
}
