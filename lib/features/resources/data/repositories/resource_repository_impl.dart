import '../../domain/repositories/resource_repository.dart';
import '../datasources/resource_api_service.dart';
import '../models/resource_model.dart';

/// Concrete implementation of [ResourceRepository].
class ResourceRepositoryImpl implements ResourceRepository {
  final ResourceApiService _api;

  ResourceRepositoryImpl(ResourceApiService api) : _api = api;

  @override
  Future<List<ResourceModel>> getResources() => _api.getResources();

  @override
  Future<ResourceModel> createResource({
    required String title,
    required String description,
    required String type,
    required String url,
    String? coverImageUrl,
    int duration = 0,
    int fileSize = 0,
  }) =>
      _api.createResource(
        title: title,
        description: description,
        type: type,
        url: url,
        coverImageUrl: coverImageUrl,
        duration: duration,
        fileSize: fileSize,
      );
}
