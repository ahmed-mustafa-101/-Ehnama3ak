import 'package:dio/dio.dart';
import 'dart:developer' as dev;
import 'dart:convert';
import 'package:ehnama3ak/core/storage/pref_manager.dart';
import 'package:http_parser/http_parser.dart';

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
  final Dio _dio;
  static const String _baseUrl =
      "https://8000-01kq25s44a7bqzmb6716gx7773.cloudspaces.litng.ai";

  ChatService()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
          },
        )) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => dev.log(o.toString(), name: 'ChatService'),
    ));
  }

  Future<ChatApiResponse> sendMessage(String message) async {
    dev.log('Sending message to /chat: $message', name: 'ChatService');

    String emotion = "string";
    String userId = "default";

    try {
      final fetchedId = await PrefManager.getUserId();
      if (fetchedId != null && fetchedId.isNotEmpty) {
        userId = fetchedId;
      }
    } catch (e) {
      dev.log('Error fetching userId: $e', name: 'ChatService');
    }

    try {
      final formData = FormData.fromMap({
        'input_type': 'string',
        'text': message,
        'emotion': emotion,
        'user_id': userId,
      });

      final response = await _dio.post(
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

  Future<ChatApiResponse> sendVoiceMessage(String filePath) async {
    dev.log('Sending voice message to /chat: $filePath', name: 'ChatService');

    String userId = "default";
    try {
      final fetchedId = await PrefManager.getUserId();
      if (fetchedId != null && fetchedId.isNotEmpty) {
        userId = fetchedId;
      }
    } catch (e) {}

    try {
      final formData = FormData.fromMap({
        'input_type': 'audio',
        'text': '',
        'emotion': 'string',
        'user_id': userId,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: 'voice_message.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      });

      final response = await _dio.post(
        '/chat',
        data: formData,
      );

      dev.log('Voice response received: ${response.data}', name: 'ChatService');
      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  ChatApiResponse _parseResponse(dynamic data) {
    var decodedData = data;
    if (decodedData is String) {
      try {
        decodedData = jsonDecode(decodedData);
      } catch (_) {}
    }

    if (decodedData is Map) {
      // Check if 'message' is present directly or nested
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
