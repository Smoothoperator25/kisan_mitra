import 'package:flutter/material.dart';

/// User Guide Screen for Kisan Mitra
/// Step-by-step guide explaining how to use each feature of the app
class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  static const _green = Color(0xFF2E7D32);
  static const _bg = Color(0xFFF5F9F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'User Guide',
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
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Learn how to use Kisan Mitra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Follow these simple steps to get started',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
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
                  // Getting Started
                  _buildGuideSection(
                    number: '1',
                    title: 'Getting Started',
                    icon: Icons.rocket_launch_outlined,
                    color: const Color(0xFF1976D2),
                    steps: const [
                      GuideStep(
                        'Create Your Account',
                        'Sign up with your email and fill in your farming details like name, village, state, and farm information.',
                        Icons.person_add_outlined,
                      ),
                      GuideStep(
                        'Set Up Your Profile',
                        'Add your profile photo and verify your details from the Profile tab. You can edit anytime.',
                        Icons.edit_outlined,
                      ),
                      GuideStep(
                        'Explore the Home Screen',
                        'The home screen shows quick access cards for Fertilizer Search, Advisory, Soil Health Check, and your Profile.',
                        Icons.home_outlined,
                      ),
                    ],
                  ),

                  // Fertilizer Search
                  _buildGuideSection(
                    number: '2',
                    title: 'Fertilizer Search',
                    icon: Icons.search_outlined,
                    color: const Color(0xFF2E7D32),
                    steps: const [
                      GuideStep(
                        'Search for Fertilizers',
                        'Go to the Search tab and type the fertilizer name (e.g., "Urea", "DAP"). Results show matching fertilizers with NPK ratios.',
                        Icons.manage_search_outlined,
                      ),
                      GuideStep(
                        'Find Nearby Stores',
                        'Tap on a fertilizer to see nearby stores on the map. Each store shows distance, price, and availability.',
                        Icons.store_outlined,
                      ),
                      GuideStep(
                        'Navigate to a Store',
                        'Tap on a store marker to see full details. Use the "Directions" button to open navigation in Google Maps.',
                        Icons.directions_outlined,
                      ),
                      GuideStep(
                        'Compare Prices',
                        'View prices from multiple stores to find the best deal for your fertilizer.',
                        Icons.compare_arrows_outlined,
                      ),
                    ],
                  ),

                  // Advisory
                  _buildGuideSection(
                    number: '3',
                    title: 'Precision Advisory',
                    icon: Icons.psychology_outlined,
                    color: const Color(0xFFF57C00),
                    steps: const [
                      GuideStep(
                        'Select Your Crop',
                        'Choose your crop from the list of 100+ Indian crops. Each crop has specific fertilizer requirements.',
                        Icons.grass_outlined,
                      ),
                      GuideStep(
                        'Enter Field Details',
                        'Provide your field size, growth stage, and soil nutrient levels (N, P, K) if known.',
                        Icons.landscape_outlined,
                      ),
                      GuideStep(
                        'Get Recommendations',
                        'The AI advisory system will generate personalized fertilizer recommendations with exact quantities.',
                        Icons.auto_awesome_outlined,
                      ),
                      GuideStep(
                        'Apply Fertilizers',
                        'Follow the recommended application method and timing for best results.',
                        Icons.agriculture_outlined,
                      ),
                    ],
                  ),

                  // Soil Health Check
                  _buildGuideSection(
                    number: '4',
                    title: 'Soil Health Check',
                    icon: Icons.biotech_outlined,
                    color: const Color(0xFF7B1FA2),
                    steps: const [
                      GuideStep(
                        'Fill Farmer Information',
                        'Enter your name, phone number, pin code, and farm area in Step 1 of the booking wizard.',
                        Icons.person_outline,
                      ),
                      GuideStep(
                        'Add Soil Details',
                        'Select soil type, previous crop, water source, irrigation type, and capture GPS location in Step 2.',
                        Icons.terrain_outlined,
                      ),
                      GuideStep(
                        'Review & Submit',
                        'Review all details in Step 3 and submit your soil test booking request.',
                        Icons.checklist_outlined,
                      ),
                      GuideStep(
                        'Wait for Results',
                        'A lab technician will contact you for sample collection. Results will be available in 5-7 days.',
                        Icons.science_outlined,
                      ),
                    ],
                  ),

                  // Profile Management
                  _buildGuideSection(
                    number: '5',
                    title: 'Profile & Settings',
                    icon: Icons.settings_outlined,
                    color: const Color(0xFF455A64),
                    steps: const [
                      GuideStep(
                        'Edit Profile',
                        'Tap the edit icon on your profile to update name, email, location, and profile photo.',
                        Icons.edit_outlined,
                      ),
                      GuideStep(
                        'Track Your Activity',
                        'View your search count, advisory count, and store visits on the profile screen statistics.',
                        Icons.bar_chart_outlined,
                      ),
                      GuideStep(
                        'Change Language',
                        'Go to Settings > Language to switch between available languages.',
                        Icons.language_outlined,
                      ),
                      GuideStep(
                        'Change Password',
                        'Use the "Change Password" button to reset your password via email.',
                        Icons.lock_outline,
                      ),
                    ],
                  ),

                  // Tips section
                  _buildTipsCard(),

                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      'Need more help? Contact us from Help & Support.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
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

  Widget _buildGuideSection({
    required String number,
    required String title,
    required IconData icon,
    required Color color,
    required List<GuideStep> steps,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Section header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Steps
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isLast = i == steps.length - 1;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                i == 0 ? 16 : 0,
                16,
                isLast ? 16 : 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number with connector line
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(step.icon, size: 14, color: color),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 30,
                          margin: const EdgeInsets.only(top: 4),
                          color: color.withValues(alpha: 0.15),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF263238),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          step.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tips_and_updates,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pro Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _tipItem(
            '💡',
            'Test your soil every season for accurate fertilizer recommendations',
          ),
          const SizedBox(height: 10),
          _tipItem('📱', 'Enable GPS for accurate nearby store results'),
          const SizedBox(height: 10),
          _tipItem(
            '🌾',
            'Update your crop growth stage regularly for better advisory',
          ),
          const SizedBox(height: 10),
          _tipItem(
            '💰',
            'Compare prices across stores before buying fertilizers',
          ),
          const SizedBox(height: 10),
          _tipItem(
            '🔔',
            'Turn on notifications to get alerts on price changes',
          ),
        ],
      ),
    );
  }

  Widget _tipItem(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Data class for a guide step
class GuideStep {
  final String title;
  final String description;
  final IconData icon;

  const GuideStep(this.title, this.description, this.icon);
}
