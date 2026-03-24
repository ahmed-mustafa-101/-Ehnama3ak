import 'package:equatable/equatable.dart';

class DoctorReportModel extends Equatable {
  final int? id;
  final String? title;
  final String? patientName;
  final String? type; // progress, weekly, assessment
  final String? date;

  const DoctorReportModel({
    this.id,
    this.title,
    this.patientName,
    this.type,
    this.date,
  });

  factory DoctorReportModel.fromJson(Map<String, dynamic> json) {
    // Robust parsing for flexible backend field names
    dynamic getField(List<String> keys) {
      for (var key in keys) {
        if (json.containsKey(key)) return json[key];
        String cap = key[0].toUpperCase() + key.substring(1);
        if (json.containsKey(cap)) return json[cap];
      }
      return null;
    }

    return DoctorReportModel(
      id: getField(['id']) as int?,
      title: getField(['title', 'reportTitle', 'name'])?.toString(),
      patientName: getField(['patientName', 'patient', 'fullName'])?.toString(),
      type: getField(['type', 'reportType', 'category'])?.toString(),
      date: getField(['date', 'createdAt', 'reportDate'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'patientName': patientName,
      'type': type,
      'date': date,
    };
  }

  @override
  List<Object?> get props => [id, title, patientName, type, date];
}
