import 'package:dio/dio.dart';
import 'dart:developer' as dev;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:ehnama3ak/core/network/dio_client.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_models.dart';
import 'package:ehnama3ak/screens_app/chatbot/chat_message.dart';

/// Represents the full response from the /chat API endpoint.
class ChatApiResponse {
  final String message;
  final String? emotion;
  final double? confidence;
  final String? aiModel;
  final String? language;

  ChatApiResponse({
    required this.message,
    this.emotion,
    this.confidence,
    this.aiModel,
    this.language,
  });

  factory ChatApiResponse.fromJson(Map<String, dynamic> json) {
    return ChatApiResponse(
      message: json['message']?.toString() ?? '',
      emotion: json['emotion']?.toString(),
      confidence: (json['confidence'] as num?)?.toDouble(),
      aiModel: json['ai']?.toString(),
      language: json['language']?.toString(),
    );
  }
}

class ChatService {
  final DioClient _dioClient;
  final Dio _emotionDio;
  static const String _emotionBaseUrl =
      "https://ahmed-hamed-emotion-api-2.hf.space";

  ChatService(this._dioClient)
      : _emotionDio = Dio(BaseOptions(
          baseUrl: _emotionBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
          },
        )) {
    _emotionDio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => dev.log(o.toString(), name: 'EmotionService'),
    ));
  }

  // --- Session Management Endpoints ---

  Future<PaginatedResponse<ChatSession>> getSessions({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/DepoChat/sessions',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return PaginatedResponse.fromJson(
        response.data,
        (item) => ChatSession.fromJson(item),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ChatSession> createSession(String title) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/DepoChat/sessions',
        data: {'title': title},
      );
      return ChatSession.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PaginatedResponse<ChatMessage>> getSessionMessages(int sessionId, {int page = 1, int pageSize = 30}) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/DepoChat/sessions/$sessionId',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      
      // Map the backend items to ChatMessage
      final items = (response.data['items'] as List?)?.map((item) {
        final message = item['message'] ?? item['Message'] ?? '';
        final sender = (item['sender'] ?? item['Sender'])?.toString().toLowerCase() ?? '';
        final createdAt = item['createdAt'] ?? item['CreatedAt'];
        final messageType = item['messageType'] ?? item['MessageType'] ?? 1;
        String? attachmentUrl = item['attachmentUrl'] ?? item['AttachmentUrl'];
        if (attachmentUrl != null && !attachmentUrl.startsWith('http')) {
          attachmentUrl = 'http://e7nama3ak.runasp.net$attachmentUrl';
        }

        return ChatMessage(
          message: message,
          isUser: sender == 'patient',
          timestamp: DateTime.parse(createdAt ?? DateTime.now().toIso8601String()),
          imagePath: messageType == 1 ? attachmentUrl : null,
          audioPath: messageType == 2 ? attachmentUrl : null,
          emotion: item['emotion'] ?? item['Emotion'],
        );
      }).toList() ?? [];

      return PaginatedResponse<ChatMessage>(
        items: items,
        totalCount: response.data['totalCount'] ?? 0,
        page: response.data['page'] ?? 1,
        pageSize: response.data['pageSize'] ?? 30,
        totalPages: response.data['totalPages'] ?? 0,
        hasNextPage: response.data['hasNextPage'] ?? false,
        hasPreviousPage: response.data['hasPreviousPage'] ?? false,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteSession(int sessionId) async {
    try {
      await _dioClient.dio.delete('/api/DepoChat/sessions/$sessionId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> saveMessage({
    required int sessionId,
    required String message,
    required String sender,
    required int messageType,
    String? attachmentPath,
    String? emotion,
  }) async {
    try {
      final map = <String, dynamic>{
        'Message': message,
        'Sender': sender,
        'MessageType': messageType,
      };
      
      if (emotion != null) {
        map['Emotion'] = emotion;
      }

      if (attachmentPath != null && attachmentPath.isNotEmpty) {
        final ext = attachmentPath.split('.').last.toLowerCase();
        final mimeType = _getMimeType(ext);
        map['Attachment'] = await MultipartFile.fromFile(
          attachmentPath,
          filename: 'attachment.$ext',
          contentType: MediaType(mimeType.split('/').first, mimeType.split('/').last),
        );
      }

      final formData = FormData.fromMap(map);

      final response = await _dioClient.dio.post(
        '/api/DepoChat/sessions/$sessionId/save',
        data: formData,
      );
      dev.log('Save Message Success: Session $sessionId, Status: ${response.statusCode}', name: 'ChatService');
    } on DioException catch (e) {
      dev.log('Save Message Failed: Session $sessionId, Error: ${e.message}', name: 'ChatService');
      throw _handleError(e);
    }
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'png': return 'image/png';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'mp3': return 'audio/mpeg';
      case 'wav': return 'audio/wav';
      default: return 'application/octet-stream';
    }
  }

  // --- AI / Emotion API Endpoints ---

  Future<ChatApiResponse> sendMultimodalMessage({
    String? text,
    String? imagePath,
    String? audioPath,
  }) async {
    dev.log('Sending message to /chat: text=$text, image=$imagePath, audio=$audioPath', name: 'ChatService');

    try {
      final map = <String, dynamic>{};
      if (text != null && text.isNotEmpty) {
        map['text'] = text;
      }
      
      if (imagePath != null && imagePath.isNotEmpty) {
        final ext = imagePath.split('.').last.toLowerCase();
        final mimeType = ext == 'png' ? 'png' : 'jpeg';
        map['image'] = await MultipartFile.fromFile(
          imagePath,
          filename: 'image_message.$ext',
          contentType: MediaType('image', mimeType),
        );
      }
      
      if (audioPath != null && audioPath.isNotEmpty) {
        final ext = audioPath.split('.').last.toLowerCase();
        final mimeType = ext == 'mp3' ? 'mpeg' : 'wav';
        map['audio'] = await MultipartFile.fromFile(
          audioPath,
          filename: 'voice_message.$ext',
          contentType: MediaType('audio', mimeType),
        );
      }

      final formData = FormData.fromMap(map);

      final response = await _emotionDio.post(
        '/chat',
        data: formData,
      );
      dev.log('Response received: ${response.data}', name: 'ChatService');
      
      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<ChatApiResponse> sendMessage(String message) async {
    return sendMultimodalMessage(text: message);
  }

  Future<ChatApiResponse> sendVoiceMessage(String filePath) async {
    return sendMultimodalMessage(audioPath: filePath);
  }

  Future<ChatApiResponse> sendImageMessage(String imagePath, {String? text}) async {
    return sendMultimodalMessage(imagePath: imagePath, text: text);
  }

  ChatApiResponse _parseResponse(dynamic data) {
    var decodedData = data;
    if (decodedData is String) {
      try {
        decodedData = jsonDecode(decodedData);
      } catch (_) {}
    }

    if (decodedData is Map) {
      final msg = decodedData['message']?.toString() ?? 
                  decodedData['response']?.toString() ?? 
                  decodedData['text']?.toString() ?? 
                  '';
      
      if (msg.isNotEmpty) {
        return ChatApiResponse(
          message: msg,
          emotion: decodedData['emotion']?.toString(),
          confidence: (decodedData['confidence'] as num?)?.toDouble(),
          aiModel: decodedData['ai']?.toString(),
          language: decodedData['language']?.toString(),
        );
      }
      return ChatApiResponse(message: 'No response content');
    }
    return ChatApiResponse(message: data.toString());
  }

  Exception _handleError(dynamic error) {
    dev.log('Error: $error', name: 'ChatService', error: error);
    if (error is DioException) {
      dev.log('Dio response: ${error.response?.data}', name: 'ChatService');
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timed out. Please try again.');
        case DioExceptionType.connectionError:
          return Exception('Network error. Please check your internet.');
        default:
          final serverMsg = error.response?.data is Map
              ? (error.response?.data['detail'] ??
                  error.response?.data['message'])
              : null;
          return Exception(
              serverMsg ?? 'Server error: ${error.response?.statusCode ?? 'Unknown'}');
      }
    }
    return Exception('Something went wrong');
  }
}

