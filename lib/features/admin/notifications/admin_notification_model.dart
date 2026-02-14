import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification types
enum NotificationType {
  storeVerification,
  farmerRegistration,
  systemAlert,
  activityUpdate,
  general,
}

/// Model for admin notifications
class AdminNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
    this.metadata,
  });

  factory AdminNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminNotification(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      type: _parseNotificationType(data['type']?.toString()),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      actionUrl: data['actionUrl']?.toString(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      if (actionUrl != null) 'actionUrl': actionUrl,
      if (metadata != null) 'metadata': metadata,
    };
  }

  static NotificationType _parseNotificationType(String? typeString) {
    switch (typeString) {
      case 'storeVerification':
        return NotificationType.storeVerification;
      case 'farmerRegistration':
        return NotificationType.farmerRegistration;
      case 'systemAlert':
        return NotificationType.systemAlert;
      case 'activityUpdate':
        return NotificationType.activityUpdate;
      default:
        return NotificationType.general;
    }
  }

  AdminNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}
