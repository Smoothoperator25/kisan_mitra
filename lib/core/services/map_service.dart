import 'dart:math';
import 'package:geolocator/geolocator.dart';

/// Service for handling map-related operations
/// Including location services and distance calculations
/// Note: For directions/routes, use MapboxService instead
class MapService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current user location
  /// Returns a map with success status and either position or error message
  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'success': false,
          'message':
              'Location services are disabled. Please enable location services.',
        };
      }

      // Check location permission
      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          return {'success': false, 'message': 'Location permission denied'};
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'success': false,
          'message':
              'Location permissions are permanently denied. Please enable them in settings.',
        };
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {
        'success': true,
        'position': position,
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to get location: $e'};
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusKm = 6371.0;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Filter locations within a certain radius (in km)
  List<Map<String, dynamic>> filterByRadius({
    required double userLat,
    required double userLon,
    required List<Map<String, dynamic>> locations,
    required double radiusKm,
  }) {
    return locations.where((location) {
      double distance = calculateDistance(
        lat1: userLat,
        lon1: userLon,
        lat2: location['latitude'] as double,
        lon2: location['longitude'] as double,
      );
      // Add calculated distance to the location map
      location['distance'] = distance;
      return distance <= radiusKm;
    }).toList();
  }
}
