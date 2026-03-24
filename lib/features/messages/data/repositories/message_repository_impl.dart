import '../../data/datasources/message_api_service.dart';
import '../../data/models/conversation_model.dart';
import '../../domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageApiService _apiService;

  MessageRepositoryImpl(this._apiService);

  @override
  Future<List<ConversationModel>> getConversations() => _apiService.getConversations();

  @override
  Future<void> sendMessage({required String receiverId, required String message}) =>
      _apiService.sendMessage(receiverId: receiverId, message: message);

  @override
  Future<int> getUnreadCount() => _apiService.getUnreadCount();
}
