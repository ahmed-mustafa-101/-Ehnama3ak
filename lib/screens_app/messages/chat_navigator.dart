import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/messages/data/models/conversation_model.dart';
import '../../features/messages/domain/repositories/message_repository.dart';
import '../../features/messages/presentation/controllers/chat_cubit.dart';
import '../../screens_app/messages/message_detail_screen.dart';

/// Opens a direct chat with a user identified by [userId] and [userName].
///
/// Strategy:
/// 1. If [userId] looks like a GUID → use it directly as receiverId.
/// 2. Look for an existing conversation matching [userId] OR [userName].
/// 3. If a real conversation is found → use its conversationId + real userId.
/// 4. If not found → open with userId as a placeholder conversationId
///    (first message will create the conversation on the backend).
class ChatNavigator {
  ChatNavigator._();

  /// Returns true if [s] looks like a GUID (contains hyphens and is 36 chars).
  static bool _isGuid(String s) =>
      s.length == 36 && s.contains('-');

  static Future<void> open(
    BuildContext context, {
    required String userId,
    required String userName,
    String? profileImage,
  }) async {
    final repo = context.read<MessageRepository>();

    log('[ChatNavigator] Opening chat → userId="$userId", userName="$userName"');

    String resolvedUserId = userId;
    String conversationId = userId; // fallback placeholder

    try {
      final list = await repo.getConversations();
      log('[ChatNavigator] Found ${list.length} existing conversations');

      ConversationModel? match;

      // 1. Try exact userId match first
      match = list.cast<ConversationModel?>().firstWhere(
            (c) => c!.userId == userId,
            orElse: () => null,
          );

      // 2. If no exact match and userId is NOT a GUID, try matching by userName
      if (match == null && !_isGuid(userId)) {
        log('[ChatNavigator] userId "$userId" is not a GUID, trying to match by name: "$userName"');
        match = list.cast<ConversationModel?>().firstWhere(
              (c) =>
                  c!.userName.toLowerCase().trim() ==
                  userName.toLowerCase().trim(),
              orElse: () => null,
            );
      }

      if (match != null) {
        conversationId = match.conversationId;
        resolvedUserId = match.userId;
        log('[ChatNavigator] Matched conversation: id="$conversationId", userId="$resolvedUserId"');
      } else {
        log('[ChatNavigator] No existing conversation found, will create on first send');
        // If userId is a GUID, use it; otherwise keep original as placeholder
        resolvedUserId = userId;
        conversationId = userId;
      }
    } catch (e) {
      log('[ChatNavigator] Error fetching conversations: $e');
      // Use placeholder — first send will create the conversation
    }

    if (!context.mounted) return;

    final synthetic = ConversationModel(
      conversationId: conversationId,
      userId: resolvedUserId,
      userName: userName,
      userImage: profileImage ?? '',
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isFavorite: false,
    );

    log('[ChatNavigator] Navigating with conversationId="$conversationId", receiverId="$resolvedUserId"');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatCubit(
            repo: repo,
            conversationId: conversationId,
            receiverId: resolvedUserId,
          )..loadMessages(),
          child: MessageDetailScreen(conversation: synthetic),
        ),
      ),
    );
  }
}
