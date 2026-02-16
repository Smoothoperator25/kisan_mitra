import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'store_location_controller.dart';

/// Store Location Screen
/// Allows store owners to set and update their store location on Mapbox Maps
class StoreLocationScreen extends StatefulWidget {
  const StoreLocationScreen({super.key});

  @override
  State<StoreLocationScreen> createState() => _StoreLocationScreenState();
}

class _StoreLocationScreenState extends State<StoreLocationScreen> {
  late final StoreLocationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StoreLocationController();
    // Initialize location after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initializeLocation();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<StoreLocationController>(
          builder: (context, controller, child) {
            // Show error snackbar if any
            if (controller.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(controller.error!),
                    backgroundColor: Colors.red,
                  ),
                );
                controller.clearError();
              });
            }

            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              );
            }

            return SafeArea(
              child: Stack(
                children: [
                  // Map Section
                  _buildMapSection(controller),

                  // Header
                  _buildHeader(),

                  // Instruction Tooltip
                  _buildInstructionTooltip(),

                  // Address Preview Card
                  _buildAddressPreviewCard(controller),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Header with back button, title, and verified badge
  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD5F4E6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back Button
            InkWell(
              onTap: () {
                // Navigation handled by bottom nav, this is just visual
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Title
            Text(
              'Store Location',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(width: 12),

            // Verified Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'VERIFIED',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Instruction tooltip at top of map
  Widget _buildInstructionTooltip() {
    return Positioned(
      top: 72,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            'Tap anywhere on the map to set your store location',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Map Section with tap-to-select location
  Widget _buildMapSection(StoreLocationController controller) {
    if (controller.selectedLatitude == null ||
        controller.selectedLongitude == null) {
      return const Center(child: Text('Unable to load map'));
    }

    return MapWidget(
      textureView: true,
      styleUri: MapboxStyles.OUTDOORS,
      onMapCreated: (MapboxMap mapboxMap) {
        controller.setMapController(mapboxMap);
      },
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            controller.selectedLongitude!,
            controller.selectedLatitude!,
          ),
        ),
        zoom: 15.0,
      ),
      onTapListener: (context) {
        // Update location on map tap
        final point = context.point;
        controller.onMapTap(
          point.coordinates.lat.toDouble(),
          point.coordinates.lng.toDouble(),
        );
      },
    );
  }

  /// Address Preview Card at bottom
  Widget _buildAddressPreviewCard(StoreLocationController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Name and Icon Row
            Row(
              children: [
                // Store Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 12),

                // Store Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.storeName,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'LAT: ${controller.selectedLatitude?.toStringAsFixed(4) ?? ''} • LNG: ${controller.selectedLongitude?.toStringAsFixed(4) ?? ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Store icon on right
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Color(0xFF2E7D32),
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Address Preview Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADDRESS PREVIEW',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.resolvedAddress,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Save Location Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.isSaving
                    ? null
                    : () => _handleSaveLocation(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: controller.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Save Location',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // Use Current Location Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: controller.isFetchingCurrentLocation
                    ? null
                    : () => controller.useCurrentLocation(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                  side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: controller.isFetchingCurrentLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF2E7D32),
                          ),
                        ),
                      )
                    : const Icon(Icons.navigation, size: 20),
                label: Text(
                  'Use Current Location',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle save location button press
  Future<void> _handleSaveLocation(StoreLocationController controller) async {
    final result = await controller.saveLocation();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Location updated'),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ),
    );
  }
}
