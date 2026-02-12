import 'package:flutter/material.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Reports Screen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Coming soon...'),
          ],
        ),
      ),
    );
  }
}
