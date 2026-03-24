import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/podcast_repository.dart';
import 'podcast_state.dart';

/// Manages the lifecycle of podcast data fetching.
class PodcastCubit extends Cubit<PodcastState> {
  final PodcastRepository _repository;

  PodcastCubit(this._repository) : super(const PodcastInitial());

  /// Fetches podcasts from the remote API.
  Future<void> fetchPodcasts() async {
    // Avoid re-fetching if already loaded (unless explicitly refreshed).
    if (state is PodcastLoading) return;

    emit(const PodcastLoading());

    try {
      final podcasts = await _repository.getPodcasts();
      emit(PodcastLoaded(podcasts));
    } catch (e) {
      emit(PodcastError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  /// Force-refresh the list from the API.
  Future<void> refresh() async {
    emit(const PodcastLoading());

    try {
      final podcasts = await _repository.getPodcasts();
      emit(PodcastLoaded(podcasts));
    } catch (e) {
      emit(PodcastError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
