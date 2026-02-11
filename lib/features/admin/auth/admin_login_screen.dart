import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/helpers.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // Default admin credentials to auto-provision if missing
  static const _defaultAdminUsername = 'admin';
  static const _defaultAdminEmail = 'admin@kisanmitra.com';
  static const _defaultAdminPassword = 'admin123@';

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isDarkMode = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _provisionDefaultAdmin() async {
    final enteredPassword = _passwordController.text.trim();
    if (enteredPassword != _defaultAdminPassword) {
      SnackBarHelper.showError(
        context,
        'Use the default admin password: $_defaultAdminPassword',
      );
      return null;
    }

    try {
      User? adminUser;

      // Try creating the admin user; if it already exists, sign in instead.
      final signUpResult = await _authService.signUpWithEmailPassword(
        email: _defaultAdminEmail,
        password: _defaultAdminPassword,
      );

      if (signUpResult['success'] == true) {
        adminUser = signUpResult['user'] as User?;
      } else {
        final message = (signUpResult['message'] as String?) ?? '';
        if (message.contains('already')) {
          final signInResult = await _authService.signInWithEmailPassword(
            email: _defaultAdminEmail,
            password: _defaultAdminPassword,
          );
          if (signInResult['success'] == true) {
            adminUser = signInResult['user'] as User?;
          } else {
            SnackBarHelper.showError(
              context,
              signInResult['message'] ?? 'Unable to sign in default admin.',
            );
            return null;
          }
        } else {
          SnackBarHelper.showError(
            context,
            message.isNotEmpty
                ? message
                : 'Unable to create default admin user.',
          );
          return null;
        }
      }

      if (adminUser == null) {
        SnackBarHelper.showError(context, 'Default admin user is unavailable.');
        return null;
      }

      final createResult = await _firestoreService.createAdminDocument(
        uid: adminUser.uid,
        adminData: {
          'username': _defaultAdminUsername,
          'email': _defaultAdminEmail,
          'role': AppConstants.roleAdmin,
        },
      );

      // If the document already exists, we still proceed.
      final created = createResult['success'] == true ||
          ((createResult['message'] as String?) ?? '').contains('exists');

      if (created) {
        return {
          'uid': adminUser.uid,
          'data': {
            'username': _defaultAdminUsername,
            'email': _defaultAdminEmail,
            'role': AppConstants.roleAdmin,
          },
        };
      }

      SnackBarHelper.showError(
        context,
        createResult['message'] ?? 'Unable to create admin profile.',
      );
      return null;
    } catch (e) {
      SnackBarHelper.showError(context, 'Default admin setup failed: $e');
      return null;
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final username = _usernameController.text.trim();
      final isDefaultAdmin = username.toLowerCase() == _defaultAdminUsername;

      Map<String, dynamic>? adminData;
      String? adminUid;
      String? email;

      // Step 1: Query Firestore to find admin by username
      var adminQueryResult = await _firestoreService.getAdminByUsername(
        username,
      );

      if (adminQueryResult['success'] == true) {
        adminData = adminQueryResult['data'] as Map<String, dynamic>;
        adminUid = adminQueryResult['uid'] as String?;
        email = adminData['email'] as String?;
      } else if (isDefaultAdmin) {
        final provisioned = await _provisionDefaultAdmin();
        if (provisioned != null) {
          adminData = provisioned['data'] as Map<String, dynamic>;
          adminUid = provisioned['uid'] as String?;
          email = adminData['email'] as String?;
        }
      }

      if (adminData == null || adminUid == null || email == null) {
        SnackBarHelper.showError(
          context,
          adminQueryResult['message'] ?? 'Invalid username',
        );
        setState(() => _isLoading = false);
        return;
      }

      // Step 3: Sign in with Firebase Auth using email and password
      final authResult = await _authService.signInWithEmailPassword(
        email: email,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (authResult['success'] == true) {
        // Verify the user ID matches
        final authUid = authResult['user'].uid;

        if (authUid == adminUid) {
          // Verify role is admin
          final role = adminData['role'] as String?;

          if (role == AppConstants.roleAdmin) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppConstants.adminDashboardRoute,
              (route) => false,
            );
          } else {
            await _authService.signOut();
            if (mounted) {
              SnackBarHelper.showError(
                context,
                'Invalid role. Please use the correct login.',
              );
            }
          }
        } else {
          await _authService.signOut();
          if (mounted) {
            SnackBarHelper.showError(
              context,
              'Authentication error. Please try again.',
            );
          }
        }
      } else {
        // Auth failed (wrong password)
        if (mounted) {
          SnackBarHelper.showError(
            context,
            authResult['message'] ?? 'Invalid password',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Logo
                Container(
                  width: 140,
                  height: 140,
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
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2E7D32),
                            width: 3,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.agriculture,
                        size: 50,
                        color: Color(0xFF2E7D32),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // App Name
                Text(
                  'Kisan Mitra',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),

                const SizedBox(height: 4),

                // Tagline
                Text(
                  'BEEJ SE BAZAR TAK',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF558B5B),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 40),

                // Admin Login
                Text(
                  'Admin Login',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Access the control panel to manage users and\nstores.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF5F7D63),
                  ),
                ),

                const SizedBox(height: 32),

                // Username Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Username',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFFB0BDB4),
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF5F7D63),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  validator: Validators.validatePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFFB0BDB4),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF5F7D63),
                    ),
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
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                            'Login',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

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
                      onPressed: () {
                        _showSupportDialog();
                      },
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
        ),
      ),

      // Theme Toggle Button
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
