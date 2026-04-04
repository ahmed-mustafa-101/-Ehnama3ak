import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/core/storage/pref_manager.dart';
import '../../data/datasources/feed_api_service.dart';
import '../../domain/repositories/feed_repository.dart';
import 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final FeedRepository _repo;
  final String postId;
  static const int _pageSize = 10;

  CommentsCubit(this._repo, this.postId) : super(const CommentsState());

  Future<void> loadComments({bool refresh = false}) async {
    emit(state.copyWith(
      status: CommentsStatus.loading,
      comments: refresh ? [] : state.comments,
      currentPage: refresh ? 1 : state.currentPage,
      hasReachedMax: refresh ? false : state.hasReachedMax,
      clearError: true,
    ));

    try {
      final page = refresh ? 1 : state.currentPage;
      final comments = await _repo.getComments(postId: postId, page: page, pageSize: _pageSize);

      final hasReachedMax = comments.length < _pageSize;
      final newComments = refresh ? comments : [...state.comments, ...comments];

      emit(state.copyWith(
        status: CommentsStatus.loaded,
        comments: newComments,
        currentPage: page + 1,
        hasReachedMax: hasReachedMax,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CommentsStatus.error,
        errorMessage: FeedApiService.parseError(e),
      ));
    }
  }

  Future<void> loadMore() async {
    if (state.hasReachedMax || state.status == CommentsStatus.loadingMore) return;

    emit(state.copyWith(status: CommentsStatus.loadingMore));

    try {
      final comments = await _repo.getComments(
        postId: postId,
        page: state.currentPage,
        pageSize: _pageSize,
      );
      final hasReachedMax = comments.length < _pageSize;
      final newComments = [...state.comments, ...comments];

      emit(state.copyWith(
        status: CommentsStatus.loaded,
        comments: newComments,
        currentPage: state.currentPage + 1,
        hasReachedMax: hasReachedMax,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CommentsStatus.loaded,
        errorMessage: FeedApiService.parseError(e),
      ));
    }
  }

  Future<void> addComment(String text) async {
    final userId = await PrefManager.getUserId() ?? '';
    if (userId.isEmpty) return;

    try {
      final comment = await _repo.addComment(
        postId: postId,
        text: text.trim(),
        userId: userId,
      );
      emit(state.copyWith(
        comments: [comment, ...state.comments],
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: FeedApiService.parseError(e)));
    }
  }

  void clearError() => emit(state.copyWith(clearError: true));

  Future<void> updateComment(String commentId, String text) async {
    final userId = await PrefManager.getUserId() ?? '';
    if (userId.isEmpty) return;

    try {
      final updatedComment = await _repo.updateComment(
        commentId: commentId,
        text: text.trim(),
        userId: userId,
      );
      final updatedList = state.comments.map((c) {
        return c.id == commentId ? updatedComment : c;
      }).toList();
      emit(state.copyWith(comments: updatedList, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: FeedApiService.parseError(e)));
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _repo.deleteComment(commentId);
      final updatedList = state.comments.where((c) => c.id != commentId).toList();
      emit(state.copyWith(comments: updatedList, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: FeedApiService.parseError(e)));
    }
  }
}
