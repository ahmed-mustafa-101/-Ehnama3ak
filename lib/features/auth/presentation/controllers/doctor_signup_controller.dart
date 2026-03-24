import 'package:ehnama3ak/core/models/user_role.dart';
import 'package:ehnama3ak/core/storage/pref_manager.dart';
import 'package:ehnama3ak/features/auth/data/models/doctor_signup_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'doctor_signup_state.dart';

class DoctorSignupCubit extends Cubit<DoctorSignupState> {
  DoctorSignupCubit() : super(const DoctorSignupInitial());

  void nextStep() {
    emit(const DoctorSignupInitial(currentStep: 2));
  }

  void previousStep() {
    emit(const DoctorSignupInitial(currentStep: 1));
  }

  Future<void> signupDoctor(DoctorSignupRequest request) async {
    emit(const DoctorSignupLoading(currentStep: 2));

    try {
      // Placeholder for actual signup logic
      // AuthController.signupDoctor(request)
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      // Save role as doctor to distinguish in MainLayout
      await PrefManager.setUserRole(UserRole.doctor);
      await PrefManager.saveToken("doctor_mock_token"); // Mock token to allow app entry
      await PrefManager.setUserId("doctor_id_1");

      print('Signup successful for: ${request.email}');
      emit(DoctorSignupSuccess());
    } catch (e) {
      emit(DoctorSignupError(e.toString(), currentStep: 2));
    }
  }
}
