import 'package:equatable/equatable.dart';

class FaqModel extends Equatable {
  final int id;
  final String question;
  final String answer;

  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, question, answer];
}

class HelpContactModel extends Equatable {
  final String email;
  final String phone;
  final String? address;

  const HelpContactModel({
    required this.email,
    required this.phone,
    this.address,
  });

  factory HelpContactModel.fromJson(Map<String, dynamic> json) {
    return HelpContactModel(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
    );
  }

  @override
  List<Object?> get props => [email, phone, address];
}

class SupportTicketModel extends Equatable {
  final String id;
  final String subject;
  final String description;
  final String status;
  final DateTime createdAt;

  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: (json['id'] ?? '').toString(),
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, subject, description, status, createdAt];
}
