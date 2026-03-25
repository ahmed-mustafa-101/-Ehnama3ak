class MoodWeeklyModel {
  final String day;
  final int value;

  MoodWeeklyModel({required this.day, required this.value});

  factory MoodWeeklyModel.fromJson(Map<String, dynamic> json) {
    return MoodWeeklyModel(
      day: json['day'] ?? '',
      value: json['value'] ?? 0,
    );
  }
}
