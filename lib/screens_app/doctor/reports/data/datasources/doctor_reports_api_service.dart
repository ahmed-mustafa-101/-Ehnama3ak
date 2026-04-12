import 'package:dio/dio.dart';
import '../../models/doctor_report_model.dart';
import 'dart:developer';

class DoctorReportsApiService {
  final Dio _dio;

  DoctorReportsApiService({required Dio dio}) : _dio = dio;

  /// GET all doctor reports
  Future<List<DoctorReportModel>> getDoctorReports() async {
    final variants = [
      '/api/DoctorReports/reports',
      '/api/DoctorReports',
      '/api/DoctorDashboard/medical-reports',
      '/api/DoctorDashboard/reports',
      '/api/Doctor/Reports',
    ];

    Object? lastError;
    for (final endpoint in variants) {
      try {
        log('GET Request to: $endpoint');
        final response = await _dio.get(endpoint);

        log('Response status: ${response.statusCode}');
        log('Response data: ${response.data}');

        final dynamic data = response.data;
        if (data == null) return [];

        if (data is List) {
          return data
              .map((json) => DoctorReportModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }

        if (data is Map) {
          final dynamic items = data['items'] ?? data['data'] ?? data['reports'];
          if (items is List) {
            return items
                .map((json) => DoctorReportModel.fromJson(Map<String, dynamic>.from(json)))
                .toList();
          }
        }
        return [];
      } on DioException catch (e) {
        lastError = e;
        if (e.response?.statusCode == 404) continue;
        rethrow;
      } catch (e) {
        lastError = e;
        continue;
      }
    }
    throw lastError ?? Exception('Failed to load reports');
  }
}
