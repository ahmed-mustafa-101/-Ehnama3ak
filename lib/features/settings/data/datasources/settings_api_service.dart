import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/settings_models.dart';

class SettingsApiService {
  final Dio _dio;

  SettingsApiService({required DioClient dioClient}) : _dio = dioClient.dio;

  Future<UserSettings> getSettings() async {
    try {
      final response = await _dio.get('/api/Settings');
      print("Settings API Response: ${response.data}");
      return UserSettings.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadAvatar(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });
      await _dio.post('/api/Profile/upload-avatar', data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? profileImagePath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'fullName': name,
        'email': email,
        if (profileImagePath != null)
          'profileImage': await MultipartFile.fromFile(profileImagePath),
      });

      await _dio.put('/api/Settings/profile', data: formData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put('/api/Settings/password', data: {
        'oldPassword': currentPassword,
        'newPassword': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<PrivacyPolicy> getPrivacyPolicy() async {
    try {
      final response = await _dio.get('/api/Settings/privacy');
      return PrivacyPolicy.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<SupportInfo> getSupportInfo() async {
    try {
      final response = await _dio.get('/api/Settings/support');
      return SupportInfo.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  static String parseError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null && e.response?.data is Map) {
        return e.response?.data['message'] ?? e.response?.data['Message'] ?? 'An error occurred';
      }
      return e.message ?? 'Connection error';
    }
    return e.toString();
  }
}
