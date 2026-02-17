import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to repair data mismatches between stores and store_fertilizers collections
/// Used to fix synchronization issues where stores exist but have no fertilizer entries
class DataRepairService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sync all fertilizers to all verified stores that are missing them
  Future<Map<String, dynamic>> syncAllFertilizersToStores() async {
    try {
      print('Starting data repair: syncing fertilizers to stores...');

      // Get all fertilizers
      final fertilizerSnapshot = await _firestore
          .collection('fertilizers_master')
          .where('isActive', isEqualTo: true)
          .get();

      print('Found ${fertilizerSnapshot.docs.length} active fertilizers');

      // Get all verified stores
      final storesSnapshot = await _firestore
          .collection('stores')
          .where('isVerified', isEqualTo: true)
          .get();

      print('Found ${storesSnapshot.docs.length} verified stores');

      int totalAdded = 0;
      int skipped = 0;

      WriteBatch batch = _firestore.batch();
      int batchCount = 0;

      for (var storeDoc in storesSnapshot.docs) {
        final storeId = storeDoc.id;
        final storeData = storeDoc.data();

        for (var fertDoc in fertilizerSnapshot.docs) {
          final fertilizerId = fertDoc.id;
          final fertilizerData = fertDoc.data();

          // Check if this store already has this fertilizer
          final existingQuery = await _firestore
              .collection('store_fertilizers')
              .where('storeId', isEqualTo: storeId)
              .where('fertilizerId', isEqualTo: fertilizerId)
              .limit(1)
              .get();

          if (existingQuery.docs.isEmpty) {
            // Create entry for this store-fertilizer pair
            final docRef = _firestore.collection('store_fertilizers').doc();

            batch.set(docRef, {
              'storeId': storeId,
              'fertilizerId': fertilizerId,
              'fertilizerName': fertilizerData['name'] ?? '',
              'npkComposition':
                  '${fertilizerData['n_value'] ?? '0'}:${fertilizerData['p_value'] ?? '0'}:${fertilizerData['k_value'] ?? '0'}',
              'price': 0.0, // Default price - store will update
              'stock': 0, // Default stock - store will update
              'isAvailable': false,
              'lastUpdated': FieldValue.serverTimestamp(),
              'createdAt': FieldValue.serverTimestamp(),
            });

            totalAdded++;
            batchCount++;

            // Commit batch every 500 operations
            if (batchCount >= 500) {
              await batch.commit();
              print('Committed batch: $batchCount operations');
              batch = _firestore.batch();
              batchCount = 0;
            }
          } else {
            skipped++;
          }
        }
      }

      // Final batch commit
      if (batchCount > 0) {
        await batch.commit();
        print('Committed final batch: $batchCount operations');
      }

      print('Data repair complete: Added=$totalAdded, Skipped=$skipped');
      return {
        'success': true,
        'message': 'Data repair completed successfully',
        'totalAdded': totalAdded,
        'skipped': skipped,
      };
    } catch (e) {
      print('Error during data repair: $e');
      return {
        'success': false,
        'message': 'Error during data repair: $e',
      };
    }
  }

  /// Get stores that have no fertilizers linked
  Future<List<String>> getUnlinkedStores() async {
    try {
      final allStores = await _firestore
          .collection('stores')
          .where('isVerified', isEqualTo: true)
          .get();

      List<String> unlinkedStoreIds = [];

      for (var storeDoc in allStores.docs) {
        final storeId = storeDoc.id;
        final linkedFertilizers = await _firestore
            .collection('store_fertilizers')
            .where('storeId', isEqualTo: storeId)
            .limit(1)
            .get();

        if (linkedFertilizers.docs.isEmpty) {
          unlinkedStoreIds.add(storeId);
        }
      }

      return unlinkedStoreIds;
    } catch (e) {
      print('Error getting unlinked stores: $e');
      return [];
    }
  }

  /// Get fertilizers that are not in any store
  Future<List<String>> getUnusedFertilizers() async {
    try {
      final allFertilizers = await _firestore
          .collection('fertilizers_master')
          .where('isActive', isEqualTo: true)
          .get();

      List<String> unusedFertilizerIds = [];

      for (var fertDoc in allFertilizers.docs) {
        final fertilizerId = fertDoc.id;
        final linkedStores = await _firestore
            .collection('store_fertilizers')
            .where('fertilizerId', isEqualTo: fertilizerId)
            .limit(1)
            .get();

        if (linkedStores.docs.isEmpty) {
          unusedFertilizerIds.add(fertilizerId);
        }
      }

      return unusedFertilizerIds;
    } catch (e) {
      print('Error getting unused fertilizers: $e');
      return [];
    }
  }

  /// Get statistics about data synchronization
  Future<Map<String, dynamic>> getDataSyncStats() async {
    try {
      final storesSnapshot = await _firestore
          .collection('stores')
          .where('isVerified', isEqualTo: true)
          .get();

      final storeFertilizersSnapshot =
          await _firestore.collection('store_fertilizers').get();

      final unlinkedStores = await getUnlinkedStores();
      final unusedFertilizers = await getUnusedFertilizers();

      return {
        'totalVerifiedStores': storesSnapshot.docs.length,
        'totalStoreFertilizerLinks': storeFertilizersSnapshot.docs.length,
        'unlinkedStoresCount': unlinkedStores.length,
        'unlinkedStoreIds': unlinkedStores,
        'unusedFertilizersCount': unusedFertilizers.length,
        'unusedFertilizerIds': unusedFertilizers,
        'averageLinksPerStore':
            storesSnapshot.docs.isEmpty ? 0 : storeFertilizersSnapshot.docs.length / storesSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting sync stats: $e');
      return {'success': false, 'message': 'Error getting stats: $e'};
    }
  }

  /// Add isActive field to all fertilizers that are missing it
  Future<Map<String, dynamic>> addIsActiveFieldToFertilizers() async {
    try {
      print('Starting fertilizer migration: Adding isActive field...');

      // Get all fertilizers
      final fertilizerSnapshot = await _firestore
          .collection('fertilizers_master')
          .get();

      print('Found ${fertilizerSnapshot.docs.length} fertilizers to check');

      int updatedCount = 0;
      int skippedCount = 0;
      List<String> updatedIds = [];

      for (var doc in fertilizerSnapshot.docs) {
        final data = doc.data();

        // Check if isActive field exists (check all possible variants)
        bool hasIsActiveField = data.containsKey('isActive') ||
                                data.containsKey('is_active') ||
                                data.containsKey('active');

        if (!hasIsActiveField) {
          // Add isActive field with default value true
          await doc.reference.update({
            'isActive': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          updatedCount++;
          updatedIds.add(doc.id);
          print('✅ Added isActive field to fertilizer: ${doc.id} (${data['name']})');
        } else {
          skippedCount++;
        }
      }

      print('\n✅ Migration complete!');
      print('Updated: $updatedCount fertilizers');
      print('Skipped: $skippedCount fertilizers');

      return {
        'success': true,
        'message': 'Successfully added isActive field to $updatedCount fertilizers',
        'updatedCount': updatedCount,
        'skippedCount': skippedCount,
        'updatedIds': updatedIds,
        'totalChecked': fertilizerSnapshot.docs.length,
      };
    } catch (e) {
      print('❌ Error during migration: $e');
      return {
        'success': false,
        'message': 'Migration failed: $e',
        'error': e.toString(),
      };
    }
  }

  /// Get fertilizers missing isActive field
  Future<List<Map<String, dynamic>>> getFertilizersMissingIsActive() async {
    try {
      final fertilizerSnapshot = await _firestore
          .collection('fertilizers_master')
          .get();

      List<Map<String, dynamic>> missingFertilizers = [];

      for (var doc in fertilizerSnapshot.docs) {
        final data = doc.data();

        bool hasIsActiveField = data.containsKey('isActive') ||
                                data.containsKey('is_active') ||
                                data.containsKey('active');

        if (!hasIsActiveField) {
          missingFertilizers.add({
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'category': data['category'] ?? 'Unknown',
          });
        }
      }

      return missingFertilizers;
    } catch (e) {
      print('Error getting missing fertilizers: $e');
      return [];
    }
  }
}

