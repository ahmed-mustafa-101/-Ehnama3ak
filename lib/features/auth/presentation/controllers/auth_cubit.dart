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
  }) async {
    if (name.trim().isEmpty) {
      emit(const AuthFailure('الاسم مطلوب'));
      return;
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      emit(const AuthFailure('البريد الإلكتروني غير صحيح'));
      return;
    }
    if (password.length < 6) {
      emit(const AuthFailure('كلمة المرور يجب أن تكون 6 أحرف على الأقل'));
      return;
    }
    if (password != confirmPassword) {
      emit(const AuthFailure('كلمات المرور غير متطابقة'));
      return;
    }

    emit(const AuthLoading());
    try {
      final response = await _repo.registerPatient(
        name.trim(),
        email.trim(),
        password,
        confirmPassword,
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
  }) async {
    if (name.trim().isEmpty) {
      emit(const AuthFailure('الاسم مطلوب'));
      return;
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      emit(const AuthFailure('البريد الإلكتروني غير صحيح'));
      return;
    }
    if (password.length < 6) {
      emit(const AuthFailure('كلمة المرور يجب أن تكون 6 أحرف على الأقل'));
      return;
    }
    if (password != confirmPassword) {
      emit(const AuthFailure('كلمات المرور غير متطابقة'));
      return;
    }
    if (specialization.trim().isEmpty) {
      emit(const AuthFailure('التخصص مطلوب'));
      return;
    }
    if (yearsOfExperience < 0) {
      emit(const AuthFailure('سنوات الخبرة غير صحيحة'));
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
      emit(AuthSuccess(response.data));
    } catch (e) {
      // Revert to current user on failure
      emit(AuthSuccess(currentState.user));
    }
  }
}

