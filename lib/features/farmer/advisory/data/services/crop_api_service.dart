import '../models/crop_model.dart';

class CropApiService {
  // Simulating an API call with a local list of global crops
  Future<List<Crop>> getGlobalCrops() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      Crop(
        id: '1',
        name: 'Rice',
        scientificName: 'Oryza sativa',
        imageUrl:
            'https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=2070&auto=format&fit=crop',
        growthStages: [
          'Seedling',
          'Tillering',
          'Panicle Initiation',
          'Heading',
          'Ripening',
        ],
        durationDays: 120,
        nutrientRequirements: {
          'Seedling': NPKRequirement(n: 20, p: 10, k: 10),
          'Tillering': NPKRequirement(n: 40, p: 20, k: 20),
          'Panicle Initiation': NPKRequirement(n: 30, p: 15, k: 30),
          'Heading': NPKRequirement(n: 10, p: 10, k: 10),
          'Ripening': NPKRequirement(n: 0, p: 0, k: 10),
        },
      ),
      Crop(
        id: '2',
        name: 'Wheat',
        scientificName: 'Triticum aestivum',
        imageUrl:
            'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=2070&auto=format&fit=crop',
        growthStages: [
          'Crown Root Initiation',
          'Tillering',
          'Jointing',
          'Flowering',
          'Milking',
          'Dough',
        ],
        durationDays: 110,
        nutrientRequirements: {
          'Crown Root Initiation': NPKRequirement(n: 25, p: 20, k: 10),
          'Tillering': NPKRequirement(n: 30, p: 15, k: 15),
          'Jointing': NPKRequirement(n: 30, p: 0, k: 10),
          'Flowering': NPKRequirement(n: 15, p: 5, k: 5),
        },
      ),
      Crop(
        id: '3',
        name: 'Maize',
        scientificName: 'Zea mays',
        imageUrl:
            'https://images.unsplash.com/photo-1551754655-cd27e38d2076?q=80&w=2070&auto=format&fit=crop',
        growthStages: [
          'Seedling',
          'Knee High',
          'Tasseling',
          'Silking',
          'Maturity',
        ],
        durationDays: 100,
        nutrientRequirements: {
          'Seedling': NPKRequirement(n: 20, p: 20, k: 20),
          'Knee High': NPKRequirement(n: 40, p: 10, k: 10),
          'Tasseling': NPKRequirement(n: 30, p: 10, k: 10),
          'Silking': NPKRequirement(n: 20, p: 10, k: 10),
        },
      ),
      Crop(
        id: '4',
        name: 'Cotton',
        scientificName: 'Gossypium',
        imageUrl:
            'https://images.unsplash.com/photo-1605335836262-1c7b56d33816?q=80&w=2070&auto=format&fit=crop',
        growthStages: [
          'Germination',
          'Vegetative',
          'Flowering',
          'Boll Formation',
          'Maturation',
        ],
        durationDays: 150,
        nutrientRequirements: {
          'Vegetative': NPKRequirement(n: 30, p: 15, k: 15),
          'Flowering': NPKRequirement(n: 20, p: 10, k: 20),
          'Boll Formation': NPKRequirement(n: 20, p: 10, k: 20),
        },
      ),
      Crop(
        id: '5',
        name: 'Sugarcane',
        scientificName: 'Saccharum officinarum',
        imageUrl:
            'https://images.unsplash.com/photo-1629821804365-517df4eb5350?q=80&w=1974&auto=format&fit=crop',
        growthStages: ['Germination', 'Tillering', 'Grand Growth', 'Maturity'],
        durationDays: 365,
        nutrientRequirements: {
          'Tillering': NPKRequirement(n: 50, p: 20, k: 30),
          'Grand Growth': NPKRequirement(n: 40, p: 10, k: 30),
          'Maturity': NPKRequirement(n: 10, p: 0, k: 10),
        },
      ),
      Crop(
        id: '6',
        name: 'Tomato',
        scientificName: 'Solanum lycopersicum',
        imageUrl:
            'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?q=80&w=2070&auto=format&fit=crop',
        growthStages: [
          'Transplanting',
          'Vegetative',
          'Flowering',
          'Fruit Setting',
          'Harvesting',
        ],
        durationDays: 90,
        nutrientRequirements: {
          'Vegetative': NPKRequirement(n: 20, p: 10, k: 10),
          'Flowering': NPKRequirement(n: 10, p: 20, k: 20),
          'Fruit Setting': NPKRequirement(n: 10, p: 10, k: 30),
        },
      ),
      Crop(
        id: '7',
        name: 'Potato',
        scientificName: 'Solanum tuberosum',
        imageUrl:
            'https://images.unsplash.com/photo-1518977676601-b53f82aba655?q=80&w=2070&auto=format&fit=crop',
        growthStages: [
          'Sprouting',
          'Vegetative',
          'Tuber Initiation',
          'Tuber Bulking',
          'Maturation',
        ],
        durationDays: 100,
        nutrientRequirements: {
          'Vegetative': NPKRequirement(n: 30, p: 15, k: 20),
          'Tuber Initiation': NPKRequirement(n: 20, p: 20, k: 30),
          'Tuber Bulking': NPKRequirement(n: 20, p: 10, k: 40),
        },
      ),
      Crop(
        id: '8',
        name: 'Soybean',
        scientificName: 'Glycine max',
        imageUrl:
            'https://images.unsplash.com/photo-1582236894050-891ca8fa8b2b?q=80&w=1964&auto=format&fit=crop',
        growthStages: [
          'Germination',
          'Flowering',
          'Pod Formation',
          'Seed Filling',
          'Maturity',
        ],
        durationDays: 120,
        nutrientRequirements: {
          'Germination': NPKRequirement(n: 5, p: 10, k: 10),
          'Flowering': NPKRequirement(n: 5, p: 15, k: 15),
          'Pod Formation': NPKRequirement(n: 10, p: 10, k: 20),
        },
      ),
      // Add more as needed to reach "All Crops" feel
    ];
  }
}
