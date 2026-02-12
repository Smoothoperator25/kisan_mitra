import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../dashboard/admin_dashboard_model.dart';

class AdminActivityLogScreen extends StatelessWidget {
  const AdminActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('adminActivityLogs')
            .orderBy('timestamp', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data?.docs ?? [];

          if (logs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No activity logs yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = AdminActivityLog.fromFirestore(logs[index]);
              return _buildLogItem(log);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogItem(AdminActivityLog log) {
    IconData icon;
    Color color;

    switch (log.action) {
      case 'APPROVED_STORE':
        icon = Icons.check_circle;
        color = const Color(0xFF10B981);
        break;
      case 'REJECTED_STORE':
        icon = Icons.cancel;
        color = const Color(0xFFEF4444);
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action.replaceAll('_', ' '),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log.targetName,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                if (log.details != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.details!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          Text(
            DateFormat('MMM dd, HH:mm').format(log.timestamp),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
