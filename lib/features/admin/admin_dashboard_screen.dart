import 'package:flutter/material.dart';
import '../../core/utils/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Admin Dashboard Screen\n(Waiting for UI design)',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading2,
        ),
      ),
    );
  }
}
