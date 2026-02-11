import 'package:flutter/material.dart';
import 'home/farmer_home_controller.dart';
import 'fertilizer_search/fertilizer_search_screen.dart';
import 'advisory/fertilizer_advisory_screen.dart';
import 'soil_health/soil_health_screen.dart';
import 'profile/farmer_profile_screen.dart';

/// Farmer Dashboard Home Screen
/// Displays welcome message, action cards, and bottom navigation
class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final FarmerHomeController _controller = FarmerHomeController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load farmer data when screen initializes
    _controller.loadFarmerData();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      // Already on home, do nothing
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on index
    switch (index) {
      case 1: // Search
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FertilizerSearchScreen(),
          ),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
      case 2: // Advisory
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FertilizerAdvisoryScreen(),
          ),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
      case 3: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FarmerProfileScreen()),
        ).then((_) => setState(() => _selectedIndex = 0));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top welcome section with gradient background
            _buildTopSection(),

            // Action cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildActionCard(
                      icon: Icons.search,
                      title: 'Fertilizer Search',
                      subtitle: 'Find nearby stores with\nbest price',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FertilizerSearchScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      icon: Icons.eco,
                      title: 'Fertilizer Advisory',
                      subtitle: 'Get crop-wise fertilizer\nguidance',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FertilizerAdvisoryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      icon: Icons.science,
                      title: 'Soil Health Check',
                      subtitle: 'Book your sample test\ntoday',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SoilHealthScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      icon: Icons.person,
                      title: 'Profile',
                      subtitle: 'View and manage your\nprofile',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FarmerProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// Top section with logo, welcome message, and title
  Widget _buildTopSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFB8E6D5),
            const Color(0xFFB8E6D5).withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          // Logo placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A7C59),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'KM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Welcome message with dynamic farmer name
          _buildWelcomeText(),

          const SizedBox(height: 8),

          // Title
          const Text(
            'Smart Fertilizer Finder',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  /// Welcome text with dynamic farmer name or loading indicator
  Widget _buildWelcomeText() {
    if (_controller.isLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Loading...',
            style: TextStyle(fontSize: 16, color: Color(0xFF4A7C59)),
          ),
        ],
      );
    }

    if (_controller.error != null) {
      return Text(
        'Welcome, Farmer',
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      );
    }

    return Text(
      'Welcome, ${_controller.farmerName ?? "Farmer"}',
      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
    );
  }

  /// Action card widget
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 28),
            ),
            const SizedBox(width: 16),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  /// Bottom navigation bar
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'HOME',
                index: 0,
                isSelected: _selectedIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.search,
                label: 'SEARCH',
                index: 1,
                isSelected: _selectedIndex == 1,
              ),
              _buildNavItem(
                icon: Icons.article,
                label: 'ADVISORY',
                index: 2,
                isSelected: _selectedIndex == 2,
              ),
              _buildNavItem(
                icon: Icons.person,
                label: 'PROFILE',
                index: 3,
                isSelected: _selectedIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom navigation item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _onBottomNavTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
