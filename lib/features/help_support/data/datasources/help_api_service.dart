import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/help_models.dart';

class HelpApiService {
  final Dio _dio;

  HelpApiService({required DioClient dioClient}) : _dio = dioClient.dio;

  Future<List<FaqModel>> getFaqs() async {
    try {
      final response = await _dio.get('/api/Help/faqs');
      final List data = response.data;
      return data.map((e) => FaqModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<HelpContactModel> getContactInfo() async {
    try {
      final response = await _dio.get('/api/Help/contact');
      return HelpContactModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createTicket({
    required String subject,
    required String message,
  }) async {
    try {
      await _dio.post('/api/Help/tickets', data: {
        'subject': subject,
        'message': message,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SupportTicketModel>> getUserTickets() async {
    try {
      final response = await _dio.get('/api/Help/tickets');
      final List data = response.data;
      return data.map((e) => SupportTicketModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmail({
    required String subject,
    required String message,
  }) async {
    try {
      await _dio.post('/api/Help/send-email', data: {
        'subject': subject,
        'message': message,
      });
    } catch (e) {
      rethrow;
    }
  }

  static String parseError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null && e.response?.data is Map) {
        return e.response?.data['message'] ?? e.response?.data['Message'] ?? 'An error occurred';
      }
      return e.message ?? 'Connection error';
    }
    return e.toString();
  }
}
