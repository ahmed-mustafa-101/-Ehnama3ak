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
  final int id;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;

  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id'] ?? 0,
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'Open',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, subject, message, status, createdAt];
}
