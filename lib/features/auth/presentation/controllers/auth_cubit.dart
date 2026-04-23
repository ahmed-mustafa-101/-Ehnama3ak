import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_api_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(const AuthInitial());

  /// Check if user has valid token and auto-login
  Future<void> checkAuth() async {
    emit(const AuthLoading());
    try {
      final session = await _repo.getCurrentSession();
      if (session != null && session.token.isNotEmpty) {
        emit(AuthSuccess(session.data));
      } else {
        emit(const AuthLoggedOut());
      }
    } catch (e) {
      emit(const AuthLoggedOut());
    }
  }

  /// Refreshes the user state from storage
  Future<void> reloadUser() async {
    final currentState = state;
    try {
      final session = await _repo.getCurrentSession();
      if (session != null && session.token.isNotEmpty) {
        emit(AuthSuccess(session.data));
      }
    } catch (_) {
      if (currentState is AuthSuccess) {
        emit(AuthSuccess(currentState.user));
      }
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final response = await _repo.login(email.trim(), password);
      emit(AuthSuccess(response.data));
    } catch (e) {
      emit(AuthFailure(AuthApiService.parseApiError(e)));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      await _repo.logout();
      emit(const AuthLoggedOut());
    } catch (e) {
      emit(AuthFailure(AuthApiService.parseApiError(e)));
    }
  }

  Future<void> registerPatient({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? nationalNumber,
    String? bio,
  }) async {
    if (name.trim().isEmpty) {
      emit(const AuthFailure('Name is required'));
      return;
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      emit(const AuthFailure('Invalid email address'));
      return;
    }
    if (password.length < 6) {
      emit(const AuthFailure('Password must be at least 6 characters'));
      return;
    }
    if (password != confirmPassword) {
      emit(const AuthFailure('Passwords do not match'));
      return;
    }

    emit(const AuthLoading());
    try {
      final response = await _repo.registerPatient(
        name.trim(),
        email.trim(),
        password,
        confirmPassword,
        nationalNumber: nationalNumber,
        bio: bio,
      );
      emit(AuthSuccess(response.data));
    } catch (e) {
      emit(AuthFailure(AuthApiService.parseApiError(e)));
    }
  }

  Future<void> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String specialization,
    required int yearsOfExperience,
    String? nationalNumber,
    String? bio,
  }) async {
    if (name.trim().isEmpty) {
      emit(const AuthFailure('Name is required'));
      return;
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      emit(const AuthFailure('Invalid email address'));
      return;
    }
    if (password.length < 6) {
      emit(const AuthFailure('Password must be at least 6 characters'));
      return;
    }
    if (password != confirmPassword) {
      emit(const AuthFailure('Passwords do not match'));
      return;
    }
    if (specialization.trim().isEmpty) {
      emit(const AuthFailure('Specialization is required'));
      return;
    }
    if (yearsOfExperience < 0) {
      emit(const AuthFailure('Invalid years of experience'));
      return;
    }

    emit(const AuthLoading());
    try {
      final response = await _repo.registerDoctor(
        name.trim(),
        email.trim(),
        password,
        confirmPassword,
        specialization.trim(),
        yearsOfExperience,
        nationalNumber: nationalNumber,
        bio: bio,
      );
      emit(AuthSuccess(response.data));
    } catch (e) {
      emit(AuthFailure(AuthApiService.parseApiError(e)));
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    final currentState = state;
    if (currentState is! AuthSuccess) return;

    emit(const AuthLoading());
    try {
      final response = await _repo.updateProfileImage(imagePath);
      // Merge: if response is partial, use old state fields
      final newUser = response.data;
      final mergedUser = currentState.user.copyWith(
        id: newUser.id.isNotEmpty ? newUser.id : currentState.user.id,
        name: newUser.name.isNotEmpty ? newUser.name : currentState.user.name,
        email: newUser.email.isNotEmpty ? newUser.email : currentState.user.email,
        token: newUser.token.isNotEmpty ? newUser.token : currentState.user.token,
        profileImageUrl: newUser.profileImageUrl ?? currentState.user.profileImageUrl,
      );
      emit(AuthSuccess(mergedUser));
    } catch (e) {
      emit(AuthSuccess(currentState.user));
    }
  }

  Future<void> updateDoctorProfileLocally({
    required String name,
    required String specialization,
    required int yearsOfExperience,
    String? bio,
    double? sessionPrice,
  }) async {
    await _repo.updateDoctorProfileLocally(
      name: name,
      specialization: specialization,
      yearsOfExperience: yearsOfExperience,
      bio: bio,
      sessionPrice: sessionPrice,
    );
    await reloadUser();
  }

  Future<void> forgotPassword(String email) async {
    emit(const AuthLoading());
    try {
      await _repo.forgotPassword(email.trim());
      emit(const AuthForgotPasswordSuccess('Password reset code sent successfully. Please check your email.'));
    } catch (e) {
      emit(AuthFailure(AuthApiService.parseApiError(e)));
    }
  }

  Future<void> resetPassword(String email, String code, String newPassword) async {
    emit(const AuthLoading());
    try {
      await _repo.resetPassword(email.trim(), code.trim(), newPassword);
      emit(const AuthResetPasswordSuccess('Password changed successfully. You can now login.'));
    } catch (e) {
      emit(AuthFailure(AuthApiService.parseApiError(e)));
    }
  }
}

