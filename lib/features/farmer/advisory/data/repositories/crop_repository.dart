import '../models/crop_model.dart';
import '../services/crop_api_service.dart';

class CropRepository {
  final CropApiService _apiService = CropApiService();

  // In-memory cache
  List<Crop>? _cachedCrops;

  Future<List<Crop>> getCrops({bool forceRefresh = false}) async {
    if (_cachedCrops != null && !forceRefresh) {
      return _cachedCrops!;
    }

    try {
      final crops = await _apiService.getGlobalCrops();
      _cachedCrops = crops;
      return crops;
    } catch (e) {
      rethrow;
    }
  }

  // Clear cache if needed
  void clearCache() {
    _cachedCrops = null;
  }
}
