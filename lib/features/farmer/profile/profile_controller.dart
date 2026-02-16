import 'dart:async';
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

  // Stream subscription for realtime updates
  StreamSubscription<DocumentSnapshot>? _activitySubscription;

  @override
  void dispose() {
    _activitySubscription?.cancel();
    super.dispose();
  }

  /// Initialize - fetch profile and start listening to activity stream
  Future<void> initialize() async {
    await fetchUserProfile();
    _initActivityStream();
  }

  /// Start listening to user activity changes
  void _initActivityStream() {
    final String? userId = _authService.currentUserId;
    if (userId == null) return;

    _activitySubscription?.cancel();
    _activitySubscription = _db
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection('activity')
        .doc('stats')
        .snapshots()
        .listen(
          (snapshot) {
            print('DEBUG: Activity stream update received'); // DEBUG LOG
            if (snapshot.exists && snapshot.data() != null) {
              _userActivity = UserActivity.fromFirestore(snapshot.data()!);
              print('DEBUG: New Search Count: ${_userActivity?.searchCount}');
            } else {
              _userActivity = UserActivity(); // Default empty
            }
            notifyListeners();
          },
          onError: (error) {
            print('Error in activity stream: $error');
          },
        );
  }

  /// Fetch user activity statistics (One-time fetch - fallback)
  Future<void> fetchUserActivity() async {
    // This is now largely redundant due to the stream, but kept for manual refresh if needed
    // logic same as before or just rely on stream
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
        email: _userProfile!.email,
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

  /// Change user password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (result['success'] == true) {
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to change password';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error changing password: $e';
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
      // Cancel stream
      _activitySubscription?.cancel();
      _activitySubscription = null;

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

  /// Increment advisory used count
  Future<void> incrementAdvisoryCount() async {
    print('DEBUG: incrementAdvisoryCount called');
    try {
      final String? userId = _authService.currentUserId;
      if (userId == null) return;

      // Update Firestore ONLY - Stream will handle local update
      await _db
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('activity')
          .doc('stats')
          .set({
            'advisoryCount': FieldValue.increment(1),
          }, SetOptions(merge: true));

      print('DEBUG: Advisory Firestore update sent');
    } catch (e) {
      print('Error incrementing advisory count: $e');
    }
  }

  /// Increment store visited count
  Future<void> incrementStoreVisitCount() async {
    try {
      final String? userId = _authService.currentUserId;
      if (userId == null) return;

      await _db
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('activity')
          .doc('stats')
          .set({
            'visitedStoresCount': FieldValue.increment(1),
          }, SetOptions(merge: true));

      print('DEBUG: Store visit update sent');
    } catch (e) {
      print('Error incrementing store visit count: $e');
    }
  }

  /// Increment search count
  Future<void> incrementSearchCount() async {
    print('DEBUG: incrementSearchCount called');
    try {
      final String? userId = _authService.currentUserId;
      if (userId == null) return;

      await _db
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('activity')
          .doc('stats')
          .set({
            'searchCount': FieldValue.increment(1),
          }, SetOptions(merge: true));

      print('DEBUG: Search count update sent');
    } catch (e) {
      print('Error incrementing search count: $e');
    }
  }
}
