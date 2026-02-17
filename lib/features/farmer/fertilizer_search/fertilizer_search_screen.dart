import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../profile/profile_controller.dart';
import 'fertilizer_search_controller.dart';
import 'fertilizer_search_model.dart';
import '../../../core/utils/app_theme.dart';
import 'package:latlong2/latlong.dart' as ll;

class FertilizerSearchScreen extends StatefulWidget {
  const FertilizerSearchScreen({super.key});

  @override
  State<FertilizerSearchScreen> createState() => _FertilizerSearchScreenState();
}

class _FertilizerSearchScreenState extends State<FertilizerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;
  CircleAnnotationManager? _circleAnnotationManager;

  late final FertilizerSearchController _controller;

  // For overlay
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // Track last shown error to prevent duplicate SnackBars
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    _controller = FertilizerSearchController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize();
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isNotEmpty) {
      _controller.filterSuggestions(_searchController.text);
      if (_controller.suggestions.isNotEmpty) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32, // Match padding
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 50.0), // Height of text field + padding
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ChangeNotifierProvider.value(
              value: _controller,
              child: Consumer<FertilizerSearchController>(
                builder: (context, controller, child) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: controller.suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = controller.suggestions[index];
                      return ListTile(
                        title: Text(suggestion.name),
                        onTap: () {
                          _searchController.text = suggestion.name;
                          _removeOverlay();
                          FocusScope.of(context).unfocus();
                          context
                              .read<ProfileController>()
                              .incrementSearchCount();
                          controller.searchFertilizer(suggestion.name);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    // Disable default gestures if needed, or adjust settings
    // mapboxMap.gestures.updateSettings(GesturesSettings(scrollEnabled: true));

    _mapboxMap?.annotations.createCircleAnnotationManager().then((manager) {
      _circleAnnotationManager = manager;
    });
    _mapboxMap?.annotations.createPolylineAnnotationManager().then((manager) {
      _polylineAnnotationManager = manager;
    });
  }

  Future<void> _updateMapMarkers() async {
    if (_circleAnnotationManager == null) return;

    await _circleAnnotationManager?.deleteAll();

    // User Location (Blue Pulse effect simulation with larger semi-transparent circle)
    if (_controller.currentPosition != null) {
      // Fly to user location
      _mapboxMap?.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              _controller.currentPosition!.longitude,
              _controller.currentPosition!.latitude,
            ),
          ),
          zoom: 16.0, // Zoom in closer
          padding: MbxEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
        ),
        MapAnimationOptions(duration: 1000, startDelay: 0),
      );

      await _circleAnnotationManager?.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              _controller.currentPosition!.longitude,
              _controller.currentPosition!.latitude,
            ),
          ),
          circleColor: Colors.blue.withOpacity(0.3).value,
          circleRadius: 20.0, // Increased radius
        ),
      );

      await _circleAnnotationManager?.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              _controller.currentPosition!.longitude,
              _controller.currentPosition!.latitude,
            ),
          ),
          circleColor: Colors.blue.value,
          circleRadius: 10.0, // Increased radius
          circleStrokeWidth: 3.0, // Thicker stroke
          circleStrokeColor: Colors.white.value,
        ),
      );
    }

    // Stores
    for (var result in _controller.stores) {
      final isBest = _controller.bestShop?.store.id == result.store.id;
      // Best shop: Amber/Gold, Others: Green
      final color = isBest ? const Color(0xFFFFAB00) : const Color(0xFF43A047);

      await _circleAnnotationManager?.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              result.store.longitude,
              result.store.latitude,
            ),
          ),
          circleColor: color.value,
          circleRadius: isBest ? 10.0 : 8.0,
          circleStrokeWidth: 2.0,
          circleStrokeColor: Colors.white.value,
        ),
      );
    }
  }

  Future<void> _updateRoute() async {
    if (_polylineAnnotationManager == null) return;

    await _polylineAnnotationManager?.deleteAll();

    if (_controller.routePolyline.isNotEmpty) {
      final List<Point> points = _controller.routePolyline.map((
        ll.LatLng latLng,
      ) {
        return Point(coordinates: Position(latLng.longitude, latLng.latitude));
      }).toList();

      await _polylineAnnotationManager?.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: points.map((e) => e.coordinates).toList(),
          ),
          lineColor: Colors.blue.value,
          lineWidth: 4.0,
          lineJoin: LineJoin.ROUND,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.white, // Match clean white background
        body: SafeArea(
          child: Consumer<FertilizerSearchController>(
            builder: (context, controller, child) {
              if (_mapboxMap != null) {
                _updateMapMarkers();
                _updateRoute();
              }

              // Show error only if it's new and different from last shown
              if (controller.error != null &&
                  controller.error!.isNotEmpty &&
                  controller.error != _lastShownError) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _lastShownError = controller.error;
                  String errorMessage = controller.error!;
                  String actionMessage = '';

                  // Check if it's a permission error
                  if (errorMessage.contains('permission-denied') ||
                      errorMessage.contains('permission denied')) {
                    errorMessage = 'Database permission error detected';
                    actionMessage =
                        'Please ensure Firestore rules are deployed. Contact support if issue persists.';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            errorMessage,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (actionMessage.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              actionMessage,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () {
                          _lastShownError = null; // Reset to allow new error
                          controller.initialize();
                        },
                      ),
                    ),
                  );
                });
              }

              // Clear last shown error when error is null
              if (controller.error == null || controller.error!.isEmpty) {
                _lastShownError = null;
              }

              return Column(
                children: [
                  // App Bar / Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const BackButton(color: Colors.black),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fertilizer Search',
                                style: AppTextStyles.heading3.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                'Find nearby stores for best prices',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Field
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Urea',
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              30,
                            ), // Rounded pill shape
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (value) {
                          _removeOverlay();
                          print('DEBUG: Search submitted via keyboard: $value');
                          context
                              .read<ProfileController>()
                              .incrementSearchCount();
                          controller.searchFertilizer(value);
                        },
                      ),
                    ),
                  ),

                  // Fertilizer Info Card
                  if (controller.selectedFertilizer != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9), // Light Green
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child:
                                    controller
                                        .selectedFertilizer!
                                        .imageUrl
                                        .isNotEmpty
                                    ? Image.network(
                                        controller.selectedFertilizer!.imageUrl,
                                        width: 24,
                                        height: 24,
                                        errorBuilder: (c, e, s) => const Icon(
                                          Icons.science_outlined,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.science_outlined,
                                        color: AppColors.primary,
                                      ), // Flask icon
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.selectedFertilizer!.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      controller.selectedFertilizer!.category
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'NPK: ${controller.selectedFertilizer!.npkComposition}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // No suitableCrops in simplified Fertilizer model as per requirements?
                                      // Assuming I should remove or use placeholder/description if available.
                                      // Requirements said "Fertilizer Master: name, category, NPK, description, image, isActive".
                                      // So I'll show description instead.
                                      const Text(
                                        'Description',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        controller
                                                .selectedFertilizer!
                                                .description
                                                .isNotEmpty
                                            ? controller
                                                  .selectedFertilizer!
                                                  .description
                                            : 'No description available',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Map
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          MapWidget(
                            mapOptions: MapOptions(
                              pixelRatio: MediaQuery.of(
                                context,
                              ).devicePixelRatio,
                            ),
                            styleUri: MapboxStyles.OUTDOORS,
                            onMapCreated: _onMapCreated,
                            cameraOptions: CameraOptions(
                              center: Point(
                                coordinates: Position(
                                  controller.currentPosition?.longitude ??
                                      77.5946, // Delhi longitude as fallback
                                  controller.currentPosition?.latitude ??
                                      12.9716, // Bangalore latitude as fallback
                                ),
                              ),
                              zoom: 16.0, // Higher zoom for better visibility
                            ),
                          ),
                          // "Within 5KM" Lozenge
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'WITHIN 5KM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (controller.isLoading)
                            const Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
                  ),

                  // Stores List Section - Flexible height to allow more map space
                  if (controller.stores.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Text(
                              'Nearby Stores (${controller.stores.length})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.stores.length,
                            itemBuilder: (context, index) {
                              final result = controller.stores[index];
                              final isBest =
                                  controller.bestShop?.store.id ==
                                  result.store.id;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isBest
                                          ? const Color(
                                              0xFFFFAB00,
                                            ) // Gold for best
                                          : Colors.grey.shade100,
                                      width: isBest ? 2.0 : 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  result.store.storeName,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (result
                                                    .store
                                                    .isVerified) ...[
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.verified,
                                                    color: Colors.blue,
                                                    size: 14,
                                                  ),
                                                ],
                                                if (isBest) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFFFAB00,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'BEST SHOP',
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),

                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 12,
                                                  color: Colors.amber,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '${result.store.rating} (${result.store.totalReviews})',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '${result.distance.toStringAsFixed(1)} km',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: result.inStock
                                                    ? AppColors.success
                                                          .withOpacity(0.1)
                                                    : Colors.red.withOpacity(
                                                        0.1,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: result.inStock
                                                          ? AppColors.success
                                                          : Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    result.inStock
                                                        ? 'IN STOCK'
                                                        : 'OUT STOCK',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: result.inStock
                                                          ? AppColors.success
                                                          : Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₹${result.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const Text(
                                            'per unit',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          InkWell(
                                            onTap: () {
                                              // Increment store visit count
                                              context
                                                  .read<ProfileController>()
                                                  .incrementStoreVisitCount();

                                              controller.navigateToStore(
                                                result.store,
                                              );
                                              // Ideally fly to store
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.background,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.navigation_outlined,
                                                    size: 12,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Navigate',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
