class DoctorSignupRequest {
  final String name;
  final String email;
  final String password;
  final String nationalNumber;
  final String specialization;
  final String yearsExperience;
  final String aboutMe;

  DoctorSignupRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.nationalNumber,
    required this.specialization,
    required this.yearsExperience,
    required this.aboutMe,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'nationalNumber': nationalNumber,
      'specialization': specialization,
      'yearsExperience': yearsExperience,
      'aboutMe': aboutMe,
    };
  }
}
