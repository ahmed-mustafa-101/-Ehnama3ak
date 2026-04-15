import 'package:ehnama3ak/screens_app/doctor/dashboard/models/dashboard_stats_model.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/models/medical_report_model.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/models/recent_activity_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/data/datasources/doctor_dashboard_api_service.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/presentation/cubit/doctor_dashboard_state.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/models/upload_models.dart';

class DoctorDashboardCubit extends Cubit<DoctorDashboardState> {
  final DoctorDashboardApiService _apiService;

  DoctorDashboardCubit({required DoctorDashboardApiService apiService})
    : _apiService = apiService,
      super(DoctorDashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DoctorDashboardLoading());
    try {
      final results = await Future.wait([
        _apiService.getStats(),
        _apiService.getRecentActivity(),
        _apiService.getMedicalReports(),
      ]);

      final stats = results[0] as DashboardStatsModel;
      final activity = results[1] as List<RecentActivityModel>;
      final reports = results[2] as List<MedicalReportModel>;

      emit(
        DoctorDashboardSuccess(
          stats: stats,
          recentActivity: activity,
          medicalReports: reports,
        ),
      );
    } on DioException catch (e) {
      _handleErrors(e);
    } catch (e) {
      emit(DoctorDashboardError(message: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> addPatientRecord(AddRecordModel model) async {
    final currentState = state;
    emit(ActionLoading());
    try {
      await _apiService.addRecord(model);
      emit(ActionSuccess('Patient record added successfully'));
      await loadDashboardData();
    } on DioException catch (e) {
      _handleErrors(e);
      if (currentState is DoctorDashboardSuccess) emit(currentState);
    } catch (e) {
      emit(DoctorDashboardError(message: 'Error adding record: $e'));
      if (currentState is DoctorDashboardSuccess) emit(currentState);
    }
  }

  Future<void> loadReports() async {
    final currentState = state;
    if (currentState is! DoctorDashboardSuccess) {
      emit(DoctorDashboardLoading());
    }
    try {
      final stats = currentState is DoctorDashboardSuccess
          ? currentState.stats
          : await _apiService.getStats();
      final activity = currentState is DoctorDashboardSuccess
          ? currentState.recentActivity
          : await _apiService.getRecentActivity();
      final reports = await _apiService.getMedicalReports();

      emit(
        DoctorDashboardSuccess(
          stats: stats,
          recentActivity: activity,
          medicalReports: reports,
        ),
      );
    } on DioException catch (e) {
      _handleErrors(e);
    } catch (e) {
      emit(DoctorDashboardError(message: 'Error loading reports: $e'));
    }
  }

  Future<void> uploadReport(UploadReportModel model) async {
    final currentState = state;
    emit(ActionLoading());
    try {
      await _apiService.uploadReport(model);
      emit(ActionSuccess('Medical report uploaded successfully'));
      await loadReports();
    } on DioException catch (e) {
      _handleErrors(e);
      if (currentState is DoctorDashboardSuccess) emit(currentState);
    } catch (e) {
      emit(DoctorDashboardError(message: 'Error uploading report: $e'));
      if (currentState is DoctorDashboardSuccess) emit(currentState);
    }
  }

  void _handleErrors(DioException e) {
    if (e.response?.statusCode == 401) {
      emit(
        DoctorDashboardError(
          message: 'Unauthorized. Please login again.',
          isUnauthorized: true,
        ),
      );
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      emit(
        DoctorDashboardError(message: 'Connection timeout. Please try again.'),
      );
    } else {
      final detail = e.response?.data?.toString() ?? e.message;
      emit(
        DoctorDashboardError(
          message: 'Server error: ${e.response?.statusCode}\nDetails: $detail',
        ),
      );
    }
  }
}
