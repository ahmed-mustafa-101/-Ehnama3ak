class DoctorModel {
  final int id;

  /// The GUID / string user-account ID used by the Messaging API as receiverId.
  /// e.g. "ec87199d-4c41-4327-8cc6-650760321c23"
  final String userId;

  final String name;
  final String specialization;
  final int experienceYears;
  final num rating;
  final String imageUrl;

  DoctorModel({
    required this.id,
    required this.userId,
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

    // The GUID userId may come under different keys depending on the endpoint.
    // We prefer the string GUID over the numeric id for messaging.
    final String userId = (json['userId'] ??
            json['UserId'] ??
            json['applicationUserId'] ??
            json['ApplicationUserId'] ??
            json['userAccountId'] ??
            json['UserAccountId'] ??
            json['accountId'] ??
            json['AccountId'] ??
            '')
        .toString();

    return DoctorModel(
      id: id,
      userId: userId,
      name: (json['name'] ?? json['Name'] ?? json['fullName'] ?? json['FullName'] ?? '').toString(),
      specialization: (json['specialization'] ?? json['Specialization'] ?? '').toString(),
      experienceYears: int.tryParse((json['experienceYears'] ?? json['ExperienceYears'] ?? 0).toString()) ?? 0,
      rating: num.tryParse((json['rating'] ?? json['Rating'] ?? 0.0).toString()) ?? 0.0,
      imageUrl: (json['imageUrl'] ?? json['ImageUrl'] ?? json['profileImageUrl'] ?? json['ProfileImageUrl'] ?? '').toString(),
    );
  }
}
