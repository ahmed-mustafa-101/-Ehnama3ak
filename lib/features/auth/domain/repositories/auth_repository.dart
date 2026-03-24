import 'package:ehnama3ak/features/auth/data/models/auth_response_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login(String email, String password);

  Future<AuthResponseModel> registerPatient(
    String name,
    String email,
    String password,
    String confirmPassword,
  );

  Future<AuthResponseModel> registerDoctor(
    String name,
    String email,
    String password,
    String confirmPassword,
    String specialization,
    int yearsOfExperience,
  );

  Future<AuthResponseModel?> getCurrentSession();

  Future<void> logout();

  Future<AuthResponseModel> updateProfileImage(String imagePath);
}

