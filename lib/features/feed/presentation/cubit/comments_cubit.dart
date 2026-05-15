import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/core/storage/pref_manager.dart';
import '../../data/datasources/feed_api_service.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../data/models/comment_model.dart';
import 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final FeedRepository _repo;
  final String postId;
  static const int _pageSize = 10;

  CommentsCubit(this._repo, this.postId) : super(const CommentsState());

  Future<List<CommentModel>> _enrichComments(List<CommentModel> list) async {
    final currentUserId = await PrefManager.getUserId() ?? '';
    final currentUserName = await PrefManager.getUserName();
    final currentUserImage = await PrefManager.getUserProfileImageUrl();

    if (currentUserId.isEmpty ||
        (currentUserName == null && currentUserImage == null)) {
      return list;
    }

    return list.map((c) {
      if (c.userId == currentUserId) {
        String newName = c.userName;
        String newImage = c.userProfileImage;
        bool changed = false;

        if (newName == 'Unknown' ||
            newName == 'Unknown User' ||
            newName == 'User' ||
            newName == 'userName' ||
            newName.isEmpty) {
          newName = currentUserName ?? 'User';
          changed = true;
        }
        if (newImage.isEmpty &&
            currentUserImage != null &&
            currentUserImage.isNotEmpty) {
          newImage = currentUserImage;
          changed = true;
        }

        if (changed) {
          return c.copyWith(
            userName: newName,
            userProfileImage: newImage,
            userAvatar: newImage,
          );
        }
      }
      return c;
    }).toList();
  }

  Future<void> loadComments({bool refresh = false}) async {
    emit(
      state.copyWith(
        status: CommentsStatus.loading,
        comments: refresh ? [] : state.comments,
        currentPage: refresh ? 1 : state.currentPage,
        hasReachedMax: refresh ? false : state.hasReachedMax,
        clearError: true,
      ),
    );

    try {
      final page = refresh ? 1 : state.currentPage;
      final comments = await _repo.getComments(
        postId: postId,
        page: page,
        pageSize: _pageSize,
      );
      final enrichedComments = await _enrichComments(comments);
      final hasReachedMax = comments.length < _pageSize;

      // Group replies if needed (simple flat list for now or nested?)
      // For now keep it simple: flat list is fine as we'll show "@user" or indentation.

      final newComments = refresh
          ? enrichedComments
          : [...state.comments, ...enrichedComments];

      emit(
        state.copyWith(
          status: CommentsStatus.loaded,
          comments: newComments,
          currentPage: page + 1,
          hasReachedMax: hasReachedMax,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommentsStatus.error,
          errorMessage: FeedApiService.parseError(e),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.hasReachedMax || state.status == CommentsStatus.loadingMore)
      return;

    emit(state.copyWith(status: CommentsStatus.loadingMore));

    try {
      final comments = await _repo.getComments(
        postId: postId,
        page: state.currentPage,
        pageSize: _pageSize,
      );
      final enrichedComments = await _enrichComments(comments);
      final hasReachedMax = comments.length < _pageSize;
      final newComments = [...state.comments, ...enrichedComments];

      emit(
        state.copyWith(
          status: CommentsStatus.loaded,
          comments: newComments,
          currentPage: state.currentPage + 1,
          hasReachedMax: hasReachedMax,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommentsStatus.loaded,
          errorMessage: FeedApiService.parseError(e),
        ),
      );
    }
  }

  Future<void> addComment(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final userId = await PrefManager.getUserId() ?? '';
    final userName = await PrefManager.getUserName() ?? 'User';
    final userImage = await PrefManager.getUserProfileImageUrl() ?? '';

    if (userId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please login to comment'));
      return;
    }

    // 1. Set posting status
    emit(state.copyWith(status: CommentsStatus.posting));

    // 2. Create optimistic/temporary comment
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempComment = CommentModel(
      id: tempId,
      postId: postId,
      userId: userId,
      userName: userName,
      userProfileImage: userImage,
      userAvatar: userImage,
      text: trimmedText,
      createdAt: DateTime.now(),
      parentId: state.replyToComment?.id,
    );

    // 3. Immediately update UI
    final updatedComments = [tempComment, ...state.comments];
    emit(
      state.copyWith(
        comments: updatedComments,
        clearReplyTo: true,
        clearError: true,
      ),
    );

    try {
      // 4. Perform API call
      final comment = await _repo.addComment(
        postId: postId,
        text: trimmedText,
        userId: userId,
        parentId: tempComment.parentId,
      );

      // 5. Enrich the real comment
      final enrichedComment = (await _enrichComments([comment])).first;

      // 6. Replace temporary comment with real one
      final finalizedComments = state.comments.map((c) {
        return c.id == tempId ? enrichedComment : c;
      }).toList();

      emit(
        state.copyWith(
          status: CommentsStatus.loaded,
          comments: finalizedComments,
        ),
      );
    } catch (e) {
      // 7. On failure, remove the temp comment and show error
      final revertedComments = state.comments
          .where((c) => c.id != tempId)
          .toList();
      emit(
        state.copyWith(
          status: CommentsStatus.error,
          comments: revertedComments,
          errorMessage: FeedApiService.parseError(e),
        ),
      );
    }
  }

  void setReplyTo(CommentModel comment) {
    emit(state.copyWith(replyToComment: comment));
  }

  void clearReplyTo() {
    emit(state.copyWith(clearReplyTo: true));
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
      final updatedList = state.comments
          .where((c) => c.id != commentId)
          .toList();
      emit(state.copyWith(comments: updatedList, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: FeedApiService.parseError(e)));
    }
  }
}
