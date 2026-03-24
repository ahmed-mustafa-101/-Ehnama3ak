import '../../data/models/podcast_model.dart';

/// Abstract contract for the podcast data layer.
abstract class PodcastRepository {
  Future<List<PodcastModel>> getPodcasts();
}
