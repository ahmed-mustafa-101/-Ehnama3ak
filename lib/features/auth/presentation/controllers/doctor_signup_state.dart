import 'package:equatable/equatable.dart';

abstract class DoctorSignupState extends Equatable {
  const DoctorSignupState();

  @override
  List<Object?> get props => [];
}

class DoctorSignupInitial extends DoctorSignupState {
  final int currentStep;
  const DoctorSignupInitial({this.currentStep = 1});

  @override
  List<Object?> get props => [currentStep];
}

class DoctorSignupLoading extends DoctorSignupState {
  final int currentStep;
  const DoctorSignupLoading({required this.currentStep});

  @override
  List<Object?> get props => [currentStep];
}

class DoctorSignupError extends DoctorSignupState {
  final String message;
  final int currentStep;
  const DoctorSignupError(this.message, {required this.currentStep});

  @override
  List<Object?> get props => [message, currentStep];
}

class DoctorSignupSuccess extends DoctorSignupState {}
