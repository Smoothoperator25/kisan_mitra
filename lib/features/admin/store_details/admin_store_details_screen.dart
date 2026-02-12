import 'package:flutter/material.dart';

class AdminStoreDetailsScreen extends StatelessWidget {
  const AdminStoreDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeId = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Details'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Store Details Screen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Store ID: ${storeId ?? "N/A"}'),
            const SizedBox(height: 16),
            const Text('Coming soon...'),
          ],
        ),
      ),
    );
  }
}
