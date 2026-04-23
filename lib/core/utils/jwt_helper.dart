import 'dart:convert';

/// Decode JWT payload and read common ASP.NET / OIDC claims.
class JwtHelper {
  static const _claimNameId =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
  static const _claimName =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';
  static const _claimEmail =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';
  static const _claimGivenName =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname';
  static const _claimSurname =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname';
  static const _claimRole =
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = json.decode(decoded);
      if (map is Map<String, dynamic>) return map;
      if (map is Map) return Map<String, dynamic>.from(map);
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? _firstNonEmptyString(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v != null) {
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
    }
    return null;
  }

  static int? _firstInt(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v == null) continue;
      if (v is int) return v;
      final p = int.tryParse(v.toString().trim());
      if (p != null) return p;
    }
    return null;
  }

  /// Display name from JWT when API body omits FullName.
  static String? getDisplayNameFromToken(String token) {
    final map = decodePayload(token);
    if (map == null) return null;

    final given = _firstNonEmptyString(map, [_claimGivenName, 'given_name', 'givenName']);
    final family = _firstNonEmptyString(map, [_claimSurname, 'family_name', 'familyName']);
    if (given != null && family != null) return '$given $family'.trim();
    if (given != null) return given;

    return _firstNonEmptyString(map, [
      'fullName',
      'FullName',
      'name',
      'unique_name',
      'preferred_username',
      _claimName,
      'email',
      _claimEmail,
    ]);
  }

  static String? getEmailFromToken(String token) {
    final map = decodePayload(token);
    if (map == null) return null;
    return _firstNonEmptyString(map, [
      'email',
      _claimEmail,
      'unique_name',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn',
    ]);
  }

  static String? getSpecializationFromToken(String token) {
    final map = decodePayload(token);
    if (map == null) return null;
    return _firstNonEmptyString(map, [
      'specialization',
      'Specialization',
      'specialty',
      'Specialty',
    ]);
  }

  static int? getYearsOfExperienceFromToken(String token) {
    final map = decodePayload(token);
    if (map == null) return null;
    return _firstInt(map, [
      'yearsOfExperience',
      'YearsOfExperience',
      'yearsExperience',
      'YearsExperience',
      'experienceYears',
    ]);
  }

  /// Extract user ID from JWT token payload (common claims: sub, nameid, ASP.NET claims)
  static String? getUserIdFromToken(String token) {
    final map = decodePayload(token);
    if (map == null) return null;

    final id = map['sub'] ??
        map['nameid'] ??
        map['userId'] ??
        map['uid'] ??
        map[_claimNameId];

    return id?.toString();
  }

  static String? getRoleFromToken(String token) {
    final map = decodePayload(token);
    if (map == null) return null;
    return _firstNonEmptyString(map, [
      'role',
      'Role',
      'roles',
      'Roles',
      _claimRole,
    ]);
  }
}
