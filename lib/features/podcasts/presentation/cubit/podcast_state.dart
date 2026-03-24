import 'package:equatable/equatable.dart';
import '../../data/models/podcast_model.dart';

/// Represents the four lifecycle states of the Podcast feature.
abstract class PodcastState extends Equatable {
  const PodcastState();

  @override
  List<Object?> get props => [];
}

/// Initial state — nothing has been fetched yet.
class PodcastInitial extends PodcastState {
  const PodcastInitial();
}

/// Podcasts are being loaded from the API.
class PodcastLoading extends PodcastState {
  const PodcastLoading();
}

/// Podcasts loaded successfully.
class PodcastLoaded extends PodcastState {
  final List<PodcastModel> podcasts;

  const PodcastLoaded(this.podcasts);

  @override
  List<Object?> get props => [podcasts];
}

/// An error occurred while loading podcasts.
class PodcastError extends PodcastState {
  final String message;

  const PodcastError(this.message);

  @override
  List<Object?> get props => [message];
}
