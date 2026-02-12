import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../admin_settings_controller.dart';
import '../admin_settings_model.dart';

class ActivityLogsScreen extends StatelessWidget {
  const ActivityLogsScreen({super.key});

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
          'Activity Logs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
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
              children: const [
                Text(
                  'Admin Activity History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Track all administrative actions and system changes',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: StreamBuilder<List<ActivityLog>>(
              stream: controller.getActivityLogsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                final logs = snapshot.data ?? [];

                if (logs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'No activity logs yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return _buildLogCard(log);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(ActivityLog log) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    Color getActionColor(String action) {
      switch (action.toUpperCase()) {
        case 'LOGIN':
          return const Color(0xFF4CAF50);
        case 'LOGOUT':
          return const Color(0xFF9E9E9E);
        case 'UPDATE_CONFIG':
        case 'UPDATE_NOTIFICATIONS':
          return const Color(0xFF2196F3);
        case 'CHANGE_PASSWORD':
          return const Color(0xFFFF9800);
        case 'APPROVE_STORE':
          return const Color(0xFF4CAF50);
        case 'REJECT_STORE':
          return const Color(0xFFF44336);
        case 'DELETE':
          return const Color(0xFFF44336);
        default:
          return const Color(0xFF607D8B);
      }
    }

    IconData getActionIcon(String action) {
      switch (action.toUpperCase()) {
        case 'LOGIN':
          return Icons.login;
        case 'LOGOUT':
          return Icons.logout;
        case 'UPDATE_CONFIG':
        case 'UPDATE_NOTIFICATIONS':
          return Icons.settings;
        case 'CHANGE_PASSWORD':
          return Icons.lock;
        case 'APPROVE_STORE':
          return Icons.check_circle;
        case 'REJECT_STORE':
          return Icons.cancel;
        case 'DELETE':
          return Icons.delete;
        default:
          return Icons.info;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: getActionColor(log.action).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              getActionIcon(log.action),
              color: getActionColor(log.action),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Log Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action.replaceAll('_', ' '),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log.description,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        log.performedBy,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(log.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
