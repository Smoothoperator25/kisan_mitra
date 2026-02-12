import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_dashboard_model.dart';

class AdminDashboardController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get real-time dashboard statistics
  Stream<DashboardStats> getStatsStream() {
    return Stream.periodic(const Duration(seconds: 2)).asyncMap((_) async {
      try {
        final results = await Future.wait([
          _firestore.collection('farmers').get(),
          _firestore.collection('stores').get(),
          _firestore
              .collection('stores')
              .where('isVerified', isEqualTo: false)
              .where('isRejected', isEqualTo: false)
              .get(),
          _firestore
              .collection('stores')
              .where('isVerified', isEqualTo: true)
              .get(),
        ]);

        return DashboardStats(
          totalFarmers: results[0].size,
          totalStores: results[1].size,
          pendingVerifications: results[2].size,
          verifiedStores: results[3].size,
        );
      } catch (e) {
        debugPrint('Error fetching stats: $e');
        return DashboardStats.empty();
      }
    });
  }

  /// Get pending verification requests
  Future<List<VerificationRequest>> getVerificationRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection('stores')
          .where('isVerified', isEqualTo: false)
          .where('isRejected', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => VerificationRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching verification requests: $e');
      // If index is missing, return empty list instead of crashing
      if (e.toString().contains('failed-precondition') ||
          e.toString().contains('index')) {
        debugPrint('Firestore index required. Please create the index.');
        return []; // Return empty list instead of crashing
      }
      rethrow;
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

  /// Logout admin user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error logging out: $e');
      rethrow;
    }
  }
}
