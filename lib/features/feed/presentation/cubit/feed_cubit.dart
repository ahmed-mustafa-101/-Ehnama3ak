import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ehnama3ak/core/storage/pref_manager.dart';
import '../../data/datasources/feed_api_service.dart';
import '../../domain/repositories/feed_repository.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final FeedRepository _repo;
  static const int _pageSize = 10;

  FeedCubit(this._repo) : super(const FeedState());

  Future<void> loadFeed({bool refresh = false}) async {
    if (refresh) {
      emit(state.copyWith(status: FeedStatus.loading, posts: [], currentPage: 1, hasReachedMax: false, clearError: true));
    } else if (state.posts.isEmpty) {
      emit(state.copyWith(status: FeedStatus.loading, clearError: true));
    }

    try {
      final page = refresh ? 1 : state.currentPage;
      final posts = await _repo.getPosts(page: page, pageSize: _pageSize);

      final hasReachedMax = posts.length < _pageSize;
      final newPosts = refresh ? posts : [...state.posts, ...posts];

      emit(state.copyWith(
        status: FeedStatus.loaded,
        posts: newPosts,
        currentPage: page + 1,
        hasReachedMax: hasReachedMax,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FeedStatus.error,
        errorMessage: FeedApiService.parseError(e),
        clearError: false,
      ));
    }
  }

  Future<void> loadMore() async {
    if (state.hasReachedMax || state.status == FeedStatus.loadingMore) return;
    if (state.posts.isEmpty) return;

    emit(state.copyWith(status: FeedStatus.loadingMore));

    try {
      final posts = await _repo.getPosts(page: state.currentPage, pageSize: _pageSize);
      final hasReachedMax = posts.length < _pageSize;
      final newPosts = [...state.posts, ...posts];

      emit(state.copyWith(
        status: FeedStatus.loaded,
        posts: newPosts,
        currentPage: state.currentPage + 1,
        hasReachedMax: hasReachedMax,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FeedStatus.loaded,
        errorMessage: FeedApiService.parseError(e),
      ));
    }
  }

  Future<void> createPost(String content, {String? imagePath}) async {
    if (content.trim().isEmpty && imagePath == null) return;

    var userId = await PrefManager.getUserId() ?? '';
    final token = await PrefManager.getToken();
    if (userId.isEmpty && (token == null || token.isEmpty)) {
      emit(state.copyWith(errorMessage: 'يجب تسجيل الدخول أولاً'));
      return;
    }

    try {
      final responsePost = await _repo.createPost(
        content: content.trim(),
        imagePath: imagePath,
        userId: userId,
      );

      final newPost = responsePost.copyWith(
        userName: 'Me',
        userProfileImage: 'assets/images/image_patient.png',
        imageUrl: (responsePost.imageUrl != null && responsePost.imageUrl!.isNotEmpty) 
            ? responsePost.imageUrl 
            : imagePath,
      );

      emit(state.copyWith(posts: [newPost, ...state.posts], clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: FeedApiService.parseError(e)));
    }
  }

  Future<void> updatePost(String postId, String content) async {
    final userId = await PrefManager.getUserId() ?? '';
    if (userId.isEmpty) return;

    try {
      await _repo.updatePost(postId: postId, content: content.trim(), userId: userId);
      final updated = state.posts.map((p) {
        if (p.id == postId) return p.copyWith(content: content.trim());
        return p;
      }).toList();
      emit(state.copyWith(posts: updated, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: FeedApiService.parseError(e)));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _repo.deletePost(postId);
      emit(state.copyWith(
        posts: state.posts.where((p) => p.id != postId).toList(),
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: FeedApiService.parseError(e)));
    }
  }

  Future<void> likePost(String postId) async {
    final index = state.posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    final post = state.posts[index];

    final isLiked = post.isLikedByMe;
    final updated = state.posts.map((p) {
      if (p.id == postId) {
        return p.copyWith(
          isLikedByMe: !isLiked,
          likesCount: isLiked ? p.likesCount - 1 : p.likesCount + 1,
        );
      }
      return p;
    }).toList();

    emit(state.copyWith(posts: updated));

    try {
      if (isLiked) {
        await _repo.unlikePost(postId, likeId: post.likeId);
      } else {
        await _repo.likePost(postId);
      }
    } catch (e) {
      final reverted = state.posts.map((p) {
        if (p.id == postId) {
          return p.copyWith(
            isLikedByMe: isLiked,
            likesCount: isLiked ? p.likesCount + 1 : p.likesCount - 1,
          );
        }
        return p;
      }).toList();
      emit(state.copyWith(posts: reverted, errorMessage: FeedApiService.parseError(e)));
    }
  }

  Future<void> addComment(String postId, String text) async {
    final userId = await PrefManager.getUserId() ?? '';
    if (userId.isEmpty) return;

    final updated = state.posts.map((p) {
      if (p.id == postId) return p.copyWith(commentsCount: p.commentsCount + 1);
      return p;
    }).toList();
    emit(state.copyWith(posts: updated));

    try {
      await _repo.addComment(postId: postId, text: text.trim(), userId: userId);
    } catch (e) {
      final reverted = state.posts.map((p) {
        if (p.id == postId) return p.copyWith(commentsCount: p.commentsCount - 1);
        return p;
      }).toList();
      emit(state.copyWith(posts: reverted, errorMessage: FeedApiService.parseError(e)));
    }
  }

  void incrementCommentCount(String postId) {
    final updated = state.posts.map((p) {
      if (p.id == postId) return p.copyWith(commentsCount: p.commentsCount + 1);
      return p;
    }).toList();
    emit(state.copyWith(posts: updated));
  }

  void clearError() => emit(state.copyWith(clearError: true));
}
