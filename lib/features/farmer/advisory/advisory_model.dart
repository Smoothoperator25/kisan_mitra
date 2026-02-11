/// Data models for Fertilizer Advisory feature
/// Contains models for crop phases, fertilizer recommendations, and safety guidelines

/// Enum representing different crop growth phases
enum CropPhase {
  germination('Germination'),
  vegetative('Vegetative (Growing)'),
  flowering('Flowering'),
  fruiting('Fruiting');

  final String label;
  const CropPhase(this.label);

  /// Get CropPhase from string label
  static CropPhase? fromLabel(String label) {
    for (var phase in CropPhase.values) {
      if (phase.label == label) return phase;
    }
    return null;
  }
}

/// Model for a fertilizer recommendation
class FertilizerRecommendation {
  final String name;
  final String npk;
  final double dosagePerAcre;
  final double totalQuantity; // dosagePerAcre × fieldSize
  final String? applicationInstructions;
  final bool isOptimized; // Flag for best match

  FertilizerRecommendation({
    required this.name,
    required this.npk,
    required this.dosagePerAcre,
    required this.totalQuantity,
    this.applicationInstructions,
    this.isOptimized = false,
  });

  /// Create from Firestore document data
  factory FertilizerRecommendation.fromFirestore({
    required Map<String, dynamic> data,
    required double fieldSize,
    bool isOptimized = false,
  }) {
    final dosagePerAcre = (data['dosagePerAcre'] as num?)?.toDouble() ?? 0.0;
    final totalQuantity = dosagePerAcre * fieldSize;

    return FertilizerRecommendation(
      name: data['name'] as String? ?? 'Unknown',
      npk: data['npk'] as String? ?? 'N/A',
      dosagePerAcre: dosagePerAcre,
      totalQuantity: totalQuantity,
      applicationInstructions: data['applicationInstructions'] as String?,
      isOptimized: isOptimized,
    );
  }
}

/// Model for safety guidelines
class SafetyGuideline {
  final String guideline;
  final int order;

  SafetyGuideline({required this.guideline, required this.order});

  /// Create from Firestore document data
  factory SafetyGuideline.fromFirestore(Map<String, dynamic> data) {
    return SafetyGuideline(
      guideline: data['guideline'] as String? ?? '',
      order: data['order'] as int? ?? 0,
    );
  }
}

/// Model for crop information
class Crop {
  final String name;
  final String? imageUrl;

  Crop({required this.name, this.imageUrl});
}
