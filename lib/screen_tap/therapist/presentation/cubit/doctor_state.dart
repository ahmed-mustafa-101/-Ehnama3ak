import 'package:ehnama3ak/screen_tap/therapist/models/doctor_model.dart';

abstract class DoctorState {}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorSuccess extends DoctorState {
  final List<DoctorModel> doctors;
  DoctorSuccess(this.doctors);
}

class DoctorError extends DoctorState {
  final String message;
  final bool isUnauthorized;

  DoctorError({required this.message, this.isUnauthorized = false});
}

class BookSessionLoading extends DoctorState {}

class BookSessionSuccess extends DoctorState {
  final String message;

  BookSessionSuccess(this.message);
}
