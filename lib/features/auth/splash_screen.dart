import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final currentUser = _authService.currentUser;

      if (currentUser == null) {
        // User not logged in, navigate to role selection
        _navigateToRoleSelection();
        return;
      }

      // User is logged in, fetch role from Firestore
      final result = await _firestoreService.getUserRoleAndData(
        currentUser.uid,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final role = result['role'] as String;
        _navigateBasedOnRole(role);
      } else {
        // Error fetching user data, navigate to role selection
        _navigateToRoleSelection();
      }
    } catch (e) {
      // Error occurred, navigate to role selection
      if (mounted) {
        _navigateToRoleSelection();
      }
    }
  }

  void _navigateBasedOnRole(String role) {
    String route;
    switch (role) {
      case AppConstants.roleFarmer:
        route = AppConstants.farmerHomeRoute;
        break;
      case AppConstants.roleStore:
        route = AppConstants.storeHomeRoute;
        break;
      case AppConstants.roleAdmin:
        route = AppConstants.adminDashboardRoute;
        break;
      default:
        route = AppConstants.loginRoute;
    }

    Navigator.of(context).pushReplacementNamed(route);
  }

  void _navigateToRoleSelection() {
    Navigator.of(context).pushReplacementNamed(AppConstants.roleSelectionRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.agriculture,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 30),

            // App Name
            Text(
              AppConstants.appName,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),

            // Tagline
            Text(
              'Smart Fertilizer Finder',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 50),

            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),

            Text(
              'Loading...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
