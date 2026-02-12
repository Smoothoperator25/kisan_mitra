import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/utils/app_theme.dart';
import 'fertilizer_search_controller.dart';

/// Fertilizer Search Screen
/// Allows farmers to find nearby stores with fertilizer availability and pricing
class FertilizerSearchScreen extends StatefulWidget {
  const FertilizerSearchScreen({super.key});

  @override
  State<FertilizerSearchScreen> createState() => _FertilizerSearchScreenState();
}

class _FertilizerSearchScreenState extends State<FertilizerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  late final FertilizerSearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FertilizerSearchController();
    // Initialize location when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initializeLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Consumer<FertilizerSearchController>(
          builder: (context, controller, child) {
            // Show error if any
            if (controller.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(controller.error!),
                    backgroundColor: AppColors.error,
                    action: SnackBarAction(
                      label: 'Dismiss',
                      textColor: Colors.white,
                      onPressed: () {
                        controller.clearError();
                      },
                    ),
                  ),
                );
                controller.clearError();
              });
            }

            if (controller.isLoadingLocation) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Getting your location...'),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Screen title header at top
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fertilizer Search',
                        style: AppTextStyles.heading3.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
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

                // Search Field
                _buildSearchField(controller),

                // Fertilizer Info Card
                if (controller.selectedFertilizer != null)
                  _buildFertilizerInfoCard(controller.selectedFertilizer!),

                // Map
                Expanded(child: _buildMapSection(controller)),

                // Store List
                if (controller.nearbyStores.isNotEmpty)
                  _buildStoreList(controller),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(FertilizerSearchController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Urea',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onSubmitted: (value) {
          controller.searchFertilizer(value);
        },
        enabled: !controller.isSearching,
      ),
    );
  }

  Widget _buildFertilizerInfoCard(Map<String, dynamic> fertilizer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fertilizer Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.science,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),

          // Fertilizer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fertilizer['name'] as String? ?? 'Unknown',
                  style: AppTextStyles.heading3.copyWith(fontSize: 16),
                ),
                Text(
                  fertilizer['type'] as String? ?? 'NITROGEN FERTILIZER',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Suitable Crops
                    const Icon(Icons.grass, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      fertilizer['suitableCrops'] as String? ??
                          'Rice, Wheat, Corn',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // NPK Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  fertilizer['npk'] as String? ?? 'NPK: 46-0-0',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${fertilizer['basePrice'] ?? '266'} / Acre',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(FertilizerSearchController controller) {
    if (controller.userLocation == null) {
      return const Center(child: Text('Unable to load map'));
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: controller.userLocation!,
              zoom: 13,
            ),
            onMapCreated: (GoogleMapController mapController) {
              _mapController = mapController;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _buildMarkers(controller),
            circles: _buildCircles(controller),
            polylines: _buildPolylines(controller),
          ),

          // WITHIN 5KM indicator
          if (controller.nearbyStores.isNotEmpty)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Text(
                  'WITHIN 5KM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(FertilizerSearchController controller) {
    Set<Marker> markers = {};

    // Add markers for each store
    for (var store in controller.nearbyStores) {
      final isBest = controller.bestStore?.storeId == store.storeId;

      markers.add(
        Marker(
          markerId: MarkerId(store.storeId),
          position: LatLng(store.latitude, store.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isBest ? BitmapDescriptor.hueYellow : BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: store.storeName,
            snippet: isBest ? 'BEST SHOP - ₹${store.price}' : '₹${store.price}',
          ),
        ),
      );
    }

    return markers;
  }

  Set<Circle> _buildCircles(FertilizerSearchController controller) {
    if (controller.userLocation == null) return {};

    return {
      Circle(
        circleId: const CircleId('radius'),
        center: controller.userLocation!,
        radius: 5000, // 5km in meters
        fillColor: AppColors.primary.withOpacity(0.1),
        strokeColor: AppColors.primary.withOpacity(0.3),
        strokeWidth: 2,
      ),
    };
  }

  Set<Polyline> _buildPolylines(FertilizerSearchController controller) {
    if (controller.directionPolyline.isEmpty) return {};

    return {
      Polyline(
        polylineId: const PolylineId('directions'),
        points: controller.directionPolyline,
        color: AppColors.info,
        width: 4,
      ),
    };
  }

  Widget _buildStoreList(FertilizerSearchController controller) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Nearby Stores (${controller.nearbyStores.length})',
                  style: AppTextStyles.heading3.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),

          // Store Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.nearbyStores.length,
              itemBuilder: (context, index) {
                final store = controller.nearbyStores[index];
                final isBest = controller.bestStore?.storeId == store.storeId;

                return _buildStoreCard(store, isBest, controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(
    StoreWithFertilizer store,
    bool isBest,
    FertilizerSearchController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: isBest ? Border.all(color: AppColors.warning, width: 2) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      store.storeName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BEST SHOP',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
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
                      Icons.location_on,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${store.distance.toStringAsFixed(1)} km • ${_getEstimatedTime(store.distance)} mins',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      store.stockStatus == 'IN STOCK'
                          ? Icons.check_circle
                          : Icons.warning,
                      size: 14,
                      color: store.stockStatus == 'IN STOCK'
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      store.stockStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: store.stockStatus == 'IN STOCK'
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${store.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                'per bag',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              OutlinedButton(
                onPressed: () {
                  controller.getDirections(store);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.navigation, size: 14),
                    const SizedBox(width: 4),
                    const Text('Navigate', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getEstimatedTime(double distanceKm) {
    // Estimate: average speed of 30 km/h in city
    return (distanceKm / 30 * 60).round();
  }
}
