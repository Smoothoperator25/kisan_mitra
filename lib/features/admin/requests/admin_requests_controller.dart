import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_request_model.dart';
import '../dashboard/admin_dashboard_model.dart';

class AdminRequestsController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get real-time stream of all stores
  Stream<List<StoreRequest>> getStoresStream() {
    return _firestore
        .collection('stores')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => StoreRequest.fromFirestore(doc))
              .toList();
        });
  }

  /// Search stores by name, city, or state
  List<StoreRequest> searchStores(String query, List<StoreRequest> stores) {
    if (query.isEmpty) return stores;

    final lowerQuery = query.toLowerCase();
    return stores.where((store) {
      return store.storeName.toLowerCase().contains(lowerQuery) ||
          store.city.toLowerCase().contains(lowerQuery) ||
          store.state.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter stores by status
  List<StoreRequest> filterStoresByStatus(
    String status,
    List<StoreRequest> stores,
  ) {
    switch (status) {
      case 'All':
        return stores;
      case 'Pending':
        return stores.where((store) => store.isPending).toList();
      case 'Approved':
        return stores.where((store) => store.isApproved).toList();
      case 'Rejected':
        return stores.where((store) => store.isRejectedStatus).toList();
      default:
        return stores;
    }
  }

  /// Approve store verification
  Future<void> approveStore(String storeId, String storeName) async {
    try {
      final batch = _firestore.batch();

      // Update store document
      final storeRef = _firestore.collection('stores').doc(storeId);
      batch.update(storeRef, {
        'isVerified': true,
        'isRejected': false,
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      // Create activity log
      final logRef = _firestore.collection('adminActivityLogs').doc();
      final log = AdminActivityLog(
        action: 'APPROVED_STORE',
        targetId: storeId,
        targetName: storeName,
        adminId: _auth.currentUser?.uid ?? '',
        timestamp: DateTime.now(),
        details: 'Store verification approved',
      );
      batch.set(logRef, log.toFirestore());

      await batch.commit();
    } catch (e) {
      debugPrint('Error approving store: $e');
      rethrow;
    }
  }

  /// Reject store verification
  Future<void> rejectStore(String storeId, String storeName) async {
    try {
      final batch = _firestore.batch();

      // Update store document
      final storeRef = _firestore.collection('stores').doc(storeId);
      batch.update(storeRef, {
        'isRejected': true,
        'isVerified': false,
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      // Create activity log
      final logRef = _firestore.collection('adminActivityLogs').doc();
      final log = AdminActivityLog(
        action: 'REJECTED_STORE',
        targetId: storeId,
        targetName: storeName,
        adminId: _auth.currentUser?.uid ?? '',
        timestamp: DateTime.now(),
        details: 'Store verification rejected',
      );
      batch.set(logRef, log.toFirestore());

      await batch.commit();
    } catch (e) {
      debugPrint('Error rejecting store: $e');
      rethrow;
    }
  }
}
