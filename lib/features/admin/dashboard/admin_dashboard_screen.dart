import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'admin_dashboard_controller.dart';
import 'admin_dashboard_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminDashboardController _controller = AdminDashboardController();
  int _currentTabIndex = 0;
  List<VerificationRequest> _verificationRequests = [];
  bool _isLoadingRequests = true;

  @override
  void initState() {
    super.initState();
    _loadVerificationRequests();
  }

  Future<void> _loadVerificationRequests() async {
    try {
      final requests = await _controller.getVerificationRequests();
      if (mounted) {
        setState(() {
          _verificationRequests = requests;
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRequests = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading requests: $e')));
      }
    }
  }

  Future<void> _handleApprove(String storeId, String storeName) async {
    try {
      await _controller.approveStore(storeId, storeName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Store approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadVerificationRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error approving store: $e')));
      }
    }
  }

  Future<void> _handleReject(String storeId, String storeName) async {
    try {
      await _controller.rejectStore(storeId, storeName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Store rejected'),
            backgroundColor: Colors.red,
          ),
        );
        _loadVerificationRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error rejecting store: $e')));
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _controller.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/admin-login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F1F4),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildDashboardTab(),
          _buildPlaceholderTab('Requests'),
          _buildPlaceholderTab('Data'),
          _buildPlaceholderTab('Settings'),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildDashboardTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatisticsCards(),
            const SizedBox(height: 24),
            _buildVerificationRequestsSection(),
            const SizedBox(height: 24),
            _buildDataManagementSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '$title Screen',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Coming soon...'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'SECURE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications_outlined, size: 20),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return StreamBuilder<DashboardStats>(
      stream: _controller.getStatsStream(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? DashboardStats.empty();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'TOTAL FARMERS',
                    stats.totalFarmers.toString(),
                    const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'TOTAL STORES',
                    stats.totalStores.toString(),
                    const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'PENDING',
                    stats.pendingVerifications.toString(),
                    const Color(0xFFFF6B35),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'VERIFIED',
                    stats.verifiedStores.toString(),
                    const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VERIFICATION REQUESTS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingRequests)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_verificationRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('No pending verification requests'),
            ),
          )
        else
          ..._verificationRequests.map(
            (request) => _buildVerificationRequestCard(request),
          ),
      ],
    );
  }

  Widget _buildVerificationRequestCard(VerificationRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.storeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(request.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Owner: ${request.ownerName}',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                request.location,
                style: TextStyle(fontSize: 13, color: const Color(0xFF6366F1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _handleApprove(request.id, request.storeName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'APPROVE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleReject(request.id, request.storeName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'REJECT',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/admin-store-details',
                      arguments: request.id,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'DETAILS',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATA MANAGEMENT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildManagementTile(
          icon: Icons.people,
          title: 'Manage Farmers',
          onTap: () => Navigator.pushNamed(context, '/admin-farmers-list'),
        ),
        _buildManagementTile(
          icon: Icons.store,
          title: 'Manage Stores',
          onTap: () => Navigator.pushNamed(context, '/admin-stores-list'),
        ),
        _buildManagementTile(
          icon: Icons.assessment,
          title: 'Reports',
          onTap: () => Navigator.pushNamed(context, '/admin-reports'),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildManagementTile(
          icon: Icons.history,
          title: 'Activity Log',
          onTap: () => Navigator.pushNamed(context, '/admin-activity-log'),
        ),
        _buildManagementTile(
          icon: Icons.logout,
          title: 'Logout',
          titleColor: const Color(0xFFEF4444),
          onTap: _handleLogout,
        ),
      ],
    );
  }

  Widget _buildManagementTile({
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: titleColor ?? const Color(0xFF1E293B),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: titleColor ?? const Color(0xFF1E293B),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                icon: Icons.dashboard,
                label: 'DASHBOARD',
                index: 0,
              ),
              _buildBottomNavItem(
                icon: Icons.calendar_today,
                label: 'REQUESTS',
                index: 1,
              ),
              _buildBottomNavItem(icon: Icons.storage, label: 'DATA', index: 2),
              _buildBottomNavItem(
                icon: Icons.settings,
                label: 'SETTINGS',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? const Color(0xFF10B981) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF10B981) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
