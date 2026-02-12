import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_settings_controller.dart';
import '../admin_settings_model.dart';

class AppConfigurationScreen extends StatefulWidget {
  const AppConfigurationScreen({super.key});

  @override
  State<AppConfigurationScreen> createState() => _AppConfigurationScreenState();
}

class _AppConfigurationScreenState extends State<AppConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _appVersionController;
  late TextEditingController _supportEmailController;
  bool _maintenanceMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _appVersionController = TextEditingController();
    _supportEmailController = TextEditingController();
  }

  @override
  void dispose() {
    _appVersionController.dispose();
    _supportEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final controller = context.read<AdminSettingsController>();
      final config = AppConfig(
        appVersion: _appVersionController.text,
        maintenanceMode: _maintenanceMode,
        supportEmail: _supportEmailController.text,
      );

      final success = await controller.updateAppConfig(config);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Configuration updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                controller.error ?? 'Failed to update configuration',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AdminSettingsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'App Configuration',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<AppConfig>(
        stream: controller.getAppConfigStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final config =
              snapshot.data ??
              AppConfig(
                appVersion: 'v2.4.0',
                maintenanceMode: false,
                supportEmail: 'support@kisanmitra.com',
              );

          // Update controllers with current values
          if (_appVersionController.text.isEmpty) {
            _appVersionController.text = config.appVersion;
          }
          if (_supportEmailController.text.isEmpty) {
            _supportEmailController.text = config.supportEmail;
          }
          if (!_isLoading) {
            _maintenanceMode = config.maintenanceMode;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'System Configuration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage application-wide settings',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // App Version
                      const Text(
                        'App Version',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _appVersionController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter app version';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'e.g. v2.4.0',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.info_outline),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Support Email
                      const Text(
                        'Support Email',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _supportEmailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter support email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'support@example.com',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Maintenance Mode
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _maintenanceMode
                              ? const Color(0xFFFFF3E0)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _maintenanceMode
                                  ? Icons.warning_amber
                                  : Icons.check_circle_outline,
                              color: _maintenanceMode
                                  ? const Color(0xFFFF9800)
                                  : const Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Maintenance Mode',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _maintenanceMode
                                        ? 'App is in maintenance mode'
                                        : 'App is running normally',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _maintenanceMode,
                              onChanged: (value) {
                                setState(() {
                                  _maintenanceMode = value;
                                });
                              },
                              activeColor: const Color(0xFFFF9800),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSaveConfig,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
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
                              : const Text(
                                  'Save Configuration',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Warning
                if (_maintenanceMode)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFF44336),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'When maintenance mode is enabled, users may see a maintenance message',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFF44336),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
