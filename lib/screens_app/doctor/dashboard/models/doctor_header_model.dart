class DoctorHeaderModel {
  final String name;
  final String specialization;
  final int experienceYears;
  final double rating;
  final String imageUrl;
  final bool isAvailable;

  DoctorHeaderModel({
    required this.name,
    required this.specialization,
    required this.experienceYears,
    required this.rating,
    required this.imageUrl,
    required this.isAvailable,
  });

  factory DoctorHeaderModel.fromJson(Map<String, dynamic> json) {
    return DoctorHeaderModel(
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
    );
  }
}
