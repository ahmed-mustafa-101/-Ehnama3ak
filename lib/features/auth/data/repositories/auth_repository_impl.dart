import 'package:ehnama3ak/core/models/user_role.dart';
import 'package:ehnama3ak/core/storage/pref_manager.dart';
import 'package:ehnama3ak/core/storage/secure_token_storage.dart';
import 'package:ehnama3ak/core/utils/jwt_helper.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_service.dart';
import '../models/auth_model.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final SecureTokenStorage _storage;

  AuthRepositoryImpl(AuthApiService apiService, [SecureTokenStorage? storage])
      : _apiService = apiService,
        _storage = storage ?? SecureTokenStorage();

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final prevId = await _storage.getUserId();
    final prevSpec = await _storage.getUserSpecialization();
    final prevYears = await _storage.getUserYearsExperience();
    final prevImage = await _storage.getUserProfileImageUrl();

    var response = await _apiService.login(email, password);
    response = _enrichFromToken(response);

    var d = response.data;
    final sameUser =
        prevId != null && prevId.isNotEmpty && prevId == d.id;
    if (sameUser) {
      response = AuthResponseModel(
        success: response.success,
        data: AuthModel(
          id: d.id,
          name: d.name,
          email: d.email,
          role: d.role,
          token: d.token,
          specialization: d.specialization ?? prevSpec,
          yearsOfExperience: d.yearsOfExperience ?? prevYears,
          profileImageUrl: d.profileImageUrl ?? prevImage,
        ),
      );
      d = response.data;
    }

    if (response.token.isEmpty) {
      throw Exception('لم يتم استلام رمز الدخول. حاول مرة أخرى.');
    }
    await _saveSession(response);
    return response;
  }

  /// Fill missing id/name/email/doctor fields from JWT claims (ASP.NET style).
  AuthResponseModel _enrichFromToken(AuthResponseModel r) {
    final d = r.data;
    if (d.token.isEmpty) return r;

    final idFromJwt = JwtHelper.getUserIdFromToken(d.token);
    final nameFromJwt = JwtHelper.getDisplayNameFromToken(d.token);
    final emailFromJwt = JwtHelper.getEmailFromToken(d.token);
    final specFromJwt = JwtHelper.getSpecializationFromToken(d.token);
    final yearsFromJwt = JwtHelper.getYearsOfExperienceFromToken(d.token);

    final newId = d.id.isNotEmpty ? d.id : (idFromJwt ?? '');
    var newName = d.name.isNotEmpty ? d.name : (nameFromJwt ?? '');
    var newEmail = d.email.isNotEmpty ? d.email : (emailFromJwt ?? '');
    final newSpec = d.specialization ?? specFromJwt;
    final newYears = d.yearsOfExperience ?? yearsFromJwt;

    // If "name" from JWT is the same as email, prefer showing email once in UI;
    // still store a non-empty display string for the drawer.
    if (newName.isNotEmpty && newName.contains('@') && newEmail.isEmpty) {
      newEmail = newName;
      newName = '';
    }
    if (newName.isEmpty && newEmail.isNotEmpty) {
      newName = newEmail.split('@').first;
    }

    if (newId == d.id &&
        newName == d.name &&
        newEmail == d.email &&
        newSpec == d.specialization &&
        newYears == d.yearsOfExperience) {
      return r;
    }

    return AuthResponseModel(
      success: r.success,
      data: AuthModel(
        id: newId,
        name: newName,
        email: newEmail,
        role: d.role,
        token: d.token,
        specialization: newSpec,
        yearsOfExperience: newYears,
        profileImageUrl: d.profileImageUrl,
      ),
    );
  }

  @override
  Future<AuthResponseModel> registerPatient(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (password != confirmPassword) {
      throw Exception('كلمات المرور غير متطابقة');
    }
    var response = await _apiService.register(
      name: name,
      email: email,
      password: password,
      role: 'patient',
    );
    response = _enrichFromToken(response);
    if (response.token.isEmpty) {
      throw Exception(
        'تم التسجيل بنجاح ولكن لم يتم استلام رمز الدخول. جرب تسجيل الدخول.',
      );
    }
    final updated = _ensureRole(response, UserRole.patient);
    await _saveSession(updated);
    return updated;
  }

  @override
  Future<AuthResponseModel> registerDoctor(
    String name,
    String email,
    String password,
    String confirmPassword,
    String specialization,
    int yearsOfExperience,
  ) async {
    if (password != confirmPassword) {
      throw Exception('كلمات المرور غير متطابقة');
    }
    var response = await _apiService.register(
      name: name,
      email: email,
      password: password,
      role: 'doctor',
      specialization: specialization.isNotEmpty ? specialization : null,
      yearsOfExperience: yearsOfExperience,
    );
    response = _enrichFromToken(response);
    if (response.token.isEmpty) {
      throw Exception(
        'تم التسجيل بنجاح ولكن لم يتم استلام رمز الدخول. جرب تسجيل الدخول.',
      );
    }
    final merged = _mergeDoctorProfileFromSignup(
      response,
      fullName: name,
      specialization: specialization,
      yearsOfExperience: yearsOfExperience,
    );
    final updated = _ensureRole(merged, UserRole.doctor);
    await _saveSession(updated);
    return updated;
  }

  /// Ensures doctor-only fields exist even if API omits them in the token payload.
  AuthResponseModel _mergeDoctorProfileFromSignup(
    AuthResponseModel response, {
    required String fullName,
    required String specialization,
    required int yearsOfExperience,
  }) {
    final d = response.data;
    // Sign-up form is the source of truth for doctor profile fields.
    final resolvedName = fullName.isNotEmpty
        ? fullName
        : (d.name.isNotEmpty ? d.name : d.email.split('@').first);
    return AuthResponseModel(
      success: response.success,
      data: AuthModel(
        id: d.id,
        name: resolvedName,
        email: d.email,
        role: d.role,
        token: d.token,
        specialization:
            specialization.isNotEmpty ? specialization : d.specialization,
        yearsOfExperience: yearsOfExperience,
        profileImageUrl: d.profileImageUrl,
      ),
    );
  }

  AuthResponseModel _ensureRole(AuthResponseModel response, UserRole role) {
    if (response.user.role == role) return response;
    final d = response.data;
    final corrected = AuthModel(
      id: d.id,
      name: d.name,
      email: d.email,
      role: role,
      token: d.token,
      specialization: d.specialization,
      yearsOfExperience: d.yearsOfExperience,
      profileImageUrl: d.profileImageUrl,
    );
    return AuthResponseModel(success: response.success, data: corrected);
  }

  @override
  Future<AuthResponseModel?> getCurrentSession() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) return null;

    final userId = await _storage.getUserId();
    final roleStr = await _storage.getUserRole();
    final email = await _storage.getUserEmail();
    final name = await _storage.getUserName();
    final specialization = await _storage.getUserSpecialization();
    final years = await _storage.getUserYearsExperience();
    final image = await _storage.getUserProfileImageUrl();

    if (roleStr == null || roleStr.isEmpty) return null;

    return AuthResponseModel(
      success: true,
      data: AuthModel(
        id: userId ?? '',
        name: name ?? '',
        email: email ?? '',
        role: UserRole.fromString(roleStr),
        token: token,
        specialization: specialization,
        yearsOfExperience: years,
        profileImageUrl: image,
      ),
    );
  }

  @override
  Future<void> logout() async {
    await PrefManager.clearAll();
  }

  @override
  Future<AuthResponseModel> updateProfileImage(String imagePath) async {
    final response = await _apiService.updateProfileImage(imagePath);
    await _saveSession(response);
    return response;
  }

  Future<void> _saveSession(AuthResponseModel response) async {
    await _storage.saveToken(response.token);
    await _storage.saveUserId(response.user.id);
    await _storage.saveUserRole(response.user.role.name);
    await _storage.saveUserEmail(response.user.email);
    await _storage.saveUserName(response.user.name);
    await _storage.saveUserSpecialization(response.data.specialization);
    await _storage.saveUserYearsExperience(response.data.yearsOfExperience);
    await _storage.saveUserProfileImageUrl(response.data.profileImageUrl);

    await PrefManager.saveToken(response.token);
    await PrefManager.setUserId(response.user.id);
    await PrefManager.setUserRole(response.user.role);
  }
}

