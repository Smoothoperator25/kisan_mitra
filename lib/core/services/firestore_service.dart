import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create user document (for farmers)
  Future<Map<String, dynamic>> createUserDocument({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await _db.collection(AppConstants.usersCollection).doc(uid).set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'role': AppConstants.roleFarmer,
      });
      return {'success': true, 'message': 'User profile created successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to create user profile: $e'};
    }
  }

  // Create store document
  Future<Map<String, dynamic>> createStoreDocument({
    required String uid,
    required Map<String, dynamic> storeData,
  }) async {
    try {
      await _db.collection(AppConstants.storesCollection).doc(uid).set({
        ...storeData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'role': AppConstants.roleStore,
      });
      return {'success': true, 'message': 'Store profile created successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create store profile: $e',
      };
    }
  }

  // Create admin document
  Future<Map<String, dynamic>> createAdminDocument({
    required String uid,
    required Map<String, dynamic> adminData,
  }) async {
    try {
      await _db.collection(AppConstants.adminsCollection).doc(uid).set({
        ...adminData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'role': AppConstants.roleAdmin,
      });
      return {'success': true, 'message': 'Admin profile created successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create admin profile: $e',
      };
    }
  }

  // Get user role and data
  Future<Map<String, dynamic>> getUserRoleAndData(String uid) async {
    try {
      // Check in users collection
      final userDoc = await _db
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (userDoc.exists) {
        return {
          'success': true,
          'role': AppConstants.roleFarmer,
          'data': userDoc.data(),
        };
      }

      // Check in stores collection
      final storeDoc = await _db
          .collection(AppConstants.storesCollection)
          .doc(uid)
          .get();
      if (storeDoc.exists) {
        return {
          'success': true,
          'role': AppConstants.roleStore,
          'data': storeDoc.data(),
        };
      }

      // Check in admins collection
      final adminDoc = await _db
          .collection(AppConstants.adminsCollection)
          .doc(uid)
          .get();
      if (adminDoc.exists) {
        return {
          'success': true,
          'role': AppConstants.roleAdmin,
          'data': adminDoc.data(),
        };
      }

      return {'success': false, 'message': 'User not found in any collection'};
    } catch (e) {
      return {'success': false, 'message': 'Error fetching user data: $e'};
    }
  }

  // Get store data specifically
  Future<Map<String, dynamic>> getStoreData(String uid) async {
    try {
      final storeDoc = await _db
          .collection(AppConstants.storesCollection)
          .doc(uid)
          .get();

      if (storeDoc.exists) {
        return {'success': true, 'data': storeDoc.data()};
      }

      return {'success': false, 'message': 'Store not found'};
    } catch (e) {
      return {'success': false, 'message': 'Error fetching store data: $e'};
    }
  }

  // Get admin by username (for username-based login)
  Future<Map<String, dynamic>> getAdminByUsername(String username) async {
    try {
      final querySnapshot = await _db
          .collection(AppConstants.adminsCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {'success': true, 'uid': doc.id, 'data': doc.data()};
      }

      return {'success': false, 'message': 'Invalid username'};
    } catch (e) {
      return {'success': false, 'message': 'Error fetching admin: $e'};
    }
  }

  // Update user document
  Future<Map<String, dynamic>> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection(collection).doc(docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return {'success': true, 'message': 'Document updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update document: $e'};
    }
  }

  // Delete document
  Future<Map<String, dynamic>> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _db.collection(collection).doc(docId).delete();
      return {'success': true, 'message': 'Document deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete document: $e'};
    }
  }

  // Get document by ID
  Future<Map<String, dynamic>> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await _db.collection(collection).doc(docId).get();
      if (doc.exists) {
        return {'success': true, 'data': doc.data()};
      }
      return {'success': false, 'message': 'Document not found'};
    } catch (e) {
      return {'success': false, 'message': 'Error fetching document: $e'};
    }
  }

  // Get all documents from a collection
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _db
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Query documents
  Future<Map<String, dynamic>> queryDocuments({
    required String collection,
    String? fieldPath,
    dynamic isEqualTo,
    int? limit,
  }) async {
    try {
      Query query = _db.collection(collection);

      if (fieldPath != null && isEqualTo != null) {
        query = query.where(fieldPath, isEqualTo: isEqualTo);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return {
        'success': true,
        'documents': snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList(),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error querying documents: $e'};
    }
  }

  // Get all documents (Future)
  Future<Map<String, dynamic>> getCollection(String collection) async {
    try {
      final snapshot = await _db.collection(collection).get();
      final data = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
      return {'success': true, 'data': data};
    } catch (e) {
      return {'success': false, 'message': 'Error fetching collection: $e'};
    }
  }
}
