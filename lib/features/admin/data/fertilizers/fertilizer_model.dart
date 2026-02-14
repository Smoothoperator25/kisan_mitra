import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Fertilizer in the fertilizers collection
class Fertilizer {
  final String id;
  final String name;
  final String imageUrl;
  final String npkComposition;
  final String applicationMethod;
  final String suitableCrops;
  final double recommendedDosage;
  final String dosageUnit; // "KG/ACRE" or "G/SQM"
  final String safetyNotes;

  // New enhanced fields
  final String description; // Detailed description
  final String manufacturer; // Brand/Company name
  final String category; // Organic, Inorganic, Bio-fertilizer, etc.
  final String form; // Granular, Liquid, Powder
  final String shelfLife; // Storage duration (e.g., "2 years")
  final String storageInstructions; // How to store
  final String benefits; // Key benefits
  final String applicationTiming; // When to apply
  final String precautions; // Additional precautions
  final double? pricePerUnit; // Optional price

  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Fertilizer({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.npkComposition,
    required this.applicationMethod,
    required this.suitableCrops,
    required this.recommendedDosage,
    required this.dosageUnit,
    required this.safetyNotes,
    this.description = '',
    this.manufacturer = '',
    this.category = 'Inorganic',
    this.form = 'Granular',
    this.shelfLife = '',
    this.storageInstructions = '',
    this.benefits = '',
    this.applicationTiming = '',
    this.precautions = '',
    this.pricePerUnit,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document
  factory Fertilizer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Fertilizer(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      npkComposition: data['npkComposition']?.toString() ?? '',
      applicationMethod:
          data['applicationMethod']?.toString() ?? 'Top Dressing',
      suitableCrops: data['suitableCrops']?.toString() ?? '',
      recommendedDosage: (data['recommendedDosage'] as num?)?.toDouble() ?? 0.0,
      dosageUnit: data['dosageUnit']?.toString() ?? 'KG/ACRE',
      safetyNotes: data['safetyNotes']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      manufacturer: data['manufacturer']?.toString() ?? '',
      category: data['category']?.toString() ?? 'Inorganic',
      form: data['form']?.toString() ?? 'Granular',
      shelfLife: data['shelfLife']?.toString() ?? '',
      storageInstructions: data['storageInstructions']?.toString() ?? '',
      benefits: data['benefits']?.toString() ?? '',
      applicationTiming: data['applicationTiming']?.toString() ?? '',
      precautions: data['precautions']?.toString() ?? '',
      pricePerUnit: (data['pricePerUnit'] as num?)?.toDouble(),
      isArchived: data['isArchived'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'npkComposition': npkComposition,
      'applicationMethod': applicationMethod,
      'suitableCrops': suitableCrops,
      'recommendedDosage': recommendedDosage,
      'dosageUnit': dosageUnit,
      'safetyNotes': safetyNotes,
      'description': description,
      'manufacturer': manufacturer,
      'category': category,
      'form': form,
      'shelfLife': shelfLife,
      'storageInstructions': storageInstructions,
      'benefits': benefits,
      'applicationTiming': applicationTiming,
      'precautions': precautions,
      'pricePerUnit': pricePerUnit,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create empty fertilizer for new entry
  factory Fertilizer.empty() {
    return Fertilizer(
      id: '',
      name: '',
      imageUrl: '',
      npkComposition: '',
      applicationMethod: 'Top Dressing',
      suitableCrops: '',
      recommendedDosage: 0,
      dosageUnit: 'KG/ACRE',
      safetyNotes: '',
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  Fertilizer copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? npkComposition,
    String? applicationMethod,
    String? suitableCrops,
    double? recommendedDosage,
    String? dosageUnit,
    String? safetyNotes,
    String? description,
    String? manufacturer,
    String? category,
    String? form,
    String? shelfLife,
    String? storageInstructions,
    String? benefits,
    String? applicationTiming,
    String? precautions,
    double? pricePerUnit,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Fertilizer(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      npkComposition: npkComposition ?? this.npkComposition,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      suitableCrops: suitableCrops ?? this.suitableCrops,
      recommendedDosage: recommendedDosage ?? this.recommendedDosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      safetyNotes: safetyNotes ?? this.safetyNotes,
      description: description ?? this.description,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      form: form ?? this.form,
      shelfLife: shelfLife ?? this.shelfLife,
      storageInstructions: storageInstructions ?? this.storageInstructions,
      benefits: benefits ?? this.benefits,
      applicationTiming: applicationTiming ?? this.applicationTiming,
      precautions: precautions ?? this.precautions,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get short crops preview (first 3 crops)
  String get cropsPreview {
    final crops = suitableCrops.split(',').map((e) => e.trim()).toList();
    if (crops.length <= 3) {
      return suitableCrops;
    }
    return '${crops.take(3).join(', ')}...';
  }
}

/// Dosage unit options
class DosageUnit {
  static const String kgPerAcre = 'KG/ACRE';
  static const String gPerSqm = 'G/SQM';

  static List<String> get all => [kgPerAcre, gPerSqm];
}

/// Application method options
class ApplicationMethod {
  static const String topDressing = 'Top Dressing';
  static const String soilApplication = 'Soil Application';
  static const String foliarSpray = 'Foliar Spray';
  static const String dripIrrigation = 'Drip Irrigation';

  static List<String> get all => [
    topDressing,
    soilApplication,
    foliarSpray,
    dripIrrigation,
  ];
}

/// Fertilizer category options
class FertilizerCategory {
  static const String organic = 'Organic';
  static const String inorganic = 'Inorganic';
  static const String bioFertilizer = 'Bio-fertilizer';
  static const String micronutrient = 'Micronutrient';
  static const String complex = 'Complex/NPK';

  static List<String> get all => [
    inorganic,
    organic,
    bioFertilizer,
    micronutrient,
    complex,
  ];
}

/// Fertilizer form/physical state options
class FertilizerForm {
  static const String granular = 'Granular';
  static const String liquid = 'Liquid';
  static const String powder = 'Powder';
  static const String pellets = 'Pellets';
  static const String crystals = 'Crystals';

  static List<String> get all => [
    granular,
    liquid,
    powder,
    pellets,
    crystals,
  ];
}

