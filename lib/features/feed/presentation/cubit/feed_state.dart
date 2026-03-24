import 'package:equatable/equatable.dart';
import '../../data/models/post_model.dart';

enum FeedStatus { initial, loading, loaded, error, loadingMore }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<PostModel> posts;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<PostModel>? posts,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
    bool clearError = false,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [status, posts, errorMessage, hasReachedMax, currentPage];
}
