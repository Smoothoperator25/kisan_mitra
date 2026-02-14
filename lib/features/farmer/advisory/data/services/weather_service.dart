import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _apiKey =
      '3b486e43fe339b5f2b9dd4a9bf858990'; // Replace with real key
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData> fetchWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData(
          temperature: (data['main']['temp'] ?? 0.0).toDouble(),
          humidity: (data['main']['humidity'] ?? 0.0).toDouble(),
          windSpeed: (data['wind']['speed'] ?? 0.0).toDouble(),
          rainProbability:
              0.0, // OpenWeatherMap free API doesn't always provide this directly in current weather
          condition: (data['weather'] as List).isNotEmpty
              ? data['weather'][0]['main']
              : 'Clear',
          iconUrl: (data['weather'] as List).isNotEmpty
              ? 'https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png'
              : '',
        );
      } else {
        // Fallback for demo/invalid key
        print('Weather API Error: ${response.statusCode}');
        return _getMockWeather();
      }
    } catch (e) {
      print('Weather Service Exception: $e');
      return _getMockWeather();
    }
  }

  WeatherData _getMockWeather() {
    // Return a realistic mock object for demo purposes
    return WeatherData(
      temperature: 28.5,
      humidity: 65.0,
      windSpeed: 12.0,
      rainProbability: 0.3, // 30% chance
      condition: 'Cloudy',
      iconUrl: 'https://openweathermap.org/img/wn/03d@2x.png',
    );
  }
}
