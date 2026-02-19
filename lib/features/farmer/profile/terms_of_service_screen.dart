import 'package:flutter/material.dart';

/// Terms of Service Screen for Kisan Mitra
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const _green = Color(0xFF2E7D32);
  static const _bg = Color(0xFFF5F9F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
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
                      Icons.gavel_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Effective: February 2026',
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
                  // Quick Summary Card
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
                        const Icon(
                          Icons.lightbulb_outline,
                          color: _green,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'By using Kisan Mitra, you agree to these terms. Please read them carefully.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    '1. Acceptance of Terms',
                    Icons.check_circle_outline,
                    'By downloading, installing, or using the Kisan Mitra application, '
                        'you agree to be bound by these Terms of Service. If you do not '
                        'agree, please do not use the app.\n\n'
                        'These terms apply to all users including farmers, store owners, '
                        'and administrators.',
                  ),
                  _buildSection(
                    '2. User Accounts',
                    Icons.person_outline,
                    '• You must provide accurate and complete registration information\n'
                        '• You are responsible for maintaining your account security\n'
                        '• One account per person; no sharing of credentials\n'
                        '• You must be at least 18 years old to create an account\n'
                        '• We reserve the right to suspend accounts that violate these terms',
                  ),
                  _buildSection(
                    '3. Services Provided',
                    Icons.agriculture_outlined,
                    'Kisan Mitra provides:\n\n'
                        '• Fertilizer search and price comparison\n'
                        '• Crop-specific fertilizer advisory\n'
                        '• Nearby store locator with navigation\n'
                        '• Soil health check booking\n'
                        '• Agricultural recommendations\n\n'
                        'Note: Advisory recommendations are for informational purposes '
                        'only and should be verified with local agricultural experts.',
                  ),
                  _buildSection(
                    '4. User Responsibilities',
                    Icons.assignment_outlined,
                    '• Provide truthful information about farms and crops\n'
                        '• Use the app only for lawful agricultural purposes\n'
                        '• Do not attempt to reverse-engineer the application\n'
                        '• Do not misuse or abuse the advisory system\n'
                        '• Report any bugs or security vulnerabilities',
                  ),
                  _buildSection(
                    '5. Store Owners',
                    Icons.store_outlined,
                    '• Must provide accurate product information and pricing\n'
                        '• Must keep inventory and availability updated\n'
                        '• Must obtain valid store verification\n'
                        '• Are responsible for fulfilling customer orders\n'
                        '• Must comply with local agricultural regulations',
                  ),
                  _buildSection(
                    '6. Disclaimer of Warranties',
                    Icons.warning_amber_outlined,
                    'The app is provided "as is" without warranties of any kind.\n\n'
                        '• Fertilizer recommendations are AI-generated suggestions\n'
                        '• Prices shown may vary from actual store prices\n'
                        '• GPS accuracy depends on your device capabilities\n'
                        '• We do not guarantee crop yield improvements\n'
                        '• Always consult local experts for critical decisions',
                  ),
                  _buildSection(
                    '7. Limitation of Liability',
                    Icons.shield_outlined,
                    'Kisan Mitra shall not be liable for:\n\n'
                        '• Crop losses based on advisory recommendations\n'
                        '• Price differences between app and actual store\n'
                        '• Service interruptions or data loss\n'
                        '• Third-party content or store actions\n'
                        '• Indirect or consequential damages',
                  ),
                  _buildSection(
                    '8. Modifications',
                    Icons.edit_note_outlined,
                    'We reserve the right to modify these terms at any time. '
                        'Changes will be communicated through app notifications. '
                        'Continued use after changes constitutes acceptance of '
                        'the modified terms.',
                  ),
                  _buildSection(
                    '9. Contact',
                    Icons.email_outlined,
                    'For questions about these terms:\n\n'
                        '📧 Email: legal@kisanmitra.com\n'
                        '📞 Phone: +91 8080509271\n'
                        '🌐 Website: www.kisanmitra.com/terms',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '© 2026 Kisan Mitra. All rights reserved.',
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
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFF57C00), size: 20),
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
