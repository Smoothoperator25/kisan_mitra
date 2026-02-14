import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/admin_data_model.dart';

/// Controller for managing stores
class AdminStoresController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all stores
  Stream<List<StoreData>> getStoresStream() {
    return _firestore
        .collection('stores')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('Error loading stores: $error');
          return const Stream.empty();
        })
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return StoreData.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing store document ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<StoreData>()
              .toList();
        });
  }

  /// Search stores by name, owner, phone, city, or state
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

  /// Approve store
  Future<void> approveStore(String storeId, String storeName) async {
    try {
      await _firestore.collection('stores').doc(storeId).update({
        'isVerified': true,
        'isRejected': false,
        'verifiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to approve store: $e');
    }
  }

  /// Reject store
  Future<void> rejectStore(String storeId, String storeName) async {
    try {
      await _firestore.collection('stores').doc(storeId).update({
        'isVerified': false,
        'isRejected': true,
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reject store: $e');
    }
  }

  /// Delete store
  Future<void> deleteStore(String storeId) async {
    try {
      await _firestore.collection('stores').doc(storeId).delete();
    } catch (e) {
      throw Exception('Failed to delete store: $e');
    }
  }

  /// Get store statistics
  Future<Map<String, int>> getStoreStats() async {
    try {
      final allStores = await _firestore.collection('stores').get();

      int totalStores = allStores.docs.length;
      int verifiedStores = 0;
      int pendingStores = 0;
      int rejectedStores = 0;

      for (var doc in allStores.docs) {
        final data = doc.data();
        final isVerified = data['isVerified'] as bool? ?? false;
        final isRejected = data['isRejected'] as bool? ?? false;

        if (isRejected) {
          rejectedStores++;
        } else if (isVerified) {
          verifiedStores++;
        } else {
          pendingStores++;
        }
      }

      return {
        'total': totalStores,
        'verified': verifiedStores,
        'pending': pendingStores,
        'rejected': rejectedStores,
      };
    } catch (e) {
      print('Error fetching store stats: $e');
      return {'total': 0, 'verified': 0, 'pending': 0, 'rejected': 0};
    }
  }
}
