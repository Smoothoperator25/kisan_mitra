class Crop {
  final String id;
  final String name;
  final String scientificName;
  final String imageUrl;
  final String category;
  final NPKRequirement nutrientRequirement;
  final List<String> growthStages;

  Crop({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.imageUrl,
    required this.category,
    required this.nutrientRequirement,
    required this.growthStages,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      nutrientRequirement: NPKRequirement.fromJson(
        json['nutrient_requirement'] ?? {},
      ),
      growthStages: List<String>.from(json['growth_stages'] ?? []),
    );
  }

  // Factory for Perenual API Response
  factory Crop.fromPerenualJson(Map<String, dynamic> json) {
    String commonName = json['common_name'] ?? 'Unknown Crop';

    // Simulate NPK based on name/category (since API doesn't provide it)
    NPKRequirement simulatedNPK = _simulateNPK(commonName);

    return Crop(
      id: (json['id'] ?? 0).toString(),
      name: commonName,
      scientificName:
          (json['scientific_name'] is List &&
              json['scientific_name'].isNotEmpty)
          ? json['scientific_name'][0]
          : 'Unknown',
      imageUrl: json['default_image']?['regular_url'] ?? '',
      category: 'General', // Perenual doesn't always provide category in list
      nutrientRequirement: simulatedNPK,
      growthStages: _getDefaultStages(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'image_url': imageUrl,
      'category': category,
      'nutrient_requirement': nutrientRequirement.toJson(),
      'growth_stages': growthStages,
    };
  }

  // Helper to simulate NPK for demo purposes
  static NPKRequirement _simulateNPK(String name) {
    name = name.toLowerCase();
    if (name.contains('wheat') ||
        name.contains('rice') ||
        name.contains('corn') ||
        name.contains('maize')) {
      return NPKRequirement(n: 120, p: 60, k: 40); // Cereals
    } else if (name.contains('potato') || name.contains('tomato')) {
      return NPKRequirement(n: 150, p: 80, k: 100); // Heavy feeders
    } else if (name.contains('bean') ||
        name.contains('pea') ||
        name.contains('legume')) {
      return NPKRequirement(n: 20, p: 60, k: 40); // Legumes (fix N)
    } else {
      return NPKRequirement(n: 100, p: 50, k: 50); // Default
    }
  }

  static List<String> _getDefaultStages() {
    return ['Seedling', 'Vegetative', 'Flowering', 'Fruiting', 'Maturity'];
  }
}

class NPKRequirement {
  final double n;
  final double p;
  final double k;

  NPKRequirement({required this.n, required this.p, required this.k});

  factory NPKRequirement.fromJson(Map<String, dynamic> json) {
    return NPKRequirement(
      n: (json['nitrogen'] ?? 0.0).toDouble(),
      p: (json['phosphorus'] ?? 0.0).toDouble(),
      k: (json['potassium'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nitrogen': n, 'phosphorus': p, 'potassium': k};
  }
}
