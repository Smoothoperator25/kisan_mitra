import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'store_profile_controller.dart';
import 'store_profile_model.dart';

class EditStoreProfileScreen extends StatefulWidget {
  const EditStoreProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditStoreProfileScreen> createState() => _EditStoreProfileScreenState();
}

class _EditStoreProfileScreenState extends State<EditStoreProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  StoreProfile? _currentProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load profile data after the first frame to ensure provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    try {
      final controller = context.read<StoreProfileController>();
      final profile = await controller.fetchStoreProfile();

      if (mounted) {
        if (profile != null) {
          setState(() {
            _currentProfile = profile;
            _storeNameController.text = profile.storeName;
            _ownerNameController.text = profile.ownerName;
            _phoneController.text = profile.phone;
            _emailController.text = profile.email;
            _addressController.text = profile.address;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          // Show error if profile couldn't be loaded
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to load store profile'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreProfileController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFFD5F5E3),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Edit Store Profile',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Profile Image Section
                            _buildProfileImageSection(controller),
                            const SizedBox(height: 24),

                            // Store Name
                            _buildTextField(
                              controller: _storeNameController,
                              label: 'Store Name',
                              hint: 'Enter store name',
                              icon: Icons.store,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Store name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Owner Name
                            _buildTextField(
                              controller: _ownerNameController,
                              label: 'Owner Name',
                              hint: 'Enter owner name',
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Owner name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Phone
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: 'Enter 10-digit phone number',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Phone number is required';
                                }
                                if (value.length != 10) {
                                  return 'Phone number must be 10 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'Enter email address',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Address
                            _buildTextField(
                              controller: _addressController,
                              label: 'Address',
                              hint: 'Enter complete address',
                              icon: Icons.location_on,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Address is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Coordinates (Read-only)
                            if (_currentProfile != null)
                              _buildReadOnlyField(
                                label: 'Coordinates',
                                value: _currentProfile!.coordinates,
                                icon: Icons.location_searching,
                              ),
                            const SizedBox(height: 32),

                            // Save Button
                            _buildSaveButton(controller),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildProfileImageSection(StoreProfileController controller) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => controller.pickImage(),
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: controller.selectedImage != null
                        ? Image.file(
                            controller.selectedImage!,
                            fit: BoxFit.cover,
                          )
                        : _currentProfile?.profileImageUrl != null
                        ? Image.network(
                            _currentProfile!.profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.storefront,
                                size: 50,
                                color: Color(0xFF27AE60),
                              );
                            },
                          )
                        : const Icon(
                            Icons.storefront,
                            size: 50,
                            color: Color(0xFF27AE60),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (controller.selectedImage != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => controller.clearSelectedImage(),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Remove Image'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: const Color(0xFF27AE60)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF27AE60), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(StoreProfileController controller) {
    return ElevatedButton(
      onPressed: controller.isLoading ? null : () => _handleSave(controller),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF27AE60),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        shadowColor: const Color(0xFF27AE60).withOpacity(0.3),
      ),
      child: controller.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Future<void> _handleSave(StoreProfileController controller) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Upload image first if selected
    if (controller.selectedImage != null) {
      final imageUrl = await controller.uploadProfileImage();
      if (imageUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(controller.error ?? 'Failed to upload image'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // Update profile
    final success = await controller.updateStoreProfile(
      storeName: _storeNameController.text,
      ownerName: _ownerNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _addressController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF27AE60),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.error ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
