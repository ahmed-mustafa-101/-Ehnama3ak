enum UserRole {
  patient,
  doctor;

  static UserRole fromString(String role) {
    final normalized = role.trim().toLowerCase();
    if (normalized == 'doctor' || normalized.contains('doctor')) {
      return UserRole.doctor;
    }
    return UserRole.patient;
  }
}
