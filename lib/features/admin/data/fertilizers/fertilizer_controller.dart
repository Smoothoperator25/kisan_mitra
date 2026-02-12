import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'fertilizer_model.dart';

/// Controller for managing fertilizer data
class FertilizerController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  static const String _collection = 'fertilizers';

  /// Stream of non-archived fertilizers
  Stream<List<Fertilizer>> getFertilizersStream() {
    return _firestore
        .collection(_collection)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('Error loading fertilizers: $error');
          // Return empty stream on error to prevent crash
          return const Stream.empty();
        })
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return Fertilizer.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing fertilizer document ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<Fertilizer>() // Filter out null values
              .toList();
        });
  }

  /// Get single fertilizer by ID
  Future<Fertilizer?> getFertilizerById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Fertilizer.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch fertilizer: $e');
    }
  }

  /// Pick image from gallery
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String fertilizerId) async {
    try {
      final String fileName =
          'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(
        'fertilizers/$fertilizerId/$fileName',
      );

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Validate fertilizer data
  String? validateFertilizer(Fertilizer fertilizer) {
    // Validate name
    if (fertilizer.name.trim().isEmpty) {
      return 'Fertilizer name is required';
    }

    // Validate NPK composition format (e.g., "46-0-0")
    final npkPattern = RegExp(r'^\d+-\d+-\d+$');
    if (!npkPattern.hasMatch(fertilizer.npkComposition.trim())) {
      return 'Invalid NPK format. Use format like "46-0-0"';
    }

    // Validate dosage
    if (fertilizer.recommendedDosage <= 0) {
      return 'Recommended dosage must be greater than 0';
    }

    // Validate suitable crops
    if (fertilizer.suitableCrops.trim().isEmpty) {
      return 'Suitable crops are required';
    }

    return null; // No errors
  }

  /// Create new fertilizer
  Future<void> createFertilizer(
    Fertilizer fertilizer, {
    File? imageFile,
  }) async {
    try {
      // Validate
      final error = validateFertilizer(fertilizer);
      if (error != null) {
        throw Exception(error);
      }

      // Create document reference
      final docRef = _firestore.collection(_collection).doc();

      String imageUrl = fertilizer.imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile, docRef.id);
      }

      // Create fertilizer with updated image URL
      final newFertilizer = fertilizer.copyWith(
        id: docRef.id,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await docRef.set(newFertilizer.toMap());
    } catch (e) {
      throw Exception('Failed to create fertilizer: $e');
    }
  }

  /// Update existing fertilizer
  Future<void> updateFertilizer(
    String id,
    Fertilizer fertilizer, {
    File? imageFile,
  }) async {
    try {
      // Validate
      final error = validateFertilizer(fertilizer);
      if (error != null) {
        throw Exception(error);
      }

      String imageUrl = fertilizer.imageUrl;

      // Upload new image if provided
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile, id);
      }

      // Update fertilizer with new image URL and timestamp
      final updatedFertilizer = fertilizer.copyWith(
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await _firestore.collection(_collection).doc(id).update({
        ...updatedFertilizer.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update fertilizer: $e');
    }
  }

  /// Archive fertilizer (soft delete)
  Future<void> archiveFertilizer(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isArchived': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to archive fertilizer: $e');
    }
  }

  /// Unarchive fertilizer
  Future<void> unarchiveFertilizer(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isArchived': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to unarchive fertilizer: $e');
    }
  }

  /// Delete image from storage (cleanup)
  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && imageUrl.contains('firebase')) {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      // Silently fail if image doesn't exist
      print('Error deleting image: $e');
    }
  }
}
