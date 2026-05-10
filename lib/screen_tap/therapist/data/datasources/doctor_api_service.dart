import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:ehnama3ak/screen_tap/therapist/models/doctor_model.dart';
import 'package:ehnama3ak/screen_tap/therapist/models/book_session_model.dart';

class DoctorApiService {
  final Dio _dio;

  DoctorApiService({required Dio dio}) : _dio = dio;

  Future<List<DoctorModel>> getDoctors() async {
    final variants = [
      '/api/Doctors',
      '/api/Doctors/all',
      '/api/Users?role=Doctor',
    ];
    Object? lastError;

    for (var endpoint in variants) {
      try {
        log('Attempting to fetch doctors from: $endpoint');
        final response = await _dio.get(endpoint);
        final data = response.data;

        if (data == null) {
          log('Data is null for $endpoint');
          continue;
        }

        log('Data type for $endpoint: ${data.runtimeType}');

        if (data is List) {
          log('Found List with ${data.length} items');
          return data.map((e) => DoctorModel.fromJson(_toMap(e))).toList();
        }

        if (data is Map) {
          log('Found Map with keys: ${data.keys.toList()}');
          final items =
              data['items'] ??
              data['data'] ??
              data['doctors'] ??
              data['doctorsList'] ??
              data['results'];
          if (items is List) {
            log('Found List in map with ${items.length} items');
            return items.map((e) => DoctorModel.fromJson(_toMap(e))).toList();
          }
          // If the map itself is a doctor
          if (data.containsKey('id') || data.containsKey('name')) {
            return [DoctorModel.fromJson(_toMap(data))];
          }
        }
      } on DioException catch (e) {
        lastError = e;
        log('DioError at $endpoint: ${e.response?.statusCode}');
        if (e.response?.statusCode == 404) continue;
        rethrow;
      } catch (e) {
        lastError = e;
        log('Unexpected error at $endpoint: $e');
        continue;
      }
    }
    return [];
  }

  Map<String, dynamic> _toMap(dynamic e) {
    if (e is Map) {
      final map = Map<String, dynamic>.from(e);
      // DEBUG: log all keys so we can identify the GUID userId field
      log('[DoctorApiService] doctor keys: ${map.keys.toList()}');
      log('[DoctorApiService] doctor data: $map');
      return map;
    }
    return {};
  }

  Future<List<DoctorModel>> searchDoctors(String query) async {
    try {
      log('Searching doctors with query: $query');
      final response = await _dio.get(
        '/api/Doctors/search',
        queryParameters: {'name': query},
      );
      final data = response.data;

      if (data is List) {
        return data.map((e) => DoctorModel.fromJson(_toMap(e))).toList();
      }
      if (data is Map) {
        final items =
            data['items'] ?? data['data'] ?? data['doctors'] ?? data['results'];
        if (items is List) {
          return items.map((e) => DoctorModel.fromJson(_toMap(e))).toList();
        }
      }
      return [];
    } catch (e) {
      log('Error searching doctors: $e');
      // If search fails, maybe try local filtering if possible or just return empty
      return [];
    }
  }

  Future<void> bookSession(
    int doctorId,
    String sessionDate,
    String sessionType,
  ) async {
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
