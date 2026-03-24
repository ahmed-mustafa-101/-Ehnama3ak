import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;

  const UserSettings({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: (json['id'] ?? json['userId'] ?? 0).toString(),
      name: (json['name'] ?? json['userName'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? json['emailAddress'] ?? '').toString(),
      profileImageUrl: json['profileImageUrl'] ?? json['imageUrl'] ?? json['image'],
    );
  }

  @override
  List<Object?> get props => [id, name, email, profileImageUrl];
}

class PrivacyPolicy extends Equatable {
  final String content;

  const PrivacyPolicy({required this.content});

  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicy(content: json['content'] ?? json['text'] ?? '');
  }

  @override
  List<Object?> get props => [content];
}

class SupportInfo extends Equatable {
  final String email;
  final String phone;
  final String? description;

  const SupportInfo({
    required this.email,
    required this.phone,
    this.description,
  });

  factory SupportInfo.fromJson(Map<String, dynamic> json) {
    return SupportInfo(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [email, phone, description];
}
