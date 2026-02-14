import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/admin_data_model.dart';
import 'admin_stores_controller.dart';
import 'admin_store_details_screen.dart';

class AdminStoresListScreen extends StatefulWidget {
  const AdminStoresListScreen({super.key});

  @override
  State<AdminStoresListScreen> createState() => _AdminStoresListScreenState();
}

class _AdminStoresListScreenState extends State<AdminStoresListScreen> {
  final AdminStoresController _controller = AdminStoresController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, verified, pending, rejected
  Map<String, int> _stats = {
    'total': 0,
    'verified': 0,
    'pending': 0,
    'rejected': 0,
  };
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _controller.getStoreStats();
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

  List<StoreData> _filterStores(List<StoreData> stores) {
    var filtered = stores;

    // Apply status filter
    if (_filterStatus == 'verified') {
      filtered = filtered.where((s) => s.isVerified).toList();
    } else if (_filterStatus == 'pending') {
      filtered = filtered.where((s) => s.isPending).toList();
    } else if (_filterStatus == 'rejected') {
      filtered = filtered.where((s) => s.isRejected).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = _controller.searchStores(_searchQuery, filtered);
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Manage Stores'),
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

          // Stores List
          Expanded(
            child: StreamBuilder<List<StoreData>>(
              stream: _controller.getStoresStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stores = snapshot.data ?? [];
                final filteredStores = _filterStores(stores);

                if (filteredStores.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _loadStats,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredStores.length,
                    itemBuilder: (context, index) {
                      return _buildStoreCard(filteredStores[index]);
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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: _isLoadingStats
          ? const Center(
              child: SizedBox(
                height: 40,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        _stats['total'].toString(),
                        Icons.store,
                        Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Verified',
                        _stats['verified'].toString(),
                        Icons.verified,
                        Colors.lightGreen[100]!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        _stats['pending'].toString(),
                        Icons.pending,
                        Colors.orange[100]!,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Rejected',
                        _stats['rejected'].toString(),
                        Icons.cancel,
                        Colors.red[100]!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 18),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
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
              hintText: 'Search by store name, owner, phone, city...',
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
                      _buildFilterChip('Verified', 'verified'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', 'pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Rejected', 'rejected'),
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

  Widget _buildStoreCard(StoreData store) {
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    if (store.isRejected) {
      statusColor = Colors.red[800]!;
      statusBgColor = Colors.red[50]!;
      statusIcon = Icons.cancel;
    } else if (store.isVerified) {
      statusColor = Colors.green[800]!;
      statusBgColor = Colors.green[50]!;
      statusIcon = Icons.verified;
    } else {
      statusColor = Colors.orange[800]!;
      statusBgColor = Colors.orange[50]!;
      statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminStoreDetailsScreen(store: store),
            ),
          );
          if (result == true) {
            _loadStats();
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
                      store.storeName.isNotEmpty
                          ? store.storeName[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Store Name and Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.storeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                store.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
                Icons.person,
                store.ownerName.isEmpty ? 'No owner' : store.ownerName,
              ),
              const SizedBox(height: 8),
              _buildInfoRowSmall(
                Icons.phone,
                store.phone.isEmpty ? 'No phone' : store.phone,
              ),
              const SizedBox(height: 8),
              _buildInfoRowSmall(
                Icons.location_on,
                store.location.isEmpty ? 'No location' : store.location,
              ),
              const SizedBox(height: 8),
              _buildInfoRowSmall(
                Icons.calendar_today,
                'Registered ${DateFormat('MMM dd, yyyy').format(store.createdAt)}',
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
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.store_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No stores found'
                : 'No stores registered yet',
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
                : 'Stores will appear here once they register',
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
              'Error loading stores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
