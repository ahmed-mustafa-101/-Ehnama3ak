import 'package:equatable/equatable.dart';
import '../../data/models/help_models.dart';

enum HelpStatus { initial, loading, success, failure }

class HelpState extends Equatable {
  final HelpStatus status;
  final List<FaqModel> faqs;
  final HelpContactModel? contactInfo;
  final List<SupportTicketModel> tickets;
  final String? errorMessage;
  final String? successMessage;
  final bool isSubmitting;

  const HelpState({
    this.status = HelpStatus.initial,
    this.faqs = const [],
    this.contactInfo,
    this.tickets = const [],
    this.errorMessage,
    this.successMessage,
    this.isSubmitting = false,
  });

  HelpState copyWith({
    HelpStatus? status,
    List<FaqModel>? faqs,
    HelpContactModel? contactInfo,
    List<SupportTicketModel>? tickets,
    String? errorMessage,
    String? successMessage,
    bool? isSubmitting,
  }) {
    return HelpState(
      status: status ?? this.status,
      faqs: faqs ?? this.faqs,
      contactInfo: contactInfo ?? this.contactInfo,
      tickets: tickets ?? this.tickets,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [status, faqs, contactInfo, tickets, errorMessage, successMessage, isSubmitting];
}
