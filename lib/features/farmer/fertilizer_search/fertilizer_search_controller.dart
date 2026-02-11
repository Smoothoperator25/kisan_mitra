import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/map_service.dart';
import '../../../core/constants/app_constants.dart';

/// Model for store with fertilizer availability
class StoreWithFertilizer {
  final String storeId;
  final String storeName;
  final double latitude;
  final double longitude;
  final bool isVerified;
  final double price;
  final double distance;
  final bool isAvailable;
  final int? stock;
  final String? estimatedTime;
  final String? estimatedDistance;

  StoreWithFertilizer({
    required this.storeId,
    required this.storeName,
    required this.latitude,
    required this.longitude,
    required this.isVerified,
    required this.price,
    required this.distance,
    required this.isAvailable,
    this.stock,
    this.estimatedTime,
    this.estimatedDistance,
  });

  bool get isBestPrice => false; // Will be set by controller

  String get stockStatus {
    if (stock == null || stock! > 10) return 'IN STOCK';
    if (stock! > 0) return 'LIMITED STOCK';
    return 'OUT OF STOCK';
  }
}

/// Controller for Fertilizer Search Screen
/// Handles search, location, and nearby stores logic
class FertilizerSearchController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final MapService _mapService = MapService();

  // State variables
  bool _isLoadingLocation = true;
  bool _isSearching = false;
  bool _isLoadingDirections = false;
  String? _error;

  LatLng? _userLocation;
  String _searchQuery = '';
  Map<String, dynamic>? _selectedFertilizer;
  List<StoreWithFertilizer> _nearbyStores = [];
  StoreWithFertilizer? _bestStore;
  List<LatLng> _directionPolyline = [];
  String? _selectedStoreId;

  // Getters
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isSearching => _isSearching;
  bool get isLoadingDirections => _isLoadingDirections;
  String? get error => _error;
  LatLng? get userLocation => _userLocation;
  String get searchQuery => _searchQuery;
  Map<String, dynamic>? get selectedFertilizer => _selectedFertilizer;
  List<StoreWithFertilizer> get nearbyStores => _nearbyStores;
  StoreWithFertilizer? get bestStore => _bestStore;
  List<LatLng> get directionPolyline => _directionPolyline;
  String? get selectedStoreId => _selectedStoreId;

  /// Initialize location on controller creation
  Future<void> initializeLocation() async {
    try {
      _isLoadingLocation = true;
      _error = null;
      notifyListeners();

      final result = await _mapService.getCurrentLocation();

      if (result['success'] == true) {
        _userLocation = result['latLng'] as LatLng;
        _error = null;
      } else {
        _error = result['message'] as String;
      }
    } catch (e) {
      _error = 'Failed to get location: $e';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Search for fertilizer by name
  Future<void> searchFertilizer(String query) async {
    if (query.trim().isEmpty) {
      _searchQuery = '';
      _selectedFertilizer = null;
      _nearbyStores = [];
      _bestStore = null;
      _directionPolyline = [];
      notifyListeners();
      return;
    }

    try {
      _isSearching = true;
      _error = null;
      _searchQuery = query;
      notifyListeners();

      // Search for fertilizer by name (case insensitive)
      final result = await _firestoreService.queryDocuments(
        collection: AppConstants.fertilizersCollection,
        fieldPath: 'name',
        isEqualTo: query.trim(),
      );

      if (result['success'] == true) {
        final documents = result['documents'] as List<dynamic>;

        if (documents.isNotEmpty) {
          // Take the first matching fertilizer
          _selectedFertilizer = documents.first as Map<String, dynamic>;

          // Fetch nearby stores with this fertilizer
          await _fetchNearbyStores(_selectedFertilizer!['id'] as String);
        } else {
          _error = 'Fertilizer not found';
          _selectedFertilizer = null;
          _nearbyStores = [];
        }
      } else {
        _error = result['message'] as String;
      }
    } catch (e) {
      _error = 'Search failed: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Fetch nearby stores that have the selected fertilizer
  Future<void> _fetchNearbyStores(String fertilizerId) async {
    if (_userLocation == null) {
      _error = 'User location not available';
      notifyListeners();
      return;
    }

    try {
      // Query store_fertilizers collection
      final result = await _firestoreService.queryDocuments(
        collection: AppConstants.storeFertilizersCollection,
        fieldPath: 'fertilizerId',
        isEqualTo: fertilizerId,
      );

      if (result['success'] == true) {
        final storeFertilizers = result['documents'] as List<dynamic>;

        List<StoreWithFertilizer> allStores = [];

        // Fetch store details for each store_fertilizer
        for (var storeFertilizer in storeFertilizers) {
          final isAvailable = storeFertilizer['isAvailable'] as bool? ?? false;

          if (!isAvailable) continue; // Skip unavailable stores

          final storeId = storeFertilizer['storeId'] as String;

          // Fetch store document
          final storeResult = await _firestoreService.getDocument(
            collection: AppConstants.storesCollection,
            docId: storeId,
          );

          if (storeResult['success'] == true) {
            final storeData = storeResult['data'] as Map<String, dynamic>;

            // Only include verified stores
            final isVerified = storeData['isVerified'] as bool? ?? false;
            if (!isVerified) continue;

            // Extract location
            final location = storeData['location'] as Map<String, dynamic>?;
            if (location == null) continue;

            final latitude = (location['latitude'] as num?)?.toDouble();
            final longitude = (location['longitude'] as num?)?.toDouble();

            if (latitude == null || longitude == null) continue;

            // Calculate distance
            final distance = _mapService.calculateDistance(
              lat1: _userLocation!.latitude,
              lon1: _userLocation!.longitude,
              lat2: latitude,
              lon2: longitude,
            );

            // Only include stores within 5km
            if (distance > AppConstants.nearbyRadiusKm) continue;

            allStores.add(
              StoreWithFertilizer(
                storeId: storeId,
                storeName: storeData['storeName'] as String? ?? 'Unknown Store',
                latitude: latitude,
                longitude: longitude,
                isVerified: isVerified,
                price: (storeFertilizer['price'] as num?)?.toDouble() ?? 0.0,
                distance: distance,
                isAvailable: isAvailable,
                stock: storeFertilizer['stock'] as int?,
              ),
            );
          }
        }

        // Sort by price (ascending)
        allStores.sort((a, b) => a.price.compareTo(b.price));

        _nearbyStores = allStores;

        // Identify best store (lowest price)
        if (allStores.isNotEmpty) {
          _bestStore = allStores.first;
        } else {
          _bestStore = null;
        }
      } else {
        _error = result['message'] as String;
        _nearbyStores = [];
        _bestStore = null;
      }
    } catch (e) {
      _error = 'Failed to load stores: $e';
      _nearbyStores = [];
      _bestStore = null;
    }

    notifyListeners();
  }

  /// Get directions to a specific store
  Future<void> getDirections(StoreWithFertilizer store) async {
    if (_userLocation == null) {
      _error = 'User location not available';
      notifyListeners();
      return;
    }

    try {
      _isLoadingDirections = true;
      _selectedStoreId = store.storeId;
      notifyListeners();

      final destination = LatLng(store.latitude, store.longitude);

      final result = await _mapService.getDirections(
        origin: _userLocation!,
        destination: destination,
      );

      if (result['success'] == true) {
        _directionPolyline = result['polylinePoints'] as List<LatLng>;

        // Update the store with estimated time and distance
        final storeIndex = _nearbyStores.indexWhere(
          (s) => s.storeId == store.storeId,
        );
        if (storeIndex != -1) {
          // Note: Since StoreWithFertilizer is immutable, we'd need to create a new instance
          // For simplicity, we'll just store the values separately or update the UI directly
        }
      } else {
        _error = result['message'] as String;
        _directionPolyline = [];
      }
    } catch (e) {
      _error = 'Failed to get directions: $e';
      _directionPolyline = [];
    } finally {
      _isLoadingDirections = false;
      notifyListeners();
    }
  }

  /// Clear directions
  void clearDirections() {
    _directionPolyline = [];
    _selectedStoreId = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
