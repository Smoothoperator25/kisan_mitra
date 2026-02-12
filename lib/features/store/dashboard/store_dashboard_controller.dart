import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/app_constants.dart';
import 'store_inventory_model.dart';

/// Controller for Store Dashboard Screen
/// Handles business logic for store data, inventory management, and price/stock updates
class StoreDashboardController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // State variables
  bool _isLoading = true;
  String? _error;
  StoreInfo? _storeInfo;

  // Cache for fertilizer details to minimize Firestore reads
  final Map<String, FertilizerDetails> _fertilizerCache = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  StoreInfo? get storeInfo => _storeInfo;

  /// Initialize controller - load store data on screen open
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await loadStoreData();
    } catch (e) {
      _error = 'Failed to initialize: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load store data from Firestore
  Future<void> loadStoreData() async {
    try {
      // Get current user UID from Firebase Auth
      final String? uid = _authService.currentUserId;

      if (uid == null) {
        _error = 'User not logged in';
        return;
      }

      // Fetch store document from Firestore
      final result = await _firestoreService.getDocument(
        collection: AppConstants.storesCollection,
        docId: uid,
      );

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>?;

        if (data != null) {
          _storeInfo = StoreInfo.fromFirestore(data);
        } else {
          _error = 'Store data not found';
        }
      } else {
        _error = result['message'] ?? 'Failed to load store data';
      }
    } catch (e) {
      _error = 'An error occurred while loading store data: $e';
    }
  }

  /// Get stream of store fertilizers for real-time updates
  Stream<List<StoreFertilizer>> getStoreFertilizersStream() {
    final String? uid = _authService.currentUserId;

    if (uid == null) {
      return Stream.value([]);
    }

    return _db
        .collection(AppConstants.storeFertilizersCollection)
        .where('storeId', isEqualTo: uid)
        .snapshots()
        .asyncMap((snapshot) async {
          // Convert documents to StoreFertilizer objects
          List<StoreFertilizer> fertilizers = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final fertilizer = StoreFertilizer.fromFirestore(doc.id, data);

            // Fetch fertilizer name and bag weight
            final details = await _getFertilizerDetails(
              fertilizer.fertilizerId,
            );

            if (details != null) {
              fertilizers.add(
                fertilizer.copyWith(
                  fertilizerName: details.name,
                  bagWeight: details.bagWeight,
                ),
              );
            }
          }

          return fertilizers;
        });
  }

  /// Get fertilizer details (name, bag weight) from fertilizers collection
  /// Uses caching to reduce Firestore reads
  Future<FertilizerDetails?> _getFertilizerDetails(String fertilizerId) async {
    // Check cache first
    if (_fertilizerCache.containsKey(fertilizerId)) {
      return _fertilizerCache[fertilizerId];
    }

    try {
      final result = await _firestoreService.getDocument(
        collection: AppConstants.fertilizersCollection,
        docId: fertilizerId,
      );

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>?;

        if (data != null) {
          final details = FertilizerDetails.fromFirestore(fertilizerId, data);
          _fertilizerCache[fertilizerId] = details; // Cache for future use
          return details;
        }
      }
    } catch (e) {
      debugPrint('Error fetching fertilizer details: $e');
    }

    return null;
  }

  /// Update price and stock for a specific fertilizer
  /// Validates input and updates Firestore
  Future<Map<String, dynamic>> updatePriceAndStock({
    required String fertilizerId,
    required double price,
    required int stock,
  }) async {
    try {
      // Validation
      if (price <= 0) {
        return {'success': false, 'message': 'Price must be a positive number'};
      }

      if (stock < 0) {
        return {'success': false, 'message': 'Stock cannot be negative'};
      }

      // Update Firestore document
      final result = await _firestoreService.updateDocument(
        collection: AppConstants.storeFertilizersCollection,
        docId: fertilizerId,
        data: {
          'price': price,
          'stock': stock,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      );

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Failed to update: $e'};
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
