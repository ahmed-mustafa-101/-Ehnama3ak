import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ehnama3ak/core/storage/secure_token_storage.dart';
import '../models/auth_response_model.dart';

class AuthApiService {
  static const String _baseUrl = 'http://e7nama3ak.runasp.net';

  late final Dio _dio;
  final SecureTokenStorage _tokenStorage;
  final VoidCallback? onTokenExpired;

  AuthApiService({
    SecureTokenStorage? tokenStorage,
    this.onTokenExpired,
  }) : _tokenStorage = tokenStorage ?? SecureTokenStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    )
      ..interceptors.add(_AuthInterceptor(_tokenStorage, onTokenExpired))
      ..interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
  }

  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _dio.post(
      '/api/Auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? specialization,
    int? yearsOfExperience,
  }) async {
    final data = <String, dynamic>{
      'FullName': name,
      'email': email,
      'password': password,
      'role': role,
    };
    if (specialization != null && specialization.isNotEmpty) {
      data['specialization'] = specialization;
      // بعض الـ APIs تتوقع PascalCase
      data['Specialization'] = specialization;
    }
    if (yearsOfExperience != null && yearsOfExperience >= 0) {
      data['yearsOfExperience'] = yearsOfExperience;
      // توافق مع موديلات تستخدم yearsExperience أو PascalCase
      data['yearsExperience'] = yearsOfExperience;
      data['YearsOfExperience'] = yearsOfExperience;
    }

    final response = await _dio.post('/api/Auth/register', data: data);
    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> updateProfileImage(String imagePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });

    final response = await _dio.post(
      '/api/Auth/update-profile-image',
      data: formData,
    );
    return AuthResponseModel.fromJson(response.data);
  }

  static String parseApiError(dynamic error) {

    if (error is DioException) {
      if (error.response != null &&
          error.response?.data != null &&
          error.response!.data.toString().isNotEmpty) {
        final data = error.response!.data;
        try {
          if (data is List) {
            return data.map((e) => e.toString()).join('\n');
          }
          if (data is Map) {
            if (data['errors'] != null) {
              final errors = data['errors'];
              if (errors is Map) {
                return errors.values
                    .map((v) {
                      if (v is List) return v.join('\n');
                      return v.toString();
                    })
                    .join('\n');
              }
              return errors.toString();
            }
            if (data['message'] != null) return data['message'].toString();
            if (data['Message'] != null) return data['Message'].toString();
            if (data['title'] != null) {
              String title = data['title'].toString();
              if (data['detail'] != null) {
                title += '\n${data['detail']}';
              }
              return title;
            }
            final values = data.values.where((v) => v is String).join('\n');
            if (values.isNotEmpty) return values;
          }
          return data.toString();
        } catch (_) {
          return data.toString();
        }
      }
      if (error.response?.statusCode == 401) {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      }
      if (error.response?.statusCode == 500) {
        return 'خطأ في السيرفر. يرجى المحاولة لاحقاً';
      }
      return error.message ?? 'خطأ في الاتصال. تحقق من الإنترنت';
    }
    return error.toString();
  }
}

/// Interceptor that attaches JWT token to requests and handles 401
class _AuthInterceptor extends Interceptor {
  final SecureTokenStorage _tokenStorage;
  final VoidCallback? onTokenExpired;

  _AuthInterceptor(this._tokenStorage, this.onTokenExpired);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _tokenStorage.clearAll();
      onTokenExpired?.call();
    }
    handler.next(err);
  }
}
