import '../../domain/repositories/help_repository.dart';
import '../datasources/help_api_service.dart';
import '../models/help_models.dart';

class HelpRepositoryImpl implements HelpRepository {
  final HelpApiService _apiService;

  HelpRepositoryImpl(this._apiService);

  @override
  Future<List<FaqModel>> getFaqs() => _apiService.getFaqs();

  @override
  Future<HelpContactModel> getContactInfo() => _apiService.getContactInfo();

  @override
  Future<void> createTicket({required String subject, required String description}) =>
      _apiService.createTicket(subject: subject, description: description);

  @override
  Future<List<SupportTicketModel>> getUserTickets() => _apiService.getUserTickets();

  @override
  Future<void> sendEmail({required String subject, required String message}) =>
      _apiService.sendEmail(subject: subject, message: message);
}
