import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../constants/app_constants.dart';

/// Service for handling map-related operations
/// Including location services, distance calculations, and directions API
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
        'latLng': LatLng(position.latitude, position.longitude),
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

  /// Get directions from origin to destination using Google Directions API
  /// Returns polyline points, distance, and duration
  Future<Map<String, dynamic>> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final String apiKey = AppConstants.googleMapsApiKey;

      // Check if API key is still placeholder
      if (apiKey == 'YOUR_API_KEY_HERE') {
        return {
          'success': false,
          'message': 'Google Maps API key not configured',
        };
      }

      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${origin.latitude},${origin.longitude}&'
          'destination=${destination.latitude},${destination.longitude}&'
          'key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final polylineString = route['overview_polyline']['points'];
          final leg = route['legs'][0];

          // Decode polyline
          PolylinePoints polylinePoints = PolylinePoints();
          List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(
            polylineString,
          );

          // Convert to LatLng
          List<LatLng> polylineCoordinates = decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          return {
            'success': true,
            'polylinePoints': polylineCoordinates,
            'distance': leg['distance']['text'],
            'duration': leg['duration']['text'],
            'distanceValue': leg['distance']['value'], // in meters
            'durationValue': leg['duration']['value'], // in seconds
          };
        } else {
          return {
            'success': false,
            'message': 'Could not find route: ${data['status']}',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to load directions: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error getting directions: $e'};
    }
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
