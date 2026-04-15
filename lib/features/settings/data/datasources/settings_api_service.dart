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

  Future<void> updateDoctorProfile({
    required String fullName,
    required String specialization,
    required num experienceYears,
    required String bio,
    required num sessionPrice,
  }) async {
    final endpoints = [
      '/api/Doctors/update-profile',
      '/api/Doctor/update-profile',
      '/api/Doctors/Update-Profile',
      '/api/Doctor/Update-Profile',
      '/api/Doctors/profile',
      '/api/Doctor/profile',
      '/api/Settings/doctor-profile',
    ];

    Object? lastError;
    for (final endpoint in endpoints) {
      try {
        print("Attempting doctor profile update at: $endpoint");
        await _dio.put(
          endpoint,
          data: {
            'fullName': fullName,
            'specialization': specialization,
            'experienceYears': experienceYears,
            'bio': bio,
            'sessionPrice': sessionPrice,
          },
        );
        print("Successfully updated doctor profile at: $endpoint");
        return; // Success
      } on DioException catch (e) {
        lastError = e;
        if (e.response?.statusCode == 404) {
          print("404 at $endpoint, trying next variant...");
          continue;
        }
        rethrow;
      } catch (e) {
        lastError = e;
        continue;
      }
    }
    if (lastError != null) throw lastError;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put('/api/Settings/password', data: {
        'currentPassword': currentPassword,
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
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          if (data['errors'] != null) {
            final errors = data['errors'];
            if (errors is Map) {
              return errors.values
                  .map((v) => (v is List) ? v.join('\n') : v.toString())
                  .join('\n');
            }
            return errors.toString();
          }
          return data['message'] ?? 
                 data['Message'] ?? 
                 data['title'] ?? 
                 data['detail'] ?? 
                 'An error occurred (${e.response?.statusCode})';
        }
        return data.toString();
      }
      return e.message ?? 'Connection error';
    }
    return e.toString();
  }
}
