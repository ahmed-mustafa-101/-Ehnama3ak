import 'package:dio/dio.dart';
import '../../models/doctor_patient_model.dart';
import 'dart:developer';

class DoctorPatientsApiService {
  final Dio _dio;

  DoctorPatientsApiService({required Dio dio}) : _dio = dio;

  /// GET all doctor patients
  Future<List<DoctorPatientModel>> getDoctorPatients() async {
    return _fetchPatients('/api/DoctorPatients');
  }

  /// GET search doctor patients
  Future<List<DoctorPatientModel>> searchDoctorPatients(String query) async {
    return _fetchPatients(
      '/api/DoctorPatients/search',
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
        return data
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
          return items
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
