class DoctorModel {
  final int id;
  final String name;
  final String specialization;
  final int experienceYears;
  final num rating;
  final String imageUrl;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experienceYears,
    required this.rating,
    required this.imageUrl,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      rating: json['rating'] ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
