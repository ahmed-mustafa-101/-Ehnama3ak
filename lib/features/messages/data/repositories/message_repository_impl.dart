import 'dart:io';
import '../../data/datasources/message_api_service.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageApiService _api;

  MessageRepositoryImpl(this._api);

  @override
  Future<List<ConversationModel>> getConversations() => _api.getConversations();

  @override
  Future<List<MessageModel>> getMessages(String conversationId) =>
      _api.getMessages(conversationId);

  @override
  Future<MessageModel> sendMessage({
    required String receiverId,
    required String message,
    int messageType = 0,
    File? attachment,
  }) =>
      _api.sendMessage(
        receiverId: receiverId,
        message: message,
        messageType: messageType,
        attachment: attachment,
      );

  @override
  Future<void> markAsRead(String conversationId) =>
      _api.markAsRead(conversationId);

  @override
  Future<int> getUnreadCount() => _api.getUnreadCount();

  @override
  Future<void> pinMessage(int messageId) => _api.pinMessage(messageId);

  @override
  Future<void> unpinMessage(int messageId) => _api.unpinMessage(messageId);

  @override
  Future<List<MessageModel>> getPinnedMessages(String conversationId) =>
      _api.getPinnedMessages(conversationId);

  @override
  Future<bool> toggleFavorite(String conversationId) =>
      _api.toggleFavorite(conversationId);

  @override
  Future<List<ConversationModel>> getFavorites() => _api.getFavorites();
}
