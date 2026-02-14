import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/admin_data_model.dart';
import 'admin_farmers_controller.dart';
import 'admin_farmer_details_screen.dart';

class AdminFarmersListScreen extends StatefulWidget {
  const AdminFarmersListScreen({super.key});

  @override
  State<AdminFarmersListScreen> createState() => _AdminFarmersListScreenState();
}

class _AdminFarmersListScreenState extends State<AdminFarmersListScreen> {
  final AdminFarmersController _controller = AdminFarmersController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, inactive
  Map<String, int> _stats = {'total': 0, 'active': 0, 'inactive': 0};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _controller.getFarmerStats();
    setState(() {
      _stats = stats;
      _isLoadingStats = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FarmerData> _filterFarmers(List<FarmerData> farmers) {
    var filtered = farmers;

    // Apply status filter
    if (_filterStatus == 'active') {
      filtered = filtered.where((f) => f.isActive).toList();
    } else if (_filterStatus == 'inactive') {
      filtered = filtered.where((f) => !f.isActive).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = _controller.searchFarmers(_searchQuery, filtered);
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Farmers'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          _buildStatsSection(),

          // Search and Filter
          _buildSearchAndFilter(),

          // Farmers List
          Expanded(
            child: StreamBuilder<List<FarmerData>>(
              stream: _controller.getFarmersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final farmers = snapshot.data ?? [];
                final filteredFarmers = _filterFarmers(farmers);

                if (filteredFarmers.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _loadStats,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredFarmers.length,
                    itemBuilder: (context, index) {
                      return _buildFarmerCard(filteredFarmers[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: _isLoadingStats
          ? const Center(
              child: SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _stats['total'].toString(),
                    Icons.people,
                    Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    _stats['active'].toString(),
                    Icons.check_circle,
                    Colors.lightGreen[100]!,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Inactive',
                    _stats['inactive'].toString(),
                    Icons.block,
                    Colors.orange[100]!,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by name, phone, city, or state...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          Row(
            children: [
              const Text(
                'Filter: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active', 'active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Inactive', 'inactive'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: const Color(0xFF10B981),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF10B981) : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildFarmerCard(FarmerData farmer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminFarmerDetailsScreen(farmer: farmer),
            ),
          );
          if (result == true) {
            _loadStats(); // Refresh stats if changes were made
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: const Color(0xFF10B981),
                    radius: 24,
                    child: Text(
                      farmer.name.isNotEmpty ? farmer.name[0].toUpperCase() : 'F',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: farmer.isActive
                                    ? Colors.green[50]
                                    : Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    farmer.isActive ? Icons.check_circle : Icons.block,
                                    size: 12,
                                    color: farmer.isActive ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    farmer.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: farmer.isActive
                                          ? Colors.green[800]
                                          : Colors.orange[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Info Rows
              _buildInfoRowSmall(
                Icons.phone,
                farmer.phone.isEmpty ? 'No phone' : farmer.phone,
              ),
              const SizedBox(height: 8),
              _buildInfoRowSmall(
                Icons.location_on,
                farmer.location.isEmpty ? 'No location' : farmer.location,
              ),
              const SizedBox(height: 8),
              _buildInfoRowSmall(
                Icons.grass,
                farmer.crops.isEmpty
                    ? 'No crops'
                    : '${farmer.crops.length} crop(s)',
              ),
              const SizedBox(height: 8),
              _buildInfoRowSmall(
                Icons.calendar_today,
                'Joined ${DateFormat('MMM dd, yyyy').format(farmer.createdAt)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRowSmall(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No farmers found'
                : 'No farmers registered yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Farmers will appear here once they register',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading farmers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
