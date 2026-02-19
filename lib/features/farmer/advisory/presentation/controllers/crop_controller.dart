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

  // Getters
  List<Crop> get crops => _filteredCrops;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Crop? get selectedCrop => _selectedCrop;

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
      _filteredCrops = List.from(_allCrops);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
