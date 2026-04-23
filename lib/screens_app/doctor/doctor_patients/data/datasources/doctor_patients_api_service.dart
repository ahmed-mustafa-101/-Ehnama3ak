import 'package:dio/dio.dart';
import '../../models/doctor_patient_model.dart';
import 'dart:developer';

class DoctorPatientsApiService {
  final Dio _dio;

  DoctorPatientsApiService({required Dio dio}) : _dio = dio;

  /// GET all doctor patients
  Future<List<DoctorPatientModel>> getDoctorPatients() async {
    final variants = [
      '/api/DoctorDashboard/patients',
      '/api/DoctorPatients/patients',
      '/api/DoctorPatients',
      '/api/Doctor/Patients',
    ];

    Object? lastError;
    for (final endpoint in variants) {
      try {
        return await _fetchPatients(endpoint);
      } on DioException catch (e) {
        lastError = e;
        if (e.response?.statusCode == 404) continue;
        rethrow;
      } catch (e) {
        lastError = e;
        continue;
      }
    }
    throw lastError ?? Exception('Failed to load patients');
  }

  /// GET search doctor patients
  Future<List<DoctorPatientModel>> searchDoctorPatients(String query) async {
    return _fetchPatients(
      '/api/DoctorPatients/search-patients',
      queryParameters: {'query': query},
    );
  }

  Future<List<DoctorPatientModel>> _fetchPatients(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      log('GET Request to: $endpoint with params: $queryParameters');
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      log('Response status: ${response.statusCode}');
      log('Response data: ${response.data}');

      final dynamic data = response.data;

      if (data == null) return [];

      // Handle direct List response
      if (data is List) {
        log('Fetching patients, total items: ${data.length}');
        return data
            .where((json) {
              if (json is Map) {
                final role = (json['role'] ?? json['Role'] ?? json['userRole'] ?? json['UserRole'] ?? json['roleName'])?.toString().toLowerCase().trim();
                log('Item role: $role');
                // Only filter out if we are SURE it is a doctor. 
                // In some APIs, patients might have role null or 'patient'.
                return role != 'doctor' && role != 'therapist' && role != 'admin';
              }
              return true;
            })
            .map(
              (json) =>
                  DoctorPatientModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }

      // Handle response containing 'data' or 'items' keys
      if (data is Map) {
        final dynamic items = data['items'] ?? data['data'] ?? data['patients'];
        if (items is List) {
          log('Fetching patients from map, total items: ${items.length}');
          return items
              .where((json) {
                if (json is Map) {
                  final role = (json['role'] ?? json['Role'] ?? json['userRole'] ?? json['UserRole'] ?? json['roleName'])?.toString().toLowerCase().trim();
                  log('Item role: $role');
                  return role != 'doctor' && role != 'therapist' && role != 'admin';
                }
                return true;
              })
              .map(
                (json) => DoctorPatientModel.fromJson(
                  Map<String, dynamic>.from(json),
                ),
              )
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      log(
        'DioError at $endpoint: ${e.response?.statusCode} - ${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      log('General Error at $endpoint: $e');
      rethrow;
    }
  }
}
