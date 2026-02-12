import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Model for store verification request
class StoreRequest {
  final String id;
  final String storeName;
  final String ownerName;
  final String phone;
  final String city;
  final String state;
  final String address;
  final DateTime createdAt;
  final bool isVerified;
  final bool isRejected;
  final DateTime? verifiedAt;
  final DateTime? rejectedAt;

  StoreRequest({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.phone,
    required this.city,
    required this.state,
    required this.address,
    required this.createdAt,
    required this.isVerified,
    required this.isRejected,
    this.verifiedAt,
    this.rejectedAt,
  });

  /// Create StoreRequest from Firestore document
  factory StoreRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreRequest(
      id: doc.id,
      storeName: data['storeName']?.toString() ?? '',
      ownerName: data['ownerName']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      state: data['state']?.toString() ?? '',
      address: data['address']?.toString() ?? data['village']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      isRejected: data['isRejected'] ?? false,
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      rejectedAt: (data['rejectedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Formatted location string
  String get location => '$city, $state';

  /// Check if request is pending
  bool get isPending => !isVerified && !isRejected;

  /// Check if request is approved
  bool get isApproved => isVerified;

  /// Check if request is rejected
  bool get isRejectedStatus => isRejected;

  /// Get status string
  String get status {
    if (isVerified) return 'APPROVED';
    if (isRejected) return 'REJECTED';
    return 'PENDING';
  }

  /// Format requested date
  String get formattedRequestDate {
    return DateFormat('dd MMM yyyy').format(createdAt);
  }
}
