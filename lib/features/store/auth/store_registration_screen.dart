import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/helpers.dart';

class StoreRegistrationScreen extends StatefulWidget {
  const StoreRegistrationScreen({super.key});

  @override
  State<StoreRegistrationScreen> createState() =>
      _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen> {
  // Form keys
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  // Controllers - Step 1
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Controllers - Step 2
  final _cityController = TextEditingController();
  final _villageController = TextEditingController();
  final _licenseController = TextEditingController();

  // Services
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isDarkMode = false;
  int _currentStep = 0; // 0 for step 1, 1 for step 2
  String? _selectedState;

  // Location variables
  double? _selectedLatitude;
  double? _selectedLongitude;
  final MapController _mapController = MapController();

  // Indian States
  final List<String> _indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _villageController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _goToStep2() {
    if (_formKey1.currentState!.validate()) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _goBackToStep1() {
    setState(() {
      _currentStep = 0;
    });
  }

  Future<void> _handleRegistration() async {
    if (!_formKey2.currentState!.validate()) {
      return;
    }

    if (_selectedState == null) {
      SnackBarHelper.showError(context, 'Please select a state');
      return;
    }

    if (_selectedLatitude == null || _selectedLongitude == null) {
      SnackBarHelper.showError(context, 'Please select location on map');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user with Firebase Auth
      final authResult = await _authService.signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (authResult['success'] == true) {
        final uid = authResult['user'].uid;

        // Create store document in Firestore
        final storeData = {
          'storeName': _storeNameController.text.trim(),
          'ownerName': _ownerNameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': AppConstants.roleStore,
          'state': _selectedState,
          'city': _cityController.text.trim(),
          'village': _villageController.text.trim(),
          'location': {
            'latitude': _selectedLatitude,
            'longitude': _selectedLongitude,
          },
          'license': _licenseController.text.trim(),
          'isVerified': false,
          'isRejected': false,
        };

        final firestoreResult = await _firestoreService.createStoreDocument(
          uid: uid,
          storeData: storeData,
        );

        if (!mounted) return;

        if (firestoreResult['success'] == true) {
          // Navigate to Store Home
          SnackBarHelper.showSuccess(
            context,
            'Store registered successfully! Awaiting verification.',
          );

          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppConstants.storeHomeRoute,
              (route) => false,
            );
          }
        } else {
          // Firestore failed, delete auth account
          await _authService.deleteAccount();
          if (mounted) {
            SnackBarHelper.showError(
              context,
              firestoreResult['message'] ?? 'Failed to create store profile',
            );
          }
        }
      } else {
        // Auth failed
        if (mounted) {
          SnackBarHelper.showError(
            context,
            authResult['message'] ?? 'Registration failed',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'An error occurred: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isDarkMode
        ? const Color(0xFF1B5E20)
        : const Color(0xFFD5E8D4);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(child: _currentStep == 0 ? _buildStep1() : _buildStep2()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
        backgroundColor: Colors.white,
        elevation: 3,
        child: Icon(
          _isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: const Color(0xFF2E7D32),
        ),
      ),
    );
  }

  // Step 1: Authentication and Store Info
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2E7D32),
                          width: 2,
                        ),
                      ),
                    ),
                    const Icon(Icons.store, size: 40, color: Color(0xFF2E7D32)),
                    Positioned(
                      bottom: 18,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 12,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // App Name
            Center(
              child: Text(
                'Kisan Mitra',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Tagline
            Center(
              child: Text(
                '"BEEJ SE BAZAR TAK"',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF558B5B),
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Store Registration
            Center(
              child: Text(
                'Store Registration',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Center(
              child: Text(
                'Step 1 of 2: Let\'s set up your store account',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5F7D63),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // AUTHENTICATION DETAILS Section
            Text(
              'AUTHENTICATION DETAILS',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 16),

            // Email ID
            Text(
              'Email ID',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5F7D63),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              decoration: _inputDecoration('store@example.com'),
            ),

            const SizedBox(height: 16),

            // Password
            Text(
              'Password',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5F7D63),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: Validators.validatePassword,
              decoration: _inputDecoration('Create a strong password').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF5F7D63),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // STORE INFORMATION Section
            Text(
              'STORE INFORMATION',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 16),

            // Store Name
            Text(
              'Store Name',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5F7D63),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _storeNameController,
              validator: Validators.validateName,
              decoration: _inputDecoration('Enter your business name'),
            ),

            const SizedBox(height: 16),

            // Owner Name
            Text(
              'Owner Name',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5F7D63),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ownerNameController,
              validator: Validators.validateName,
              decoration: _inputDecoration('Full name of proprietor'),
            ),

            const SizedBox(height: 16),

            // Mobile Number
            Text(
              'Mobile Number',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5F7D63),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
              decoration: _inputDecoration('+91 00000 00000'),
            ),

            const SizedBox(height: 32),

            // Next Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _goToStep2,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Already have an account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF5F7D63),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppConstants.storeLoginRoute,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Contact Support
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Need help? ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF5F7D63),
                  ),
                ),
                TextButton(
                  onPressed: _showSupportDialog,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Contact Support',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Step 2: Location & Verification
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Logo
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.store, size: 35, color: Color(0xFF2E7D32)),
                    Positioned(
                      bottom: 15,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 10,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // App Name
            Center(
              child: Text(
                'Kisan Mitra',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Tagline
            Center(
              child: Text(
                '"BEEJ SE BAZAR TAK"',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF558B5B),
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Store Profile
            Center(
              child: Text(
                'Store Profile',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Step indicator
            Center(
              child: Text(
                'Step 2: Location & Verification',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5F7D63),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // STORE ADDRESS Section Header with icon
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Store Address',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // State
            Text(
              'State',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5F7D63),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedState,
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                });
              },
              decoration: _inputDecoration('Select your state'),
              items: _indianStates.map((state) {
                return DropdownMenuItem(
                  value: state,
                  child: Text(state, style: GoogleFonts.poppins(fontSize: 14)),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // City and Village in a row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'City / District',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5F7D63),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cityController,
                        validator: (value) =>
                            Validators.validateRequired(value, 'City'),
                        decoration: _inputDecoration('Enter city'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Village / Area',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5F7D63),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _villageController,
                        validator: (value) =>
                            Validators.validateRequired(value, 'Village'),
                        decoration: _inputDecoration('Enter village'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Store Location (Pin on Map)
            Text(
              'Store Location (Pin on Map)',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5F7D63),
              ),
            ),
            const SizedBox(height: 8),

            // Map Container
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    // Default center: India (approximate center)
                    initialCenter: const LatLng(20.5937, 78.9629),
                    initialZoom: 5.0,
                    onTap: (tapPosition, latLng) {
                      setState(() {
                        _selectedLatitude = latLng.latitude;
                        _selectedLongitude = latLng.longitude;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.kisan_mitra',
                    ),
                    if (_selectedLatitude != null && _selectedLongitude != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              _selectedLatitude!,
                              _selectedLongitude!,
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF2E7D32),
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Coordinates display
            if (_selectedLatitude != null && _selectedLongitude != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedLatitude!.toStringAsFixed(4)}° N, ${_selectedLongitude!.toStringAsFixed(4)}° E',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                          Text(
                            'Tap to adjust location',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF5F7D63),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap on map to select your store location',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF5F7D63),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // VERIFICATION DETAILS Section Header with icon
            Row(
              children: [
                const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Verification Details',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Store License Number / GSTIN
            Text(
              'Store License Number / GSTIN',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5F7D63),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _licenseController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'License/GSTIN is required';
                }
                if (value.trim().length < 10) {
                  return 'Invalid license number';
                }
                return null;
              },
              decoration: _inputDecoration('Enter 15-digit GST or License No.')
                  .copyWith(
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF5F7D63),
                      ),
                      onPressed: () {
                        SnackBarHelper.showInfo(
                          context,
                          'Enter your GST number or store license for verification',
                        );
                      },
                    ),
                  ),
            ),

            const SizedBox(height: 32),

            // Complete Signup Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Complete Signup',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Back button
            Center(
              child: TextButton(
                onPressed: _isLoading ? null : _goBackToStep1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Back to Step 1',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Already have an account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF5F7D63),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppConstants.storeLoginRoute,
                          );
                        },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Contact Support
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Need help? ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF5F7D63),
                  ),
                ),
                TextButton(
                  onPressed: _showSupportDialog,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Contact Support',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFFB0BDB4),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Contact Support',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: support@kisanmitra.com',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: +91 1800-XXX-XXXX',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
