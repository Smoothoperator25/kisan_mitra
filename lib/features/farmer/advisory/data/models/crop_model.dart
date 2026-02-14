class Crop {
  final String id;
  final String name;
  final String scientificName;
  final String imageUrl;
  final List<String> growthStages;
  final Map<String, NPKRequirement>
  nutrientRequirements; // keyed by growth stage
  final int durationDays;

  Crop({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.imageUrl,
    required this.growthStages,
    required this.nutrientRequirements,
    required this.durationDays,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      growthStages: List<String>.from(json['growth_stages'] ?? []),
      nutrientRequirements:
          (json['nutrient_requirements'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, NPKRequirement.fromJson(value)),
          ) ??
          {},
      durationDays: json['duration_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'image_url': imageUrl,
      'growth_stages': growthStages,
      'nutrient_requirements': nutrientRequirements.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'duration_days': durationDays,
    };
  }
}

class NPKRequirement {
  final double n;
  final double p;
  final double k;

  NPKRequirement({required this.n, required this.p, required this.k});

  factory NPKRequirement.fromJson(Map<String, dynamic> json) {
    return NPKRequirement(
      n: (json['n'] ?? 0.0).toDouble(),
      p: (json['p'] ?? 0.0).toDouble(),
      k: (json['k'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'n': n, 'p': p, 'k': k};
  }
}
