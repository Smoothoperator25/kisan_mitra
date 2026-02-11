import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';

/// Fertilizer Search Screen
/// Allows farmers to find nearby stores with fertilizer availability and pricing
class FertilizerSearchScreen extends StatelessWidget {
  const FertilizerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fertilizer Search'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Fertilizer Search Screen\n(Coming Soon)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
