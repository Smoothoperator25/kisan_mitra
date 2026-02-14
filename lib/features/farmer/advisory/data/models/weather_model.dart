class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double rainProbability; // 0.0 to 1.0
  final String condition; // e.g., "Rainy", "Sunny"
  final String iconUrl;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.condition,
    required this.iconUrl,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      windSpeed: (json['wind_speed'] ?? 0.0).toDouble(),
      rainProbability: (json['rain_probability'] ?? 0.0).toDouble(),
      condition: json['condition'] ?? '',
      iconUrl: json['icon_url'] ?? '',
    );
  }

  // Create a mock default for when API fails or initial state
  factory WeatherData.initial() {
    return WeatherData(
      temperature: 25.0,
      humidity: 60.0,
      windSpeed: 5.0,
      rainProbability: 0.0,
      condition: "Unknown",
      iconUrl: "",
    );
  }
}
