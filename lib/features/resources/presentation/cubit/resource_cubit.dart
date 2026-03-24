import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/resource_repository.dart';
import '../../data/models/resource_model.dart';
import 'resource_state.dart';

class ResourceCubit extends Cubit<ResourceState> {
  final ResourceRepository _repository;

  ResourceCubit(this._repository) : super(const ResourceInitial());

  // ─── Fetch ───────────────────────────────────────────────────────────────────

  Future<void> fetchResources() async {
    if (state is ResourceLoading) return;

    emit(const ResourceLoading());

    try {
      final resources = await _repository.getResources();
      emit(ResourceLoaded(resources));
    } catch (e) {
      emit(ResourceError(_clean(e)));
    }
  }

  // ─── Refresh ─────────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    emit(const ResourceLoading());
    try {
      final resources = await _repository.getResources();
      emit(ResourceLoaded(resources));
    } catch (e) {
      emit(ResourceError(_clean(e)));
    }
  }

  // ─── Create ──────────────────────────────────────────────────────────────────

  Future<void> createResource({
    required String title,
    required String description,
    required String type,
    required String url,
    String? coverImageUrl,
    int duration = 0,
    int fileSize = 0,
  }) async {
    // Keep current list visible while posting.
    final List<ResourceModel> currentList =
        (state is ResourceLoaded) ? (state as ResourceLoaded).resources : <ResourceModel>[];

    emit(ResourceCreating(List<ResourceModel>.from(currentList)));

    try {
      final newResource = await _repository.createResource(
        title: title,
        description: description,
        type: type,
        url: url,
        coverImageUrl: coverImageUrl,
        duration: duration,
        fileSize: fileSize,
      );

      final updated = [newResource, ...currentList];
      emit(ResourceCreateSuccess(updated));
    } catch (e) {
      // Restore the previous list on error.
      emit(ResourceLoaded(List<ResourceModel>.from(currentList)));
      // Then emit the error so the UI can show a snackbar.
      emit(ResourceError(_clean(e)));
    }
  }

  // ─── Helper ───────────────────────────────────────────────────────────────────

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '');
}
