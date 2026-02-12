import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import 'store_location_service.dart';

/// Controller for Store Location Screen
/// Handles location state, marker dragging, and Firebase integration
class StoreLocationController extends ChangeNotifier {
  final StoreLocationService _locationService = StoreLocationService();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Map controller
  GoogleMapController? _mapController;

  // Location state
  double? _selectedLatitude;
  double? _selectedLongitude;
  String _resolvedAddress = 'Fetching address...';
  String _storeName = '';

  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isFetchingCurrentLocation = false;

  // Error state
  String? _error;

  // Getters
  GoogleMapController? get mapController => _mapController;
  double? get selectedLatitude => _selectedLatitude;
  double? get selectedLongitude => _selectedLongitude;
  String get resolvedAddress => _resolvedAddress;
  String get storeName => _storeName;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isFetchingCurrentLocation => _isFetchingCurrentLocation;
  String? get error => _error;

  /// Initialize location - load from Firestore or use current GPS
  Future<void> initializeLocation() async {
    try {
      _isLoading = true;
      notifyListeners();

      final uid = _authService.currentUserId;
      if (uid == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch store document
      final result = await _firestoreService.getDocument(
        collection: 'stores',
        docId: uid,
      );

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>?;
        _storeName = data?['storeName'] as String? ?? 'Store';

        // Check if location exists
        final latitude = data?['latitude'] as double?;
        final longitude = data?['longitude'] as double?;

        if (latitude != null && longitude != null) {
          // Use saved location
          _selectedLatitude = latitude;
          _selectedLongitude = longitude;

          // Get address for saved location
          await _updateAddress(latitude, longitude);
        } else {
          // No saved location, use current GPS
          await _useCurrentLocationInternal();
        }
      } else {
        // Failed to fetch store, use current location
        await _useCurrentLocationInternal();
      }
    } catch (e) {
      _error = 'Failed to initialize location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update address using reverse geocoding
  Future<void> _updateAddress(double latitude, double longitude) async {
    _resolvedAddress = 'Fetching address...';
    notifyListeners();

    final result = await _locationService.reverseGeocode(
      latitude: latitude,
      longitude: longitude,
    );

    if (result['success'] == true) {
      _resolvedAddress = result['address'] as String;
    } else {
      _resolvedAddress = 'Address not available';
    }
    notifyListeners();
  }

  /// Internal method to use current location
  Future<void> _useCurrentLocationInternal() async {
    final result = await _locationService.getCurrentLocation();

    if (result['success'] == true) {
      _selectedLatitude = result['latitude'] as double;
      _selectedLongitude = result['longitude'] as double;

      await _updateAddress(_selectedLatitude!, _selectedLongitude!);
    } else {
      _error = result['message'] as String? ?? 'Failed to get location';
    }
  }

  /// Handle marker drag end
  Future<void> onMarkerDragEnd(LatLng position) async {
    _selectedLatitude = position.latitude;
    _selectedLongitude = position.longitude;
    notifyListeners();

    // Update address
    await _updateAddress(position.latitude, position.longitude);
  }

  /// Use current location button handler
  Future<void> useCurrentLocation() async {
    try {
      _isFetchingCurrentLocation = true;
      _error = null;
      notifyListeners();

      final result = await _locationService.getCurrentLocation();

      if (result['success'] == true) {
        final latitude = result['latitude'] as double;
        final longitude = result['longitude'] as double;

        _selectedLatitude = latitude;
        _selectedLongitude = longitude;

        // Animate camera to new location
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 15),
          );
        }

        // Update address
        await _updateAddress(latitude, longitude);
      } else {
        _error = result['message'] as String? ?? 'Failed to get location';
      }
    } catch (e) {
      _error = 'Error getting current location: $e';
    } finally {
      _isFetchingCurrentLocation = false;
      notifyListeners();
    }
  }

  /// Save location to Firestore
  Future<Map<String, dynamic>> saveLocation() async {
    if (_selectedLatitude == null || _selectedLongitude == null) {
      return {
        'success': false,
        'message': 'Please select a location on the map',
      };
    }

    try {
      _isSaving = true;
      notifyListeners();

      final uid = _authService.currentUserId;
      if (uid == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Update Firestore
      final result = await _firestoreService.updateDocument(
        collection: 'stores',
        docId: uid,
        data: {
          'latitude': _selectedLatitude,
          'longitude': _selectedLongitude,
          'address': _resolvedAddress,
          'locationUpdatedAt': Timestamp.now(),
        },
      );

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Failed to save location: $e'};
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Set map controller
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
