
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://e7na-ma3ak-test.runasp.net',
  ));

  print('--- Testing POST /api/Posts/add-comment (v2) ---');
  try {
    final response = await dio.post('/api/Posts/add-comment', data: {
      'postId': 1,
      'Text': 'Great post!',
      'userId': 'user123'
    });
    print('Status: ${response.statusCode}');
    print('Response: ${response.data}');
  } on DioException catch (e) {
    print('Error Status: ${e.response?.statusCode}');
    print('Error Data: ${e.response?.data}');
  }
}
