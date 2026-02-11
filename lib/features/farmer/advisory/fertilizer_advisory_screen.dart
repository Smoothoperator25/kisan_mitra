import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';
import 'advisory_controller.dart';
import 'advisory_model.dart';

/// Fertilizer Advisory Screen
/// Provides personalized fertilizer guidance based on crop, phase, and field size
class FertilizerAdvisoryScreen extends StatefulWidget {
  const FertilizerAdvisoryScreen({super.key});

  @override
  State<FertilizerAdvisoryScreen> createState() =>
      _FertilizerAdvisoryScreenState();
}

class _FertilizerAdvisoryScreenState extends State<FertilizerAdvisoryScreen> {
  final AdvisoryController _controller = AdvisoryController();

  @override
  void initState() {
    super.initState();
    _controller.initialize();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});

    // Show error as snackbar if present
    if (_controller.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.error!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _controller.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPersonalizedGuidanceSection(),
                  const SizedBox(height: 16),
                  _buildCropSelectionSection(),
                  const SizedBox(height: 16),
                  _buildCropPhaseSection(),
                  const SizedBox(height: 16),
                  _buildFieldSizeSection(),
                  const SizedBox(height: 16),
                  _buildCalculateButton(),
                  if (_controller.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildRecommendedPlanSection(),
                  ],
                  if (_controller.safetyGuidelines.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSafetyInstructionsSection(),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  /// App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fertilizer Advisory',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Kisan Mitra',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF2E7D32),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.help_outline, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  /// Personalized Guidance Section
  Widget _buildPersonalizedGuidanceSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personalized Guidance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get precise nutrient plans for your specific crop needs.',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  /// Crop Selection Section
  Widget _buildCropSelectionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Crop',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF2E7D32), fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _controller.crops.length,
              itemBuilder: (context, index) {
                final crop = _controller.crops[index];
                final isSelected = _controller.selectedCrop == crop.name;
                return _buildCropItem(crop, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Crop Item
  Widget _buildCropItem(Crop crop, bool isSelected) {
    return GestureDetector(
      onTap: () => _controller.selectCrop(crop.name),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Center(child: _getCropIcon(crop.name)),
            ),
            const SizedBox(height: 4),
            Text(
              crop.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get icon for crop (placeholder icons based on crop name)
  Widget _getCropIcon(String cropName) {
    IconData iconData;
    switch (cropName.toLowerCase()) {
      case 'wheat':
        iconData = Icons.grain;
        break;
      case 'rice':
        iconData = Icons.rice_bowl;
        break;
      case 'corn':
        iconData = Icons.grass;
        break;
      case 'sugar':
        iconData = Icons.local_florist;
        break;
      default:
        iconData = Icons.eco;
    }

    return Icon(iconData, color: const Color(0xFF2E7D32), size: 30);
  }

  /// Crop Phase Section
  Widget _buildCropPhaseSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Crop Phase',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CropPhase>(
                value: _controller.selectedPhase,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: CropPhase.values.map((phase) {
                  return DropdownMenuItem(
                    value: phase,
                    child: Text(
                      phase.label,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (phase) {
                  if (phase != null) {
                    _controller.selectPhase(phase);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Field Size Section
  Widget _buildFieldSizeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Field Size (Acres)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_controller.fieldSize.toStringAsFixed(1)} Acres',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF2E7D32),
              inactiveTrackColor: Colors.grey[300],
              thumbColor: const Color(0xFF2E7D32),
              overlayColor: const Color(0xFF2E7D32).withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _controller.fieldSize,
              min: 1,
              max: 50,
              divisions: 98, // 0.5 increments
              onChanged: (value) {
                _controller.updateFieldSize(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 ACRE',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                Text(
                  '25 ACRES',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                Text(
                  '50 ACRES',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate Advice Button
  Widget _buildCalculateButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _controller.isCalculating
            ? null
            : () => _controller.calculateAdvice(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _controller.isCalculating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Calculate Advice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Recommended Plan Section
  Widget _buildRecommendedPlanSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco, color: Color(0xFF2E7D32), size: 24),
              SizedBox(width: 8),
              Text(
                'Recommended Plan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._controller.recommendations.map((rec) {
            return _buildRecommendationCard(rec);
          }).toList(),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Application Window: 48 Hours',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text(
                      'DETAILS',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Color(0xFF2E7D32),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Individual Recommendation Card
  Widget _buildRecommendationCard(FertilizerRecommendation rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: rec.isOptimized
            ? Border.all(color: const Color(0xFF2E7D32), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.science, color: Color(0xFF1976D2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rec.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (rec.isOptimized)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OPTIMIZED',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Apply via soil drenching during morning hours.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${rec.dosagePerAcre.toStringAsFixed(0)}kg / Acre',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Total: ${rec.totalQuantity.toStringAsFixed(1)}kg',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Safety Instructions Section
  Widget _buildSafetyInstructionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF6F00),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Safety Instructions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6F00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._controller.safetyGuidelines.map((guideline) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.circle, size: 8, color: Color(0xFFFF6F00)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      guideline.guideline,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
