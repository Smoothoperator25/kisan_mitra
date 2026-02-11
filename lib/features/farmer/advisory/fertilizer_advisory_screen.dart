import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';

/// Fertilizer Advisory Screen
/// Provides crop-wise fertilizer guidance to farmers
class FertilizerAdvisoryScreen extends StatelessWidget {
  const FertilizerAdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fertilizer Advisory'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Fertilizer Advisory Screen\n(Coming Soon)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
