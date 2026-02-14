import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_data_model.dart';

/// Controller for managing admin data (farmers and stores)
class AdminDataController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all farmers
  Stream<List<FarmerData>> getFarmersStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'farmer')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('Error loading farmers: $error');
          // Return empty list on error to prevent crash
          return const Stream.empty();
        })
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return FarmerData.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing farmer document ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<FarmerData>() // Filter out null values
              .toList();
        });
  }

  /// Stream of all stores
  Stream<List<StoreData>> getStoresStream() {
    return _firestore
        .collection('stores')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => StoreData.fromFirestore(doc))
              .toList();
        });
  }

  /// Search farmers by name, city, or phone
  List<FarmerData> searchFarmers(String query, List<FarmerData> farmers) {
    if (query.isEmpty) return farmers;

    final lowerQuery = query.toLowerCase();
    return farmers.where((farmer) {
      return farmer.name.toLowerCase().contains(lowerQuery) ||
          farmer.phone.contains(lowerQuery) ||
          farmer.city.toLowerCase().contains(lowerQuery) ||
          farmer.state.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Search stores by name, owner, city, or phone
  List<StoreData> searchStores(String query, List<StoreData> stores) {
    if (query.isEmpty) return stores;

    final lowerQuery = query.toLowerCase();
    return stores.where((store) {
      return store.storeName.toLowerCase().contains(lowerQuery) ||
          store.ownerName.toLowerCase().contains(lowerQuery) ||
          store.phone.contains(lowerQuery) ||
          store.city.toLowerCase().contains(lowerQuery) ||
          store.state.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get single farmer by ID
  Future<FarmerData?> getFarmerById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return FarmerData.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch farmer: $e');
    }
  }

  /// Get single store by ID
  Future<StoreData?> getStoreById(String id) async {
    try {
      final doc = await _firestore.collection('stores').doc(id).get();
      if (doc.exists) {
        return StoreData.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch store: $e');
    }
  }

  /// Get comprehensive reports data for analytics
  Future<Map<String, dynamic>> getReportsData() async {
    try {
      // Get farmers count
      final farmersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'farmer')
          .get();
      final farmerCount = farmersSnapshot.docs.length;

      // Count active farmers
      final activeFarmers = farmersSnapshot.docs
          .where((doc) => doc.data()['isActive'] == true)
          .length;

      // Count total crops
      int totalCrops = 0;
      for (var doc in farmersSnapshot.docs) {
        final crops = doc.data()['crops'] as List?;
        if (crops != null) {
          totalCrops += crops.length;
        }
      }

      // Get stores count
      final storesSnapshot = await _firestore.collection('stores').get();
      final storeCount = storesSnapshot.docs.length;

      // Count verified stores
      final verifiedStores = storesSnapshot.docs
          .where((doc) => doc.data()['isVerified'] == true)
          .length;

      // Count pending stores
      final pendingStores = storesSnapshot.docs
          .where((doc) =>
              doc.data()['isVerified'] == false &&
              doc.data()['isRejected'] == false)
          .length;

      return {
        'farmerCount': farmerCount,
        'storeCount': storeCount,
        'verifiedStores': verifiedStores,
        'pendingStores': pendingStores,
        'activeFarmers': activeFarmers,
        'totalCrops': totalCrops,
      };
    } catch (e) {
      throw Exception('Failed to fetch reports data: $e');
    }
  }
}
