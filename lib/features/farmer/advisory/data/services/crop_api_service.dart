import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/crop_model.dart';

class CropApiService {
  // Use dotenv to get base URL, fallback to meaningful default if needed for dev
  String get _baseUrl => 'https://perenual.com/api/v2';

  String get _apiKey {
    if (!dotenv.isInitialized) return '';
    return dotenv.env['PERENUAL_API_KEY'] ?? '';
  }

  Future<List<Crop>> getGlobalCrops() async {
    // Perenual API Endpoint for Species List
    final uri = Uri.parse(
      '$_baseUrl/species-list?key=$_apiKey&page=1&edible=1',
    ); // Filter for edible plants

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('data') && data['data'] is List) {
          final List<dynamic> cropsList = data['data'];
          // Filter out entries without images to keep UI looking good
          var crops = cropsList
              .map((json) => Crop.fromPerenualJson(json))
              .where(
                (crop) =>
                    crop.imageUrl.isNotEmpty && crop.name != 'Unknown Crop',
              )
              .toList();

          if (crops.isEmpty) {
            print("API returned no valid crops with images. Using Mock Data.");
            return _getMockCrops();
          }
          return crops;
        } else {
          print('Invalid response format: "data" key missing or not a list');
          return _getMockCrops();
        }
      } else if (response.statusCode == 429) {
        print('Rate limit exceeded. Using Mock Data.');
        return _getMockCrops();
      } else {
        print('Failed to load crops: ${response.statusCode}');
        return _getMockCrops();
      }
    } catch (e) {
      // FALLBACK TO MOCK DATA on any error (Network or API)
      print("API Error: $e. Using Mock Data.");
      return _getMockCrops();
    }
  }

  // Mock Data for immediate testing/offline usage
  List<Crop> _getMockCrops() {
    return [
      Crop(
        id: '1',
        name: 'Wheat',
        scientificName: 'Triticum aestivum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Vehn%C3%A4pelto_6.jpg/1200px-Vehn%C3%A4pelto_6.jpg',
        category: 'Cereal',
        nutrientRequirement: NPKRequirement(n: 120, p: 60, k: 40),
        growthStages: [
          'Seedling',
          'Tillering',
          'Jointing',
          'Booting',
          'Flowering',
          'Maturity',
        ],
      ),
      Crop(
        id: '2',
        name: 'Paddy (Rice)',
        scientificName: 'Oryza sativa',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/c/c7/Rice_Plants_%28Oryza_sativa%29.jpg',
        category: 'Cereal',
        nutrientRequirement: NPKRequirement(n: 100, p: 50, k: 50),
        growthStages: [
          'Seedling',
          'Transplanting',
          'Tillering',
          'Panicle Initiation',
          'Flowering',
          'Maturity',
        ],
      ),
      Crop(
        id: '3',
        name: 'Corn (Maize)',
        scientificName: 'Zea mays',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Maize_ear_closeup.jpg/1200px-Maize_ear_closeup.jpg',
        category: 'Cereal',
        nutrientRequirement: NPKRequirement(n: 150, p: 60, k: 60),
        growthStages: [
          'Seedling',
          'Knee High',
          'Tasseling',
          'Silking',
          'Dough',
          'Dent',
        ],
      ),
      Crop(
        id: '4',
        name: 'Potato',
        scientificName: 'Solanum tuberosum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/a/ab/Patates.jpg',
        category: 'Tuber',
        nutrientRequirement: NPKRequirement(n: 120, p: 80, k: 120),
        growthStages: [
          'Sprouting',
          'Vegetative',
          'Tuber Initiation',
          'Tuber Bulking',
          'Maturation',
        ],
      ),
      Crop(
        id: '5',
        name: 'Tomato',
        scientificName: 'Solanum lycopersicum',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/8/89/Tomato_je.jpg',
        category: 'Vegetable',
        nutrientRequirement: NPKRequirement(n: 100, p: 60, k: 100),
        growthStages: [
          'Transplanting',
          'Vegetative',
          'Flowering',
          'Fruit Set',
          'Harvest',
        ],
      ),
      Crop(
        id: '6',
        name: 'Cotton',
        scientificName: 'Gossypium',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/c/c1/Cotton_plant.jpg',
        category: 'Fiber',
        nutrientRequirement: NPKRequirement(n: 120, p: 60, k: 60),
        growthStages: [
          'Germination',
          'Seedling',
          'Square Formation',
          'Flowering',
          'Boll Development',
          'Boll Opening',
        ],
      ),
    ];
    // End of class CropApiService
  }
}
