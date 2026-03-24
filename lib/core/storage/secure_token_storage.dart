import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for JWT token and user session data.
/// Uses Flutter Secure Storage for sensitive data.
class SecureTokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userRoleKey = 'user_role';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';
  static const _userSpecializationKey = 'user_specialization';
  static const _userYearsExperienceKey = 'user_years_experience';
  static const _userProfileImageUrlKey = 'user_profile_image_url';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );


  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  Future<void> saveUserName(String name) async {
    await _storage.write(key: _userNameKey, value: name);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  Future<void> saveUserSpecialization(String? value) async {
    if (value == null || value.isEmpty) {
      await _storage.delete(key: _userSpecializationKey);
      return;
    }
    await _storage.write(key: _userSpecializationKey, value: value);
  }

  Future<String?> getUserSpecialization() async {
    return await _storage.read(key: _userSpecializationKey);
  }

  Future<void> saveUserYearsExperience(int? years) async {
    if (years == null) {
      await _storage.delete(key: _userYearsExperienceKey);
      return;
    }
    await _storage.write(
      key: _userYearsExperienceKey,
      value: years.toString(),
    );
  }

  Future<int?> getUserYearsExperience() async {
    final s = await _storage.read(key: _userYearsExperienceKey);
    if (s == null || s.isEmpty) return null;
    return int.tryParse(s);
  }

  Future<void> saveUserProfileImageUrl(String? url) async {
    if (url == null || url.isEmpty) {
      await _storage.delete(key: _userProfileImageUrlKey);
      return;
    }
    await _storage.write(key: _userProfileImageUrlKey, value: url);
  }

  Future<String?> getUserProfileImageUrl() async {
    return await _storage.read(key: _userProfileImageUrlKey);
  }

  Future<void> clearAll() async {

    await _storage.deleteAll();
  }

  /// Check if user has a valid token (is logged in)
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
