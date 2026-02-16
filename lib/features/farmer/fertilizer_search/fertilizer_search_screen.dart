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

  @override
  void initState() {
    super.initState();
    _controller = FertilizerSearchController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
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
      await _circleAnnotationManager?.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              _controller.currentPosition!.longitude,
              _controller.currentPosition!.latitude,
            ),
          ),
          circleColor: Colors.blue.withOpacity(0.3).value,
          circleRadius: 12.0,
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
          circleRadius: 6.0,
          circleStrokeWidth: 2.0,
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

              if (controller.error != null && controller.error!.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(controller.error!),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
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
                  Padding(
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
                        print('DEBUG: Search submitted via keyboard: $value');
                        context
                            .read<ProfileController>()
                            .incrementSearchCount();
                        controller.searchFertilizer(value);
                      },
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
                                child: const Icon(
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
                                    const Text(
                                      'NITROGEN FERTILIZER', // Static or dynamic if available
                                      style: TextStyle(
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
                                      const Text(
                                        'Suitable Crops',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.grass,
                                            size: 14,
                                            color: AppColors.success,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              controller
                                                  .selectedFertilizer!
                                                  .suitableCrops,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                      const Text(
                                        'Dosage',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.water_drop_outlined,
                                            size: 14,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              controller
                                                  .selectedFertilizer!
                                                  .recommendedDosage,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
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
                              zoom: 14.0, // Higher zoom for better visibility
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

                  // Stores List Section
                  if (controller.stores.isNotEmpty)
                    Container(
                      height: 240, // Fixed height for list area
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
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                          ? const Color(0xFFE0F7FA)
                                          : Colors.grey.shade100,
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
                                            Text(
                                              result.store.storeName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  size: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${result.distance.toStringAsFixed(1)} km • ${_calculateTime(result.distance)} mins',
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
                                                color:
                                                    result.details.isAvailable
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
                                                      color:
                                                          result
                                                              .details
                                                              .isAvailable
                                                          ? AppColors.success
                                                          : Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    result.details.isAvailable
                                                        ? 'IN STOCK'
                                                        : 'OUT STOCK',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          result
                                                              .details
                                                              .isAvailable
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
                                            '₹${result.details.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const Text(
                                            'per bag',
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

  String _calculateTime(double distance) {
    // Approx 30km/h
    return (distance / 30 * 60).toStringAsFixed(0);
  }
}
