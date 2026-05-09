import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/settings_api_service.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../core/storage/secure_token_storage.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repo;
  final SecureTokenStorage _tokenStorage;

  SettingsCubit(this._repo, this._tokenStorage) : super(const SettingsState());

  Future<void> fetchSettings() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final settings = await _repo.getSettings();
      // Update cached profile image URL
      await _tokenStorage.saveUserProfileImageUrl(settings.profileImageUrl);
      emit(state.copyWith(status: SettingsStatus.success, userSettings: settings));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: SettingsApiService.parseError(e),
      ));
    }
  }

  Future<bool> uploadAvatar(String imagePath) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await _repo.uploadAvatar(imagePath);
      await fetchSettings();
      emit(state.copyWith(status: SettingsStatus.success));
      emit(state.copyWith(isUpdating: false, status: SettingsStatus.initial));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        status: SettingsStatus.failure,
        errorMessage: SettingsApiService.parseError(e),
      ));
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? profileImagePath,
  }) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await _repo.updateProfile(
        name: name,
        email: email,
        profileImagePath: profileImagePath,
      );
      // Refresh settings to get updated info
      await fetchSettings();
      emit(state.copyWith(status: SettingsStatus.success));
      emit(state.copyWith(isUpdating: false, status: SettingsStatus.initial));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        status: SettingsStatus.failure,
        errorMessage: SettingsApiService.parseError(e),
      ));
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(state.copyWith(isPasswordChanging: true));
    try {
      await _repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(state.copyWith(status: SettingsStatus.success));
      emit(state.copyWith(isPasswordChanging: false, status: SettingsStatus.initial));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isPasswordChanging: false,
        status: SettingsStatus.failure,
        errorMessage: SettingsApiService.parseError(e),
      ));
      return false;
    }
  }

  Future<bool> updateDoctorProfile({
    required String fullName,
    required String specialization,
    required num experienceYears,
    required String bio,
    required num sessionPrice,
  }) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await _repo.updateDoctorProfile(
        fullName: fullName,
        specialization: specialization,
        experienceYears: experienceYears,
        bio: bio,
        sessionPrice: sessionPrice,
      );
      emit(state.copyWith(status: SettingsStatus.success));
      emit(state.copyWith(isUpdating: false, status: SettingsStatus.initial));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        status: SettingsStatus.failure,
        errorMessage: SettingsApiService.parseError(e),
      ));
      return false;
    }
  }

  Future<void> fetchPrivacyPolicy() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final privacyPolicy = await _repo.getPrivacyPolicy();
      emit(state.copyWith(
        status: SettingsStatus.success,
        privacyPolicy: privacyPolicy,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: SettingsApiService.parseError(e),
      ));
    }
  }

  Future<void> fetchSupportInfo() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final supportInfo = await _repo.getSupportInfo();
      emit(state.copyWith(
        status: SettingsStatus.success,
        supportInfo: supportInfo,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: SettingsApiService.parseError(e),
      ));
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: SettingsStatus.initial));
  }
}
