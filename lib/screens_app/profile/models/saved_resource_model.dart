class SavedResourceModel {
  final int id;
  final String title;
  final String type;
  final String imageUrl;
  final String resourceUrl;

  SavedResourceModel({
    required this.id,
    required this.title,
    required this.type,
    required this.imageUrl,
    required this.resourceUrl,
  });

  factory SavedResourceModel.fromJson(Map<String, dynamic> json) {
    return SavedResourceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      resourceUrl: json['resourceUrl'] ?? '',
    );
  }
}
