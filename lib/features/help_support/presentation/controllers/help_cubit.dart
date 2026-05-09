import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/help_api_service.dart';
import '../../domain/repositories/help_repository.dart';
import 'help_state.dart';

class HelpCubit extends Cubit<HelpState> {
  final HelpRepository _repo;

  HelpCubit(this._repo) : super(const HelpState());

  Future<void> fetchFaqs() async {
    emit(state.copyWith(status: HelpStatus.loading));
    try {
      final faqs = await _repo.getFaqs();
      emit(state.copyWith(status: HelpStatus.success, faqs: faqs));
    } catch (e) {
      emit(state.copyWith(status: HelpStatus.failure, errorMessage: HelpApiService.parseError(e)));
    }
  }

  Future<void> fetchContactInfo() async {
    emit(state.copyWith(status: HelpStatus.loading));
    try {
      final contact = await _repo.getContactInfo();
      emit(state.copyWith(status: HelpStatus.success, contactInfo: contact));
    } catch (e) {
      emit(state.copyWith(status: HelpStatus.failure, errorMessage: HelpApiService.parseError(e)));
    }
  }

  Future<void> fetchUserTickets() async {
    emit(state.copyWith(status: HelpStatus.loading));
    try {
      final tickets = await _repo.getUserTickets();
      emit(state.copyWith(status: HelpStatus.success, tickets: tickets));
    } catch (e) {
      emit(state.copyWith(status: HelpStatus.failure, errorMessage: HelpApiService.parseError(e)));
    }
  }

  Future<void> createTicket(String subject, String message) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await _repo.createTicket(subject: subject, message: message);
      await fetchUserTickets();
      emit(state.copyWith(isSubmitting: false, status: HelpStatus.success, successMessage: 'ticket_created'));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, status: HelpStatus.failure, errorMessage: HelpApiService.parseError(e)));
    }
  }

  Future<void> sendSupportEmail(String subject, String message) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await _repo.sendEmail(subject: subject, message: message);
      emit(state.copyWith(isSubmitting: false, status: HelpStatus.success, successMessage: 'email_sent'));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, status: HelpStatus.failure, errorMessage: HelpApiService.parseError(e)));
    }
  }
  
  void resetStatus() {
    emit(state.copyWith(status: HelpStatus.initial, errorMessage: null, successMessage: null));
  }
}
