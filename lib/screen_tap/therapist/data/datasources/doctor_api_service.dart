import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:ehnama3ak/screen_tap/therapist/models/doctor_model.dart';
import 'package:ehnama3ak/screen_tap/therapist/models/book_session_model.dart';

class DoctorApiService {
  final Dio _dio;
  
  DoctorApiService({required Dio dio}) : _dio = dio;

  Future<List<DoctorModel>> getDoctors() async {
    try {
      final response = await _dio.get('/api/Doctors');
      if (response.data is List) {
        return (response.data as List).map((e) => DoctorModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      log('DioError getting doctors: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error getting doctors: $e');
      rethrow;
    }
  }

  Future<List<DoctorModel>> searchDoctors(String query) async {
    try {
      final response = await _dio.get('/api/Doctors/search', queryParameters: {'name': query});
      if (response.data is List) {
        return (response.data as List).map((e) => DoctorModel.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      log('DioError searching doctors: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error searching doctors: $e');
      rethrow;
    }
  }

  Future<void> bookSession(int doctorId, String sessionDate, String sessionType) async {
    try {
      final model = BookSessionModel(
        doctorId: doctorId,
        sessionDate: sessionDate,
        sessionType: sessionType,
      );
      await _dio.post('/api/Doctors/book-session', data: model.toJson());
    } on DioException catch (e) {
      log('DioError booking session: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error booking session: $e');
      rethrow;
    }
  }
}
