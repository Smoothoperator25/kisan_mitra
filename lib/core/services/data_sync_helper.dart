/// Easy-to-use initialization helper for data synchronization
///
/// Usage in main.dart or app initialization:
/// ```dart
/// await DataSyncHelper.ensureDataIntegrity();
/// ```

import 'package:flutter/material.dart';
import 'data_repair_service.dart';

class DataSyncHelper {
  static final DataSyncHelper _instance = DataSyncHelper._internal();

  factory DataSyncHelper() {
    return _instance;
  }

  DataSyncHelper._internal();

  final DataRepairService _repairService = DataRepairService();
  bool _hasCheckedIntegrity = false;

  /// Check and automatically repair data integrity if needed
  /// Safe to call multiple times (only runs once per app session)
  /// Returns true if repair was needed and completed
  Future<bool> ensureDataIntegrity({
    bool forceRepair = false,
    bool silent = true,
  }) async {
    if (_hasCheckedIntegrity && !forceRepair) {
      print('Data integrity check already completed this session');
      return false;
    }

    try {
      if (!silent) {
        debugPrint('🔍 Checking data synchronization status...');
      }

      final stats = await _repairService.getDataSyncStats();

      final unlinkedCount = stats['unlinkedStoresCount'] ?? 0;
      final totalStores = stats['totalVerifiedStores'] ?? 0;
      final avgLinks = stats['averageLinksPerStore'] ?? 0.0;

      if (!silent) {
        debugPrint(
          '📊 Sync Status: $unlinkedCount/$totalStores stores unlinked, '
          'Avg $avgLinks links per store',
        );
      }

      // If significant mismatch detected, repair
      if (unlinkedCount > 0 || forceRepair) {
        if (!silent) {
          debugPrint('🔧 Running data repair...');
        }

        final repairResult = await _repairService.syncAllFertilizersToStores();

        _hasCheckedIntegrity = true;

        if (repairResult['success'] == true) {
          if (!silent) {
            debugPrint(
              '✅ Data repair successful! '
              'Added: ${repairResult['totalAdded'] ?? 0} entries',
            );
          }
          return true;
        } else {
          if (!silent) {
            debugPrint(
              '❌ Data repair failed: ${repairResult['message']}',
            );
          }
          return false;
        }
      } else {
        if (!silent) {
          debugPrint('✅ Data integrity verified, no repairs needed');
        }
        _hasCheckedIntegrity = true;
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ Error during data integrity check: $e');
      return false;
    }
  }

  /// Get current data synchronization statistics
  /// Useful for admin dashboards to show data health
  Future<Map<String, dynamic>> getDataStatus() async {
    try {
      return await _repairService.getDataSyncStats();
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Manually trigger a repair without checking first
  Future<bool> repairNow() async {
    try {
      print('🔧 Starting manual data repair...');
      final result = await _repairService.syncAllFertilizersToStores();

      _hasCheckedIntegrity = true;

      if (result['success'] == true) {
        print('✅ Repair completed: ${result['message']}');
        return true;
      } else {
        print('❌ Repair failed: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error during repair: $e');
      return false;
    }
  }

  /// Reset the integrity check flag (useful for testing)
  void resetIntegrityCheck() {
    _hasCheckedIntegrity = false;
  }
}

/// Convenience function - can be called directly in main()
Future<void> initializeDataSync({bool verbose = false}) async {
  await DataSyncHelper().ensureDataIntegrity(silent: !verbose);
}

