import 'dart:io';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';

/// Abstract contract for the messages feature.
abstract class MessageRepository {
  Future<List<ConversationModel>> getConversations();
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<MessageModel> sendMessage({
    required String receiverId,
    required String message,
    int messageType,
    File? attachment,
  });
  Future<void> markAsRead(String conversationId);
  Future<int> getUnreadCount();
  Future<void> pinMessage(int messageId);
  Future<void> unpinMessage(int messageId);
  Future<List<MessageModel>> getPinnedMessages(String conversationId);
  Future<bool> toggleFavorite(String conversationId);
  Future<List<ConversationModel>> getFavorites();
}
