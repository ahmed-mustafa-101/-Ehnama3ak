import '../../data/models/settings_models.dart';

abstract class SettingsRepository {
  Future<UserSettings> getSettings();
  Future<void> uploadAvatar(String imagePath);
  Future<void> updateProfile({
    required String name,
    required String email,
    String? profileImagePath,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> updateDoctorProfile({
    required String fullName,
    required String specialization,
    required num experienceYears,
    required String bio,
    required num sessionPrice,
  });
  Future<PrivacyPolicy> getPrivacyPolicy();
  Future<SupportInfo> getSupportInfo();
}
