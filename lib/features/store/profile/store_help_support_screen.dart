import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreHelpSupportScreen extends StatelessWidget {
  const StoreHelpSupportScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@kisanmitra.com',
      queryParameters: {'subject': 'Support Request: Store Issue'},
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '+911234567890');
    if (!await launchUrl(phoneLaunchUri)) {
      debugPrint('Could not launch phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Support Section
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.email_outlined,
              title: 'Email Us',
              subtitle: 'support@kisanmitra.com',
              onTap: _launchEmail,
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.phone_outlined,
              title: 'Call Us',
              subtitle: '+91 12345 67890',
              onTap: _launchPhone,
            ),

            const SizedBox(height: 24),

            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              'How do I add new fertilizers?',
              'As a store owner, you cannot create new fertilizers. Admin adds the master list of fertilizers. You can only manage the stock and price of existing fertilizers in your inventory.',
            ),
            _buildFaqItem(
              'How do I update my store location?',
              'Go to Store Dashboard > Location. You can tap on the map to set your precise location or use the "Use Current Location" button.',
            ),
            _buildFaqItem(
              'How can I change my password?',
              'Go to Store Profile > Change Password. Enter your current password and the new password to update it.',
            ),
            _buildFaqItem(
              'Why is my store not verified yet?',
              'Verification usually takes 24-48 hours. Admin verifies details manually. Ensure your profile information is complete.',
            ),

            const SizedBox(height: 24),

            // Send Feedback Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _launchEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Send Feedback'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(answer, style: TextStyle(color: Colors.grey[600], height: 1.5)),
        ],
      ),
    );
  }
}
