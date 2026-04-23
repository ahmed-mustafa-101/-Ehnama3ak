import 'package:dio/dio.dart';
import 'dart:developer' as dev;
import 'package:ehnama3ak/core/storage/pref_manager.dart';

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
      "https://8080-01kpfza2ykbgwssk6yhydnk5ac.cloudspaces.litng.ai";

  ChatService()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
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
    double? analyzeConfidence;
    String? analyzeLanguage;

    try {
      final fetchedId = await PrefManager.getUserId();
      if (fetchedId != null && fetchedId.isNotEmpty) {
        userId = fetchedId;
      }
      dev.log('Sending text to /analyze: $message', name: 'ChatService');
      final analyzeRes = await _dio.post('/analyze', data: {'text': message});
      dev.log('Analyze response: ${analyzeRes.data}', name: 'ChatService');
      if (analyzeRes.data != null && analyzeRes.data is Map<String, dynamic>) {
        emotion = analyzeRes.data['emotion']?.toString() ??
                  analyzeRes.data['label']?.toString() ??
                  analyzeRes.data['sentiment']?.toString() ??
                  "string";
        analyzeConfidence = (analyzeRes.data['confidence'] as num?)?.toDouble();
        analyzeLanguage = analyzeRes.data['language']?.toString();
      } else if (analyzeRes.data is String) {
        emotion = analyzeRes.data as String;
      }
    } catch (e) {
      dev.log('Analyze error: $e', name: 'ChatService');
    }

    try {
      final response = await _dio.post(
        '/chat',
        data: {
          'text': message,
          'emotion': emotion,
          'user_id': userId,
        },
      );
      dev.log('Response received: ${response.data}', name: 'ChatService');
      
      final parsedResponse = _parseResponse(response.data);
      
      return ChatApiResponse(
        message: parsedResponse.message,
        emotion: parsedResponse.emotion ?? emotion,
        confidence: parsedResponse.confidence ?? analyzeConfidence,
        aiModel: parsedResponse.aiModel,
        language: parsedResponse.language ?? analyzeLanguage,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  ChatApiResponse _parseResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final msg = data['message']?.toString() ?? '';
      if (msg.isNotEmpty) {
        return ChatApiResponse.fromJson(data);
      }
      // Fallback: try other common keys
      final fallback = data['response']?.toString() ??
          data['result']?.toString() ??
          'No response content';
      return ChatApiResponse(message: fallback);
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
