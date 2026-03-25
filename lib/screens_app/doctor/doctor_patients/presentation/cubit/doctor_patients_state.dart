import 'package:equatable/equatable.dart';
import 'package:ehnama3ak/screens_app/doctor/doctor_patients/models/doctor_patient_model.dart';

abstract class DoctorPatientsState extends Equatable {
  const DoctorPatientsState();

  @override
  List<Object?> get props => [];
}

class DoctorPatientsInitial extends DoctorPatientsState {}

class DoctorPatientsLoading extends DoctorPatientsState {}

class DoctorPatientsSearching extends DoctorPatientsState {}

class DoctorPatientsLoaded extends DoctorPatientsState {
  final List<DoctorPatientModel> patients;
  const DoctorPatientsLoaded(this.patients);

  @override
  List<Object?> get props => [patients];
}

class DoctorPatientsError extends DoctorPatientsState {
  final String message;
  const DoctorPatientsError(this.message);

  @override
  List<Object?> get props => [message];
}
