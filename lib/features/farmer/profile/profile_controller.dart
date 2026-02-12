import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/app_constants.dart';
import 'profile_model.dart';

/// Profile Controller
/// Handles all business logic for profile management
class ProfileController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // State variables
  UserProfile? _userProfile;
  UserActivity? _userActivity;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserProfile? get userProfile => _userProfile;
  UserActivity? get userActivity => _userActivity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch user profile from Firestore
  Future<void> fetchUserProfile() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final String? userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Fetch user document
      final result = await _firestoreService.getDocument(
        collection: AppConstants.usersCollection,
        docId: userId,
      );

      if (result['success'] == true && result['data'] != null) {
        _userProfile = UserProfile.fromFirestore(userId, result['data']);
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch profile');
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading profile: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch user activity statistics
  Future<void> fetchUserActivity() async {
    try {
      final String? userId = _authService.currentUserId;
      if (userId == null) return;

      // Fetch activity subcollection document
      final activityDoc = await _db
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('activity')
          .doc('stats')
          .get();

      if (activityDoc.exists && activityDoc.data() != null) {
        _userActivity = UserActivity.fromFirestore(activityDoc.data()!);
      } else {
        // Initialize with default values if doesn't exist
        _userActivity = UserActivity();
      }

      notifyListeners();
    } catch (e) {
      // Silently fail - statistics are not critical
      _userActivity = UserActivity();
      notifyListeners();
    }
  }

  /// Update user profile in Firestore
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String state,
    required String city,
    required String village,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final String? userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Prepare update data
      final Map<String, dynamic> updateData = {
        'name': name.trim(),
        'phone': phone.trim(),
        'state': state.trim(),
        'city': city.trim(),
        'village': village.trim(),
      };

      // Update Firestore
      final result = await _firestoreService.updateDocument(
        collection: AppConstants.usersCollection,
        docId: userId,
        data: updateData,
      );

      if (result['success'] == true) {
        // Update local profile
        if (_userProfile != null) {
          _userProfile = _userProfile!.copyWith(
            name: name.trim(),
            phone: phone.trim(),
            state: state.trim(),
            city: city.trim(),
            village: village.trim(),
          );
        }
        notifyListeners();
        return true;
      } else {
        throw Exception(result['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Upload profile image
  Future<bool> uploadProfileImage() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final String? userId = _authService.currentUserId;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Pick image from gallery
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        _setLoading(false);
        return false; // User cancelled
      }

      // Upload to Firebase Storage
      final storageRef = _storage.ref().child(
        'profile_images/$userId/profile.jpg',
      );
      final File imageFile = File(image.path);

      await storageRef.putFile(imageFile);

      // Get download URL
      final String downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore with new image URL
      final result = await _firestoreService.updateDocument(
        collection: AppConstants.usersCollection,
        docId: userId,
        data: {'profileImageUrl': downloadUrl},
      );

      if (result['success'] == true) {
        // Update local profile
        if (_userProfile != null) {
          _userProfile = _userProfile!.copyWith(profileImageUrl: downloadUrl);
        }
        notifyListeners();
        return true;
      } else {
        throw Exception(result['message'] ?? 'Failed to save image URL');
      }
    } catch (e) {
      _errorMessage = 'Error uploading image: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      if (_userProfile == null) {
        throw Exception('Profile not loaded');
      }

      final result = await _authService.sendPasswordResetEmail(
        _userProfile!.email,
      );

      if (result['success'] == true) {
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error sending reset email: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _userProfile = null;
      _userActivity = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error signing out: $e';
      notifyListeners();
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initialize - fetch both profile and activity
  Future<void> initialize() async {
    await fetchUserProfile();
    await fetchUserActivity();
  }
}
