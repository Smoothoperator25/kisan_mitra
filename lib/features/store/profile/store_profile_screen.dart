import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import 'store_profile_controller.dart';
import 'store_profile_model.dart';
import 'edit_store_profile_screen.dart';
import 'change_password_screen.dart';
import 'store_help_support_screen.dart';
import 'store_terms_policies_screen.dart';

class StoreProfileScreen extends StatelessWidget {
  const StoreProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreProfileController(),
      child: const _StoreProfileContent(),
    );
  }
}

class _StoreProfileContent extends StatefulWidget {
  const _StoreProfileContent({Key? key}) : super(key: key);

  @override
  State<_StoreProfileContent> createState() => _StoreProfileContentState();
}

class _StoreProfileContentState extends State<_StoreProfileContent> {
  @override
  void initState() {
    super.initState();
    // Auto-update statistics when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<StoreProfileController>(
        context,
        listen: false,
      );
      controller.updateStoreStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<StoreProfileController>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFD5F5E3),
      body: StreamBuilder<StoreProfile?>(
        stream: controller.getStoreProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppLocalizations.of(
                  context,
                ).errorPrefix(snapshot.error.toString()),
              ),
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return Center(
              child: Text(AppLocalizations.of(context).profileNotFound),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).storeProfile,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Row(
                        children: [
                          // Refresh stats button
                          IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.grey[700],
                              size: 24,
                            ),
                            onPressed: () async {
                              await controller.updateStoreStatistics();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).statisticsUpdated,
                                    ),
                                    backgroundColor: const Color(0xFF27AE60),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            tooltip: AppLocalizations.of(
                              context,
                            ).refreshStatistics,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: Colors.grey[700],
                              size: 24,
                            ),
                            onPressed: () async {
                              // Get the controller from context before navigation
                              final storeController = context
                                  .read<StoreProfileController>();

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider.value(
                                        value: storeController,
                                        child: const EditStoreProfileScreen(),
                                      ),
                                ),
                              );
                            },
                            tooltip: AppLocalizations.of(context).edit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        // Profile Header Section
                        _buildProfileHeader(profile),
                        const SizedBox(height: 16),

                        // Statistics Cards
                        _buildStatisticsCards(profile),
                        const SizedBox(height: 20),

                        // Store Details Card
                        _buildStoreDetailsCard(profile),
                        const SizedBox(height: 20),

                        // Menu Options
                        _buildMenuOptions(context, controller),
                        const SizedBox(height: 20),

                        // Logout Button
                        _buildLogoutButton(context, controller),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(StoreProfile profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Profile Icon with Verified Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: profile.profileImageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          profile.profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.storefront,
                              color: Color(0xFF27AE60),
                              size: 50,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.storefront,
                        color: Color(0xFF27AE60),
                        size: 50,
                      ),
              ),
              if (profile.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF27AE60),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Store Name
          Text(
            profile.storeName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 6),

          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Color(0xFFFF6B6B), size: 20),
              const SizedBox(width: 4),
              Text(
                profile.formattedRating,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                profile.formattedReviews,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(StoreProfile profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildStatCard(
              profile.totalFertilizers.toString(),
              AppLocalizations.of(context).fertilizersListed,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              profile.formattedStock,
              AppLocalizations.of(context).activeStock,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatCard(
              profile.formattedViews,
              AppLocalizations.of(context).farmerViews,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8.5,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreDetailsCard(StoreProfile profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem(
            AppLocalizations.of(context).storeName.toUpperCase(),
            profile.storeName,
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            AppLocalizations.of(context).ownerName.toUpperCase(),
            profile.ownerName,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  AppLocalizations.of(context).mobileNumber.toUpperCase(),
                  profile.phone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  AppLocalizations.of(context).email.toUpperCase(),
                  profile.email,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            AppLocalizations.of(context).storeAddress.toUpperCase(),
            profile.address,
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            AppLocalizations.of(context).coordinates.toUpperCase(),
            profile.coordinates,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOptions(
    BuildContext context,
    StoreProfileController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.edit_outlined,
            title: AppLocalizations.of(context).editStoreDetails,
            onTap: () async {
              // Get the controller from context before navigation
              final controller = context.read<StoreProfileController>();

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: controller,
                    child: const EditStoreProfileScreen(),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.lock_outline,
            title: AppLocalizations.of(context).changePassword,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: AppLocalizations.of(context).helpSupport,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StoreHelpSupportScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            context,
            icon: Icons.description_outlined,
            title: AppLocalizations.of(context).termsOfService,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StoreTermsPoliciesScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    StoreProfileController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context, controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFE74C3C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.04),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).logout,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    StoreProfileController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context).confirmLogout),
        content: Text(AppLocalizations.of(context).logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.logout();
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                // Navigate to Store Login screen and clear navigation stack
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.storeLoginRoute,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(AppLocalizations.of(context).logout),
          ),
        ],
      ),
    );
  }
}
