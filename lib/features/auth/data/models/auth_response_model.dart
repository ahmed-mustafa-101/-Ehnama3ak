import 'auth_model.dart';
import 'user_model.dart';

/// API response wrapper: { success: true, data: { id, name, email, role, token } }
class AuthResponseModel {
  final bool success;
  final AuthModel data;

  AuthResponseModel({required this.success, required this.data});

  String get token => data.token;

  UserModel get user => UserModel(
        id: data.id,
        email: data.email,
        name: data.name,
        role: data.role,
      );

  /// Many backends nest profile under `user`, `applicationUser`, or `profile`.
  static Map<String, dynamic> _flattenAuthMap(Map<String, dynamic> map) {
    const nestedKeys = [
      'user',
      'User',
      'applicationUser',
      'ApplicationUser',
      'profile',
      'Profile',
      'doctor',
      'Doctor',
    ];
    var copy = Map<String, dynamic>.from(map);
    final merged = <String, dynamic>{};

    for (final key in nestedKeys) {
      final v = copy.remove(key);
      if (v is Map) {
        merged.addAll(_flattenAuthMap(Map<String, dynamic>.from(v)));
      }
    }

    // Inner profile first, then outer keys win (token often only on outer).
    return {...merged, ...copy};
  }

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle wrapped format: { success, data: { ... } }
    if (json['data'] != null && json['data'] is Map) {
      final dataMap = json['data'] as Map<String, dynamic>;
      // Token might be at root or inside data
      final token = dataMap['token']?.toString() ??
          json['token']?.toString() ??
          dataMap['accessToken']?.toString() ??
          '';
      final combined = _flattenAuthMap(Map<String, dynamic>.from(dataMap));
      if (token.isNotEmpty && (combined['token'] == null || combined['token'].toString().isEmpty)) {
        combined['token'] = token;
      }
      return AuthResponseModel(
        success: json['success'] == true,
        data: AuthModel.fromJson(combined),
      );
    }

    // Handle flat format: { id, name, email, role, token } at root
    final flat = _flattenAuthMap(Map<String, dynamic>.from(json));
    return AuthResponseModel(
      success: json['success'] != false,
      data: AuthModel.fromJson(flat),
    );
  }
}
