import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';

/// Minimal Admin Dashboard Screen for Testing
/// This is a simplified version to debug the black screen issue
class AdminDashboardScreenMinimal extends StatefulWidget {
  const AdminDashboardScreenMinimal({super.key});

  @override
  State<AdminDashboardScreenMinimal> createState() =>
      _AdminDashboardScreenMinimalState();
}

class _AdminDashboardScreenMinimalState
    extends State<AdminDashboardScreenMinimal> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F1F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  AppConstants.adminLoginRoute,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dashboard is loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoRow('Status', 'Active'),
                        const Divider(),
                        _buildInfoRow('Role', 'Admin'),
                        const Divider(),
                        _buildInfoRow('Access', 'Full Control'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Full dashboard features are being loaded.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
