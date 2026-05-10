import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/resource_repository.dart';
import '../../data/models/resource_model.dart';
import 'resource_state.dart';

class ResourceCubit extends Cubit<ResourceState> {
  final ResourceRepository _repository;

  ResourceCubit(this._repository) : super(const ResourceInitial());

  List<ResourceModel> _allResources = [];
  String _lastQuery = '';

  // ─── Fetch ───────────────────────────────────────────────────────────────────

  Future<void> fetchResources() async {
    if (state is ResourceLoading) return;

    emit(const ResourceLoading());

    try {
      _allResources = await _repository.getResources();
      _applySearch();
    } catch (e) {
      emit(ResourceError(_clean(e)));
    }
  }

  // ─── Search ──────────────────────────────────────────────────────────────────

  void searchResources(String query) {
    _lastQuery = query.trim().toLowerCase();
    _applySearch();
  }

  void _applySearch() {
    if (_lastQuery.isEmpty) {
      emit(ResourceLoaded(_allResources));
    } else {
      final filtered = _allResources.where((r) {
        final titleMatch = r.title.toLowerCase().contains(_lastQuery);
        final descMatch = r.description.toLowerCase().contains(_lastQuery);
        return titleMatch || descMatch;
      }).toList();
      emit(ResourceLoaded(filtered));
    }
  }

  // ─── Refresh ─────────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    emit(const ResourceLoading());
    try {
      _allResources = await _repository.getResources();
      _applySearch();
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

      _allResources = [newResource, ..._allResources];
      _applySearch();
    } catch (e) {
      // Restore the previous list on error.
      _applySearch();
      // Then emit the error so the UI can show a snackbar.
      emit(ResourceError(_clean(e)));
    }
  }

  // ─── Helper ───────────────────────────────────────────────────────────────────

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '');
}
