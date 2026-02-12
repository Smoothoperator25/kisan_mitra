import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_settings_model.dart';

class AdminSettingsController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminProfile? _adminProfile;
  AppConfig? _appConfig;
  bool _isLoading = false;
  String? _error;

  AdminProfile? get adminProfile => _adminProfile;
  AppConfig? get appConfig => _appConfig;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setError(String errorMsg) {
    _error = errorMsg;
    notifyListeners();
  }

  User? get currentUser => _auth.currentUser;

  // Fetch admin profile
  Future<void> fetchAdminProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Check if this is the default admin account
      if (user.email == 'admin@kisanmitra.com') {
        // Create a default profile for the main admin
        _adminProfile = AdminProfile(
          uid: user.uid,
          name: 'Administrator',
          email: user.email!,
          role: 'admin',
          accessLevel: 'FULL ACCESS',
          isOnline: true,
        );
        _isLoading = false;
        notifyListeners();
        return;
      }

      // For other admins, fetch from Firestore
      final doc = await _firestore.collection('adminUsers').doc(user.uid).get();

      if (!doc.exists) {
        throw Exception('Admin profile not found');
      }

      // Verify role
      final role = doc.data()?['role'] ?? '';
      if (role != 'admin') {
        throw Exception('Access denied: Not an admin');
      }

      _adminProfile = AdminProfile.fromFirestore(doc.data()!, user.uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch app config
  Future<void> fetchAppConfig() async {
    try {
      final doc = await _firestore.collection('appConfig').doc('config').get();

      if (doc.exists) {
        _appConfig = AppConfig.fromFirestore(doc.data()!);
      } else {
        _appConfig = AppConfig(
          appVersion: 'v2.4.0',
          maintenanceMode: false,
          supportEmail: 'support@kisanmitra.com',
        );
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update app config
  Future<bool> updateAppConfig(AppConfig config) async {
    try {
      await _firestore
          .collection('appConfig')
          .doc('config')
          .set(config.toFirestore(), SetOptions(merge: true));

      _appConfig = config;
      notifyListeners();

      // Log activity
      await logActivity(
        action: 'UPDATE_CONFIG',
        description: 'Updated app configuration',
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      // Log activity
      await logActivity(
        action: 'CHANGE_PASSWORD',
        description: 'Changed account password',
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update notification settings
  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await _firestore.collection('adminUsers').doc(user.uid).update({
        'notificationSettings': settings.toFirestore(),
      });

      // Log activity
      await logActivity(
        action: 'UPDATE_NOTIFICATIONS',
        description: 'Updated notification settings',
      );

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Log activity
  Future<void> logActivity({
    required String action,
    required String description,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final log = ActivityLog(
        id: '',
        action: action,
        description: description,
        performedBy: user.email ?? 'Unknown',
        timestamp: DateTime.now(),
      );

      await _firestore.collection('adminActivityLogs').add(log.toFirestore());
    } catch (e) {
      // Silently fail for activity logging
      debugPrint('Failed to log activity: $e');
    }
  }

  // Stream activity logs
  Stream<List<ActivityLog>> getActivityLogsStream({int limit = 50}) {
    return _firestore
        .collection('adminActivityLogs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ActivityLog.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Stream notification settings
  Stream<NotificationSettings> getNotificationSettingsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(
        NotificationSettings(
          pushNotifications: true,
          emailNotifications: true,
          storeApprovalAlerts: true,
          systemAlerts: true,
        ),
      );
    }

    return _firestore.collection('adminUsers').doc(user.uid).snapshots().map((
      doc,
    ) {
      if (!doc.exists || doc.data()?['notificationSettings'] == null) {
        return NotificationSettings(
          pushNotifications: true,
          emailNotifications: true,
          storeApprovalAlerts: true,
          systemAlerts: true,
        );
      }
      return NotificationSettings.fromFirestore(
        doc.data()!['notificationSettings'],
      );
    });
  }

  // Stream app config
  Stream<AppConfig> getAppConfigStream() {
    return _firestore.collection('appConfig').doc('config').snapshots().map((
      doc,
    ) {
      if (!doc.exists) {
        return AppConfig(
          appVersion: 'v2.4.0',
          maintenanceMode: false,
          supportEmail: 'support@kisanmitra.com',
        );
      }
      return AppConfig.fromFirestore(doc.data()!);
    });
  }

  // Logout
  Future<void> logout() async {
    try {
      // Log activity before logout
      await logActivity(
        action: 'LOGOUT',
        description: 'Logged out from admin panel',
      );

      await _auth.signOut();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Check admin access
  Future<bool> checkAdminAccess() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check if the logged-in user is the default admin
      if (user.email == 'admin@kisanmitra.com') {
        return true;
      }

      // Otherwise, check in adminUsers collection for other admins
      final doc = await _firestore.collection('adminUsers').doc(user.uid).get();

      if (!doc.exists) return false;

      final role = doc.data()?['role'] ?? '';
      return role == 'admin';
    } catch (e) {
      return false;
    }
  }
}
