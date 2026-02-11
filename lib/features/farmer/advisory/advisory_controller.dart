import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/app_constants.dart';
import 'advisory_model.dart';

/// Controller for Fertilizer Advisory Screen
/// Handles business logic for crop selection, recommendations, and safety guidelines
class AdvisoryController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // State variables
  bool _isLoading = true;
  bool _isCalculating = false;
  String? _error;

  List<Crop> _crops = [];
  String? _selectedCrop;
  CropPhase _selectedPhase = CropPhase.vegetative;
  double _fieldSize = 4.5; // Default value in acres

  List<FertilizerRecommendation> _recommendations = [];
  List<SafetyGuideline> _safetyGuidelines = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isCalculating => _isCalculating;
  String? get error => _error;

  List<Crop> get crops => _crops;
  String? get selectedCrop => _selectedCrop;
  CropPhase get selectedPhase => _selectedPhase;
  double get fieldSize => _fieldSize;

  List<FertilizerRecommendation> get recommendations => _recommendations;
  List<SafetyGuideline> get safetyGuidelines => _safetyGuidelines;

  /// Initialize controller - load crops and safety guidelines
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Future.wait([loadCrops(), loadSafetyGuidelines()]);
    } catch (e) {
      _error = 'Failed to initialize: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load crops dynamically from fertilizers collection
  /// Extracts unique crops from suitableCrops arrays
  Future<void> loadCrops() async {
    try {
      // Fetch all fertilizers
      final result = await _firestoreService.queryDocuments(
        collection: AppConstants.fertilizersCollection,
      );

      if (result['success'] == true) {
        final documents = result['documents'] as List<dynamic>;

        // Extract unique crop names from suitableCrops arrays
        Set<String> uniqueCrops = {};

        for (var doc in documents) {
          final suitableCrops = doc['suitableCrops'] as List<dynamic>?;
          if (suitableCrops != null) {
            for (var crop in suitableCrops) {
              if (crop is String && crop.isNotEmpty) {
                uniqueCrops.add(crop);
              }
            }
          }
        }

        // Convert to Crop objects and sort alphabetically
        _crops = uniqueCrops.map((name) => Crop(name: name)).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        // Select first crop by default if available
        if (_crops.isNotEmpty && _selectedCrop == null) {
          _selectedCrop = _crops.first.name;
        }
      } else {
        _error = result['message'] as String?;
      }
    } catch (e) {
      _error = 'Failed to load crops: $e';
    }
  }

  /// Load safety guidelines from Firestore
  Future<void> loadSafetyGuidelines() async {
    try {
      final result = await _firestoreService.queryDocuments(
        collection: 'safety_guidelines',
      );

      if (result['success'] == true) {
        final documents = result['documents'] as List<dynamic>;

        _safetyGuidelines =
            documents
                .map(
                  (doc) => SafetyGuideline.fromFirestore(
                    doc as Map<String, dynamic>,
                  ),
                )
                .toList()
              ..sort((a, b) => a.order.compareTo(b.order));
      } else {
        _error = result['message'] as String?;
      }
    } catch (e) {
      _error = 'Failed to load safety guidelines: $e';
    }
  }

  /// Update selected crop
  void selectCrop(String crop) {
    if (_selectedCrop != crop) {
      _selectedCrop = crop;
      _recommendations = []; // Clear previous recommendations
      notifyListeners();
    }
  }

  /// Update selected crop phase
  void selectPhase(CropPhase phase) {
    if (_selectedPhase != phase) {
      _selectedPhase = phase;
      _recommendations = []; // Clear previous recommendations
      notifyListeners();
    }
  }

  /// Update field size
  void updateFieldSize(double size) {
    if (_fieldSize != size) {
      _fieldSize = size;
      notifyListeners();
    }
  }

  /// Calculate fertilizer recommendations based on selected crop, phase, and field size
  Future<void> calculateAdvice() async {
    if (_selectedCrop == null) {
      _error = 'Please select a crop first';
      notifyListeners();
      return;
    }

    try {
      _isCalculating = true;
      _error = null;
      _recommendations = [];
      notifyListeners();

      // Fetch all fertilizers
      final result = await _firestoreService.queryDocuments(
        collection: AppConstants.fertilizersCollection,
      );

      if (result['success'] == true) {
        final documents = result['documents'] as List<dynamic>;

        // Filter fertilizers based on crop and phase
        List<Map<String, dynamic>> matchingFertilizers = [];

        for (var doc in documents) {
          final docMap = doc as Map<String, dynamic>;

          // Check if fertilizer is suitable for the selected crop
          final suitableCrops = docMap['suitableCrops'] as List<dynamic>?;
          final isSuitableForCrop =
              suitableCrops?.contains(_selectedCrop) ?? false;

          // Check if fertilizer matches the application stage
          final applicationStage = docMap['applicationStage'] as String?;
          final matchesPhase = applicationStage == _selectedPhase.label;

          if (isSuitableForCrop && matchesPhase) {
            matchingFertilizers.add(docMap);
          }
        }

        // Sort by dosage (ascending) to find the best match
        matchingFertilizers.sort((a, b) {
          final dosageA =
              (a['dosagePerAcre'] as num?)?.toDouble() ?? double.infinity;
          final dosageB =
              (b['dosagePerAcre'] as num?)?.toDouble() ?? double.infinity;
          return dosageA.compareTo(dosageB);
        });

        // Create recommendation objects
        _recommendations = matchingFertilizers.asMap().entries.map((entry) {
          final index = entry.key;
          final fertilizer = entry.value;

          return FertilizerRecommendation.fromFirestore(
            data: fertilizer,
            fieldSize: _fieldSize,
            isOptimized: index == 0, // First result is optimized
          );
        }).toList();

        if (_recommendations.isEmpty) {
          _error = 'No fertilizers found for the selected crop and phase';
        }
      } else {
        _error = result['message'] as String?;
      }
    } catch (e) {
      _error = 'Failed to calculate advice: $e';
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
