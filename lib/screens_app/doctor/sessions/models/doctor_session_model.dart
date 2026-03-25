import 'package:equatable/equatable.dart';

class DoctorSessionModel extends Equatable {
  final int? id;
  final String? patientName;
  final String? sessionType;
  final String? date;
  final String? time;
  final double? price;
  final String? status;
  final String? sessionUrl;
  final DateTime? scheduledAt;

  const DoctorSessionModel({
    this.id,
    this.patientName,
    this.sessionType,
    this.date,
    this.time,
    this.price,
    this.status,
    this.sessionUrl,
    this.scheduledAt,
  });

  factory DoctorSessionModel.fromJson(Map<String, dynamic> json) {
    // Robust key matching (handles PascalCase and camelCase)
    dynamic getField(List<String> keys) {
      for (var key in keys) {
        if (json.containsKey(key)) return json[key];
        // Also check capitalized version
        String cap = key[0].toUpperCase() + key.substring(1);
        if (json.containsKey(cap)) return json[cap];
      }
      return null;
    }

    final rawScheduledAt = getField(['scheduledAt', 'date_time']);
    DateTime? parsedScheduledAt;
    if (rawScheduledAt != null) {
      parsedScheduledAt = DateTime.tryParse(rawScheduledAt.toString());
    }

    return DoctorSessionModel(
      id: getField(['id']) as int?,
      patientName: getField(['patientName', 'patient', 'name'])?.toString(),
      sessionType: getField(['sessionType', 'type'])?.toString(),
      date: getField(['date'])?.toString(),
      time: getField(['time'])?.toString(),
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      status: getField(['status', 'state'])?.toString(),
      sessionUrl: getField(['sessionUrl', 'url', 'link'])?.toString(),
      scheduledAt: parsedScheduledAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'sessionType': sessionType,
      'date': date,
      'time': time,
      'price': price,
      'status': status,
      'sessionUrl': sessionUrl,
      'scheduledAt': scheduledAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, patientName, sessionType, date, time, price, status, sessionUrl, scheduledAt];
}
