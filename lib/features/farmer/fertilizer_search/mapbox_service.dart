import 'dart:convert';
import 'package:kisan_mitra/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapboxService {
  // Mapbox Access Token - From your account
  static const String _accessToken = AppConstants.mapboxAccessToken;

  // Directions API
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&access_token=$_accessToken';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> routes = data['routes'];
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final List<dynamic> coordinates = geometry['coordinates'];

          return coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching directions: $e');
      return [];
    }
  }
}
