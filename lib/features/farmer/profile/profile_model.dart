import 'package:cloud_firestore/cloud_firestore.dart';

/// User Profile Model
/// Represents farmer profile data from Firestore
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String state;
  final String city;
  final String village;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.state,
    required this.city,
    required this.village,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Create UserProfile from Firestore document
  factory UserProfile.fromFirestore(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'farmer',
      state: data['state'] ?? '',
      city: data['city'] ?? '',
      village: data['village'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert UserProfile to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'state': state,
      'city': city,
      'village': village,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Create a copy with updated fields
  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? state,
    String? city,
    String? village,
    String? profileImageUrl,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      state: state ?? this.state,
      city: city ?? this.city,
      village: village ?? this.village,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// User Activity Statistics Model
/// Tracks farmer's app usage statistics
class UserActivity {
  final int searchCount;
  final int advisoryCount;
  final int visitedStoresCount;

  UserActivity({
    this.searchCount = 0,
    this.advisoryCount = 0,
    this.visitedStoresCount = 0,
  });

  /// Create UserActivity from Firestore document
  factory UserActivity.fromFirestore(Map<String, dynamic> data) {
    return UserActivity(
      searchCount: data['searchCount'] ?? 0,
      advisoryCount: data['advisoryCount'] ?? 0,
      visitedStoresCount: data['visitedStoresCount'] ?? 0,
    );
  }

  /// Convert UserActivity to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'searchCount': searchCount,
      'advisoryCount': advisoryCount,
      'visitedStoresCount': visitedStoresCount,
    };
  }
}
