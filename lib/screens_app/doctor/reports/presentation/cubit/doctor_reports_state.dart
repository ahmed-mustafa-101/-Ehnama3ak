import 'package:equatable/equatable.dart';
import '../../models/doctor_report_model.dart';

abstract class DoctorReportsState extends Equatable {
  const DoctorReportsState();

  @override
  List<Object?> get props => [];
}

class DoctorReportsInitial extends DoctorReportsState {}

class DoctorReportsLoading extends DoctorReportsState {}

class DoctorReportsLoaded extends DoctorReportsState {
  final List<DoctorReportModel> reports;
  const DoctorReportsLoaded(this.reports);

  @override
  List<Object?> get props => [reports];
}

class DoctorReportsError extends DoctorReportsState {
  final String message;
  const DoctorReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
