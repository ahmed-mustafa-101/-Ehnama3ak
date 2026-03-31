class ProfileModel {
  final String fullName;
  final String email;
  final String profileImageUrl;
  final int sessionsCount;
  final int exercisesCount;
  final int daysCount;

  ProfileModel({
    required this.fullName,
    required this.email,
    required this.profileImageUrl,
    required this.sessionsCount,
    required this.exercisesCount,
    required this.daysCount,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      fullName: json['fullName'] ?? json['FullName'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? json['ProfileImage'] ?? json['imageUrl'] ?? json['image'] ?? '',
      sessionsCount: json['sessionsCount'] ?? 0,
      exercisesCount: json['exercisesCount'] ?? 0,
      daysCount: json['daysCount'] ?? 0,
    );
  }
}
