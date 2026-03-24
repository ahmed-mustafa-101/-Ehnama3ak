
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://e7na-ma3ak-test.runasp.net',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  print('--- Testing POST /api/Posts/add-comment ---');
  try {
    // Attempting common field names for comments
    final response = await dio.post('/api/Posts/add-comment', data: {
      'postId': 1, // Example ID
      'content': 'Test comment',
      'userId': 'test_user'
    });
    print('Status: ${response.statusCode}');
    print('Response: ${response.data}');
  } on DioException catch (e) {
    print('Error Status: ${e.response?.statusCode}');
    print('Error Data: ${e.response?.data}');
  }
}
