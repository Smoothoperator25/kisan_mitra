import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/helpers.dart';

class FarmerLoginScreen extends StatefulWidget {
  const FarmerLoginScreen({super.key});

  @override
  State<FarmerLoginScreen> createState() => _FarmerLoginScreenState();
}

class _FarmerLoginScreenState extends State<FarmerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isDarkMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign in with Firebase Auth
      final authResult = await _authService.signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (authResult['success'] == true) {
        // Fetch user data from Firestore
        final uid = authResult['user'].uid;
        final firestoreResult = await _firestoreService.getUserRoleAndData(uid);

        if (!mounted) return;

        if (firestoreResult['success'] == true) {
          final role = firestoreResult['role'] as String;

          // Verify role is farmer
          if (role == AppConstants.roleFarmer) {
            // Navigate to Farmer Home
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppConstants.farmerHomeRoute,
                (route) => false,
              );
            }
          } else {
            // Wrong role
            await _authService.signOut();
            if (mounted) {
              SnackBarHelper.showError(
                context,
                'Invalid role. Please use the correct login.',
              );
            }
          }
        } else {
          // User data not found
          await _authService.signOut();
          if (mounted) {
            SnackBarHelper.showError(
              context,
              firestoreResult['message'] ?? 'User data not found',
            );
          }
        }
      } else {
        // Auth failed
        if (mounted) {
          SnackBarHelper.showError(
            context,
            authResult['message'] ?? 'Login failed',
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (result['success'] == true) {
        final user = result['user'] as User;
        final isNewUser = result['isNewUser'] as bool;

        if (isNewUser) {
          // New user - create farmer profile in Firestore
          final createResult = await _firestoreService.createUserDocument(
            uid: user.uid,
            userData: {
              'name': user.displayName ?? 'Farmer',
              'email': user.email ?? '',
              'phone': user.phoneNumber ?? '',
              'state': '',
              'city': '',
              'village': '',
              'profileImageUrl': user.photoURL,
            },
          );

          if (!mounted) return;

          if (createResult['success'] == true) {
            // Navigate to Farmer Home
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppConstants.farmerHomeRoute,
              (route) => false,
            );
          } else {
            // Failed to create profile, sign out
            await _authService.signOut();
            SnackBarHelper.showError(
              context,
              'Failed to create profile. Please try again.',
            );
          }
        } else {
          // Existing user - verify role
          final firestoreResult = await _firestoreService.getUserRoleAndData(user.uid);

          if (!mounted) return;

          if (firestoreResult['success'] == true) {
            final role = firestoreResult['role'] as String;

            if (role == AppConstants.roleFarmer) {
              // Navigate to Farmer Home
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppConstants.farmerHomeRoute,
                (route) => false,
              );
            } else {
              // Wrong role
              await _authService.signOut();
              if (mounted) {
                SnackBarHelper.showError(
                  context,
                  'This Google account is registered with a different role.',
                );
              }
            }
          } else {
            // User data not found, create it
            final createResult = await _firestoreService.createUserDocument(
              uid: user.uid,
              userData: {
                'name': user.displayName ?? 'Farmer',
                'email': user.email ?? '',
                'phone': user.phoneNumber ?? '',
                'state': '',
                'city': '',
                'village': '',
                'profileImageUrl': user.photoURL,
              },
            );

            if (!mounted) return;

            if (createResult['success'] == true) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppConstants.farmerHomeRoute,
                (route) => false,
              );
            } else {
              await _authService.signOut();
              SnackBarHelper.showError(
                context,
                'Failed to create profile. Please try again.',
              );
            }
          }
        }
      } else {
        // Google sign-in failed
        if (mounted) {
          SnackBarHelper.showError(
            context,
            result['message'] ?? 'Google sign-in failed',
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
                const SizedBox(height: 16),

                // Logo
                Container(
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
                            width: 3,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.agriculture,
                        size: 38,
                        color: Color(0xFF2E7D32),
                      ),
                      Positioned(
                        bottom: 25,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

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
                  '"BEEJ SE BAZAR TAK"',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF558B5B),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 20),

                // Welcome Back
                Text(
                  'Welcome Back',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Login to find nearby fertilizer stores\neasily',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF5F7D63),
                  ),
                ),

                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  validator: Validators.validateEmail,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: const Icon(
                      Icons.email_outlined,
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

                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  validator: Validators.validatePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
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

                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              AppConstants.forgotPasswordRoute,
                            );
                          },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

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

                const SizedBox(height: 12),

                // Divider with "OR"
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFB0BDB4))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF5F7D63),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFB0BDB4))),
                  ],
                ),

                const SizedBox(height: 12),

                // Sign in with Google
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFDDDDDD),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google Logo
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: CustomPaint(
                            painter: GoogleLogoPainter(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sign in with Google',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3C4043),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Create New Account
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppConstants.farmerSignupRoute,
                          );
                        },
                  child: Text(
                    'Create New Account',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

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

/// Custom painter for Google logo
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue part
    paint.color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.2)
      ..arcToPoint(
        Offset(size.width * 0.8, size.height * 0.5),
        radius: Radius.circular(size.width * 0.3),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(bluePath, paint);

    // Red part
    paint.color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.8, size.height * 0.5)
      ..arcToPoint(
        Offset(size.width * 0.5, size.height * 0.8),
        radius: Radius.circular(size.width * 0.3),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(redPath, paint);

    // Yellow part
    paint.color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..arcToPoint(
        Offset(size.width * 0.2, size.height * 0.5),
        radius: Radius.circular(size.width * 0.3),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Green part
    paint.color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height * 0.5)
      ..arcToPoint(
        Offset(size.width * 0.5, size.height * 0.2),
        radius: Radius.circular(size.width * 0.3),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(greenPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

