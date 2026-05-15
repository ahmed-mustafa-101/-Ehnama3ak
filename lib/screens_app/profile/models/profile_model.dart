class ProfileModel {
  final String fullName;
  final String email;
  final String avatarUrl;
  final int sessionsCompleted;
  final int exercisesCompleted;
  final int activeDays;
  final int age;
  final String gender;

  ProfileModel({
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.sessionsCompleted,
    required this.exercisesCompleted,
    required this.activeDays,
    this.age = 0,
    this.gender = '',
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      sessionsCompleted: json['sessionsCompleted'] ?? 0,
      exercisesCompleted: json['exercisesCompleted'] ?? 0,
      activeDays: json['activeDays'] ?? 0,
      age: json['age'] ?? json['Age'] ?? 0,
      gender: json['gender'] ?? json['Gender'] ?? '',
    );
  }
}
