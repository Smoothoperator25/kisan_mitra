import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import 'store_location_service.dart';

/// Controller for Store Location Screen
/// Handles location state, marker dragging, and Firebase integration with Mapbox
class StoreLocationController extends ChangeNotifier {
  final StoreLocationService _locationService = StoreLocationService();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Map controller
  MapboxMap? _mapController;
  CircleAnnotationManager? _circleAnnotationManager;
  PointAnnotationManager? _pointAnnotationManager;

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
  MapboxMap? get mapController => _mapController;
  CircleAnnotationManager? get circleAnnotationManager =>
      _circleAnnotationManager;
  PointAnnotationManager? get pointAnnotationManager => _pointAnnotationManager;
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
        // Check if location exists (Support both nested map and root fields)
        double? latitude;
        double? longitude;

        // Try reading from nested 'location' map first (New standard from registration)
        if (data?['location'] is Map) {
          final loc = data!['location'] as Map<String, dynamic>;
          latitude = (loc['latitude'] as num?)?.toDouble();
          longitude = (loc['longitude'] as num?)?.toDouble();
        }

        // Fallback to root fields (Old standard)
        if (latitude == null || longitude == null) {
          latitude = (data?['latitude'] as num?)?.toDouble();
          longitude = (data?['longitude'] as num?)?.toDouble();
        }

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

  /// Handle map tap
  Future<void> onMapTap(double latitude, double longitude) async {
    _selectedLatitude = latitude;
    _selectedLongitude = longitude;

    // Update marker position
    await _updateMarkerPosition(latitude, longitude);

    // Update address
    await _updateAddress(latitude, longitude);

    notifyListeners();
  }

  /// Update marker position on map
  Future<void> _updateMarkerPosition(double latitude, double longitude) async {
    if (_circleAnnotationManager == null) return;

    try {
      // Clear existing markers
      await _circleAnnotationManager!.deleteAll();
      if (_pointAnnotationManager != null) {
        await _pointAnnotationManager!.deleteAll();
      }

      // Add Main Marker (Custom Pin)
      if (_pointAnnotationManager != null) {
        await _pointAnnotationManager!.create(
          PointAnnotationOptions(
            geometry: Point(coordinates: Position(longitude, latitude)),
            iconImage: "user_location_marker",
            iconSize: 0.8,
            iconAnchor: IconAnchor.BOTTOM,
            iconOffset: [0.0, -5.0],
          ),
        );
      } else {
        // Fallback to circles if point manager not ready (shouldn't happen)
        await _circleAnnotationManager!.create(
          CircleAnnotationOptions(
            geometry: Point(coordinates: Position(longitude, latitude)),
            circleColor: Colors.red.withOpacity(0.3).value,
            circleRadius: 20.0,
          ),
        );
      }
    } catch (e) {
      print('Error updating marker: $e');
    }
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

        // Animate camera to new location with closer zoom
        if (_mapController != null) {
          _mapController!.flyTo(
            CameraOptions(
              center: Point(coordinates: Position(longitude, latitude)),
              zoom: 16.0, // Zoom closer
            ),
            MapAnimationOptions(duration: 1000),
          );
        }

        // Update marker position
        await _updateMarkerPosition(latitude, longitude);

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
          // Save to root fields (Backward compatibility)
          'latitude': _selectedLatitude,
          'longitude': _selectedLongitude,
          // Save to nested location map (New standard)
          'location': {
            'latitude': _selectedLatitude,
            'longitude': _selectedLongitude,
          },
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
  Future<void> setMapController(MapboxMap controller) async {
    _mapController = controller;

    // Initialize circle annotation manager for markers (keeping for fallback/pulse if needed)
    _circleAnnotationManager = await controller.annotations
        .createCircleAnnotationManager();

    // Initialize point annotation manager
    _pointAnnotationManager = await controller.annotations
        .createPointAnnotationManager();

    // Add User Location Marker Image
    try {
      final userMarker = await _buildUserLocationMarkerImage(
        const Color(0xFF2196F3),
      );
      await controller.style.addStyleImage(
        "user_location_marker",
        2.0,
        MbxImage(width: 100, height: 120, data: userMarker),
        false,
        [],
        [],
        null,
      );
    } catch (e) {
      debugPrint("Error adding style image: $e");
    }

    // Add initial marker if location is set
    if (_selectedLatitude != null && _selectedLongitude != null) {
      // Small delay to ensure manager is ready
      await Future.delayed(const Duration(milliseconds: 200));
      await _updateMarkerPosition(_selectedLatitude!, _selectedLongitude!);

      // Also fly to location on init
      controller.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(_selectedLongitude!, _selectedLatitude!),
          ),
          zoom: 16.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController = null;
    _circleAnnotationManager = null;
    _pointAnnotationManager = null;
    super.dispose();
  }

  Future<Uint8List> _buildUserLocationMarkerImage(Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = ui.Size(100, 120);

    // 1. Draw Pin Body
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(size.width / 2, size.height); // Bottom tip

    // Right curve
    path.cubicTo(
      size.width / 2,
      size.height * 0.7,
      size.width * 0.95,
      size.height * 0.6,
      size.width * 0.95,
      45,
    );

    // Top Arc
    path.arcToPoint(
      Offset(size.width * 0.05, 45),
      radius: const Radius.circular(45),
      clockwise: false,
    );

    // Left curve
    path.cubicTo(
      size.width * 0.05,
      size.height * 0.6,
      size.width / 2,
      size.height * 0.7,
      size.width / 2,
      size.height,
    );

    path.close();
    canvas.drawPath(path, paint);

    // 2. Draw White Inner Circle
    final circlePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(50, 45), 30, circlePaint);

    // 3. Draw User Icon (Person)
    final iconIcon = Icons.person; // User icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconIcon.codePoint),
      style: TextStyle(
        fontSize: 40,
        fontFamily: iconIcon.fontFamily,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        45 - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
