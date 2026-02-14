import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../dashboard/admin_dashboard_controller.dart';
import '../dashboard/admin_dashboard_model.dart';
import '../data/admin_data_model.dart';
import '../stores/admin_stores_controller.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final AdminDashboardController _dashboardController = AdminDashboardController();
  final AdminStoresController _storesController = AdminStoresController();

  Future<void> _handleRefresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F1F4),
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: const Color(0xFF10B981),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatsStream(),
            const SizedBox(height: 16),
            _buildRecentStores(),
            const SizedBox(height: 16),
            _buildHealthNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsStream() {
    return StreamBuilder<DashboardStats>(
      stream: _dashboardController.getStatsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorCard('Error loading reports', snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final stats = snapshot.data!;
        final totalStores = stats.totalStores;
        final approvalRate = totalStores == 0
            ? 0
            : ((stats.verifiedStores / totalStores) * 100).round();
        final pendingRate = totalStores == 0
            ? 0
            : ((stats.pendingVerifications / totalStores) * 100).round();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Icon(Icons.assessment, color: Color(0xFF10B981)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatCard(
                  label: 'Farmers',
                  value: stats.totalFarmers,
                  icon: Icons.agriculture,
                  color: Colors.white,
                ),
                _buildStatCard(
                  label: 'Stores',
                  value: stats.totalStores,
                  icon: Icons.store,
                  color: Colors.white,
                ),
                _buildStatCard(
                  label: 'Verified',
                  value: stats.verifiedStores,
                  icon: Icons.verified,
                  color: Colors.white,
                  iconColor: Colors.green[700],
                ),
                _buildStatCard(
                  label: 'Pending',
                  value: stats.pendingVerifications,
                  icon: Icons.pending_actions,
                  color: Colors.white,
                  iconColor: Colors.orange[700],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightRow(
              approvalRate: approvalRate,
              pendingRate: pendingRate,
              totalStores: totalStores,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    Color? iconColor,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Card(
        color: color,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                foregroundColor: iconColor ?? const Color(0xFF10B981),
                child: Icon(icon, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightRow({required int approvalRate, required int pendingRate, required int totalStores}) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Store Approval Rate',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$approvalRate%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalStores stores tracked',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.timer, color: Color(0xFF10B981), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Pending Load',
                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$pendingRate% of stores waiting',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Act on pending stores to improve approvals.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentStores() {
    return StreamBuilder<List<StoreData>>(
      stream: _storesController.getStoresStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorCard('Error loading stores', snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final stores = snapshot.data!.take(6).toList();
        if (stores.isEmpty) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No stores available yet',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        }

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Store Activity',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/admin-stores-list'),
                      child: const Text('View all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...stores.map((store) => _buildStoreTile(store)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreTile(StoreData store) {
    Color statusColor;
    IconData statusIcon;

    if (store.isRejected) {
      statusColor = Colors.red[700]!;
      statusIcon = Icons.cancel;
    } else if (store.isVerified) {
      statusColor = Colors.green[700]!;
      statusIcon = Icons.verified;
    } else {
      statusColor = Colors.orange[800]!;
      statusIcon = Icons.pending_actions;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
        foregroundColor: const Color(0xFF10B981),
        child: Text(
          store.storeName.isNotEmpty ? store.storeName[0].toUpperCase() : 'S',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(store.storeName, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('${store.city}, ${store.state}\n${DateFormat('MMM d, yyyy').format(store.createdAt)}'),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 6),
          Text(
            store.status,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthNotes() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionChip(
                  label: 'Manage Stores',
                  icon: Icons.store,
                  onTap: () => Navigator.pushNamed(context, '/admin-stores-list'),
                ),
                _buildActionChip(
                  label: 'Manage Farmers',
                  icon: Icons.people,
                  onTap: () => Navigator.pushNamed(context, '/admin-farmers-list'),
                ),
                _buildActionChip(
                  label: 'View Activity',
                  icon: Icons.history,
                  onTap: () => Navigator.pushNamed(context, '/admin-activity-log'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip({required String label, required IconData icon, required VoidCallback onTap}) {
    return ActionChip(
      avatar: Icon(icon, color: const Color(0xFF10B981), size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onPressed: onTap,
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildErrorCard(String title, String details) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text(details, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {}),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
