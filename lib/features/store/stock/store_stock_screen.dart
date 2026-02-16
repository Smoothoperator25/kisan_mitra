import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store_stock_controller.dart';
import 'store_stock_model.dart';
import '../../../core/services/auth_service.dart';
import 'fertilizer_details_screen.dart';
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

class _StockScreenContent extends StatefulWidget {
  const _StockScreenContent();

  @override
  State<_StockScreenContent> createState() => _StockScreenContentState();
}

class _StockScreenContentState extends State<_StockScreenContent> {
  @override
  void initState() {
    super.initState();
    // Clean up duplicates when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<StoreStockController>(
        context,
        listen: false,
      );
      controller.removeDuplicateFertilizers();
    });
  }

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

            const SizedBox(height: 12),

            // Filter Tabs
            _buildFilterTabs(context),

            const SizedBox(height: 12),

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
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              const SizedBox(width: 10),

              // Title and Store Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Stock & Price',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

    return StreamBuilder<List<StockFertilizer>>(
      stream: controller.getStoreFertilizersStream(),
      builder: (context, snapshot) {
        final allFertilizers = snapshot.data ?? [];

        // Calculate counts for each filter
        final totalCount = allFertilizers.length;
        final inStockCount = allFertilizers
            .where((f) => f.stock > 0 && f.isAvailable)
            .length;
        final outOfStockCount = allFertilizers
            .where((f) => f.stock <= 0 || !f.isAvailable)
            .length;

        final filters = [
          {'label': 'All', 'count': totalCount},
          {'label': 'In Stock', 'count': inStockCount},
          {'label': 'Out of Stock', 'count': outOfStockCount},
        ];

        return SizedBox(
          height: 42,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: filters.map((filter) {
              final label = filter['label'] as String;
              final count = filter['count'] as int;
              final isSelected = controller.selectedFilter == label;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => controller.updateFilter(label),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.3)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
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
                          // Use composite key with reset version to force rebuild
                          key: ValueKey(
                            '${filteredFertilizers[index].id}_${controller.resetVersion}',
                          ),
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

  const _FertilizerCard({super.key, required this.fertilizer});

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
  void didUpdateWidget(_FertilizerCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset controllers if fertilizer data changed (e.g., after reset)
    // Check if the fertilizer's original values changed
    if (oldWidget.fertilizer.price != widget.fertilizer.price ||
        oldWidget.fertilizer.stock != widget.fertilizer.stock ||
        oldWidget.fertilizer.isAvailable != widget.fertilizer.isAvailable) {
      // Remove listeners to prevent triggering onChange while updating
      _priceController.removeListener(_onFieldChanged);
      _stockController.removeListener(_onFieldChanged);

      // Update controller values
      _priceController.text = widget.fertilizer.price.toStringAsFixed(0);
      _stockController.text = widget.fertilizer.stock.toString();

      // Update availability state
      setState(() {
        _isAvailable = widget.fertilizer.isAvailable;
      });

      // Re-add listeners
      _priceController.addListener(_onFieldChanged);
      _stockController.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    _priceController.removeListener(_onFieldChanged);
    _stockController.removeListener(_onFieldChanged);
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
    // Determine stock status
    final currentStock =
        int.tryParse(_stockController.text) ?? widget.fertilizer.stock;
    final isInStock = currentStock > 0 && _isAvailable;
    final isLowStock = currentStock > 0 && currentStock <= 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInStock
              ? (isLowStock ? Colors.orange.shade100 : const Color(0xFFE8F5E9))
              : Colors.red.shade100,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.06 * 255).toInt()),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Gradient
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFE8F5E9), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fertilizer Icon with gradient
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF2E7D32,
                        ).withAlpha((0.3 * 255).toInt()),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.eco, size: 24, color: Colors.white),
                ),

                const SizedBox(width: 12),

                // Fertilizer Name & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fertilizer Name
                      Text(
                        widget.fertilizer.fertilizerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E20),
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 10),

                      // Info Badges: NPK, Form, Category, Manufacturer
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          // NPK Badge
                          if (widget.fertilizer.npkComposition != null &&
                              widget.fertilizer.npkComposition!.isNotEmpty)
                            _buildInfoChip(
                              icon: Icons.analytics_outlined,
                              label: widget.fertilizer.npkComposition!,
                              color: const Color(0xFF0288D1),
                            ),

                          // Form Badge
                          if (widget.fertilizer.form != null &&
                              widget.fertilizer.form!.isNotEmpty)
                            _buildInfoChip(
                              icon: Icons.grain_outlined,
                              label: widget.fertilizer.form!,
                              color: const Color(0xFF1976D2),
                            ),

                          // Category Badge
                          if (widget.fertilizer.category != null &&
                              widget.fertilizer.category!.isNotEmpty)
                            _buildInfoChip(
                              icon: Icons.category_outlined,
                              label: widget.fertilizer.category!,
                              color: const Color(0xFF7B1FA2),
                            ),

                          // Manufacturer Badge
                          if (widget.fertilizer.manufacturer != null &&
                              widget.fertilizer.manufacturer!.isNotEmpty)
                            _buildInfoChip(
                              icon: Icons.business_outlined,
                              label: widget.fertilizer.manufacturer!,
                              color: const Color(0xFFE65100),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Stock Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isInStock
                                ? (isLowStock
                                      ? [
                                          Colors.orange.shade400,
                                          Colors.orange.shade600,
                                        ]
                                      : [
                                          const Color(0xFF66BB6A),
                                          const Color(0xFF2E7D32),
                                        ])
                                : [Colors.red.shade400, Colors.red.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isInStock
                                          ? (isLowStock
                                                ? Colors.orange.shade300
                                                : const Color(0xFF2E7D32))
                                          : Colors.red.shade300)
                                      .withAlpha((0.4 * 255).toInt()),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isInStock
                                  ? (isLowStock
                                        ? Icons.warning_rounded
                                        : Icons.check_circle_rounded)
                                  : Icons.cancel_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isInStock
                                  ? (isLowStock ? 'LOW STOCK' : 'IN STOCK')
                                  : 'OUT OF STOCK',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Price and Stock Inputs
                Row(
                  children: [
                    // Price Input
                    Expanded(
                      child: _buildInputField(
                        controller: _priceController,
                        label: 'PRICE',
                        icon: Icons.currency_rupee_rounded,
                        color: const Color(0xFF1976D2),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Stock Input
                    Expanded(
                      child: _buildInputField(
                        controller: _stockController,
                        label: 'STOCK (BAGS)',
                        icon: Icons.inventory_2_rounded,
                        color: const Color(0xFF388E3C),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Available for Sale Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available for Sale',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                          });
                          _onFieldChanged(); // Track modification
                        },
                        activeTrackColor: const Color(0xFF2E7D32),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action Buttons Row
                Row(
                  children: [
                    // View Details Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FertilizerDetailsScreen(
                                fertilizerId: widget.fertilizer.fertilizerId,
                                fertilizerName:
                                    widget.fertilizer.fertilizerName,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline_rounded, size: 16),
                        label: const Text(
                          'DETAILS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          side: const BorderSide(
                            color: Color(0xFF2E7D32),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Save Button with gradient
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: _isSaving
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF2E7D32),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _isSaving
                              ? null
                              : [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2E7D32,
                                    ).withAlpha((0.4 * 255).toInt()),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSaving
                                ? Colors.grey.shade300
                                : Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.save_rounded, size: 16),
                          label: Text(
                            _isSaving ? 'SAVING...' : 'SAVE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: _isSaving
                                  ? Colors.grey.shade600
                                  : Colors.white,
                            ),
                          ),
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
    );
  }

  // Helper method to build consistent input fields
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with icon
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        // Input field with enhanced styling
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.04 * 255).toInt()),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: (_) => _onFieldChanged(),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: color, width: 2.5),
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build info chips
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: color.withAlpha((0.3 * 255).toInt()),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
