import 'package:ehnama3ak/screens_app/doctor/dashboard/models/dashboard_stats_model.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/models/recent_activity_model.dart';
import 'package:ehnama3ak/screens_app/doctor/dashboard/models/medical_report_model.dart';

abstract class DoctorDashboardState {}

class DoctorDashboardInitial extends DoctorDashboardState {}

class DoctorDashboardLoading extends DoctorDashboardState {}

class DoctorDashboardSuccess extends DoctorDashboardState {
  final DashboardStatsModel stats;
  final List<RecentActivityModel> recentActivity;
  final List<MedicalReportModel>? medicalReports;
  DoctorDashboardSuccess({
    required this.stats,
    required this.recentActivity,
    this.medicalReports,
  });
}

class DoctorDashboardError extends DoctorDashboardState {
  final String message;
  final bool isUnauthorized;
  DoctorDashboardError({required this.message, this.isUnauthorized = false});
}

class ActionLoading extends DoctorDashboardState {}

class ActionSuccess extends DoctorDashboardState {
  final String message;
  ActionSuccess(this.message);
}
