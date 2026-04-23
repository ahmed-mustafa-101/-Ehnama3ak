import 'package:ehnama3ak/features/auth/data/models/auth_response_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login(String email, String password);

  Future<AuthResponseModel> registerPatient(
    String name,
    String email,
    String password,
    String confirmPassword, {
    String? nationalNumber,
    String? bio,
  });

  Future<AuthResponseModel> registerDoctor(
    String name,
    String email,
    String password,
    String confirmPassword,
    String specialization,
    int yearsOfExperience, {
    String? nationalNumber,
    String? bio,
  });

  Future<AuthResponseModel?> getCurrentSession();

  Future<void> logout();

  Future<AuthResponseModel> updateProfileImage(String imagePath);

  Future<void> updateDoctorProfileLocally({
    required String name,
    required String specialization,
    required int yearsOfExperience,
    String? bio,
    double? sessionPrice,
  });

  Future<void> forgotPassword(String email);
  
  Future<void> resetPassword(String email, String code, String newPassword);
}

