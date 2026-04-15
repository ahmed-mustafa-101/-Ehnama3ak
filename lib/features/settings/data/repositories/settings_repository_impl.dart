import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_api_service.dart';
import '../models/settings_models.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsApiService _apiService;

  SettingsRepositoryImpl(this._apiService);

  @override
  Future<UserSettings> getSettings() => _apiService.getSettings();

  @override
  Future<void> uploadAvatar(String imagePath) =>
      _apiService.uploadAvatar(imagePath);

  @override
  Future<void> updateProfile({
    required String name,
    required String email,
    String? profileImagePath,
  }) =>
      _apiService.updateProfile(
        name: name,
        email: email,
        profileImagePath: profileImagePath,
      );

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  @override
  Future<void> updateDoctorProfile({
    required String fullName,
    required String specialization,
    required num experienceYears,
    required String bio,
    required num sessionPrice,
  }) =>
      _apiService.updateDoctorProfile(
        fullName: fullName,
        specialization: specialization,
        experienceYears: experienceYears,
        bio: bio,
        sessionPrice: sessionPrice,
      );

  @override
  Future<PrivacyPolicy> getPrivacyPolicy() => _apiService.getPrivacyPolicy();

  @override
  Future<SupportInfo> getSupportInfo() => _apiService.getSupportInfo();
}
