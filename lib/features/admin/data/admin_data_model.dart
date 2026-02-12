import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Farmer data in the farmers collection
class FarmerData {
  final String id;
  final String name;
  final String phone;
  final String city;
  final String state;
  final List<Crop> crops;
  final bool isActive;
  final DateTime createdAt;

  FarmerData({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.state,
    required this.crops,
    required this.isActive,
    required this.createdAt,
  });

  factory FarmerData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Document data is null');
    }

    List<Crop> cropsList = [];
    if (data['crops'] != null && data['crops'] is List) {
      final cropsData = data['crops'] as List<dynamic>;
      cropsList = cropsData
          .map((crop) {
            try {
              return Crop.fromMap(crop as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing crop: $e');
              return null;
            }
          })
          .whereType<Crop>()
          .toList();
    }

    return FarmerData(
      id: doc.id,
      name: data['name']?.toString() ?? 'Unknown',
      phone: data['phone']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      state: data['state']?.toString() ?? '',
      crops: cropsList,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get location => '$city, $state';

  String get cropsDisplay {
    if (crops.isEmpty) return 'No crops added';
    return crops.map((crop) => '${crop.name} (${crop.acres} acres)').join(', ');
  }
}

/// Model for Crop
class Crop {
  final String name;
  final double acres;

  Crop({required this.name, required this.acres});

  factory Crop.fromMap(Map<String, dynamic> data) {
    return Crop(
      name: data['name']?.toString() ?? '',
      acres: (data['acres'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Model for Store data in the stores collection
class StoreData {
  final String id;
  final String storeName;
  final String ownerName;
  final String phone;
  final String city;
  final String state;
  final bool isVerified;
  final bool isRejected;
  final DateTime createdAt;

  StoreData({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.phone,
    required this.city,
    required this.state,
    required this.isVerified,
    required this.isRejected,
    required this.createdAt,
  });

  factory StoreData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreData(
      id: doc.id,
      storeName: data['storeName']?.toString() ?? '',
      ownerName: data['ownerName']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      state: data['state']?.toString() ?? '',
      isVerified: data['isVerified'] as bool? ?? false,
      isRejected: data['isRejected'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get location => '$city, $state';

  String get status {
    if (isRejected) return 'REJECTED';
    if (isVerified) return 'VERIFIED';
    return 'PENDING';
  }

  bool get isPending => !isVerified && !isRejected;
  bool get isApproved => isVerified;
}
