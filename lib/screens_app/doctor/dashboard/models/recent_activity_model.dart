class RecentActivityModel {
  final String title;
  final String description;
  final String timeAgo;
  final String type;

  RecentActivityModel({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
