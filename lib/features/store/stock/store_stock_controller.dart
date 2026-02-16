import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/app_constants.dart';
import 'store_stock_model.dart';

/// Controller for Store Stock Management Screen
/// Handles business logic for stock management, search, filtering, and batch updates
class StoreStockController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // State variables
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'In Stock', 'Out of Stock'
  int _resetVersion = 0; // Incremented each time reset is called

  // Track modified items for batch update
  final Map<String, StockFertilizer> _modifiedItems = {};

  // Getters
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  int get modifiedCount => _modifiedItems.length;
  bool get hasModifications => _modifiedItems.isNotEmpty;
  int get resetVersion => _resetVersion; // Used to force widget rebuild

  /// Sync fertilizers from admin's fertilizers collection to store inventory
  /// Automatically adds all available fertilizers if store has none
  Future<void> _syncFertilizersToInventory() async {
    try {
      final String? uid = _authService.currentUserId;

      if (uid == null) return;

      // Check if store already has fertilizers
      final existingSnapshot = await _db
          .collection(AppConstants.storeFertilizersCollection)
          .where('storeId', isEqualTo: uid)
          .limit(1)
          .get();

      // Only sync if inventory is empty
      if (existingSnapshot.docs.isNotEmpty) {
        return;
      }

      debugPrint('Store inventory is empty, syncing fertilizers...');

      // Fetch all available fertilizers from admin's collection
      final fertilizersSnapshot = await _db
          .collection(AppConstants.fertilizersCollection)
          .where('isArchived', isEqualTo: false)
          .get();

      if (fertilizersSnapshot.docs.isEmpty) {
        debugPrint('No fertilizers available to sync');
        return;
      }

      // Add each fertilizer to store inventory with default values
      final batch = _db.batch();
      int count = 0;

      for (var doc in fertilizersSnapshot.docs) {
        final fertilizerData = doc.data();
        final fertilizerRef = _db
            .collection(AppConstants.storeFertilizersCollection)
            .doc(); // Auto-generate ID

        batch.set(fertilizerRef, {
          'storeId': uid,
          'fertilizerId': doc.id,
          'fertilizerName': fertilizerData['name'] ?? '',
          'bagWeight': fertilizerData['npkComposition'] ?? '',
          'price': 0.0, // Store must set their own price
          'stock': 0, // Store must set their own stock
          'isAvailable': false, // Not available until price/stock is set
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        count++;
      }

      // Commit batch write
      await batch.commit();
      debugPrint('Successfully synced $count fertilizers to store inventory');
    } catch (e) {
      debugPrint('Error syncing fertilizers: $e');
    }
  }

  Stream<List<StockFertilizer>>? _fertilizerStream;

  /// Get stream of store fertilizers for real-time updates
  Stream<List<StockFertilizer>> getStoreFertilizersStream() {
    final String? uid = _authService.currentUserId;

    if (uid == null) {
      return Stream.value([]);
    }

    if (_fertilizerStream != null) return _fertilizerStream!;

    // Auto-sync fertilizers if inventory is empty (fire and forget)
    _syncFertilizersToInventory();

    _fertilizerStream = _db
        .collection(AppConstants.storeFertilizersCollection)
        .where('storeId', isEqualTo: uid)
        .snapshots()
        .asyncMap((snapshot) async {
          // Create list from Firestore
          List<StockFertilizer> fertilizers = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            var fertilizer = StockFertilizer.fromFirestore(doc.id, data);

            // Fetch additional details from fertilizers collection
            final fertilizerId = fertilizer.fertilizerId;
            if (fertilizerId.isNotEmpty) {
              try {
                final fertilizerDoc = await _db
                    .collection(AppConstants.fertilizersCollection)
                    .doc(fertilizerId)
                    .get();

                if (fertilizerDoc.exists) {
                  final fertilizerData = fertilizerDoc.data();
                  if (fertilizerData != null) {
                    fertilizer = fertilizer.copyWith(
                      npkComposition: fertilizerData['npkComposition'] as String?,
                      form: fertilizerData['form'] as String?,
                      category: fertilizerData['category'] as String?,
                      manufacturer: fertilizerData['manufacturer'] as String?,
                    );
                  }
                }
              } catch (e) {
                debugPrint('Error fetching fertilizer details for $fertilizerId: $e');
              }
            }

            fertilizers.add(fertilizer);
          }

          // Remove duplicates based on fertilizerId (keep the first occurrence)
          final uniqueFertilizers = <String, StockFertilizer>{};
          for (var fertilizer in fertilizers) {
            if (!uniqueFertilizers.containsKey(fertilizer.fertilizerId)) {
              uniqueFertilizers[fertilizer.fertilizerId] = fertilizer;
            } else {
              // Log duplicate for debugging
              debugPrint('Duplicate fertilizer found: ${fertilizer.fertilizerName} (ID: ${fertilizer.fertilizerId})');
            }
          }

          return uniqueFertilizers.values.toList();
        });

    return _fertilizerStream!;
  }

  /// Update search query and notify listeners
  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  /// Update selected filter and notify listeners
  void updateFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Filter fertilizers based on search query and selected filter
  List<StockFertilizer> filterFertilizers(List<StockFertilizer> fertilizers) {
    List<StockFertilizer> filtered = fertilizers;

    // Apply search filter first (on original data)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((f) {
        return f.fertilizerName.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply availability filter based on SAVED state from Firestore
    // NOT on local modifications - filters should only show saved data
    switch (_selectedFilter) {
      case 'In Stock':
        // In stock means: has stock quantity AND is marked as available (from Firestore)
        filtered = filtered.where((f) {
          return f.stock > 0 && f.isAvailable;
        }).toList();
        break;
      case 'Out of Stock':
        // Out of stock means: either no stock OR marked as not available (from Firestore)
        filtered = filtered.where((f) {
          return f.stock <= 0 || !f.isAvailable;
        }).toList();
        break;
      default: // 'All'
        // Show all fertilizers
        break;
    }

    // NOW apply modified values for display ONLY (not for filtering)
    // This ensures filters work on saved state, but UI shows current edits
    filtered = filtered.map((f) {
      if (_modifiedItems.containsKey(f.id)) {
        return _modifiedItems[f.id]!;
      }
      return f;
    }).toList();

    return filtered;
  }

  /// Track a modified item for batch update
  void trackModifiedItem(StockFertilizer fertilizer) {
    _modifiedItems[fertilizer.id] = fertilizer;
    notifyListeners();
  }

  /// Remove an item from modified tracking (after individual save)
  void untrackModifiedItem(String id) {
    _modifiedItems.remove(id);
    notifyListeners();
  }

  /// Validate price and stock input
  Map<String, dynamic> validateInput({
    required double price,
    required int stock,
  }) {
    if (price < 0) {
      return {'success': false, 'message': 'Price cannot be negative'};
    }

    if (stock < 0) {
      return {'success': false, 'message': 'Stock cannot be negative'};
    }

    return {'success': true};
  }

  /// Update a single fertilizer (individual save)
  Future<Map<String, dynamic>> updateSingleFertilizer({
    required String id,
    required double price,
    required int stock,
    required bool isAvailable,
  }) async {
    try {
      // Validate input
      final validation = validateInput(price: price, stock: stock);
      if (validation['success'] != true) {
        return validation;
      }

      // Update Firestore
      await _db
          .collection(AppConstants.storeFertilizersCollection)
          .doc(id)
          .update({
            'price': price,
            'stock': stock,
            'isAvailable': isAvailable,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      // Remove from modified tracking
      untrackModifiedItem(id);

      return {'success': true, 'message': 'Updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update: $e'};
    }
  }

  /// Batch update all modified items
  Future<Map<String, dynamic>> batchUpdateAllChanges() async {
    if (_modifiedItems.isEmpty) {
      return {'success': false, 'message': 'No changes to update'};
    }

    try {
      // Validate all items first
      for (var fertilizer in _modifiedItems.values) {
        final validation = validateInput(
          price: fertilizer.price,
          stock: fertilizer.stock,
        );
        if (validation['success'] != true) {
          return {
            'success': false,
            'message': '${fertilizer.fertilizerName}: ${validation['message']}',
          };
        }
      }

      // Create batch write
      final batch = _db.batch();

      for (var fertilizer in _modifiedItems.values) {
        final docRef = _db
            .collection(AppConstants.storeFertilizersCollection)
            .doc(fertilizer.id);

        batch.update(docRef, {
          'price': fertilizer.price,
          'stock': fertilizer.stock,
          'isAvailable': fertilizer.isAvailable,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      // Commit batch
      await batch.commit();

      // Clear modified items
      final count = _modifiedItems.length;
      _modifiedItems.clear();
      notifyListeners();

      return {'success': true, 'message': 'Updated $count items successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update: $e'};
    }
  }

  /// Reset all unsaved changes
  void resetChanges() {
    _modifiedItems.clear();
    _resetVersion++; // Increment to force widget rebuild
    notifyListeners();
  }

  /// Clear search and filters
  void clearFilters() {
    _searchQuery = '';
    _selectedFilter = 'All';
    notifyListeners();
  }

  /// Remove duplicate fertilizers from Firestore
  /// This method checks for duplicate fertilizerId entries and keeps only the first one
  Future<void> removeDuplicateFertilizers() async {
    try {
      final String? uid = _authService.currentUserId;
      if (uid == null) return;

      // Get all fertilizers for this store
      final snapshot = await _db
          .collection(AppConstants.storeFertilizersCollection)
          .where('storeId', isEqualTo: uid)
          .get();

      // Group by fertilizerId
      final Map<String, List<QueryDocumentSnapshot>> grouped = {};
      for (var doc in snapshot.docs) {
        final fertilizerId = doc.data()['fertilizerId'] as String?;
        if (fertilizerId != null) {
          grouped.putIfAbsent(fertilizerId, () => []).add(doc);
        }
      }

      // Find and delete duplicates
      final batch = _db.batch();
      int duplicateCount = 0;

      grouped.forEach((fertilizerId, docs) {
        if (docs.length > 1) {
          // Keep the first document, delete the rest
          for (int i = 1; i < docs.length; i++) {
            batch.delete(docs[i].reference);
            duplicateCount++;
            final data = docs[i].data() as Map<String, dynamic>?;
            final fertilizerName = (data != null && data['fertilizerName'] != null)
                ? data['fertilizerName'] as String
                : 'Unknown';
            debugPrint('Removing duplicate: $fertilizerName (${docs[i].id})');
          }
        }
      });

      if (duplicateCount > 0) {
        await batch.commit();
        debugPrint('Removed $duplicateCount duplicate fertilizer(s)');
      } else {
        debugPrint('No duplicate fertilizers found');
      }
    } catch (e) {
      debugPrint('Error removing duplicates: $e');
    }
  }
}
