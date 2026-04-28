import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';

abstract class MessageRepository {
  Future<List<ConversationModel>> getConversations();
  Future<List<MessageModel>> getMessages(String otherUserId);
  Future<void> sendMessage({required String receiverId, required String message});
  Future<int> getUnreadCount();
}
