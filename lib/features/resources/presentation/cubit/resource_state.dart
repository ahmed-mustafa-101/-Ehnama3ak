import 'package:equatable/equatable.dart';
import '../../data/models/resource_model.dart';

// ─── Base state ───────────────────────────────────────────────────────────────

abstract class ResourceState extends Equatable {
  const ResourceState();

  @override
  List<Object?> get props => [];
}

// ─── Initial ──────────────────────────────────────────────────────────────────

/// Nothing fetched yet.
class ResourceInitial extends ResourceState {
  const ResourceInitial();
}

// ─── Loading ─────────────────────────────────────────────────────────────────

/// Fetching the list of resources.
class ResourceLoading extends ResourceState {
  const ResourceLoading();
}

// ─── Loaded ──────────────────────────────────────────────────────────────────

/// Resources fetched successfully.
class ResourceLoaded extends ResourceState {
  final List<ResourceModel> resources;

  const ResourceLoaded(this.resources);

  /// Convenience: articles only.
  List<ResourceModel> get articles =>
      resources.where((r) => r.type == ResourceType.article || r.type == ResourceType.pdf).toList();

  /// Convenience: videos only.
  List<ResourceModel> get videos =>
      resources.where((r) => r.type == ResourceType.video).toList();

  /// Convenience: all resources for downloading.
  List<ResourceModel> get pdfs =>
      resources.where((r) => r.type == ResourceType.pdf).toList();

  @override
  List<Object?> get props => [resources];
}

// ─── Error ────────────────────────────────────────────────────────────────────

/// An error occurred while fetching or creating a resource.
class ResourceError extends ResourceState {
  final String message;

  const ResourceError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Creating ────────────────────────────────────────────────────────────────

/// A POST request is in-flight.
class ResourceCreating extends ResourceLoaded {
  const ResourceCreating(super.resources);
}

// ─── Create Success ──────────────────────────────────────────────────────────

/// POST finished and the new resource is in the list.
class ResourceCreateSuccess extends ResourceLoaded {
  const ResourceCreateSuccess(super.resources);
}
