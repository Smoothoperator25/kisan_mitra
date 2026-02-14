class Fertilizer {
  final String id;
  final String name;
  final double n;
  final double p;
  final double k;
  final String type; // Organic, Inorganic, Bio
  final String form; // Granular, Liquid, Powder
  final List<String> suitableCrops; // ['All'] or specific IDs
  final List<String> conditions; // e.g., "Avoid in Rain", "Acidic Soil"

  Fertilizer({
    required this.id,
    required this.name,
    required this.n,
    required this.p,
    required this.k,
    required this.type,
    required this.form,
    this.suitableCrops = const ['All'],
    this.conditions = const [],
  });

  // Calculate nutrient contribution for a given amount (kg)
  double getN(double amount) => (amount * n) / 100;
  double getP(double amount) => (amount * p) / 100;
  double getK(double amount) => (amount * k) / 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'n': n,
      'p': p,
      'k': k,
      'type': type,
      'form': form,
      'suitableCrops': suitableCrops,
      'conditions': conditions,
    };
  }

  factory Fertilizer.fromMap(Map<String, dynamic> map) {
    return Fertilizer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      n: (map['n'] ?? 0).toDouble(),
      p: (map['p'] ?? 0).toDouble(),
      k: (map['k'] ?? 0).toDouble(),
      type: map['type'] ?? '',
      form: map['form'] ?? '',
      suitableCrops: List<String>.from(map['suitableCrops'] ?? ['All']),
      conditions: List<String>.from(map['conditions'] ?? []),
    );
  }
}
