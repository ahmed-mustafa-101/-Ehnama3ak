import 'package:equatable/equatable.dart';

class DoctorPatientModel extends Equatable {
  final String? id;
  final String? fullName;
  final String? diagnosis;
  final String? lastSessionDate;
  final String? profileImageUrl;

  const DoctorPatientModel({
    this.id,
    this.fullName,
    this.diagnosis,
    this.lastSessionDate,
    this.profileImageUrl,
  });

  factory DoctorPatientModel.fromJson(Map<String, dynamic> json) {
    // Robust parsing for different possible key names from backend
    dynamic getField(List<String> keys) {
      for (var key in keys) {
        if (json.containsKey(key)) return json[key];
        // Check capitalized
        String cap = key[0].toUpperCase() + key.substring(1);
        if (json.containsKey(cap)) return json[cap];
      }
      return null;
    }

    return DoctorPatientModel(
      id: getField(['id'])?.toString(),
      fullName: getField(['fullName', 'name', 'patientName'])?.toString(),
      diagnosis: getField(['diagnosis', 'condition', 'medicalHistory'])?.toString(),
      lastSessionDate: getField(['lastSessionDate', 'lastSession', 'date'])?.toString(),
      profileImageUrl: getField(['profileImageUrl', 'imageUrl', 'image', 'picture'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'diagnosis': diagnosis,
      'lastSessionDate': lastSessionDate,
      'profileImageUrl': profileImageUrl,
    };
  }

  @override
  List<Object?> get props => [id, fullName, diagnosis, lastSessionDate, profileImageUrl];
}
