import '../../data/models/resource_model.dart';

/// Domain contract — no Dio/framework dependencies.
abstract class ResourceRepository {
  Future<List<ResourceModel>> getResources();

  Future<ResourceModel> createResource({
    required String title,
    required String description,
    required String type,
    required String url,
    String? coverImageUrl,
    int duration,
    int fileSize,
  });
}
