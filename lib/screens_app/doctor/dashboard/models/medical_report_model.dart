class MedicalReportModel {
  final int id;
  final String doctorId;
  final String patientId;
  final String type;
  final String fileUrl;
  final String reportDate;

  MedicalReportModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.type,
    required this.fileUrl,
    required this.reportDate,
  });

  factory MedicalReportModel.fromJson(Map<String, dynamic> json) {
    return MedicalReportModel(
      id: json['id'] ?? 0,
      doctorId: json['doctorId']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      type: json['type'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      reportDate: json['reportDate'] ?? '',
    );
  }
}
