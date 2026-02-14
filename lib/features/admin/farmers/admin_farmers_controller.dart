import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/admin_data_model.dart';

/// Controller for managing farmers
class AdminFarmersController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all farmers
  Stream<List<FarmerData>> getFarmersStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'farmer')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
          print('Error loading farmers: $error');
          return const Stream.empty();
        })
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                try {
                  return FarmerData.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing farmer document ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<FarmerData>()
              .toList();
        });
  }

  /// Search farmers by name, city, phone, or state
  List<FarmerData> searchFarmers(String query, List<FarmerData> farmers) {
    if (query.isEmpty) return farmers;

    final lowerQuery = query.toLowerCase();
    return farmers.where((farmer) {
      return farmer.name.toLowerCase().contains(lowerQuery) ||
          farmer.phone.contains(lowerQuery) ||
          farmer.city.toLowerCase().contains(lowerQuery) ||
          farmer.state.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Toggle farmer active status
  Future<void> toggleFarmerStatus(String farmerId, bool currentStatus) async {
    try {
      await _firestore.collection('users').doc(farmerId).update({
        'isActive': !currentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update farmer status: $e');
    }
  }

  /// Delete farmer account
  Future<void> deleteFarmer(String farmerId) async {
    try {
      await _firestore.collection('users').doc(farmerId).delete();
    } catch (e) {
      throw Exception('Failed to delete farmer: $e');
    }
  }

  /// Get farmer statistics
  Future<Map<String, int>> getFarmerStats() async {
    try {
      final allFarmers = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'farmer')
          .get();

      int totalFarmers = allFarmers.docs.length;
      int activeFarmers = allFarmers.docs
          .where((doc) => (doc.data()['isActive'] as bool?) ?? true)
          .length;
      int inactiveFarmers = totalFarmers - activeFarmers;

      return {
        'total': totalFarmers,
        'active': activeFarmers,
        'inactive': inactiveFarmers,
      };
    } catch (e) {
      print('Error fetching farmer stats: $e');
      return {'total': 0, 'active': 0, 'inactive': 0};
    }
  }
}
