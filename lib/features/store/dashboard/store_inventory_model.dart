import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Store Information
/// Represents store header data displayed in dashboard
class StoreInfo {
  final String storeName;
  final String address;
  final String phone;
  final double rating;
  final bool isVerified;

  StoreInfo({
    required this.storeName,
    required this.address,
    required this.phone,
    required this.rating,
    required this.isVerified,
  });

  /// Create StoreInfo from Firestore document
  factory StoreInfo.fromFirestore(Map<String, dynamic> data) {
    return StoreInfo(
      storeName: data['storeName']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      isVerified: data['isVerified'] as bool? ?? false,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'storeName': storeName,
      'address': address,
      'phone': phone,
      'rating': rating,
      'isVerified': isVerified,
    };
  }
}

/// Model for Store Fertilizer Inventory Item
/// Represents a fertilizer available in the store with pricing and stock info
class StoreFertilizer {
  final String id; // Document ID
  final String storeId;
  final String fertilizerId;
  final double price;
  final int stock;
  final bool isAvailable;
  final DateTime? lastUpdated;

  // Additional fields fetched from fertilizers collection
  String? fertilizerName;
  String? bagWeight;
  String? npkComposition;
  String? manufacturer;
  String? category;
  String? form;

  StoreFertilizer({
    required this.id,
    required this.storeId,
    required this.fertilizerId,
    required this.price,
    required this.stock,
    required this.isAvailable,
    this.lastUpdated,
    this.fertilizerName,
    this.bagWeight,
    this.npkComposition,
    this.manufacturer,
    this.category,
    this.form,
  });

  /// Create StoreFertilizer from Firestore document
  factory StoreFertilizer.fromFirestore(
    String docId,
    Map<String, dynamic> data,
  ) {
    return StoreFertilizer(
      id: docId,
      storeId: data['storeId'] as String? ?? '',
      fertilizerId: data['fertilizerId'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      isAvailable: data['isAvailable'] as bool? ?? true,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Map for Firestore update
  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'fertilizerId': fertilizerId,
      'price': price,
      'stock': stock,
      'isAvailable': isAvailable,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  StoreFertilizer copyWith({
    String? id,
    String? storeId,
    String? fertilizerId,
    double? price,
    int? stock,
    bool? isAvailable,
    DateTime? lastUpdated,
    String? fertilizerName,
    String? bagWeight,
    String? npkComposition,
    String? manufacturer,
    String? category,
    String? form,
  }) {
    return StoreFertilizer(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      fertilizerId: fertilizerId ?? this.fertilizerId,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      fertilizerName: fertilizerName ?? this.fertilizerName,
      bagWeight: bagWeight ?? this.bagWeight,
      npkComposition: npkComposition ?? this.npkComposition,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      form: form ?? this.form,
    );
  }
}

/// Model for Fertilizer Details
/// Fetched from fertilizers collection to get name and bag weight
class FertilizerDetails {
  final String id;
  final String name;
  final String bagWeight;
  final String npkComposition;
  final String manufacturer;
  final String category;
  final String form;

  FertilizerDetails({
    required this.id,
    required this.name,
    required this.bagWeight,
    required this.npkComposition,
    required this.manufacturer,
    required this.category,
    required this.form,
  });

  /// Create FertilizerDetails from Firestore document
  factory FertilizerDetails.fromFirestore(
    String docId,
    Map<String, dynamic> data,
  ) {
    return FertilizerDetails(
      id: docId,
      name: data['name'] as String? ?? '',
      bagWeight: data['npkComposition'] as String? ?? '',
      npkComposition: data['npkComposition'] as String? ?? '',
      manufacturer: data['manufacturer'] as String? ?? '',
      category: data['category'] as String? ?? 'Inorganic',
      form: data['form'] as String? ?? 'Granular',
    );
  }
}
