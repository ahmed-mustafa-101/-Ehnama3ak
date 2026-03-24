import '../../data/models/settings_models.dart';

abstract class SettingsRepository {
  Future<UserSettings> getSettings();
  Future<void> updateProfile({
    required String name,
    required String email,
    String? profileImagePath,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<PrivacyPolicy> getPrivacyPolicy();
  Future<SupportInfo> getSupportInfo();
}
