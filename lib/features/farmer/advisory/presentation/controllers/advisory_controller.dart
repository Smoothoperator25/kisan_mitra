import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/crop_model.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/advisory_model.dart';
import '../../data/repositories/advisory_repository.dart';
import '../../data/services/soil_service.dart';

class AdvisoryController with ChangeNotifier {
  final AdvisoryRepository _repository = AdvisoryRepository();

  // State Variables
  bool isLoading = false;
  bool isCalculating = false;
  String? errorMessage;

  // Data
  WeatherData? currentWeather;
  AdvisoryResponse? advisoryResult;

  // Inputs
  String selectedGrowthStage = 'Seedling'; // Default
  double fieldSize = 1.0;
  bool isHectares = false;

  // Soil Inputs
  String selectedSoilType = 'Loamy';

  // Crop Issues
  List<String> selectedIssues = [];

  // Lifecycle
  AdvisoryController() {
    _init();
  }

  Future<void> _init() async {
    isLoading = true;
    notifyListeners();
    try {
      await fetchWeather(); // Auto-fetch weather on load
    } catch (e) {
      errorMessage = "Failed to load initial data: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeather() async {
    try {
      // Get Location
      Position position = await _determinePosition();
      currentWeather = await _repository.getWeather(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      print("Location/Weather Error: $e");
      // Fallback to mock if permission denied or error
      currentWeather = await _repository.getWeather(0, 0);
    }
    notifyListeners();
  }

  // Calculate Advisory
  Future<void> calculateAdvisory(Crop selectedCrop) async {
    isCalculating = true;
    errorMessage = null;
    notifyListeners();

    try {
      final request = AdvisoryRequest(
        crop: selectedCrop,
        growthStage: selectedGrowthStage,
        fieldSize: fieldSize,
        isHectares: isHectares,
        soilData: SoilData(soilType: selectedSoilType),
        weatherData: currentWeather,
        cropIssues: selectedIssues,
        location: "Current Location",
      );

      advisoryResult = await _repository.getAdvisory(request);
    } catch (e) {
      errorMessage = "Calculation failed: $e";
    } finally {
      isCalculating = false;
      notifyListeners();
    }
  }

  // Setters for UI
  void setGrowthStage(String stage) {
    selectedGrowthStage = stage;
    notifyListeners();
  }

  void setFieldSize(double size) {
    fieldSize = size;
    notifyListeners();
  }

  void toggleUnit(bool value) {
    isHectares = value;
    notifyListeners();
  }

  void setSoilType(String type) {
    selectedSoilType = type;
    notifyListeners();
  }

  void toggleIssue(String issue) {
    if (selectedIssues.contains(issue)) {
      selectedIssues.remove(issue);
    } else {
      selectedIssues.add(issue);
    }
    notifyListeners();
  }

  void reset() {
    advisoryResult = null;
    errorMessage = null;
    selectedIssues = [];
    notifyListeners();
  }

  // Geolocator Helper
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }
}
