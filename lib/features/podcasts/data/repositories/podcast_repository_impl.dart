import '../../domain/repositories/podcast_repository.dart';
import '../datasources/podcast_api_service.dart';
import '../models/podcast_model.dart';

/// Concrete implementation of [PodcastRepository] backed by [PodcastApiService].
class PodcastRepositoryImpl implements PodcastRepository {
  final PodcastApiService _api;

  PodcastRepositoryImpl(PodcastApiService api) : _api = api;

  @override
  Future<List<PodcastModel>> getPodcasts() => _api.getPodcasts();
}
