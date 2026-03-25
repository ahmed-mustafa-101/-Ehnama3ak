class AssessmentDetailsModel {
  final String title;
  final num score;
  final String recommendation;
  final List<dynamic>? answers;

  AssessmentDetailsModel({
    required this.title,
    required this.score,
    required this.recommendation,
    this.answers,
  });

  factory AssessmentDetailsModel.fromJson(Map<String, dynamic> json) {
    return AssessmentDetailsModel(
      title: json['title'] ?? '',
      score: json['score'] ?? 0,
      recommendation: json['recommendation'] ?? '',
      answers: json['answers'] as List<dynamic>?,
    );
  }
}
