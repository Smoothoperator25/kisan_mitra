import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/app_constants.dart';

/// Controller for Farmer Home Screen
/// Handles business logic for fetching and managing farmer data
class FarmerHomeController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // State variables
  bool _isLoading = true;
  String? _farmerName;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get farmerName => _farmerName;
  String? get error => _error;

  /// Load farmer data from Firestore
  Future<void> loadFarmerData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get current user UID from Firebase Auth
      final String? uid = _authService.currentUserId;

      if (uid == null) {
        _error = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch user document from Firestore
      final result = await _firestoreService.getDocument(
        collection: AppConstants.usersCollection,
        docId: uid,
      );

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>?;

        if (data != null && data['name'] != null) {
          _farmerName = data['name'] as String;
        } else {
          _farmerName = 'Farmer'; // Fallback if name is not available
        }
      } else {
        _error = result['message'] ?? 'Failed to load farmer data';
      }
    } catch (e) {
      _error = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
