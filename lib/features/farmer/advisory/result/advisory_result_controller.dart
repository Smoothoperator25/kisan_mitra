import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/advisory_model.dart';
import '../data/models/crop_model.dart';
import '../data/models/weather_model.dart';
import '../data/services/advisory_service.dart';
import '../data/services/crop_api_service.dart';

class AdvisoryResultController extends ChangeNotifier {
  final AdvisoryService _advisoryService = AdvisoryService();
  final CropApiService _cropService = CropApiService();
  Timer? _debounceTimer;

  // Inputs
  final Map<String, dynamic> _inputs = {
    'crop': 'Wheat',
    'growth_stage': 'Vegetative', // Default stage
    'field_size': 4.5,
    'soil_nitrogen': 140.0,
    'soil_phosphorus': 40.0,
    'soil_potassium': 180.0,
    'soil_ph': 6.5,
    'soil_type': 'Loam', // Default valid soil type
    'crop_issues': <String>[],
    'weather_data': 'Clear',
  };

  // State
  List<FertilizerRecommendation> _recommendations = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<Crop> _availableCrops = [];

  // Getters
  List<FertilizerRecommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get inputs => _inputs;
  List<Crop> get availableCrops => _availableCrops;

  AdvisoryResultController() {
    // Initial fetch
    _loadCropsAndRecommendations();
  }

  Future<void> _loadCropsAndRecommendations() async {
    _isLoading = true;
    notifyListeners();
    try {
      _availableCrops = await _cropService.getGlobalCrops();
      // Ensure default crop exists in list or pick first
      if (_availableCrops.isNotEmpty) {
        if (!_availableCrops.any((c) => c.name == _inputs['crop'])) {
          // If default 'Wheat' not found, use first available
          _inputs['crop'] = _availableCrops.first.name;
        }
      }
      await fetchRecommendations();
    } catch (e) {
      _errorMessage = 'Failed to load initial data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateInput(String key, dynamic value) {
    if (_inputs[key] != value) {
      _inputs[key] = value;
      notifyListeners();
      _debounceFetch();
    }
  }

  void _debounceFetch() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchRecommendations();
    });
  }

  Future<void> fetchRecommendations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_availableCrops.isEmpty) {
        _availableCrops = await _cropService.getGlobalCrops();
      }

      // Find Crop Object
      Crop selectedCrop = _availableCrops.firstWhere(
        (c) => c.name == _inputs['crop'],
        orElse: () => _availableCrops.isNotEmpty
            ? _availableCrops.first
            : throw Exception("No crops available"),
      );

      // Update growth stage if not valid for this crop
      if (!selectedCrop.growthStages.contains(_inputs['growth_stage'])) {
        if (selectedCrop.growthStages.isNotEmpty) {
          _inputs['growth_stage'] = selectedCrop.growthStages.first;
          // No need to notify here as we are inside a process that will update UI at end,
          // but effectively we changed the state.
        }
      }

      // Construct Weather Data (Mock based on input string for now)
      WeatherData weather;
      if (_inputs['weather_data'].toString().contains('Rain')) {
        weather = WeatherData(
          temperature: 28.0,
          humidity: 80.0,
          windSpeed: 10.0,
          rainProbability: 0.8,
          condition: 'Rainy',
          iconUrl: '',
        );
      } else {
        weather = WeatherData.initial();
      }

      // Construct Soil Data
      SoilData soil = SoilData(
        nitrogen: (_inputs['soil_nitrogen'] as num).toDouble(),
        phosphorus: (_inputs['soil_phosphorus'] as num).toDouble(),
        potassium: (_inputs['soil_potassium'] as num).toDouble(),
        ph: (_inputs['soil_ph'] as num).toDouble(),
        soilType:
            _inputs['soil_type'] ?? 'Loam', // Use string from inputs or default
      );

      final request = AdvisoryRequest(
        crop: selectedCrop,
        growthStage:
            _inputs['growth_stage'] ??
            (selectedCrop.growthStages.isNotEmpty
                ? selectedCrop.growthStages.first
                : ''),
        fieldSize: (_inputs['field_size'] as num).toDouble(),
        soilData: soil,
        weatherData: weather,
        cropIssues: List<String>.from(_inputs['crop_issues'] ?? []),
        location: "Unknown",
      );

      final response = await _advisoryService.generateAdvisory(request);
      _recommendations = response.recommendations;
    } catch (e) {
      _errorMessage = 'Failed to load recommendations: $e';
      print("Error fetching recommendations: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
