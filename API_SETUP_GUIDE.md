# API Setup Guide for Advisory System

The **Global Precision Agriculture Advisory System** uses the **OpenWeatherMap API** to fetch real-time weather data for accurate fertilizer adjustments.

## 1. Get an API Key
1.  Go to [OpenWeatherMap](https://openweathermap.org/).
2.  Sign up for a free account.
3.  Navigate to "My API Keys" to copy your key.

## 2. Configure in App
Open the following file in your project:

`lib/features/advisory/data/services/weather_service.dart`

Find the `_apiKey` constant at the top of the class (around line 6) and replace the placeholder text with your actual key.

```dart
class WeatherService {
  // REPLACE THIS STRING
  static const String _apiKey = 'YOUR_OPENWEATHERMAP_API_KEY'; 
  
  // ...
}
```

## 3. Troubleshooting
-   **Invalid Key**: If the API key is incorrect or not activated yet (it can take 10-15 mins after creation), the app will automatically fall back to **Mock Data** so you can still test the UI.
-   **Mock Data Indicator**: If you see data like "28.5°C" and "Cloudy" constantly, you are viewing mock data.
