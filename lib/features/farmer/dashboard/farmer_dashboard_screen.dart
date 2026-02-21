import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kisan_mitra/l10n/app_localizations.dart';
import '../farmer_home_screen.dart';
import '../fertilizer_search/fertilizer_search_screen.dart';
import '../advisory/presentation/screens/advisory_screen.dart';
import '../profile/farmer_profile_screen.dart';
import '../profile/profile_controller.dart';

/// Farmer Dashboard Screen
/// Main container for farmer module with persistent bottom navigation
/// Uses IndexedStack to preserve state across tab switches
class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int _selectedIndex = 0;

  // Handle tab changes from bottom navigation bar
  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Handle navigation requests from home screen action cards
  void _onNavigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => ProfileController()..initialize(),
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // Index 0: Home
            FarmerHomeScreen(onNavigateToTab: _onNavigateToTab),

            // Index 1: Fertilizer Search
            const FertilizerSearchScreen(),

            // Index 2: Advisory
            const AdvisoryScreen(),

            // Index 3: Profile
            // ProfileController is now provided above, so we just use the screen
            FarmerProfileScreen(onNavigateToTab: _onNavigateToTab),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// Bottom navigation bar — premium design
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: AppLocalizations.of(context).home,
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search_rounded,
                label: AppLocalizations.of(context).search,
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.article_outlined,
                activeIcon: Icons.article_rounded,
                label: AppLocalizations.of(context).advisory,
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outlined,
                activeIcon: Icons.person_rounded,
                label: AppLocalizations.of(context).profile,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom navigation item with pill-style active indicator
  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    const green = Color(0xFF2E7D32);
    const greenBg = Color(0xFFE8F5E9);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onBottomNavTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill background behind icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 20 : 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? greenBg : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? green : const Color(0xFF9E9E9E),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? green : const Color(0xFF9E9E9E),
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
