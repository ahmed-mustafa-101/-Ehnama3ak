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
    dynamic idVal = json['id'] ?? json['Id'] ?? json['doctorId'] ?? 0;
    int id;
    if (idVal is int) {
      id = idVal;
    } else {
      id = int.tryParse(idVal.toString()) ?? 0;
    }

    return DoctorModel(
      id: id,
      name: (json['name'] ?? json['Name'] ?? json['fullName'] ?? json['FullName'] ?? '').toString(),
      specialization: (json['specialization'] ?? json['Specialization'] ?? '').toString(),
      experienceYears: int.tryParse((json['experienceYears'] ?? json['ExperienceYears'] ?? 0).toString()) ?? 0,
      rating: num.tryParse((json['rating'] ?? json['Rating'] ?? 0.0).toString()) ?? 0.0,
      imageUrl: (json['imageUrl'] ?? json['ImageUrl'] ?? json['profileImageUrl'] ?? json['ProfileImageUrl'] ?? '').toString(),
    );
  }
}
