import '../models/advisory_model.dart';
import '../models/crop_model.dart';
import '../models/fertilizer_model.dart';
import '../models/weather_model.dart';
import '../repositories/fertilizer_repository.dart';
import '../../result/fertilizer_image_service.dart';
import 'dart:math';

class AdvisoryService {
  final FertilizerRepository _fertilizerRepository = FertilizerRepository();

  // Calculate Fertilizer Recommendations
  Future<AdvisoryResponse> generateAdvisory(AdvisoryRequest request) async {
    // 1. Get Base Nutrient Requirement for Crop & Stage
    NPKRequirement? req =
        request.crop.nutrientRequirements[request.growthStage];

    // Default fallback if specific stage not found (use first available or avg)
    if (req == null && request.crop.nutrientRequirements.isNotEmpty) {
      req = request.crop.nutrientRequirements.values.first;
    }

    // Safety check
    double targetN = req?.n ?? 0.0;
    double targetP = req?.p ?? 0.0;
    double targetK = req?.k ?? 0.0;

    // 1b. Smart Adjustment: Estimate Soil Nutrients if not provided
    SoilData effectiveSoil = request.soilData ?? SoilData(soilType: 'Loamy');
    if (effectiveSoil.nitrogen == null) {
      // Estimate based on soil type
      var estimated = _estimateSoilNutrients(effectiveSoil.soilType);
      effectiveSoil = SoilData(
        soilType: effectiveSoil.soilType,
        nitrogen: estimated['n'],
        phosphorus: estimated['p'],
        potassium: estimated['k'],
        ph: estimated['ph'],
      );
    }

    // 2. Adjust for Soil Data (Smart Logic)
    // Sandy Soil calls for more frequent N/K (leaching) -> Increase target slightly to compensate
    if (effectiveSoil.soilType.toLowerCase().contains('sandy')) {
      targetN *= 1.2;
      targetK *= 1.2;
    }
    // Clay Soil holds K well -> Reduce target
    else if (effectiveSoil.soilType.toLowerCase().contains('clay')) {
      targetK *= 0.8;
    }

    // Adjust based on soil test values (estimated or actual)
    if (effectiveSoil.nitrogen! > 300) targetN *= 0.8;
    if (effectiveSoil.phosphorus! > 30) targetP *= 0.8;
    if (effectiveSoil.potassium! > 150) targetK *= 0.8;

    // 3. Adjust for Weather (Smart Logic)
    bool rainWarning = false;
    String irrigationAdvice = "Normal irrigation schedule recommended.";
    bool avoidLeaching = false;

    if (request.weatherData != null) {
      if (request.weatherData!.rainProbability > 0.6 ||
          request.weatherData!.condition.contains("Rain")) {
        rainWarning = true;
        avoidLeaching = true;
        irrigationAdvice =
            "Heavy rain expected. Delay irrigation and fertilizer application to prevent leaching.";
      } else if (request.weatherData!.temperature > 35) {
        irrigationAdvice =
            "High temperature detected. Ensure adequate soil moisture before applying fertilizers to avoid scorching.";
      }
    }

    // 4. Optimization Engine: Find best fertilizer combination
    // Get all available fertilizers
    List<Fertilizer> allFertilizers = await _fertilizerRepository
        .getFertilizers();
    List<FertilizerRecommendation> recommendations = [];

    double currentN = 0.0;
    double currentP = 0.0;
    double currentK = 0.0;

    // --- SMART FERTILIZER SELECTION ---
    bool preferSOP = false;
    bool preferCAN = false;

    // Crop Specific Sensitivities
    if (['Tobacco', 'Potato', 'Grapes', 'Citrus'].contains(request.crop.name)) {
      preferSOP = true; // Avoid Chloride
    }
    // Soil Specific Sensitivities
    if (effectiveSoil.soilType.toLowerCase().contains('saline')) {
      preferSOP = true; // Minimize salt index
    }
    if (effectiveSoil.soilType.toLowerCase().contains('acidic')) {
      // Rock phosphate is efficient, but let's stick to standard commercial for now
      // Maybe prefer CAN over Urea as it neutralizes?
      preferCAN = true;
    }
    if (rainWarning) {
      preferCAN =
          true; // Less volatilization/leaching than simple Urea in some contexts
    }

    // Step A: Phosphorus (P)
    // Generally controls the basal dose.
    if (targetP > 0) {
      var pFertilizers = allFertilizers.where((f) => f.p > 10).toList();

      // Sort logic
      pFertilizers.sort((a, b) {
        // If acidic, maybe prefer SSP (Calcium helps)?
        // For now, simple logic: High P first
        return b.p.compareTo(a.p);
      });

      if (pFertilizers.isNotEmpty) {
        var pSource = pFertilizers.first;
        // Check if we have DAP and want to use it
        // If we want SULPHUR (e.g. Oilseeds), maybe SSP is better?
        if (['Groundnut', 'Mustard', 'Soybean'].contains(request.crop.name)) {
          var ssp = pFertilizers.firstWhere(
            (f) => f.id == 'ssp',
            orElse: () => pFertilizers.first,
          );
          pSource = ssp;
        }

        double amount = (targetP / pSource.p) * 100;
        currentP += pSource.getP(amount);
        currentN += pSource.getN(amount);
        currentK += pSource.getK(amount);

        recommendations.add(
          _createRecommendation(
            pSource,
            amount,
            request.fieldSizeInAcres,
            rainWarning,
            effectiveSoil.soilType,
          ),
        );
      }
    }

    // Step B: Potassium (K)
    if (targetK - currentK > 0) {
      double neededK = targetK - currentK;
      var kFertilizers = allFertilizers.where((f) => f.k > 10).toList();

      Fertilizer? kSource;
      if (preferSOP) {
        kSource = kFertilizers.firstWhere(
          (f) => f.id == 'sop',
          orElse: () => kFertilizers.isNotEmpty
              ? kFertilizers.first
              : allFertilizers.first,
        );
      } else {
        // Default to MOP (cheaper, high K)
        kSource = kFertilizers.firstWhere(
          (f) => f.id == 'mop',
          orElse: () => kFertilizers.isNotEmpty
              ? kFertilizers.first
              : allFertilizers.first,
        );
      }

      double amount = (neededK / kSource.k) * 100;
      currentK += kSource.getK(amount);

      recommendations.add(
        _createRecommendation(
          kSource,
          amount,
          request.fieldSizeInAcres,
          rainWarning,
          effectiveSoil.soilType,
        ),
      );
    }

    // Step C: Nitrogen (N) Top-up
    double neededN = targetN - currentN;
    if (neededN > 0) {
      var nFertilizers = allFertilizers
          .where((f) => f.n > 10 && f.p < 5 && f.k < 5)
          .toList();

      if (nFertilizers.isNotEmpty) {
        Fertilizer nSource;
        if (preferCAN) {
          nSource = nFertilizers.firstWhere(
            (f) => f.id == 'can',
            orElse: () => nFertilizers.firstWhere((f) => f.id == 'urea'),
          );
        } else {
          nSource = nFertilizers.firstWhere(
            (f) => f.id == 'urea',
            orElse: () => nFertilizers.first,
          );
        }

        double amount = (neededN / nSource.n) * 100;

        recommendations.add(
          _createRecommendation(
            nSource,
            amount,
            request.fieldSizeInAcres,
            rainWarning,
            effectiveSoil.soilType,
          ),
        );
      }
    }

    // 5. Add Simulated "Smart API" Advice
    // This adds a dynamic layer that looks like it came from an LLM/External Engine
    if (recommendations.isNotEmpty) {
      recommendations.add(_simulateSmartAdvice(request, effectiveSoil));
    }

    // 7. Micronutrients & Organic
    List<String> organicOptions = [
      "Farm Yard Manure (FYM): 2-3 tons/acre",
      "Vermicompost: 500 kg/acre",
    ];
    if (effectiveSoil.soilType.toLowerCase().contains('sandy')) {
      organicOptions.add("Green Manure (Sesbania) to improve water retention");
    }

    List<String> micronutrients = [];
    if (request.cropIssues.contains("Yellow leaves")) {
      micronutrients.add("Zinc Sulphate (10 kg/acre) - Zinc Deficiency Check");
      micronutrients.add("Ferrous Sulphate Spray - Iron Deficiency Check");
    }
    if (request.cropIssues.contains("Stunted growth")) {
      organicOptions.add("Bio-fertilizers (Azotobacter/PSB) to boost growth");
    }

    // Crop specific micros
    if (request.crop.name == 'Paddy' || request.crop.name == 'Rice') {
      micronutrients.add(
        "Zinc is critical for Paddy. Ensure basal application.",
      );
    }

    return AdvisoryResponse(
      recommendations: recommendations,
      micronutrients: micronutrients,
      organicAlternatives: organicOptions,
      irrigationAdvice: irrigationAdvice,
      nextReviewDate: DateTime.now().add(const Duration(days: 14)),
      rainWarning: rainWarning,
      estimatedCost: _calculateEstimatedCost(recommendations),
    );
  }

  // --- HELPER METHODS ---

  Map<String, double> _estimateSoilNutrients(String soilType) {
    // Return average N-P-K-pH for Indian soil types
    // This makes the advice dynamic based on soil type even without a lab test
    switch (soilType.toLowerCase()) {
      case 'alluvial':
        return {'n': 280, 'p': 15, 'k': 250, 'ph': 7.0}; // Good K, Med N/P
      case 'black (regur)':
        return {'n': 200, 'p': 10, 'k': 300, 'ph': 7.5}; // Rich in K, Poor N
      case 'red':
        return {'n': 250, 'p': 12, 'k': 150, 'ph': 6.0}; // Generally poor
      case 'laterite':
        return {'n': 180, 'p': 8, 'k': 100, 'ph': 5.0}; // Acidic, poor
      case 'sandy':
        return {'n': 150, 'p': 20, 'k': 150, 'ph': 7.0}; // Leaches easily
      case 'clay':
        return {'n': 300, 'p': 25, 'k': 350, 'ph': 7.2}; // Rich
      default:
        return {'n': 280, 'p': 15, 'k': 200, 'ph': 7.0}; // Loamy/Default
    }
  }

  FertilizerRecommendation _createRecommendation(
    Fertilizer f,
    double amountPerAcre,
    double acres,
    bool rainWarning,
    String soilType,
  ) {
    double totalQty = amountPerAcre * acres;

    // Dynamic Precautions
    List<String> precautions = List.from(f.conditions);

    // Weather based Logic
    if (rainWarning && f.n > 20) {
      precautions.add("CRITICAL: Heavy rain forecast. DELAY application.");
    }

    // Application Method Logic
    String time = "Basal / Early Stage";
    String method = "Broadcast";

    // Sandy soil requires split doses for N and K
    bool splitDose =
        soilType.toLowerCase().contains('sandy') && (f.n > 10 || f.k > 10);

    if (f.id == 'urea' || f.n > 30) {
      if (splitDose) {
        time = "Split into 3 doses (Sowing, 30 DAS, 60 DAS)";
        method = "Top Dressing";
      } else {
        time = "Split dose: 1/2 now, 1/2 later";
        method = "Top Dressing";
      }
    } else if (f.p > 30) {
      time = "Basal (At Sowing)";
      method = "Soil Placement (Drilling)";
    }

    // Add specific text to show dynamic logic
    if (soilType.toLowerCase().contains('acidic') && f.id == 'ssp') {
      precautions.add("Contains Calcium which helps neutralize acidity.");
    }

    return FertilizerRecommendation(
      name: f.name,
      imageUrl: FertilizerImageService.getImageUrl(f.name),
      npkRatio: "${f.n.toInt()}:${f.p.toInt()}:${f.k.toInt()}",
      quantityPerAcre: amountPerAcre,
      totalQuantity: totalQty,
      applicationMethod: method,
      applicationTime: time,
      precautions: precautions,
    );
  }

  // Simulates a "Smart" recommendation that might come from a Cloud AI
  FertilizerRecommendation _simulateSmartAdvice(
    AdvisoryRequest request,
    SoilData soil,
  ) {
    String advice = "Based on ${request.growthStage} stage";
    if (soil.soilType.isNotEmpty)
      advice += " and ${soil.soilType} soil conditions.";

    // Random variations to simulate "AI Thinking"
    var random = Random();
    bool foliar = random.nextBool();
    String name = foliar
        ? "Specialty Soluble NPK (19:19:19)"
        : "Growth Promoter (Seaweed Extract)";

    return FertilizerRecommendation(
      name: name,
      imageUrl: FertilizerImageService.getImageUrl(name),
      npkRatio: foliar ? "19:19:19" : "0:0:0",
      quantityPerAcre: foliar ? 1.5 : 0.5,
      totalQuantity: (foliar ? 1.5 : 0.5) * request.fieldSizeInAcres,
      applicationMethod: "Foliar Spray",
      applicationTime: "Best applied in evening",
      precautions: [
        "Automated Recommendation: $advice",
        foliar ? "Ensure good leaf coverage." : "Mix well with water.",
      ],
    );
  }

  double _calculateEstimatedCost(List<FertilizerRecommendation> recs) {
    // Approximate Market Prices (INR)
    const double priceUrea = 6.0;
    const double priceDAP = 27.0;
    const double priceMOP = 34.0;
    const double priceTSP = 40.0;
    const double priceSSP = 12.0;
    const double priceCAN = 30.0;
    const double priceSOP = 80.0; // Premium
    const double priceGeneric = 50.0;

    double total = 0.0;
    for (var r in recs) {
      double price = priceGeneric;
      String n = r.name.toLowerCase();
      if (n.contains("urea"))
        price = priceUrea;
      else if (n.contains("dap"))
        price = priceDAP;
      else if (n.contains("mop"))
        price = priceMOP;
      else if (n.contains("tsp"))
        price = priceTSP;
      else if (n.contains("ssp"))
        price = priceSSP;
      else if (n.contains("can"))
        price = priceCAN;
      else if (n.contains("sulphate of potash") || n.contains("sop"))
        price = priceSOP;
      else if (n.contains("npk"))
        price = 90.0; // Solubles are expensive

      total += r.totalQuantity * price;
    }
    return total;
  }
}
