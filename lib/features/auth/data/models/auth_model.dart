import 'package:equatable/equatable.dart';
import 'package:ehnama3ak/core/models/user_role.dart';

/// Auth model representing the authenticated user and token.
/// Supports API response format: { success, data: { id, name, email, role, token, specialization, ... } }
class AuthModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String token;
  /// Doctor profile (from register/login API or persisted session).
  final String? specialization;
  final int? yearsOfExperience;

  final String? profileImageUrl;
  final String? bio;
  final double? sessionPrice;

  const AuthModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    this.specialization,
    this.yearsOfExperience,
    this.profileImageUrl,
    this.bio,
    this.sessionPrice,
  });

  /// Header: registered name, then email, then generic label.
  String get displayNameLine {
    final n = name.trim();
    if (n.isNotEmpty) return n;
    final e = email.trim();
    if (e.isNotEmpty) return e;
    return 'Doctor';
  }

  /// Shown under the name (e.g. specialization from signup / API).
  String get specializationLine {
    final s = specialization?.trim() ?? '';
    return s.isNotEmpty ? s : '—';
  }

  /// e.g. "5 Years Exp" from [yearsOfExperience] / API `yearsExperience`.
  String get yearsExperienceLine {
    final y = yearsOfExperience;
    if (y != null) return '$y Years Exp';
    return '—';
  }

  static int? _parseYears(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString().trim());
  }

  static String? _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return null;
  }

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    String roleStr = 'patient';
    if (json['role'] != null) {
      roleStr = json['role'].toString().trim().toLowerCase();
    } else if (json['Role'] != null) {
      roleStr = json['Role'].toString().trim().toLowerCase();
    } else if (json['roles'] is List && (json['roles'] as List).isNotEmpty) {
      roleStr = (json['roles'] as List).first.toString().trim().toLowerCase();
    } else if (json['Roles'] is List && (json['Roles'] as List).isNotEmpty) {
      roleStr = (json['Roles'] as List).first.toString().trim().toLowerCase();
    }

    final id = json['id'] ?? json['userId'] ?? json['userIds'] ?? json['uid'];
    String? name = _pickString(json, [
      'fullName',
      'FullName',
      'displayName',
      'DisplayName',
      'name',
      'Name',
      'userFullName',
      'UserFullName',
    ]);

    // Avoid using login username as "name" when it's clearly an email.
    final userNameRaw = json['userName']?.toString().trim();
    if (name == null || name.isEmpty) {
      if (userNameRaw != null &&
          userNameRaw.isNotEmpty &&
          !userNameRaw.contains('@')) {
        name = userNameRaw;
      }
    }

    final given = _pickString(json, ['givenName', 'GivenName', 'firstName', 'FirstName']);
    final family = _pickString(json, ['familyName', 'FamilyName', 'lastName', 'LastName']);
    if ((name == null || name.isEmpty) && given != null) {
      name = family != null && family.isNotEmpty ? '$given $family'.trim() : given;
    }

    final resolvedName = (name ?? '').trim();

    return AuthModel(
      id: id?.toString() ?? '',
      name: resolvedName,
      email: json['email']?.toString() ?? json['userName']?.toString() ?? '',
      role: UserRole.fromString(roleStr),
      token: json['token']?.toString() ?? json['accessToken']?.toString() ?? '',
      specialization: _pickString(json, [
        'specialization',
        'Specialization',
        'specialty',
        'Specialty',
      ]),
      yearsOfExperience: _parseYears(
        json['experienceYears'] ??
            json['experience_years'] ??
            json['yearsOfExperience'] ??
            json['YearsOfExperience'] ??
            json['yearsOfExp'] ??
            json['yearsExperience'] ??
            json['ExperienceYears'] ??
            json['experience'],
      ),
      profileImageUrl: _pickString(json, [
        'profileImageUrl',
        'ProfileImageUrl',
        'imageUrl',
        'ImageUrl',
        'image',
        'Image',
        'picture',
        'Picture',
        'photoPath',
        'photoUrl',
        'avatarUrl',
        'profileImage',
        'profilePicture',
        'url',
        'avatar',
      ]),
      bio: _pickString(json, ['bio', 'Bio', 'biography', 'Biography']),
      sessionPrice: json['sessionPrice'] != null
          ? double.tryParse(json['sessionPrice'].toString())
          : (json['SessionPrice'] != null
              ? double.tryParse(json['SessionPrice'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'token': token,
        if (specialization != null) 'specialization': specialization,
        if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (bio != null) 'bio': bio,
        if (sessionPrice != null) 'sessionPrice': sessionPrice,
      };

  AuthModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? token,
    String? specialization,
    int? yearsOfExperience,
    String? profileImageUrl,
    String? bio,
    double? sessionPrice,
  }) {
    return AuthModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      specialization: specialization ?? this.specialization,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      sessionPrice: sessionPrice ?? this.sessionPrice,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        token,
        specialization,
        yearsOfExperience,
        profileImageUrl,
        bio,
        sessionPrice
      ];
}

