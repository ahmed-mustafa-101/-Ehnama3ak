import 'package:equatable/equatable.dart';
import '../../data/models/comment_model.dart';

enum CommentsStatus { initial, loading, loaded, error, loadingMore }

class CommentsState extends Equatable {
  final CommentsStatus status;
  final List<CommentModel> comments;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;

  const CommentsState({
    this.status = CommentsStatus.initial,
    this.comments = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  CommentsState copyWith({
    CommentsStatus? status,
    List<CommentModel>? comments,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    bool clearError = false,
  }) {
    return CommentsState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, comments, errorMessage, hasReachedMax, currentPage];
}
