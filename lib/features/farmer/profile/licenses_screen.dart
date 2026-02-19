import 'package:flutter/material.dart';

/// Open Source Licenses Screen for Kisan Mitra
class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  static const _green = Color(0xFF2E7D32);
  static const _bg = Color(0xFFF5F9F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Open Source Licenses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: _green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              decoration: const BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.source_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Built with open-source software',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App License Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _green.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.agriculture, color: _green, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kisan Mitra',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Proprietary License © 2024 Satyajit Gaikwad',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flutter button to see all licenses
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showLicensePage(
                          context: context,
                          applicationName: 'Kisan Mitra',
                          applicationVersion: '1.0.0',
                          applicationIcon: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.agriculture,
                                size: 36,
                                color: _green,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt, size: 20),
                      label: const Text('View All Flutter Licenses'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  // Section Title
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'KEY DEPENDENCIES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  _buildLicenseCard(
                    'Flutter',
                    'Google',
                    'BSD 3-Clause License',
                    'UI framework for building natively compiled applications.',
                    const Color(0xFF027DFD),
                  ),
                  _buildLicenseCard(
                    'Firebase',
                    'Google',
                    'Apache 2.0 License',
                    'Backend services including authentication, database, and storage.',
                    const Color(0xFFFFCA28),
                  ),
                  _buildLicenseCard(
                    'Provider',
                    'Remi Rousselet',
                    'MIT License',
                    'State management solution for Flutter applications.',
                    const Color(0xFF7C4DFF),
                  ),
                  _buildLicenseCard(
                    'Mapbox GL',
                    'Mapbox',
                    'BSD License',
                    'Interactive maps and location services.',
                    const Color(0xFF4264FB),
                  ),
                  _buildLicenseCard(
                    'URL Launcher',
                    'Flutter Community',
                    'BSD 3-Clause License',
                    'Plugin for launching URLs in mobile browsers.',
                    const Color(0xFF00BCD4),
                  ),
                  _buildLicenseCard(
                    'Cached Network Image',
                    'Baseflow',
                    'MIT License',
                    'Library to load and cache network images.',
                    const Color(0xFFFF7043),
                  ),
                  _buildLicenseCard(
                    'Intl',
                    'Dart Team',
                    'BSD 3-Clause License',
                    'Internationalization and formatting utilities.',
                    const Color(0xFF66BB6A),
                  ),
                  _buildLicenseCard(
                    'Image Picker',
                    'Flutter Community',
                    'Apache 2.0 License',
                    'Plugin for selecting images from gallery or camera.',
                    const Color(0xFFEC407A),
                  ),
                  _buildLicenseCard(
                    'Package Info Plus',
                    'Flutter Community',
                    'BSD 3-Clause License',
                    'Querying app version and build info.',
                    const Color(0xFF8D6E63),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Thank you to the open-source community! ❤️',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseCard(
    String name,
    String author,
    String license,
    String description,
    Color accent,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                name[0],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF263238),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• $author',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    license,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
