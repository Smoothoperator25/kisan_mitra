class AdminProfile {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String accessLevel;
  final bool isOnline;

  AdminProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.accessLevel,
    this.isOnline = true,
  });

  factory AdminProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return AdminProfile(
      uid: uid,
      name: data['name'] ?? 'System Administrator',
      email: data['email'] ?? '',
      role: data['role'] ?? 'admin',
      accessLevel: data['accessLevel'] ?? 'FULL ACCESS',
      isOnline: data['isOnline'] ?? true,
    );
  }
}

class AppConfig {
  final String appVersion;
  final bool maintenanceMode;
  final String supportEmail;

  AppConfig({
    required this.appVersion,
    required this.maintenanceMode,
    required this.supportEmail,
  });

  factory AppConfig.fromFirestore(Map<String, dynamic> data) {
    return AppConfig(
      appVersion: data['appVersion'] ?? 'v2.4.0',
      maintenanceMode: data['maintenanceMode'] ?? false,
      supportEmail: data['supportEmail'] ?? 'support@kisanmitra.com',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appVersion': appVersion,
      'maintenanceMode': maintenanceMode,
      'supportEmail': supportEmail,
    };
  }
}

class ActivityLog {
  final String id;
  final String action;
  final String description;
  final String performedBy;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.action,
    required this.description,
    required this.performedBy,
    required this.timestamp,
  });

  factory ActivityLog.fromFirestore(Map<String, dynamic> data, String id) {
    return ActivityLog(
      id: id,
      action: data['action'] ?? '',
      description: data['description'] ?? '',
      performedBy: data['performedBy'] ?? '',
      timestamp: (data['timestamp'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'action': action,
      'description': description,
      'performedBy': performedBy,
      'timestamp': timestamp,
    };
  }
}

class UserRole {
  final String id;
  final String roleName;
  final RolePermissions permissions;

  UserRole({
    required this.id,
    required this.roleName,
    required this.permissions,
  });

  factory UserRole.fromFirestore(Map<String, dynamic> data, String id) {
    return UserRole(
      id: id,
      roleName: data['roleName'] ?? '',
      permissions: RolePermissions.fromFirestore(data['permissions'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'roleName': roleName, 'permissions': permissions.toFirestore()};
  }
}

class RolePermissions {
  final bool canApproveStores;
  final bool canEditFertilizers;
  final bool canViewReports;
  final bool canManageUsers;

  RolePermissions({
    required this.canApproveStores,
    required this.canEditFertilizers,
    required this.canViewReports,
    required this.canManageUsers,
  });

  factory RolePermissions.fromFirestore(Map<String, dynamic> data) {
    return RolePermissions(
      canApproveStores: data['canApproveStores'] ?? false,
      canEditFertilizers: data['canEditFertilizers'] ?? false,
      canViewReports: data['canViewReports'] ?? false,
      canManageUsers: data['canManageUsers'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'canApproveStores': canApproveStores,
      'canEditFertilizers': canEditFertilizers,
      'canViewReports': canViewReports,
      'canManageUsers': canManageUsers,
    };
  }
}

class NotificationSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool storeApprovalAlerts;
  final bool systemAlerts;

  NotificationSettings({
    required this.pushNotifications,
    required this.emailNotifications,
    required this.storeApprovalAlerts,
    required this.systemAlerts,
  });

  factory NotificationSettings.fromFirestore(Map<String, dynamic> data) {
    return NotificationSettings(
      pushNotifications: data['pushNotifications'] ?? true,
      emailNotifications: data['emailNotifications'] ?? true,
      storeApprovalAlerts: data['storeApprovalAlerts'] ?? true,
      systemAlerts: data['systemAlerts'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'storeApprovalAlerts': storeApprovalAlerts,
      'systemAlerts': systemAlerts,
    };
  }
}
