class LatestAssessmentModel {
  final String assessmentName;
  final num percentage;
  final String symptomLevel;

  LatestAssessmentModel({
    required this.assessmentName,
    required this.percentage,
    required this.symptomLevel,
  });

  factory LatestAssessmentModel.fromJson(Map<String, dynamic> json) {
    return LatestAssessmentModel(
      assessmentName: json['assessmentName'] ?? '',
      percentage: json['percentage'] ?? 0,
      symptomLevel: json['symptomLevel'] ?? '',
    );
  }
}
