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

  // Track modified items for batch update
  final Map<String, StockFertilizer> _modifiedItems = {};

  // Getters
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  int get modifiedCount => _modifiedItems.length;
  bool get hasModifications => _modifiedItems.isNotEmpty;

  /// Get stream of store fertilizers for real-time updates
  Stream<List<StockFertilizer>> getStoreFertilizersStream() {
    final String? uid = _authService.currentUserId;

    if (uid == null) {
      return Stream.value([]);
    }

    return _db
        .collection(AppConstants.storeFertilizersCollection)
        .where('storeId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => StockFertilizer.fromFirestore(doc.id, doc.data()))
              .toList();
        });
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

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((f) {
        return f.fertilizerName.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply availability filter
    switch (_selectedFilter) {
      case 'In Stock':
        filtered = filtered.where((f) => f.stock > 0 && f.isAvailable).toList();
        break;
      case 'Out of Stock':
        filtered = filtered
            .where((f) => f.stock == 0 || !f.isAvailable)
            .toList();
        break;
      default: // 'All'
        break;
    }

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
    if (price <= 0) {
      return {'success': false, 'message': 'Price must be a positive number'};
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
    notifyListeners();
  }

  /// Clear search and filters
  void clearFilters() {
    _searchQuery = '';
    _selectedFilter = 'All';
    notifyListeners();
  }
}
