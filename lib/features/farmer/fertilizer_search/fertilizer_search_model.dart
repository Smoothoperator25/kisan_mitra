class Fertilizer {
  final String id;
  final String name;
  final String npkComposition;
  final String suitableCrops;
  final String recommendedDosage;

  Fertilizer({
    required this.id,
    required this.name,
    required this.npkComposition,
    required this.suitableCrops,
    required this.recommendedDosage,
  });

  factory Fertilizer.fromMap(Map<String, dynamic> data, String id) {
    return Fertilizer(
      id: id,
      name: data['name']?.toString() ?? '',
      npkComposition: data['npkComposition']?.toString() ?? '',
      suitableCrops: data['suitableCrops'] is List
          ? (data['suitableCrops'] as List).join(', ')
          : data['suitableCrops']?.toString() ?? '',
      recommendedDosage: data['recommendedDosage'] is List
          ? (data['recommendedDosage'] as List).join(', ')
          : data['recommendedDosage']?.toString() ?? '',
    );
  }
}

class Store {
  final String id;
  final String storeName;
  final double latitude;
  final double longitude;
  final double rating;
  final int totalReviews;

  Store({
    required this.id,
    required this.storeName,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.totalReviews,
  });

  factory Store.fromMap(Map<String, dynamic> data, String id) {
    return Store(
      id: id,
      storeName: data['storeName']?.toString() ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (data['totalReviews'] as num?)?.toInt() ?? 0,
    );
  }
}

class StoreFertilizer {
  final String storeId;
  final String fertilizerId;
  final double price;
  final int stock;
  final bool isAvailable;

  StoreFertilizer({
    required this.storeId,
    required this.fertilizerId,
    required this.price,
    required this.stock,
    required this.isAvailable,
  });

  factory StoreFertilizer.fromMap(Map<String, dynamic> data) {
    return StoreFertilizer(
      storeId: data['storeId']?.toString() ?? '',
      fertilizerId: data['fertilizerId']?.toString() ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      isAvailable: data['isAvailable'] == true,
    );
  }
}

class StoreSearchResult {
  final Store store;
  final StoreFertilizer details;
  final double distance;
  final double score;

  StoreSearchResult({
    required this.store,
    required this.details,
    required this.distance,
    required this.score,
  });
}
