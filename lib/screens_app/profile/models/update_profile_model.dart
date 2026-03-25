class UpdateProfileModel {
  final String fullName;
  final String profileImageUrl;

  UpdateProfileModel({
    required this.fullName,
    required this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
    };
  }
}
