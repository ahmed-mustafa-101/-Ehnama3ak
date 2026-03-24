import 'package:equatable/equatable.dart';
import 'package:ehnama3ak/models/doctor_session_model.dart';

abstract class DoctorSessionsState extends Equatable {
  const DoctorSessionsState();

  @override
  List<Object?> get props => [];
}

class DoctorSessionsInitial extends DoctorSessionsState {}

class DoctorSessionsLoading extends DoctorSessionsState {}

class DoctorSessionsLoaded extends DoctorSessionsState {
  final List<DoctorSessionModel> sessions;
  const DoctorSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class DoctorSessionsError extends DoctorSessionsState {
  final String message;
  const DoctorSessionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class DoctorSessionCreating extends DoctorSessionsState {}

class DoctorSessionCreateSuccess extends DoctorSessionsState {}

class DoctorSessionCreateError extends DoctorSessionsState {
  final String message;
  const DoctorSessionCreateError(this.message);

  @override
  List<Object?> get props => [message];
}
