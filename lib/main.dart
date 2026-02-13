import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/app_theme.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/role_selection_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/farmer_login_screen.dart';
import 'features/auth/farmer_signup_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/farmer/dashboard/farmer_dashboard_screen.dart';
import 'features/store/dashboard/store_dashboard_screen.dart';
import 'features/admin/dashboard/admin_dashboard_screen.dart';
import 'features/admin/auth/admin_login_screen.dart';
import 'features/admin/store_details/admin_store_details_screen.dart';
import 'features/admin/farmers/admin_farmers_list_screen.dart';
import 'features/admin/stores/admin_stores_list_screen.dart';
import 'features/admin/activity/admin_activity_log_screen.dart';
import 'features/admin/reports/admin_reports_screen.dart';
import 'features/store/auth/store_login_screen.dart';
import 'features/store/auth/store_registration_screen.dart';
import 'features/farmer/profile/profile_controller.dart';
import 'features/store/profile/store_profile_controller.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  Future<void> _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFirebase(),
      builder: (context, snapshot) {
        // Show loading while initializing
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // Show a friendly error screen if initialization failed
        if (snapshot.hasError) {
          final message = snapshot.error.toString();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Firebase initialization failed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(message, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          // Retry by rebuilding the widget tree
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const AppInitializer(),
                            ),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Success: continue to the real app
        return const MyApp();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => StoreProfileController()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.background,
            error: AppColors.error,
          ),
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.poppinsTextTheme().copyWith(
            displayLarge: AppTextStyles.heading1,
            displayMedium: AppTextStyles.heading2,
            displaySmall: AppTextStyles.heading3,
            bodyLarge: AppTextStyles.bodyLarge,
            bodyMedium: AppTextStyles.bodyMedium,
            bodySmall: AppTextStyles.bodySmall,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              textStyle: AppTextStyles.button,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          cardTheme: const CardThemeData(
            color: AppColors.cardBackground,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        initialRoute: AppConstants.splashRoute,
        routes: {
          AppConstants.splashRoute: (context) => const SplashScreen(),
          AppConstants.roleSelectionRoute: (context) =>
              const RoleSelectionScreen(),
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.farmerLoginRoute: (context) => const FarmerLoginScreen(),
          AppConstants.farmerSignupRoute: (context) =>
              const FarmerSignupScreen(),
          AppConstants.forgotPasswordRoute: (context) =>
              const ForgotPasswordScreen(),
          AppConstants.storeLoginRoute: (context) => const StoreLoginScreen(),
          AppConstants.storeRegistrationRoute: (context) =>
              const StoreRegistrationScreen(),
          AppConstants.adminLoginRoute: (context) => const AdminLoginScreen(),
          AppConstants.farmerHomeRoute: (context) =>
              const FarmerDashboardScreen(),
          AppConstants.storeHomeRoute: (context) =>
              const StoreDashboardScreen(),
          AppConstants.adminDashboardRoute: (context) =>
              const AdminDashboardScreen(),
          '/admin-store-details': (context) => const AdminStoreDetailsScreen(),
          '/admin-farmers-list': (context) => const AdminFarmersListScreen(),
          '/admin-stores-list': (context) => const AdminStoresListScreen(),
          '/admin-activity-log': (context) => const AdminActivityLogScreen(),
          '/admin-reports': (context) => const AdminReportsScreen(),
        },
      ),
    );
  }
}
