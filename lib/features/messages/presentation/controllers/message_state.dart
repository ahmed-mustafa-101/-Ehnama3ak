// Backward-compatible re-exports so any existing imports still compile.
import 'conversations_state.dart';
export 'conversations_state.dart';

typedef MessageState = ConversationsState;
typedef MessageStatus = ConversationsStatus;
