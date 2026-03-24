import '../../data/models/conversation_model.dart';

abstract class MessageRepository {
  Future<List<ConversationModel>> getConversations();
  Future<void> sendMessage({required String receiverId, required String message});
  Future<int> getUnreadCount();
}
