import 'package:flutter/material.dart';
import '../../core/utils/app_theme.dart';

class StoreHomeScreen extends StatelessWidget {
  const StoreHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Store Home Screen\n(Waiting for UI design)',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading2,
        ),
      ),
    );
  }
}
