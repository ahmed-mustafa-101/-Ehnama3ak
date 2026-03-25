class AddRecordModel {
  final String patientId;
  final String diagnosis;
  final String notes;
  final String treatmentPlan;

  AddRecordModel({
    required this.patientId,
    required this.diagnosis,
    required this.notes,
    required this.treatmentPlan,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'diagnosis': diagnosis,
      'notes': notes,
      'treatmentPlan': treatmentPlan,
    };
  }
}

class UploadReportModel {
  final int id;
  final String doctorId;
  final String patientId;
  final String type;
  final String fileUrl;
  final String reportDate;

  UploadReportModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.type,
    required this.fileUrl,
    required this.reportDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'type': type,
      'fileUrl': fileUrl,
      'reportDate': reportDate,
    };
  }
}
