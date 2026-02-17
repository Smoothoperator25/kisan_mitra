import 'package:flutter/material.dart';
import '../services/data_repair_service.dart';

/// Dialog to show data repair options and run repair if needed
class DataRepairDialog extends StatefulWidget {
  const DataRepairDialog({super.key});

  @override
  State<DataRepairDialog> createState() => _DataRepairDialogState();
}

class _DataRepairDialogState extends State<DataRepairDialog> {
  late DataRepairService _dataRepairService;
  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  String? _repairMessage;

  @override
  void initState() {
    super.initState();
    _dataRepairService = DataRepairService();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _dataRepairService.getDataSyncStats();
      setState(() => _stats = stats);
    } catch (e) {
      setState(() => _repairMessage = 'Error loading stats: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runRepair() async {
    setState(() => _isLoading = true);
    try {
      final result = await _dataRepairService.syncAllFertilizersToStores();
      setState(() {
        _repairMessage = result['message'] ?? 'Repair completed';
        _stats = null; // Reset stats to reload
      });
      await _loadStats();
    } catch (e) {
      setState(() => _repairMessage = 'Error during repair: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Data Repair & Synchronization'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_stats != null) ...[
              _buildStatRow('Total Verified Stores', _stats!['totalVerifiedStores'] ?? 0),
              _buildStatRow('Store-Fertilizer Links', _stats!['totalStoreFertilizerLinks'] ?? 0),
              _buildStatRow('Unlinked Stores', _stats!['unlinkedStoresCount'] ?? 0),
              _buildStatRow('Unused Fertilizers', _stats!['unusedFertilizersCount'] ?? 0),
              const SizedBox(height: 12),
              Text(
                'Average Links: ${(_stats!['averageLinksPerStore'] ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (_repairMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _repairMessage!.contains('Error') ? Colors.red.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _repairMessage!,
                  style: TextStyle(
                    color: _repairMessage!.contains('Error') ? Colors.red : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (_stats != null && (_stats!['unlinkedStoresCount'] ?? 0) > 0)
          ElevatedButton(
            onPressed: _isLoading ? null : _runRepair,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Run Repair'),
          ),
      ],
    );
  }

  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Convenience function to show the repair dialog
void showDataRepairDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const DataRepairDialog(),
  );
}

