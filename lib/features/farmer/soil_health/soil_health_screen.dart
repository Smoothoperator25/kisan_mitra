import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';

/// Soil Health Check Screen
/// Allows farmers to book soil sample tests
class SoilHealthScreen extends StatelessWidget {
  const SoilHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Soil Health Check'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Soil Health Check Screen\n(Coming Soon)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
