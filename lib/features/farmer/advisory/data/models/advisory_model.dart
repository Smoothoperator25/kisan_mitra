import 'weather_model.dart';
import 'crop_model.dart';

class AdvisoryRequest {
  final Crop crop;
  final String growthStage;
  final double fieldSize; // in acres
  final bool isHectares; // if true, convert fieldSize to acres for calculation
  final SoilData? soilData;
  final WeatherData? weatherData;
  final List<String> cropIssues;
  final String location;

  AdvisoryRequest({
    required this.crop,
    required this.growthStage,
    required this.fieldSize,
    this.isHectares = false,
    this.soilData,
    this.weatherData,
    required this.cropIssues,
    required this.location,
  });

  // Helper to get field size in acres
  double get fieldSizeInAcres => isHectares ? fieldSize * 2.47105 : fieldSize;
}

class SoilData {
  final double? nitrogen; // ppm or level index
  final double? phosphorus;
  final double? potassium;
  final double? ph;
  final String soilType;

  SoilData({
    this.nitrogen,
    this.phosphorus,
    this.potassium,
    this.ph,
    required this.soilType,
  });
}

class AdvisoryResponse {
  final List<FertilizerRecommendation> recommendations;
  final List<String> micronutrients;
  final List<String> organicAlternatives;
  final String irrigationAdvice;
  final DateTime nextReviewDate;
  final bool rainWarning;
  final double estimatedCost;

  AdvisoryResponse({
    required this.recommendations,
    required this.micronutrients,
    required this.organicAlternatives,
    required this.irrigationAdvice,
    required this.nextReviewDate,
    required this.rainWarning,
    required this.estimatedCost,
  });
}

class FertilizerRecommendation {
  final String name;
  final String imageUrl;
  final String npkRatio;
  final double quantityPerAcre;
  final double totalQuantity;
  final String applicationMethod;
  final String applicationTime;
  final List<String> precautions;
  final String? manufacturer;

  FertilizerRecommendation({
    required this.name,
    required this.imageUrl,
    required this.npkRatio,
    required this.quantityPerAcre,
    required this.totalQuantity,
    required this.applicationMethod,
    required this.applicationTime,
    required this.precautions,
    this.manufacturer,
  });
}
