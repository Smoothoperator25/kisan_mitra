import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'store_profile_model.dart';

class StoreProfileController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  String? _error;
  File? _selectedImage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  File? get selectedImage => _selectedImage;

  String get currentStoreUid => _auth.currentUser?.uid ?? '';

  // Stream for real-time profile updates
  Stream<StoreProfile?> getStoreProfileStream() {
    if (currentStoreUid.isEmpty) {
      return Stream.value(null);
    }

    return _firestore.collection('stores').doc(currentStoreUid).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) return null;
        return StoreProfile.fromFirestore(snapshot);
      },
    );
  }

  // Fetch store profile once
  Future<StoreProfile?> fetchStoreProfile() async {
    try {
      _setLoading(true);
      _error = null;

      if (currentStoreUid.isEmpty) {
        throw Exception('No store logged in');
      }

      final doc = await _firestore
          .collection('stores')
          .doc(currentStoreUid)
          .get();

      if (!doc.exists) {
        throw Exception('Store profile not found');
      }

      return StoreProfile.fromFirestore(doc);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update store profile
  Future<bool> updateStoreProfile({
    required String storeName,
    required String ownerName,
    required String phone,
    required String email,
    required String address,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      if (currentStoreUid.isEmpty) {
        throw Exception('No store logged in');
      }

      // Validation
      if (storeName.trim().isEmpty) {
        throw Exception('Store name is required');
      }
      if (ownerName.trim().isEmpty) {
        throw Exception('Owner name is required');
      }
      if (phone.trim().isEmpty || phone.length != 10) {
        throw Exception('Valid 10-digit phone number is required');
      }
      if (email.trim().isEmpty || !_isValidEmail(email)) {
        throw Exception('Valid email is required');
      }
      if (address.trim().isEmpty) {
        throw Exception('Address is required');
      }

      final updateData = {
        'storeName': storeName.trim(),
        'ownerName': ownerName.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'address': address.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('stores')
          .doc(currentStoreUid)
          .update(updateData);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to pick image: ${e.toString()}';
      notifyListeners();
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage() async {
    if (_selectedImage == null) return null;

    try {
      _setLoading(true);
      _error = null;

      final String fileName = '$currentStoreUid.jpg';
      final Reference ref = _storage.ref().child('store_profiles/$fileName');

      final UploadTask uploadTask = ref.putFile(_selectedImage!);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore with new image URL
      await _firestore.collection('stores').doc(currentStoreUid).update({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _selectedImage = null;
      notifyListeners();

      return downloadUrl;
    } catch (e) {
      _error = 'Failed to upload image: ${e.toString()}';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Clear selected image
  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      notifyListeners();
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Update store statistics
  Future<void> updateStoreStatistics() async {
    try {
      if (currentStoreUid.isEmpty) return;

      // Get total fertilizers listed
      final fertilizersSnapshot = await _firestore
          .collection('store_fertilizers')
          .where('storeId', isEqualTo: currentStoreUid)
          .get();

      final totalFertilizers = fertilizersSnapshot.docs.length;

      // Calculate active stock (sum of stock where isAvailable = true)
      int totalStock = 0;
      for (var doc in fertilizersSnapshot.docs) {
        final data = doc.data();
        final isAvailable = data['isAvailable'] ?? false;
        if (isAvailable) {
          final stock = data['stock'] ?? 0;
          totalStock += stock as int;
        }
      }

      // Update store document with new statistics
      await _firestore.collection('stores').doc(currentStoreUid).update({
        'totalFertilizers': totalFertilizers,
        'totalStock': totalStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating statistics: $e');
      // Don't throw error, just log it
    }
  }

  // Increment farmer views
  Future<void> incrementFarmerViews() async {
    try {
      if (currentStoreUid.isEmpty) return;

      await _firestore.collection('stores').doc(currentStoreUid).update({
        'totalViews': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
