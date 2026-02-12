import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Stock Fertilizer
/// Represents a fertilizer in the store's inventory with editable fields
class StockFertilizer {
  final String id; // Document ID in store_fertilizers collection
  final String storeId;
  final String fertilizerId;
  final String fertilizerName;
  final String bagWeight; // e.g., "NPK 46-0-0 | 45kg"
  final double price;
  final int stock;
  final bool isAvailable;
  final DateTime? lastUpdated;

  // Track if this item has been modified locally
  bool isModified;

  StockFertilizer({
    required this.id,
    required this.storeId,
    required this.fertilizerId,
    required this.fertilizerName,
    required this.bagWeight,
    required this.price,
    required this.stock,
    required this.isAvailable,
    this.lastUpdated,
    this.isModified = false,
  });

  /// Create StockFertilizer from Firestore document
  factory StockFertilizer.fromFirestore(
    String docId,
    Map<String, dynamic> data,
  ) {
    return StockFertilizer(
      id: docId,
      storeId: data['storeId'] as String? ?? '',
      fertilizerId: data['fertilizerId'] as String? ?? '',
      fertilizerName: data['fertilizerName'] as String? ?? '',
      bagWeight: data['bagWeight'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      isAvailable: data['isAvailable'] as bool? ?? true,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
      isModified: false,
    );
  }

  /// Convert to Map for Firestore update
  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'fertilizerId': fertilizerId,
      'fertilizerName': fertilizerName,
      'bagWeight': bagWeight,
      'price': price,
      'stock': stock,
      'isAvailable': isAvailable,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  StockFertilizer copyWith({
    String? id,
    String? storeId,
    String? fertilizerId,
    String? fertilizerName,
    String? bagWeight,
    double? price,
    int? stock,
    bool? isAvailable,
    DateTime? lastUpdated,
    bool? isModified,
  }) {
    return StockFertilizer(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      fertilizerId: fertilizerId ?? this.fertilizerId,
      fertilizerName: fertilizerName ?? this.fertilizerName,
      bagWeight: bagWeight ?? this.bagWeight,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isModified: isModified ?? this.isModified,
    );
  }
}
