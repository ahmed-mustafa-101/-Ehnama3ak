import 'package:dio/dio.dart';
import 'package:ehnama3ak/core/storage/secure_token_storage.dart';

/// Shared Dio client with auth interceptor for authenticated API calls.
class DioClient {
  static const String baseUrl = 'http://e7nama3ak.runasp.net';

  late final Dio _dio;
  final SecureTokenStorage _tokenStorage;

  DioClient({required SecureTokenStorage tokenStorage})
      : _tokenStorage = tokenStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    )
      ..interceptors.add(_AuthInterceptor(_tokenStorage))
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

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final SecureTokenStorage _tokenStorage;

  _AuthInterceptor(this._tokenStorage);

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
}
