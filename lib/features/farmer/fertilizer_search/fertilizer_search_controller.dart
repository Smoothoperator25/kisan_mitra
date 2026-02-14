import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'fertilizer_search_model.dart';
import 'geo_service.dart';
import 'ranking_service.dart';
import 'mapbox_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firestore_service.dart'; // Assuming this exists

class FertilizerSearchController extends ChangeNotifier {
  final GeoService _geoService = GeoService();
  final RankingService _rankingService = RankingService();
  final MapboxService _mapboxService = MapboxService();
  final FirestoreService _firestoreService = FirestoreService();

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  StoreSearchResult? _bestShop;
  StoreSearchResult? get bestShop => _bestShop;

  List<StoreSearchResult> _stores = [];
  List<StoreSearchResult> get stores => _stores;

  Fertilizer? _selectedFertilizer;
  Fertilizer? get selectedFertilizer => _selectedFertilizer;

  List<LatLng> _routePolyline = [];
  List<LatLng> get routePolyline => _routePolyline;

  // Search
  Future<void> initialize() async {
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentPosition = await _geoService.getCurrentLocation();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchFertilizer(String query) async {
    if (query.isEmpty) return;

    _isLoading = true;
    _error = null;
    _selectedFertilizer = null;
    _stores = [];
    _bestShop = null;
    _routePolyline = [];
    notifyListeners();

    try {
      // 1. Fetch Fertilizer
      final fertilizerData = await _firestoreService.queryDocuments(
        collection: AppConstants.fertilizersCollection,
        fieldPath: 'name',
        isEqualTo: query,
      );

      // Handle the case where queryDocuments returns a Map<String, dynamic> with success/documents
      // Based on previous file content, it returns a Map.
      if (fertilizerData['success'] == true) {
        List docs = fertilizerData['documents'];
        if (docs.isNotEmpty) {
          _selectedFertilizer = Fertilizer.fromMap(
            docs.first,
            docs.first['id'],
          );
        } else {
          _error = 'Fertilizer not found';
          _isLoading = false;
          notifyListeners();
          return;
        }
      } else {
        _error = fertilizerData['message'] ?? 'Error fetching fertilizer';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (_selectedFertilizer == null) return; // Should be handled above

      // 2. Fetch Store Fertilizers (Availability & Price)
      final storeFertilizersData = await _firestoreService.queryDocuments(
        collection: 'store_fertilizers', // Assuming this is the collection name
        fieldPath: 'fertilizerId',
        isEqualTo: _selectedFertilizer!.id,
      );

      List<StoreFertilizer> storeFertilizers = [];
      if (storeFertilizersData['success'] == true) {
        for (var doc in storeFertilizersData['documents']) {
          storeFertilizers.add(StoreFertilizer.fromMap(doc));
        }
      }

      // 3. Fetch Stores and Filter/Rank
      await _processStores(storeFertilizers);
    } catch (e) {
      _error = 'Search failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _processStores(List<StoreFertilizer> storeFertilizers) async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
      if (_currentPosition == null) return;
    }

    List<StoreSearchResult> tempResults = [];

    for (var sf in storeFertilizers) {
      // Fetch Store Details
      final storeData = await _firestoreService.getDocument(
        collection: AppConstants.storesCollection,
        docId: sf.storeId,
      );

      if (storeData['success'] == true) {
        final store = Store.fromMap(storeData['data'], sf.storeId);

        // Calculate Distance
        double distance = _geoService.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          store.latitude,
          store.longitude,
        );

        // Filter 5KM Radius
        if (distance <= 5.0) {
          // Basic score as placeholder, real ranking happens in RankingService
          tempResults.add(
            StoreSearchResult(
              store: store,
              details: sf,
              distance: distance,
              score: 0.0,
            ),
          );
        }
      }
    }

    // Smart Ranking
    if (tempResults.isNotEmpty) {
      // Pass maxPrice if needed, or service calculates it
      // Passed dummy maxDistance=5.0, maxPrice=0.0 (service handles min/max calculation internally if list passed)
      _stores = _rankingService.rankStores(tempResults, 5.0, 0.0);
      _bestShop = _stores.isNotEmpty ? _stores.first : null;
    } else {
      _stores = [];
      _bestShop = null;
    }
  }

  Future<void> navigateToStore(Store store) async {
    if (_currentPosition == null) return;

    _isLoading = true; // Maybe local loading state for map?
    notifyListeners();

    try {
      _routePolyline = await _mapboxService.getRoute(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        LatLng(store.latitude, store.longitude),
      );
    } catch (e) {
      print('Navigation error: $e');
      _error = 'Could not fetch route';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
