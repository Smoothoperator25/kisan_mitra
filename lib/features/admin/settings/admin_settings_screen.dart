import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import 'admin_settings_controller.dart';
import 'screens/change_password_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/security_access_screen.dart';
import 'screens/activity_logs_screen.dart';
import 'screens/app_configuration_screen.dart';
import 'screens/terms_privacy_screen.dart';
import 'screens/user_access_control_screen.dart';
import '../data/fertilizers/fertilizer_list_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final controller = context.read<AdminSettingsController>();

    // Check admin access first
    final hasAccess = await controller.checkAdminAccess();
    if (!hasAccess && mounted) {
      controller.setError('Access denied: Admin privileges required');
      return;
    }

    await controller.fetchAdminProfile();
    await controller.fetchAppConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Admin Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<AdminSettingsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${controller.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final adminProfile = controller.adminProfile;
          final appConfig = controller.appConfig;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Admin Profile Section
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
                    children: [
                      // Profile Avatar with Online Indicator
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shield,
                              size: 40,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Name
                      Text(
                        adminProfile?.name ?? 'System Administrator',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Email
                      Text(
                        adminProfile?.email ??
                            controller.currentUser?.email ??
                            'admin@kisanmitra.com',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Full Access Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          adminProfile?.accessLevel ?? 'FULL ACCESS',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // General Settings Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
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
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'GENERAL SETTINGS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        iconColor: const Color(0xFF2196F3),
                        title: 'Change Password',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: controller,
                                child: const ChangePasswordScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        iconColor: const Color(0xFFFF9800),
                        title: 'Notification Settings',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: controller,
                                child: const NotificationSettingsScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.security,
                        iconColor: const Color(0xFF9C27B0),
                        title: 'Security & Access Control',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SecurityAccessScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.history,
                        iconColor: const Color(0xFF673AB7),
                        title: 'Activity Logs',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: controller,
                                child: const ActivityLogsScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.settings_applications,
                        iconColor: const Color(0xFF607D8B),
                        title: 'App Configuration',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: controller,
                                child: const AppConfigurationScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: const Color(0xFF009688),
                        title: 'Terms & Privacy Policy',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TermsPrivacyScreen(),
                            ),
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // System Management Section
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
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
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'SYSTEM MANAGEMENT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      _buildMenuItem(
                        icon: Icons.inventory_2_outlined,
                        iconColor: const Color(0xFF4CAF50),
                        title: 'Manage Fertilizer Master Data',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FertilizerListScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.admin_panel_settings,
                        iconColor: const Color(0xFF4CAF50),
                        title: 'User Access Control',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserAccessControlScreen(),
                            ),
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton(
                    onPressed: () => _handleLogout(context, controller),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Logout Account',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Version Footer
                Text(
                  'KISAN MITRA ADMIN ${appConfig?.appVersion ?? 'v2.4.0'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 22),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    AdminSettingsController controller,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      try {
        await controller.logout();
        if (mounted) {
          // Navigate to admin login screen and clear back stack
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppConstants.adminLoginRoute, (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
