import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Screen to display full fertilizer details from admin's fertilizer collection
class FertilizerDetailsScreen extends StatelessWidget {
  final String fertilizerId;
  final String fertilizerName;

  const FertilizerDetailsScreen({
    super.key,
    required this.fertilizerId,
    required this.fertilizerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Fertilizer Details'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fertilizers')
            .doc(fertilizerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildNotFoundState();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          return _buildDetailsContent(data);
        },
      ),
    );
  }

  Widget _buildDetailsContent(Map<String, dynamic> data) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fertilizer Image
          _buildImageSection(data['imageUrl']?.toString() ?? ''),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fertilizer Name
                Text(
                  data['name']?.toString() ?? fertilizerName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),

                const SizedBox(height: 8),

                // NPK Composition Badge
                if (data['npkComposition'] != null &&
                    data['npkComposition'].toString().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'NPK: ${data['npkComposition']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Description
                if (data['description'] != null &&
                    data['description'].toString().isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.description_outlined,
                    title: 'Description',
                    content: data['description'].toString(),
                  ),

                // Manufacturer
                if (data['manufacturer'] != null &&
                    data['manufacturer'].toString().isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.business_outlined,
                    title: 'Manufacturer',
                    content: data['manufacturer'].toString(),
                  ),

                // Category and Form
                Row(
                  children: [
                    if (data['category'] != null &&
                        data['category'].toString().isNotEmpty)
                      Expanded(
                        child: _buildSmallInfoCard(
                          icon: Icons.category_outlined,
                          title: 'Category',
                          content: data['category'].toString(),
                        ),
                      ),
                    if (data['category'] != null &&
                        data['category'].toString().isNotEmpty &&
                        data['form'] != null &&
                        data['form'].toString().isNotEmpty)
                      const SizedBox(width: 12),
                    if (data['form'] != null &&
                        data['form'].toString().isNotEmpty)
                      Expanded(
                        child: _buildSmallInfoCard(
                          icon: Icons.science_outlined,
                          title: 'Form',
                          content: data['form'].toString(),
                        ),
                      ),
                  ],
                ),

                // Application Method
                if (data['applicationMethod'] != null &&
                    data['applicationMethod'].toString().isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.agriculture_outlined,
                    title: 'Application Method',
                    content: data['applicationMethod'].toString(),
                  ),

                // Recommended Dosage
                if (data['recommendedDosage'] != null)
                  _buildInfoCard(
                    icon: Icons.straighten_outlined,
                    title: 'Recommended Dosage',
                    content:
                        '${data['recommendedDosage']} ${data['dosageUnit'] ?? 'KG/ACRE'}',
                  ),

                // Suitable Crops
                if (data['suitableCrops'] != null &&
                    data['suitableCrops'].toString().isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.grass_outlined,
                    title: 'Suitable Crops',
                    content: data['suitableCrops'].toString(),
                  ),

                // Application Timing
                if (data['applicationTiming'] != null &&
                    data['applicationTiming'].toString().isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.schedule_outlined,
                    title: 'Application Timing',
                    content: data['applicationTiming'].toString(),
                  ),

                // Benefits
                if (data['benefits'] != null &&
                    data['benefits'].toString().isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.eco_outlined,
                    title: 'Benefits',
                    content: data['benefits'].toString(),
                    backgroundColor: const Color(0xFFE8F5E9),
                  ),

                // Storage Instructions
                if (data['storageInstructions'] != null &&
                    data['storageInstructions'].toString().isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.warehouse_outlined,
                    title: 'Storage Instructions',
                    content: data['storageInstructions'].toString(),
                  ),

                // Shelf Life
                if (data['shelfLife'] != null &&
                    data['shelfLife'].toString().isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.timer_outlined,
                    title: 'Shelf Life',
                    content: data['shelfLife'].toString(),
                  ),

                // Safety Notes
                if (data['safetyNotes'] != null &&
                    data['safetyNotes'].toString().isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.warning_amber_outlined,
                    title: 'Safety Notes',
                    content: data['safetyNotes'].toString(),
                    backgroundColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                  ),

                // Precautions
                if (data['precautions'] != null &&
                    data['precautions'].toString().isNotEmpty)
                  _buildInfoCard(
                    icon: Icons.shield_outlined,
                    title: 'Precautions',
                    content: data['precautions'].toString(),
                    backgroundColor: const Color(0xFFFFEBEE),
                    iconColor: const Color(0xFFF44336),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(
          Icons.image,
          size: 80,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    Color backgroundColor = Colors.white,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: iconColor ?? const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Fertilizer details not found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error loading details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
