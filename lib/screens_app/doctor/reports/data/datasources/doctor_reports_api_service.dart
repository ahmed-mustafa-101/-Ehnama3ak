import 'package:dio/dio.dart';
import '../../models/doctor_report_model.dart';
import 'dart:developer';

class DoctorReportsApiService {
  final Dio _dio;

  DoctorReportsApiService({required Dio dio}) : _dio = dio;

  /// GET all doctor reports
  Future<List<DoctorReportModel>> getDoctorReports() async {
    try {
      log('GET Request to: /api/DoctorReports');
      final response = await _dio.get('/api/DoctorReports');

      log('Response status: ${response.statusCode}');
      log('Response data: ${response.data}');

      final dynamic data = response.data;

      if (data == null) return [];

      // Handle direct List response
      if (data is List) {
        return data
            .map(
              (json) =>
                  DoctorReportModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();
      }

      // Handle response containing 'data' or 'items' keys
      if (data is Map) {
        final dynamic items = data['items'] ?? data['data'] ?? data['reports'];
        if (items is List) {
          return items
              .map(
                (json) =>
                    DoctorReportModel.fromJson(Map<String, dynamic>.from(json)),
              )
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      log(
        'DioError in getDoctorReports: ${e.response?.statusCode} - ${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      log('General Error in getDoctorReports: $e');
      rethrow;
    }
  }
}
