import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:ehnama3ak/screens_app/doctor/dashboard/models/dashboard_stats_model.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/models/recent_activity_model.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/models/medical_report_model.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/models/upload_models.dart';

class DoctorDashboardApiService {
  final Dio _dio;

  DoctorDashboardApiService({required Dio dio}) : _dio = dio;

  Future<DashboardStatsModel> getStats() async {
    try {
      final response = await _dio.get('/api/DoctorDashboard/stats');
      return DashboardStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      log('DioError getting dashboard stats: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error getting dashboard stats: $e');
      rethrow;
    }
  }

  Future<List<RecentActivityModel>> getRecentActivity() async {
    try {
      final response = await _dio.get('/api/DoctorDashboard/recent-activity');
      if (response.data is List) {
        return (response.data as List)
            .map((e) => RecentActivityModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      log('DioError getting recent activity: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error getting recent activity: $e');
      rethrow;
    }
  }

  Future<void> addRecord(AddRecordModel model) async {
    try {
      await _dio.post('/api/DoctorDashboard/add-record', data: model.toJson());
    } on DioException catch (e) {
      log('DioError adding patient record: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error adding patient record: $e');
      rethrow;
    }
  }

  Future<List<MedicalReportModel>> getMedicalReports() async {
    final endpoints = [
      '/api/DoctorDashboard/medical-reports',
      '/api/DoctorReports',
      '/api/DoctorReports/reports',
      '/api/DoctorDashboard/reports',
    ];

    Object? lastError;
    for (final endpoint in endpoints) {
      try {
        final response = await _dio.get(endpoint);
        if (response.data is List) {
          return (response.data as List)
              .map((e) => MedicalReportModel.fromJson(e))
              .toList();
        }
        if (response.data is Map) {
          final dynamic items = response.data['items'] ?? response.data['data'] ?? response.data['reports'];
          if (items is List) {
            return items.map((e) => MedicalReportModel.fromJson(e)).toList();
          }
        }
        return [];
      } on DioException catch (e) {
        lastError = e;
        log('Error hitting $endpoint: ${e.response?.statusCode}');
        if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
          continue;
        }
        rethrow;
      } catch (e) {
        lastError = e;
        continue;
      }
    }
    log('All medical reports endpoints failed. Last error: $lastError');
    return [];
  }

  Future<void> uploadReport(UploadReportModel model) async {
    try {
      await _dio.post(
        '/api/DoctorReports',
        data: {
          'patientId': model.patientId,
          'type': model.type,
          'fileUrl': model.fileUrl,
        },
      );
    } on DioException catch (e) {
      log('DioError uploading medical report: ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      log('Error uploading medical report: $e');
      rethrow;
    }
  }
}
