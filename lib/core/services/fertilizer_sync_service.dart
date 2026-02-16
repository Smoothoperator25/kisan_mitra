import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to sync fertilizers to all verified stores
/// When admin adds a new fertilizer, it's automatically added to all store inventories
class FertilizerSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add fertilizer to all verified stores
  /// Called when admin creates a new fertilizer
  Future<void> addFertilizerToAllStores({
    required String fertilizerId,
    required String fertilizerName,
    required String npkComposition,
  }) async {
    try {
      // Get all verified stores
      final storesSnapshot = await _firestore
          .collection('stores')
          .where('isVerified', isEqualTo: true)
          .where('isRejected', isEqualTo: false)
          .get();

      if (storesSnapshot.docs.isEmpty) {
        print('No verified stores found');
        return;
      }

      // Create batch to add fertilizer to all stores
      WriteBatch batch = _firestore.batch();
      int count = 0;

      for (var storeDoc in storesSnapshot.docs) {
        final storeId = storeDoc.id;

        // Create unique document ID
        final docRef = _firestore.collection('store_fertilizers').doc();

        batch.set(docRef, {
          'storeId': storeId,
          'fertilizerId': fertilizerId,
          'fertilizerName': fertilizerName,
          'bagWeight': npkComposition,
          'price': 0.0, // Store will set their price
          'stock': 0, // Store will set their stock
          'isAvailable': false, // Initially not available until store updates
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        count++;

        // Firestore batch has a limit of 500 operations
        // Commit and create new batch if needed
        if (count % 500 == 0) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      // Commit remaining operations
      if (count % 500 != 0) {
        await batch.commit();
      }

      print('Fertilizer added to $count stores');
    } catch (e) {
      print('Error adding fertilizer to stores: $e');
      rethrow;
    }
  }

  /// Remove fertilizer from all stores
  /// Called when admin deletes or archives a fertilizer
  Future<void> removeFertilizerFromAllStores(String fertilizerId) async {
    try {
      // Get all store_fertilizers documents with this fertilizerId
      final snapshot = await _firestore
          .collection('store_fertilizers')
          .where('fertilizerId', isEqualTo: fertilizerId)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No store fertilizers found for deletion');
        return;
      }

      // Create batch to delete all
      WriteBatch batch = _firestore.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        count++;

        // Commit batch every 500 operations
        if (count % 500 == 0) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      // Commit remaining operations
      if (count % 500 != 0) {
        await batch.commit();
      }

      print('Fertilizer removed from $count stores');
    } catch (e) {
      print('Error removing fertilizer from stores: $e');
      rethrow;
    }
  }

  /// Sync existing fertilizers to a newly verified store
  /// Called when a store gets verified
  Future<void> syncAllFertilizersToNewStore(String storeId) async {
    try {
      // Get all non-archived fertilizers
      final fertilizersSnapshot = await _firestore
          .collection('fertilizers')
          .where('isArchived', isEqualTo: false)
          .get();

      if (fertilizersSnapshot.docs.isEmpty) {
        print('No fertilizers found to sync');
        return;
      }

      // Create batch to add all fertilizers to this store
      WriteBatch batch = _firestore.batch();
      int count = 0;

      for (var fertDoc in fertilizersSnapshot.docs) {
        final fertilizerId = fertDoc.id;
        final data = fertDoc.data();
        final fertilizerName = data['name'] as String? ?? '';
        final npkComposition = data['npkComposition'] as String? ?? '';

        // Check if fertilizer already exists for this store
        final existing = await _firestore
            .collection('store_fertilizers')
            .where('storeId', isEqualTo: storeId)
            .where('fertilizerId', isEqualTo: fertilizerId)
            .get();

        if (existing.docs.isNotEmpty) {
          print('Fertilizer $fertilizerId already exists for store $storeId');
          continue; // Skip if already exists
        }

        // Create unique document ID
        final docRef = _firestore.collection('store_fertilizers').doc();

        batch.set(docRef, {
          'storeId': storeId,
          'fertilizerId': fertilizerId,
          'fertilizerName': fertilizerName,
          'bagWeight': npkComposition,
          'price': 0.0,
          'stock': 0,
          'isAvailable': false,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        count++;

        // Commit batch every 500 operations
        if (count % 500 == 0) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      // Commit remaining operations
      if (count % 500 != 0) {
        await batch.commit();
      }

      print('Synced $count fertilizers to store $storeId');
    } catch (e) {
      print('Error syncing fertilizers to new store: $e');
      rethrow;
    }
  }

  /// Update fertilizer name across all store inventories
  /// Called when admin updates fertilizer name
  Future<void> updateFertilizerNameInAllStores({
    required String fertilizerId,
    required String newName,
    required String newNpkComposition,
  }) async {
    try {
      // Get all store_fertilizers documents with this fertilizerId
      final snapshot = await _firestore
          .collection('store_fertilizers')
          .where('fertilizerId', isEqualTo: fertilizerId)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No store fertilizers found for update');
        return;
      }

      // Create batch to update all
      WriteBatch batch = _firestore.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'fertilizerName': newName,
          'bagWeight': newNpkComposition,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        count++;

        // Commit batch every 500 operations
        if (count % 500 == 0) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      // Commit remaining operations
      if (count % 500 != 0) {
        await batch.commit();
      }

      print('Fertilizer name updated in $count stores');
    } catch (e) {
      print('Error updating fertilizer name in stores: $e');
      rethrow;
    }
  }
}
