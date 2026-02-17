import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';

/// Service for handling location and geocoding operations
/// Used by Store Location Screen to manage GPS and address resolution
class StoreLocationService {
  /// Get current GPS location
  /// Returns map with success status and either position or error message
  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'success': false,
          'message': 'Location services are disabled. Please enable them.',
        };
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
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
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to get location: $e'};
    }
  }

  /// Reverse geocode coordinates to address
  /// Returns map with success status and either address or error message
  Future<Map<String, dynamic>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final String accessToken = AppConstants.mapboxAccessToken;
      // Request POIs and addresses, limit to 5 results to find the best match
      final String url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json?access_token=$accessToken&limit=5&types=poi,address';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List features = data['features'];

        if (features.isNotEmpty) {
          // 1. Try to find a POI (Point of Interest) first
          var bestFeature = features.firstWhere(
            (f) => (f['id'] as String).startsWith('poi.'),
            orElse: () => null,
          );

          // 2. If no POI, fallback to the first result (usually address)
          bestFeature ??= features.first;

          final placeName = bestFeature['place_name'] as String;
          return {
            'success': true,
            'address': placeName,
            'features': bestFeature,
          };
        } else {
          return {
            'success': false,
            'message': 'No address found for this location',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch address: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to get address: $e'};
    }
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
