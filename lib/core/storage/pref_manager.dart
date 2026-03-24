import 'package:shared_preferences/shared_preferences.dart';
import 'package:ehnama3ak/core/models/user_role.dart';
import 'package:ehnama3ak/core/utils/jwt_helper.dart';
import 'secure_token_storage.dart';

class PrefManager {
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';

  static final SecureTokenStorage _secureStorage = SecureTokenStorage();

  static Future<void> setUserRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.name);
    await _secureStorage.saveUserRole(role.name);
  }

  static Future<UserRole> getUserRole() async {
    final roleStr = await _secureStorage.getUserRole();
    if (roleStr != null && roleStr.isNotEmpty) {
      return UserRole.fromString(roleStr);
    }
    final prefs = await SharedPreferences.getInstance();
    return UserRole.fromString(prefs.getString(_roleKey) ?? 'patient');
  }

  static Future<void> saveToken(String token) async {
    await _secureStorage.saveToken(token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }

  static Future<void> setUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
    await _secureStorage.saveUserId(id);
  }

  static Future<String?> getUserId() async {
    final id = await _secureStorage.getUserId();
    if (id != null && id.isNotEmpty) return id;
    final prefs = await SharedPreferences.getInstance();
    final fromPrefs = prefs.getString(_userIdKey);
    if (fromPrefs != null && fromPrefs.isNotEmpty) return fromPrefs;
    // Fallback: extract from JWT if user has token (logged in) but userId not saved
    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      final fromToken = JwtHelper.getUserIdFromToken(token);
      if (fromToken != null && fromToken.isNotEmpty) {
        await setUserId(fromToken);
        return fromToken;
      }
    }
    return null;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _secureStorage.clearAll();
  }
}
