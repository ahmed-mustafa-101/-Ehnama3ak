
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://e7na-ma3ak-test.runasp.net',
  ));

  print('--- Testing POST /api/Posts (Multipart with correct fields) ---');
  try {
    final formData = FormData.fromMap({
      'userId': 'test_user_id',
      'content': 'Hello world from diagnostic script',
    });
    final response = await dio.post('/api/Posts', data: formData);
    print('Status: ${response.statusCode}');
    print('Response: ${response.data}');
  } on DioException catch (e) {
    print('Error Status: ${e.response?.statusCode}');
    print('Error Data: ${e.response?.data}');
  }
}
