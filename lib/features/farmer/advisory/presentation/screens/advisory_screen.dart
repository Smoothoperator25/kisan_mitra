import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/crop_model.dart';
import '../../data/models/advisory_model.dart';
import '../controllers/advisory_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdvisoryScreen extends StatelessWidget {
  const AdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdvisoryController(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Precision Advisory',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Consumer<AdvisoryController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeatherHeader(controller),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Select Crop"),
                  const SizedBox(height: 12),
                  _buildCropSelector(context, controller),
                  const SizedBox(height: 24),
                  if (controller.selectedCrop != null) ...[
                    _buildGrowthStageSelector(controller),
                    const SizedBox(height: 24),
                    _buildFieldSizeSlider(controller),
                    const SizedBox(height: 24),
                    _buildSoilHealthSection(controller),
                    const SizedBox(height: 24),
                    _buildCropIssuesSection(controller),
                    const SizedBox(height: 32),
                    _buildCalculateButton(controller),
                  ],
                  if (controller.isCalculating)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        controller.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (controller.advisoryResult != null &&
                      !controller.isCalculating)
                    _buildResultSection(controller.advisoryResult!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildWeatherHeader(AdvisoryController controller) {
    final weather = controller.currentWeather;
    if (weather == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Current Weather",
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
              const SizedBox(height: 4),
              Text(
                "${weather.temperature.toStringAsFixed(1)}°C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                weather.condition,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _weatherInfoRow(Icons.water_drop, "${weather.humidity}%"),
              const SizedBox(height: 4),
              _weatherInfoRow(Icons.air, "${weather.windSpeed} m/s"),
              if (weather.rainProbability > 0) ...[
                const SizedBox(height: 4),
                _weatherInfoRow(
                  Icons.umbrella,
                  "${(weather.rainProbability * 100).toInt()}% Rain",
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _weatherInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildCropSelector(
    BuildContext context,
    AdvisoryController controller,
  ) {
    return SizedBox(
      height: 140, // Height for avatar + text
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.crops.length + 1, // +1 for "View All"
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == controller.crops.length) {
            return _buildViewAllCard();
          }
          final crop = controller.crops[index];
          final isSelected = controller.selectedCrop?.id == crop.id;

          return GestureDetector(
            onTap: () => controller.selectCrop(crop),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: crop.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  crop.name,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.green[800] : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewAllCard() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.grid_view_rounded,
            color: Colors.green[700],
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        const Text("View All"),
      ],
    );
  }

  Widget _buildGrowthStageSelector(AdvisoryController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: controller.selectedGrowthStage,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.green),
          items: controller.selectedCrop!.growthStages.map((String stage) {
            return DropdownMenuItem<String>(value: stage, child: Text(stage));
          }).toList(),
          onChanged: (val) {
            if (val != null) controller.setGrowthStage(val);
          },
        ),
      ),
    );
  }

  Widget _buildFieldSizeSlider(AdvisoryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Field Size",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${controller.fieldSize.toStringAsFixed(1)} ${controller.isHectares ? 'Ha' : 'Acres'}",
                style: TextStyle(
                  color: Colors.green[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: controller.fieldSize,
          min: 0.5,
          max: 50.0,
          divisions: 99,
          activeColor: Colors.green,
          onChanged: (val) => controller.setFieldSize(val),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("Acres"),
            Switch(
              value: controller.isHectares,
              activeColor: Colors.green,
              onChanged: (val) => controller.toggleUnit(val),
            ),
            const Text("Hectares"),
          ],
        ),
      ],
    );
  }

  Widget _buildSoilHealthSection(AdvisoryController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Soil Health"),
        const SizedBox(height: 12),
        // Soil Type Dropdown
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Soil Type",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
          value: controller.selectedSoilType,
          items: [
            "Loamy",
            "Clay",
            "Sandy",
            "Black",
            "Red",
            "Alluvial",
            "Saline",
          ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (val) {
            if (val != null) controller.setSoilType(val);
          },
        ),
        // Add more sophisticated inputs here later (N, P, K sliders/inputs)
      ],
    );
  }

  Widget _buildCropIssuesSection(AdvisoryController controller) {
    List<String> issues = [
      "Yellow leaves",
      "Stunted growth",
      "Pest attack",
      "Fungal disease",
      "Wilting",
      "Low yield",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Observations / Issues"),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: issues.map((issue) {
            final isSelected = controller.selectedIssues.contains(issue);
            return FilterChip(
              label: Text(issue),
              selected: isSelected,
              selectedColor: Colors.red[100],
              checkmarkColor: Colors.red,
              labelStyle: TextStyle(
                color: isSelected ? Colors.red[900] : Colors.black87,
              ),
              onSelected: (_) => controller.toggleIssue(issue),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCalculateButton(AdvisoryController controller) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: controller.isCalculating
            ? null
            : controller.calculateAdvisory,
        child: const Text(
          "Calculate Advice",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(AdvisoryResponse result) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(thickness: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text(
                "Your Advisory Plan",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (result.rainWarning)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Rain expected! Consider delaying fertilizer application.",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Recommendations List
          ...result.recommendations.map((rec) => _buildFertilizerCard(rec)),

          const SizedBox(height: 16),
          _buildInfoCard("Irrigation", result.irrigationAdvice, Icons.water),

          if (result.micronutrients.isNotEmpty)
            _buildListCard(
              "Micronutrients",
              result.micronutrients,
              Icons.science,
            ),

          if (result.organicAlternatives.isNotEmpty)
            _buildListCard(
              "Organic Alternatives",
              result.organicAlternatives,
              Icons.eco,
            ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              "Total Est. Cost: ₹${result.estimatedCost.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerCard(FertilizerRecommendation rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  rec.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rec.npkRatio,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildDetailRow(
            "Quantity",
            "${rec.totalQuantity.toStringAsFixed(1)} kg (${rec.quantityPerAcre.toStringAsFixed(1)} kg/acre)",
          ),
          _buildDetailRow("Method", rec.applicationMethod),
          _buildDetailRow("Timing", rec.applicationTime),
          const SizedBox(height: 8),
          const Text(
            "Precautions:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          ...rec.precautions.map(
            (p) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(content, style: TextStyle(color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List<String> items, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...items.map(
            (i) => Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Text("• $i"),
            ),
          ),
        ],
      ),
    );
  }
}
