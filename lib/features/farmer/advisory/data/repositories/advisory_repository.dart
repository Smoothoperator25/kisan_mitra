import '../models/advisory_model.dart';
import '../models/crop_model.dart';
import '../models/weather_model.dart';
import '../services/crop_api_service.dart';
import '../services/weather_service.dart';
import '../services/advisory_service.dart';

class AdvisoryRepository {
  final CropApiService _cropService = CropApiService();
  final WeatherService _weatherService = WeatherService();
  final AdvisoryService _advisoryService = AdvisoryService();

  // Cache for crops
  List<Crop>? _cachedCrops;

  Future<List<Crop>> getCrops() async {
    if (_cachedCrops != null && _cachedCrops!.isNotEmpty) {
      return _cachedCrops!;
    }
    _cachedCrops = await _cropService.getGlobalCrops();
    return _cachedCrops!;
  }

  Future<WeatherData> getWeather(double lat, double lon) async {
    return await _weatherService.fetchWeather(lat, lon);
  }

  Future<AdvisoryResponse> getAdvisory(AdvisoryRequest request) async {
    return await _advisoryService.generateAdvisory(request);
  }
}
