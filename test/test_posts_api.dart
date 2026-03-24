
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://e7na-ma3ak-test.runasp.net',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  print('--- Testing POST /api/Posts (JSON) ---');
  try {
    final response = await dio.post('/api/Posts', data: {
      'postText': 'Test post from diagnostic script ${DateTime.now()}',
      // 'postImage': null, // Some backends fail if null is sent explicitly
    });
    print('Status: ${response.statusCode}');
    print('Response: ${response.data}');
  } on DioException catch (e) {
    print('Error Status: ${e.response?.statusCode}');
    print('Error Data: ${e.response?.data}');
  }

  print('\n--- Testing POST /api/Posts (Multipart) ---');
  try {
    final formData = FormData.fromMap({
      'postText': 'Test multipart post ${DateTime.now()}',
    });
    final response = await dio.post('/api/Posts', data: formData);
    print('Status: ${response.statusCode}');
    print('Response: ${response.data}');
  } on DioException catch (e) {
    print('Error Status: ${e.response?.statusCode}');
    print('Error Data: ${e.response?.data}');
  }
}
