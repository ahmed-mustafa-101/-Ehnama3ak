import 'package:equatable/equatable.dart';
import '../../data/models/conversation_model.dart';

enum ConversationsStatus { initial, loading, success, error }

class ConversationsState extends Equatable {
  final ConversationsStatus status;
  final List<ConversationModel> conversations;
  final List<ConversationModel> favorites;
  final String? errorMessage;

  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const [],
    this.favorites = const [],
    this.errorMessage,
  });

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<ConversationModel>? conversations,
    List<ConversationModel>? favorites,
    String? errorMessage,
  }) =>
      ConversationsState(
        status: status ?? this.status,
        conversations: conversations ?? this.conversations,
        favorites: favorites ?? this.favorites,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, conversations, favorites, errorMessage];
}
