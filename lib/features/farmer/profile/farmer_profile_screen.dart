import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import 'profile_controller.dart';
import 'edit_profile_screen.dart';

/// Farmer Profile Screen
/// Displays farmer profile with statistics and settings
class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize profile data on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1), // Light mint green
      body: Consumer<ProfileController>(
        builder: (context, controller, child) {
          // Show loading indicator
          if (controller.isLoading && controller.userProfile == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
            );
          }

          // Show error if profile failed to load
          if (controller.errorMessage != null &&
              controller.userProfile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.initialize(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A4F),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          final profile = controller.userProfile;
          final activity = controller.userActivity;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: const BoxDecoration(color: Color(0xFFE8F5F1)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Profile',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B4332),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF2D6A4F),
                              ),
                              onPressed: () => _navigateToEditProfile(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Profile Image
                        GestureDetector(
                          onTap: () => _uploadProfileImage(context, controller),
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF2D6A4F),
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: profile?.profileImageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: profile!.profileImageUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2D6A4F),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // User Name
                        Text(
                          profile?.name ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4332),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Email
                        Text(
                          profile?.email ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF52796F),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Location
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Color(0xFF52796F),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${profile?.village ?? ''}, ${profile?.city ?? ''}, ${profile?.state ?? ''}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF52796F),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Statistics Cards
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          '${activity?.searchCount ?? 24}',
                          'Fertilizers\nsearched',
                        ),
                        _buildStatCard(
                          '${activity?.advisoryCount ?? 12}',
                          'Advisory used',
                        ),
                        _buildStatCard(
                          '${activity?.visitedStoresCount ?? 8}',
                          'Stores visited',
                        ),
                      ],
                    ),
                  ),

                  // White background section
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),

                        // APP SETTINGS Section
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'APP SETTINGS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF95A5A6),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildSettingsItem(
                          icon: Icons.language,
                          iconColor: const Color(0xFF2D6A4F),
                          title: 'Language Preference',
                          trailing: 'English',
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Icons.notifications_outlined,
                          iconColor: const Color(0xFF2D6A4F),
                          title: 'Notification Settings',
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Icons.help_outline,
                          iconColor: const Color(0xFF2D6A4F),
                          title: 'Help & Support',
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Icons.info_outline,
                          iconColor: const Color(0xFF2D6A4F),
                          title: 'About App',
                          onTap: () {},
                        ),

                        const SizedBox(height: 24),

                        // PERSONAL DETAILS Section
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'PERSONAL DETAILS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF95A5A6),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildDetailItem('FULL NAME', profile?.name ?? ''),
                        _buildDetailItem('EMAIL ID', profile?.email ?? ''),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'STATE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF95A5A6),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      profile?.state ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CITY',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF95A5A6),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      profile?.city ?? '',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildDetailItem('VILLAGE', profile?.village ?? ''),

                        const SizedBox(height: 24),

                        // Change Password Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: OutlinedButton(
                            onPressed: () =>
                                _changePassword(context, controller),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2D6A4F)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF2D6A4F),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Change Password',
                                  style: TextStyle(
                                    color: Color(0xFF2D6A4F),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Logout Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: () => _logout(context, controller),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFEBEE),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.logout,
                                  color: Color(0xFFE53935),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Color(0xFFE53935),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 100,
                        ), // Bottom padding for nav bar
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Build statistics card
  Widget _buildStatCard(String count, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF52796F),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // Build settings item
  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(fontSize: 14, color: Color(0xFF95A5A6)),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF95A5A6), size: 20),
          ],
        ),
      ),
    );
  }

  // Build detail item
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF95A5A6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to edit profile
  void _navigateToEditProfile(BuildContext context) async {
    // Capture the controller BEFORE the MaterialPageRoute builder
    final controller = context.read<ProfileController>();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: controller,
          child: const EditProfileScreen(),
        ),
      ),
    );

    // Refresh profile if edited
    if (result == true) {
      if (mounted) {
        controller.initialize();
      }
    }
  }

  // Upload profile image
  void _uploadProfileImage(
    BuildContext context,
    ProfileController controller,
  ) async {
    final success = await controller.uploadProfileImage();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Profile image updated!' : 'Image upload cancelled',
          ),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  // Change password
  void _changePassword(
    BuildContext context,
    ProfileController controller,
  ) async {
    final success = await controller.sendPasswordResetEmail();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Password reset email sent! Check your inbox.'
                : controller.errorMessage ?? 'Failed to send reset email',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Logout
  void _logout(BuildContext context, ProfileController controller) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await controller.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppConstants.farmerLoginRoute,
          (route) => false,
        );
      }
    }
  }
}
