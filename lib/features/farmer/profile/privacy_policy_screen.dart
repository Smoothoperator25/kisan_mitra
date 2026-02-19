import 'package:flutter/material.dart';

/// Privacy Policy Screen for Kisan Mitra
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _green = Color(0xFF2E7D32);
  static const _bg = Color(0xFFF5F9F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
                      Icons.privacy_tip_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Last Updated: February 2026',
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
                children: [
                  _buildSection(
                    '1. Information We Collect',
                    Icons.info_outline,
                    'We collect information that you provide directly:\n\n'
                        '• Personal details (name, phone number, email)\n'
                        '• Farm details (location, soil type, farm area)\n'
                        '• GPS coordinates (only when you grant permission)\n'
                        '• Search and advisory history within the app\n'
                        '• Profile pictures (optional)',
                  ),
                  _buildSection(
                    '2. How We Use Your Information',
                    Icons.analytics_outlined,
                    'Your information is used to:\n\n'
                        '• Provide personalized fertilizer recommendations\n'
                        '• Show nearby fertilizer stores and prices\n'
                        '• Generate crop-specific advisory reports\n'
                        '• Schedule soil health check appointments\n'
                        '• Improve our services and user experience',
                  ),
                  _buildSection(
                    '3. Data Storage & Security',
                    Icons.security_outlined,
                    'We take data security seriously:\n\n'
                        '• All data is stored securely on Firebase servers\n'
                        '• SSL/TLS encryption for all data transfers\n'
                        '• Access controls to protect your information\n'
                        '• Regular security audits and updates\n'
                        '• Data is not sold to third parties',
                  ),
                  _buildSection(
                    '4. Location Data',
                    Icons.location_on_outlined,
                    'We access your location only when:\n\n'
                        '• You search for nearby fertilizer stores\n'
                        '• You manually capture GPS for soil testing\n'
                        '• Location access can be revoked anytime from phone settings',
                  ),
                  _buildSection(
                    '5. Data Sharing',
                    Icons.share_outlined,
                    'We may share limited data with:\n\n'
                        '• Registered fertilizer stores (only your search queries)\n'
                        '• Soil testing laboratories (when you book a test)\n'
                        '• We never sell your personal information',
                  ),
                  _buildSection(
                    '6. Your Rights',
                    Icons.gavel_outlined,
                    'You have the right to:\n\n'
                        '• Access your personal data at any time\n'
                        '• Request deletion of your account and data\n'
                        '• Update or correct your information\n'
                        '• Opt out of non-essential data collection\n'
                        '• Export your data in a readable format',
                  ),
                  _buildSection(
                    '7. Contact Us',
                    Icons.email_outlined,
                    'For privacy-related questions:\n\n'
                        '📧 Email: privacy@kisanmitra.com\n'
                        '📞 Phone: +91 8080509271\n'
                        '🌐 Website: www.kisanmitra.com/privacy',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '© 2024 Kisan Mitra. All rights reserved.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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

  Widget _buildSection(String title, IconData icon, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263238),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
