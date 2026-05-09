import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/messages/data/models/conversation_model.dart';
import '../../features/messages/domain/repositories/message_repository.dart';
import '../../features/messages/presentation/controllers/chat_cubit.dart';
import '../../screens_app/messages/message_detail_screen.dart';

/// Opens a direct chat with [userId].
///
/// Strategy:
/// 1. Look for an existing conversation with [userId] in the list.
/// 2. If found → use the real conversationId.
/// 3. If not found → open with userId as a placeholder conversationId
///    (first message creates the conversation on the backend).
class ChatNavigator {
  ChatNavigator._();

  static Future<void> open(
    BuildContext context, {
    required String userId,
    required String userName,
    String? profileImage,
  }) async {
    final repo = context.read<MessageRepository>();

    // Try to find an existing conversation for this user
    String conversationId = userId; // fallback placeholder
    try {
      final list = await repo.getConversations();
      final match = list.where((c) => c.userId == userId).toList();
      if (match.isNotEmpty) {
        conversationId = match.first.conversationId;
      }
    } catch (_) {
      // Use placeholder — first send will create the conversation
    }

    if (!context.mounted) return;

    final synthetic = ConversationModel(
      conversationId: conversationId,
      userId: userId,
      userName: userName,
      userImage: profileImage ?? '',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isFavorite: false,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatCubit(
            repo: repo,
            conversationId: conversationId,
            receiverId: userId,
          )..loadMessages(),
          child: MessageDetailScreen(conversation: synthetic),
        ),
      ),
    );
  }
}
