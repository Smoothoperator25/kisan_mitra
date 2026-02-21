import 'package:flutter/material.dart';
import '../../data/models/crop_model.dart';
import '../../data/repositories/crop_repository.dart';

class CropController extends ChangeNotifier {
  final CropRepository _repository = CropRepository();

  // State
  List<Crop> _allCrops = [];
  List<Crop> _filteredCrops = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Crop? _selectedCrop;
  bool _showAllCrops = false;

  // Constants
  static const int INITIAL_CROPS_LIMIT = 10;

  // Getters
  List<Crop> get crops => _filteredCrops;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Crop? get selectedCrop => _selectedCrop;
  bool get showAllCrops => _showAllCrops;
  List<Crop> get allCrops => _allCrops;

  // Constructor
  CropController() {
    loadCrops();
  }

  // Fetch crops
  Future<void> loadCrops() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _allCrops = await _repository.getCrops();
      _updateFilteredCrops();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update filtered crops based on showAllCrops flag
  void _updateFilteredCrops() {
    if (_showAllCrops) {
      _filteredCrops = List.from(_allCrops);
    } else {
      _filteredCrops = _allCrops.take(INITIAL_CROPS_LIMIT).toList();
    }
  }

  // Toggle view all crops
  void toggleViewAllCrops() {
    _showAllCrops = !_showAllCrops;
    _updateFilteredCrops();
    notifyListeners();
  }

  // Select a crop
  void selectCrop(Crop crop) {
    _selectedCrop = crop;
    notifyListeners();
  }

  // Search/Filter crops
  void searchCrops(String query) {
    if (query.isEmpty) {
      _filteredCrops = List.from(_allCrops);
    } else {
      _filteredCrops = _allCrops
          .where(
            (crop) =>
                crop.name.toLowerCase().contains(query.toLowerCase()) ||
                crop.scientificName.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  // Retry loading
  void retry() {
    loadCrops();
  }
}
