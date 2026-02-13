import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_dashboard_model.dart';

class AdminDashboardController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get real-time dashboard statistics
  Stream<DashboardStats> getStatsStream() {
    debugPrint('🔄 Starting stats stream...');

    // Combine stores snapshot with periodic farmer checks
    return _firestore.collection('stores').snapshots().asyncExpand((storesSnapshot) async* {
      try {
        debugPrint('📊 Stats Update - Stores snapshot received: ${storesSnapshot.size} stores');

        // Get farmers count from users collection with role filter
        final farmersSnapshot = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'farmer')
            .get();
        final totalFarmers = farmersSnapshot.size;
        debugPrint('👨‍🌾 Total Farmers: $totalFarmers');

        // Get total stores from the snapshot
        final totalStores = storesSnapshot.size;
        debugPrint('🏪 Total Stores: $totalStores');

        // Count pending verifications (not verified and not rejected)
        int pendingCount = 0;
        int verifiedCount = 0;
        int rejectedCount = 0;
        int noStatusCount = 0;

        for (var doc in storesSnapshot.docs) {
          final data = doc.data();
          final isVerified = data['isVerified'] as bool? ?? false;
          final isRejected = data['isRejected'] as bool? ?? false;

          if (isVerified) {
            verifiedCount++;
          } else if (isRejected) {
            rejectedCount++;
          } else {
            pendingCount++;
          }

          // Check if fields exist
          if (!data.containsKey('isVerified') && !data.containsKey('isRejected')) {
            noStatusCount++;
            debugPrint('⚠️ Store ${doc.id} missing status fields');
          }
        }

        debugPrint('✅ Verified: $verifiedCount');
        debugPrint('⏳ Pending: $pendingCount');
        debugPrint('❌ Rejected: $rejectedCount');
        if (noStatusCount > 0) {
          debugPrint('⚠️ WARNING: $noStatusCount stores without status fields - Click Fix Database button!');
        }

        final stats = DashboardStats(
          totalFarmers: totalFarmers,
          totalStores: totalStores,
          pendingVerifications: pendingCount,
          verifiedStores: verifiedCount,
        );

        debugPrint('📈 Emitting stats: F=$totalFarmers, S=$totalStores, P=$pendingCount, V=$verifiedCount');
        yield stats;
      } catch (e, stackTrace) {
        debugPrint('❌ Error in stats stream: $e');
        debugPrint('Stack trace: $stackTrace');
        yield DashboardStats.empty();
      }
    });
  }

  /// Get initial dashboard statistics (one-time fetch)
  Future<DashboardStats> getInitialStats() async {
    try {
      debugPrint('📊 Fetching initial stats...');

      final results = await Future.wait([
        _firestore.collection('users').where('role', isEqualTo: 'farmer').get(),
        _firestore.collection('stores').get(),
      ]);

      final farmersSnapshot = results[0];
      final storesSnapshot = results[1];

      debugPrint('👨‍🌾 Initial Farmers count: ${farmersSnapshot.size}');
      debugPrint('🏪 Initial Stores count: ${storesSnapshot.size}');

      // Count pending and verified from stores snapshot
      int pendingCount = 0;
      int verifiedCount = 0;
      int rejectedCount = 0;
      int noStatusCount = 0;

      for (var doc in storesSnapshot.docs) {
        final data = doc.data();
        final isVerified = data['isVerified'] as bool? ?? false;
        final isRejected = data['isRejected'] as bool? ?? false;

        if (isVerified) {
          verifiedCount++;
        } else if (isRejected) {
          rejectedCount++;
        } else {
          pendingCount++;
        }

        // Check if fields exist
        if (!data.containsKey('isVerified') && !data.containsKey('isRejected')) {
          noStatusCount++;
          debugPrint('⚠️ Store ${doc.id} missing status fields');
        }
      }

      debugPrint('✅ Initial Verified: $verifiedCount');
      debugPrint('⏳ Initial Pending: $pendingCount');
      debugPrint('❌ Initial Rejected: $rejectedCount');
      if (noStatusCount > 0) {
        debugPrint('⚠️ Stores without status fields: $noStatusCount');
      }

      return DashboardStats(
        totalFarmers: farmersSnapshot.size,
        totalStores: storesSnapshot.size,
        pendingVerifications: pendingCount,
        verifiedStores: verifiedCount,
      );
    } catch (e) {
      debugPrint('❌ Error fetching initial stats: $e');
      return DashboardStats.empty();
    }
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

  /// Fix stores that are missing isVerified or isRejected fields
  /// This should be run once to migrate old data
  Future<void> fixMissingStoreFields() async {
    try {
      debugPrint('🔧 Starting store fields migration...');

      final storesSnapshot = await _firestore.collection('stores').get();
      final batch = _firestore.batch();
      int fixedCount = 0;

      for (var doc in storesSnapshot.docs) {
        final data = doc.data();
        bool needsUpdate = false;
        Map<String, dynamic> updates = {};

        // Check if isVerified exists, if not set to false
        if (!data.containsKey('isVerified')) {
          updates['isVerified'] = false;
          needsUpdate = true;
          debugPrint('Adding isVerified to store: ${doc.id}');
        }

        // Check if isRejected exists, if not set to false
        if (!data.containsKey('isRejected')) {
          updates['isRejected'] = false;
          needsUpdate = true;
          debugPrint('Adding isRejected to store: ${doc.id}');
        }

        // Add createdAt if missing
        if (!data.containsKey('createdAt')) {
          updates['createdAt'] = FieldValue.serverTimestamp();
          needsUpdate = true;
          debugPrint('Adding createdAt to store: ${doc.id}');
        }

        if (needsUpdate) {
          batch.update(doc.reference, updates);
          fixedCount++;
        }
      }

      if (fixedCount > 0) {
        await batch.commit();
        debugPrint('✅ Fixed $fixedCount stores');
      } else {
        debugPrint('✅ All stores have correct fields');
      }
    } catch (e) {
      debugPrint('❌ Error fixing store fields: $e');
      rethrow;
    }
  }
}
