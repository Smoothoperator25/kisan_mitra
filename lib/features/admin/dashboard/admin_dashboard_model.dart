import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for dashboard statistics
class DashboardStats {
  final int totalFarmers;
  final int totalStores;
  final int pendingVerifications;
  final int verifiedStores;

  DashboardStats({
    required this.totalFarmers,
    required this.totalStores,
    required this.pendingVerifications,
    required this.verifiedStores,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalFarmers: 0,
      totalStores: 0,
      pendingVerifications: 0,
      verifiedStores: 0,
    );
  }
}

/// Model for verification request
class VerificationRequest {
  final String id;
  final String storeName;
  final String ownerName;
  final String city;
  final String state;
  final DateTime createdAt;

  VerificationRequest({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.city,
    required this.state,
    required this.createdAt,
  });

  factory VerificationRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VerificationRequest(
      id: doc.id,
      storeName: data['storeName']?.toString() ?? '',
      ownerName: data['ownerName']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      state: data['state']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String get location => '$city, $state';
}

/// Model for admin activity log
class AdminActivityLog {
  final String action;
  final String targetId;
  final String targetName;
  final String adminId;
  final DateTime timestamp;
  final String? details;

  AdminActivityLog({
    required this.action,
    required this.targetId,
    required this.targetName,
    required this.adminId,
    required this.timestamp,
    this.details,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'action': action,
      'targetId': targetId,
      'targetName': targetName,
      'adminId': adminId,
      'timestamp': Timestamp.fromDate(timestamp),
      if (details != null) 'details': details,
    };
  }

  factory AdminActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminActivityLog(
      action: data['action'] ?? '',
      targetId: data['targetId'] ?? '',
      targetName: data['targetName'] ?? '',
      adminId: data['adminId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      details: data['details'] as String?,
    );
  }
}
