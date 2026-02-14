import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'advisory_result_controller.dart';
import '../data/models/advisory_model.dart';

class AdvisoryResultScreen extends StatelessWidget {
  const AdvisoryResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdvisoryResultController(),
      child: const _AdvisoryResultView(),
    );
  }
}

class _AdvisoryResultView extends StatelessWidget {
  const _AdvisoryResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AdvisoryResultController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text(
          'Precision Advisory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Modify Conditions',
            onPressed: () => _showEditConditionsDialog(context, controller),
          ),
        ],
      ),
      body: controller.isLoading && controller.recommendations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : controller.errorMessage != null
          ? Center(child: Text(controller.errorMessage!))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.recommendations.length,
              itemBuilder: (context, index) {
                final rec = controller.recommendations[index];
                return _buildFertilizerCard(rec);
              },
            ),
    );
  }

  Widget _buildFertilizerCard(FertilizerRecommendation rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small Image Thumbnail as requested
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    rec.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.broken_image,
                        size: 24,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and NPK
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              rec.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50], // Light green bg
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              rec.npkRatio,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow(
                  'Quantity',
                  '${rec.totalQuantity} kg (${rec.quantityPerAcre} kg/acre)',
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Method', rec.applicationMethod),
                const SizedBox(height: 8),
                _buildDetailRow('Timing', rec.applicationTime),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Precautions:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ...rec.precautions.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    );
  }

  void _showEditConditionsDialog(
    BuildContext context,
    AdvisoryResultController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Conditions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Crop Dropdown
              DropdownButtonFormField<String>(
                value: controller.inputs['crop'],
                decoration: const InputDecoration(labelText: 'Crop'),
                items: ['Wheat', 'Rice', 'Corn', 'Potato', 'Sugarcane']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.updateInput('crop', val);
                },
              ),
              const SizedBox(height: 12),
              // Field Size Slider
              Text('Field Size: ${controller.inputs['field_size']} acres'),
              Slider(
                value: (controller.inputs['field_size'] as num).toDouble(),
                min: 1.0,
                max: 20.0,
                divisions: 19,
                label: '${controller.inputs['field_size']} acres',
                onChanged: (val) {
                  controller.updateInput('field_size', val);
                },
              ),
              const SizedBox(height: 12),
              // Soil K
              TextFormField(
                initialValue: controller.inputs['soil_potassium'].toString(),
                decoration: const InputDecoration(
                  labelText: 'Soil Potassium (kg/ha)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final numVal = double.tryParse(val);
                  if (numVal != null)
                    controller.updateInput('soil_potassium', numVal);
                },
              ),
              const SizedBox(height: 12),
              // Weather (Mock dropdown)
              DropdownButtonFormField<String>(
                value:
                    controller.inputs['weather_data'].toString().contains(
                      'Rain',
                    )
                    ? 'Rain Expected'
                    : 'Clear',
                decoration: const InputDecoration(
                  labelText: 'Weather Forecast',
                ),
                items: ['Clear', 'Rain Expected']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.updateInput('weather_data', val);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
