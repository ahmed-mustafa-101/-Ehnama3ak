class BookSessionModel {
  final int doctorId;
  final String sessionDate;
  final String sessionType;

  BookSessionModel({
    required this.doctorId,
    required this.sessionDate,
    required this.sessionType,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'sessionDate': sessionDate,
      'sessionType': sessionType,
    };
  }
}
