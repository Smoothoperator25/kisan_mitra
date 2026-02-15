import 'package:flutter/material.dart';
import 'fertilizer_controller.dart';
import 'fertilizer_model.dart';
import 'edit_fertilizer_screen.dart';

class FertilizerListScreen extends StatefulWidget {
  const FertilizerListScreen({super.key});

  @override
  State<FertilizerListScreen> createState() => _FertilizerListScreenState();
}

class _FertilizerListScreenState extends State<FertilizerListScreen> {
  final FertilizerController _controller = FertilizerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Manage Fertilizer Master Data'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Fertilizer>>(
        stream: _controller.getFertilizersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            );
          }

          final fertilizers = snapshot.data ?? [];

          if (fertilizers.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fertilizers.length,
            itemBuilder: (context, index) {
              return _buildFertilizerCard(fertilizers[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditFertilizerScreen(
                fertilizer: Fertilizer.empty(),
                isNewFertilizer: true,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFertilizerCard(Fertilizer fertilizer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with floating icons
          Stack(
            children: [
              // Fertilizer image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: fertilizer.imageUrl.isNotEmpty
                    ? Image.network(
                        fertilizer.imageUrl,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
              // Floating edit icon
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditFertilizerScreen(
                            fertilizer: fertilizer,
                            isNewFertilizer: false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Floating download icon (UI only)
              Positioned(
                top: 12,
                right: 56,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.download,
                      size: 18,
                      color: Color(0xFF10B981),
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // UI only - no functionality for now
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Download feature coming soon'),
                          backgroundColor: Color(0xFF6366F1),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fertilizer name
                Text(
                  fertilizer.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                // NPK Composition
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'NPK ${fertilizer.npkComposition}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Suitable crops
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.grass, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        fertilizer.cropsPreview,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Edit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditFertilizerScreen(
                            fertilizer: fertilizer,
                            isNewFertilizer: false,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'EDIT FERTILIZER',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 180,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.image, size: 64, color: Color(0xFF94A3B8)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No fertilizers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a new fertilizer',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
            'Error loading fertilizers',
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
