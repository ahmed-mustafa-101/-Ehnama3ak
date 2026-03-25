class SaveMoodModel {
  final String day;
  final int value;

  SaveMoodModel({required this.day, required this.value});

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'value': value,
    };
  }
}
