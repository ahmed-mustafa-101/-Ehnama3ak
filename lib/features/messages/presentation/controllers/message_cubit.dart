import '../../domain/repositories/message_repository.dart';
import 'conversations_cubit.dart';

/// Backward-compatible alias so main.dart keeps working without changes.
/// New code should use [ConversationsCubit] directly.
class MessageCubit extends ConversationsCubit {
  MessageCubit(MessageRepository repo) : super(repo);

  /// No-op — unread count is now handled by [UnreadCubit].
  Future<void> loadUnreadCount() async {}
}
