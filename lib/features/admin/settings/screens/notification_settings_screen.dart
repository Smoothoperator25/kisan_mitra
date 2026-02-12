import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_settings_controller.dart';
import '../admin_settings_model.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AdminSettingsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<NotificationSettings>(
        stream: controller.getNotificationSettingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final settings =
              snapshot.data ??
              NotificationSettings(
                pushNotifications: true,
                emailNotifications: true,
                storeApprovalAlerts: true,
                systemAlerts: true,
              );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose what notifications you want to receive',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // Push Notifications
                    _buildToggleItem(
                      title: 'Push Notifications',
                      subtitle: 'Receive push notifications on this device',
                      value: settings.pushNotifications,
                      onChanged: (value) async {
                        final newSettings = NotificationSettings(
                          pushNotifications: value,
                          emailNotifications: settings.emailNotifications,
                          storeApprovalAlerts: settings.storeApprovalAlerts,
                          systemAlerts: settings.systemAlerts,
                        );
                        await _updateSettings(context, controller, newSettings);
                      },
                    ),

                    const Divider(height: 32),

                    // Email Notifications
                    _buildToggleItem(
                      title: 'Email Notifications',
                      subtitle: 'Receive notifications via email',
                      value: settings.emailNotifications,
                      onChanged: (value) async {
                        final newSettings = NotificationSettings(
                          pushNotifications: settings.pushNotifications,
                          emailNotifications: value,
                          storeApprovalAlerts: settings.storeApprovalAlerts,
                          systemAlerts: settings.systemAlerts,
                        );
                        await _updateSettings(context, controller, newSettings);
                      },
                    ),

                    const Divider(height: 32),

                    // Store Approval Alerts
                    _buildToggleItem(
                      title: 'Store Approval Alerts',
                      subtitle:
                          'Get notified about new store verification requests',
                      value: settings.storeApprovalAlerts,
                      onChanged: (value) async {
                        final newSettings = NotificationSettings(
                          pushNotifications: settings.pushNotifications,
                          emailNotifications: settings.emailNotifications,
                          storeApprovalAlerts: value,
                          systemAlerts: settings.systemAlerts,
                        );
                        await _updateSettings(context, controller, newSettings);
                      },
                    ),

                    const Divider(height: 32),

                    // System Alerts
                    _buildToggleItem(
                      title: 'System Alerts',
                      subtitle: 'Critical system notifications and updates',
                      value: settings.systemAlerts,
                      onChanged: (value) async {
                        final newSettings = NotificationSettings(
                          pushNotifications: settings.pushNotifications,
                          emailNotifications: settings.emailNotifications,
                          storeApprovalAlerts: settings.storeApprovalAlerts,
                          systemAlerts: value,
                        );
                        await _updateSettings(context, controller, newSettings);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  Future<void> _updateSettings(
    BuildContext context,
    AdminSettingsController controller,
    NotificationSettings settings,
  ) async {
    final success = await controller.updateNotificationSettings(settings);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification settings updated'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.error ?? 'Failed to update settings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
