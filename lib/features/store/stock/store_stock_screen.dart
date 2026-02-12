import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store_stock_controller.dart';
import 'store_stock_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

/// Store Stock Management Screen
/// Allows store owners to manage fertilizer prices, stock, and availability
class StoreStockScreen extends StatelessWidget {
  const StoreStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreStockController(),
      child: const _StockScreenContent(),
    );
  }
}

class _StockScreenContent extends StatelessWidget {
  const _StockScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light mint green background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Search Bar
            _buildSearchBar(context),

            const SizedBox(height: 16),

            // Filter Tabs
            _buildFilterTabs(context),

            const SizedBox(height: 16),

            // Item Count and List
            Expanded(child: _buildFertilizerList(context)),

            // Bottom Action Buttons
            _buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  /// Header with back button, title, and store name
  Widget _buildHeader(BuildContext context) {
    return FutureBuilder<String>(
      future: _getStoreName(),
      builder: (context, snapshot) {
        final storeName = snapshot.data ?? 'Loading...';

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    // Just switch tab, don't pop - bottom nav will handle it
                    // This back button is mainly for visual consistency with the design
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Title and Store Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Stock & Price',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Search Bar
  Widget _buildSearchBar(BuildContext context) {
    final controller = Provider.of<StoreStockController>(
      context,
      listen: false,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search fertilizer name...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Filter Tabs (All, In Stock, Out of Stock)
  Widget _buildFilterTabs(BuildContext context) {
    final controller = Provider.of<StoreStockController>(context);
    final filters = ['All', 'In Stock', 'Out of Stock'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = controller.selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => controller.updateFilter(filter),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Fertilizer List with StreamBuilder
  Widget _buildFertilizerList(BuildContext context) {
    final controller = Provider.of<StoreStockController>(context);

    return StreamBuilder<List<StockFertilizer>>(
      stream: controller.getStoreFertilizersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading inventory: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final allFertilizers = snapshot.data ?? [];
        final filteredFertilizers = controller.filterFertilizers(
          allFertilizers,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Count and Info Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Only price and stock can be updated',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    '${filteredFertilizers.length} ITEMS FOUND',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Fertilizer Cards List
            Expanded(
              child: filteredFertilizers.isEmpty
                  ? const Center(
                      child: Text(
                        'No fertilizers found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredFertilizers.length,
                      itemBuilder: (context, index) {
                        return _FertilizerCard(
                          fertilizer: filteredFertilizers[index],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Bottom Action Buttons (Update All Changes, Reset)
  Widget _buildBottomActions(BuildContext context) {
    final controller = Provider.of<StoreStockController>(context);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Update All Changes Button
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: controller.hasModifications
                    ? () => _handleBatchUpdate(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Update All Changes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Reset Button
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: controller.hasModifications
                    ? () => _handleReset(context)
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  disabledForegroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle batch update
  Future<void> _handleBatchUpdate(BuildContext context) async {
    final controller = Provider.of<StoreStockController>(
      context,
      listen: false,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final result = await controller.batchUpdateAllChanges();

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Updated'),
          backgroundColor: result['success'] == true
              ? Colors.green
              : Colors.red,
        ),
      );
    }
  }

  /// Handle reset
  void _handleReset(BuildContext context) {
    final controller = Provider.of<StoreStockController>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Changes?'),
        content: const Text('All unsaved changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.resetChanges();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Changes reset'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Get store name from Firestore
  Future<String> _getStoreName() async {
    try {
      final authService = AuthService();
      final firestoreService = FirestoreService();
      final uid = authService.currentUserId;

      if (uid == null) return '';

      final result = await firestoreService.getDocument(
        collection: 'stores',
        docId: uid,
      );

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>?;
        return data?['storeName'] as String? ?? '';
      }
    } catch (e) {
      debugPrint('Error fetching store name: $e');
    }
    return '';
  }
}

/// Fertilizer Card with editable fields
class _FertilizerCard extends StatefulWidget {
  final StockFertilizer fertilizer;

  const _FertilizerCard({required this.fertilizer});

  @override
  State<_FertilizerCard> createState() => _FertilizerCardState();
}

class _FertilizerCardState extends State<_FertilizerCard> {
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late bool _isAvailable;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.fertilizer.price.toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: widget.fertilizer.stock.toString(),
    );
    _isAvailable = widget.fertilizer.isAvailable;

    // Listen to changes to track modifications
    _priceController.addListener(_onFieldChanged);
    _stockController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  /// Track when fields are modified
  void _onFieldChanged() {
    final controller = Provider.of<StoreStockController>(
      context,
      listen: false,
    );

    final price =
        double.tryParse(_priceController.text) ?? widget.fertilizer.price;
    final stock =
        int.tryParse(_stockController.text) ?? widget.fertilizer.stock;

    // Check if values have changed
    if (price != widget.fertilizer.price ||
        stock != widget.fertilizer.stock ||
        _isAvailable != widget.fertilizer.isAvailable) {
      // Track as modified
      controller.trackModifiedItem(
        widget.fertilizer.copyWith(
          price: price,
          stock: stock,
          isAvailable: _isAvailable,
          isModified: true,
        ),
      );
    } else {
      // Remove from modified if reverted to original
      controller.untrackModifiedItem(widget.fertilizer.id);
    }
  }

  /// Handle individual save
  Future<void> _handleSave() async {
    final controller = Provider.of<StoreStockController>(
      context,
      listen: false,
    );

    final price = double.tryParse(_priceController.text);
    final stock = int.tryParse(_stockController.text);

    if (price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final result = await controller.updateSingleFertilizer(
      id: widget.fertilizer.id,
      price: price,
      stock: stock,
      isAvailable: _isAvailable,
    );

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Updated'),
          backgroundColor: result['success'] == true
              ? Colors.green
              : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Icon, Name, Save Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fertilizer Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.science_outlined,
                  size: 28,
                  color: Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(width: 12),

              // Fertilizer Name and NPK
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fertilizer.fertilizerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.fertilizer.bagWeight,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price and Stock Inputs
          Row(
            children: [
              // Price Input
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRICE (₹)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Stock Input
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STOCK QUANTITY',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Available for Sale Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available for Sale',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Switch(
                value: _isAvailable,
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                  _onFieldChanged(); // Track modification
                },
                activeColor: const Color(0xFF2E7D32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
