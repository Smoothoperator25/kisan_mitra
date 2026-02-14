import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_notification_model.dart';

/// Controller for managing admin notifications
class AdminNotificationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _adminId => _auth.currentUser?.uid ?? '';

  /// Get notifications stream for current admin
  Stream<List<AdminNotification>> getNotificationsStream() {
    return _firestore
        .collection('adminNotifications')
        .where('adminId', isEqualTo: _adminId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return AdminNotification.fromFirestore(doc);
            } catch (e) {
              debugPrint('Error parsing notification ${doc.id}: $e');
              return null;
            }
          })
          .whereType<AdminNotification>()
          .toList();
    });
  }

  /// Get unread notifications count
  Stream<int> getUnreadCountStream() {
    // Use client-side filtering to avoid composite index requirement
    return _firestore
        .collection('adminNotifications')
        .where('adminId', isEqualTo: _adminId)
        .snapshots()
        .map((snapshot) {
      // Filter unread notifications on client side
      return snapshot.docs
          .where((doc) => doc.data()['isRead'] == false)
          .length;
    });
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('adminNotifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Get all notifications for this admin and filter on client side
      final allDocs = await _firestore
          .collection('adminNotifications')
          .where('adminId', isEqualTo: _adminId)
          .get();

      // Filter unread on client side
      final unreadDocs = allDocs.docs
          .where((doc) => doc.data()['isRead'] == false)
          .toList();

      if (unreadDocs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in unreadDocs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('adminNotifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      rethrow;
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      final allDocs = await _firestore
          .collection('adminNotifications')
          .where('adminId', isEqualTo: _adminId)
          .get();

      final batch = _firestore.batch();
      for (var doc in allDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
      rethrow;
    }
  }

  /// Create a test notification (for development)
  Future<void> createTestNotification() async {
    try {
      final notification = AdminNotification(
        id: '',
        title: 'Test Notification',
        message: 'This is a test notification created at ${DateTime.now()}',
        type: NotificationType.general,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _firestore.collection('adminNotifications').add({
        ...notification.toFirestore(),
        'adminId': _adminId,
      });
    } catch (e) {
      debugPrint('Error creating test notification: $e');
      rethrow;
    }
  }

  /// Create notification for store verification request
  Future<void> createStoreVerificationNotification({
    required String storeId,
    required String storeName,
  }) async {
    try {
      final notification = AdminNotification(
        id: '',
        title: 'New Store Verification Request',
        message: '$storeName has requested verification',
        type: NotificationType.storeVerification,
        timestamp: DateTime.now(),
        isRead: false,
        actionUrl: '/admin-store-details',
        metadata: {'storeId': storeId, 'storeName': storeName},
      );

      await _firestore.collection('adminNotifications').add({
        ...notification.toFirestore(),
        'adminId': _adminId,
      });
    } catch (e) {
      debugPrint('Error creating store verification notification: $e');
    }
  }

  /// Create notification for new farmer registration
  Future<void> createFarmerRegistrationNotification({
    required String farmerId,
    required String farmerName,
  }) async {
    try {
      final notification = AdminNotification(
        id: '',
        title: 'New Farmer Registration',
        message: '$farmerName has registered on the platform',
        type: NotificationType.farmerRegistration,
        timestamp: DateTime.now(),
        isRead: false,
        actionUrl: '/admin-farmers-list',
        metadata: {'farmerId': farmerId, 'farmerName': farmerName},
      );

      await _firestore.collection('adminNotifications').add({
        ...notification.toFirestore(),
        'adminId': _adminId,
      });
    } catch (e) {
      debugPrint('Error creating farmer registration notification: $e');
    }
  }

  /// Create system alert notification
  Future<void> createSystemAlert({
    required String title,
    required String message,
  }) async {
    try {
      final notification = AdminNotification(
        id: '',
        title: title,
        message: message,
        type: NotificationType.systemAlert,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _firestore.collection('adminNotifications').add({
        ...notification.toFirestore(),
        'adminId': _adminId,
      });
    } catch (e) {
      debugPrint('Error creating system alert: $e');
    }
  }

  /// Get notifications by type
  Stream<List<AdminNotification>> getNotificationsByType(NotificationType type) {
    // Use client-side ordering to avoid composite index requirement
    return _firestore
        .collection('adminNotifications')
        .where('adminId', isEqualTo: _adminId)
        .where('type', isEqualTo: type.name)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs
          .map((doc) {
            try {
              return AdminNotification.fromFirestore(doc);
            } catch (e) {
              debugPrint('Error parsing notification ${doc.id}: $e');
              return null;
            }
          })
          .whereType<AdminNotification>()
          .toList();

      // Sort by timestamp on client side
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Limit to 20 items
      return notifications.take(20).toList();
    });
  }
}
