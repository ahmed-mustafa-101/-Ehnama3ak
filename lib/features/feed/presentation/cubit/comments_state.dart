import 'package:equatable/equatable.dart';
import '../../data/models/comment_model.dart';

enum CommentsStatus { initial, loading, loaded, error, loadingMore }

class CommentsState extends Equatable {
  final CommentsStatus status;
  final List<CommentModel> comments;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;
  final CommentModel? replyToComment;

  const CommentsState({
    this.status = CommentsStatus.initial,
    this.comments = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.replyToComment,
  });

  CommentsState copyWith({
    CommentsStatus? status,
    List<CommentModel>? comments,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    CommentModel? replyToComment,
    bool clearError = false,
    bool clearReplyTo = false,
  }) {
    return CommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      replyToComment: clearReplyTo ? null : (replyToComment ?? this.replyToComment),
    );
  }

  @override
  List<Object?> get props => [status, comments, errorMessage, hasReachedMax, currentPage, replyToComment];
}
