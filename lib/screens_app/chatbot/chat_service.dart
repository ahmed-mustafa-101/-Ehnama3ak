import 'package:dio/dio.dart';
import 'dart:developer' as dev;
import 'dart:convert';
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
      "https://ahmed-hamed-emotion-api-2.hf.space";

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
    dev.log('Sending message to /predict: $message', name: 'ChatService');

    try {
      final formData = FormData.fromMap({
        'text': message,
        'audio': '',
      });

      final response = await _dio.post(
        '/predict',
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
    dev.log('Sending voice message to /predict: $filePath', name: 'ChatService');

    try {
      final formData = FormData.fromMap({
        'text': '',
        'audio': await MultipartFile.fromFile(
          filePath,
          filename: 'voice_message.wav',
          contentType: MediaType('audio', 'wav'),
        ),
      });

      final response = await _dio.post(
        '/predict',
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
