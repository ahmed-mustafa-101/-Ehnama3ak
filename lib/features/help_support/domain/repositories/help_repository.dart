import '../../data/models/help_models.dart';

abstract class HelpRepository {
  Future<List<FaqModel>> getFaqs();
  Future<HelpContactModel> getContactInfo();
  Future<void> createTicket({required String subject, required String description});
  Future<List<SupportTicketModel>> getUserTickets();
  Future<void> sendEmail({required String subject, required String message});
}
