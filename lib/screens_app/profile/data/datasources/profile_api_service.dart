import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:ehnama3ak/screens_app/profile/models/profile_model.dart';
import 'package:ehnama3ak/screens_app/profile/models/saved_resource_model.dart';

class ProfileApiService {
  final Dio _dio;

  ProfileApiService({required Dio dio}) : _dio = dio;

  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dio.get('/api/Profile/me');
      log('Profile API full response: ${response.data}');
      return ProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      log('DioError getting profile: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error getting profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    int age = 0,
    String gender = '',
  }) async {
    try {
      await _dio.post(
        '/api/Profile/update-info',
        data: {
          'fullName': fullName,
          'age': age,
          'gender': gender,
        },
      );
    } on DioException catch (e) {
      log('DioError updating profile: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });
      await _dio.post('/api/Profile/upload-avatar', data: formData);
    } on DioException catch (e) {
      log('DioError updating profile image: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error updating profile image: $e');
      rethrow;
    }
  }

  Future<List<SavedResourceModel>> getSavedResources() async {
    try {
      final response = await _dio.get('/api/Profile/saved-resources');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => SavedResourceModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      log('DioError getting saved resources: ${e.response?.statusCode}');
      if (e.response?.statusCode == 404) return [];
      rethrow;
    } catch (e) {
      log('Error getting saved resources: $e');
      rethrow;
    }
  }
}
