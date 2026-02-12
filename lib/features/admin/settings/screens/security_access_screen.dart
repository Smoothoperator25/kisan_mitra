import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin_settings_model.dart';

class SecurityAccessScreen extends StatelessWidget {
  const SecurityAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Security & Access Control',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('roles').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final roles = snapshot.data?.docs ?? [];

          if (roles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'No roles configured',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
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
                  children: const [
                    Text(
                      'Role Permissions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Manage access permissions for different user roles',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Roles List
              ...roles.map((doc) {
                final role = UserRole.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );
                return _buildRoleCard(context, role);
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, UserRole role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role Name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  role.roleName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                onPressed: () {
                  _showEditDialog(context, role);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Permissions
          _buildPermissionRow(
            'Approve Stores',
            role.permissions.canApproveStores,
          ),
          _buildPermissionRow(
            'Edit Fertilizers',
            role.permissions.canEditFertilizers,
          ),
          _buildPermissionRow('View Reports', role.permissions.canViewReports),
          _buildPermissionRow('Manage Users', role.permissions.canManageUsers),
        ],
      ),
    );
  }

  Widget _buildPermissionRow(String label, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: enabled ? const Color(0xFF4CAF50) : Colors.grey[300],
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: enabled ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserRole role) {
    bool canApproveStores = role.permissions.canApproveStores;
    bool canEditFertilizers = role.permissions.canEditFertilizers;
    bool canViewReports = role.permissions.canViewReports;
    bool canManageUsers = role.permissions.canManageUsers;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit ${role.roleName} Permissions'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Can Approve Stores'),
                    value: canApproveStores,
                    onChanged: (value) {
                      setState(() => canApproveStores = value);
                    },
                    activeColor: const Color(0xFF4CAF50),
                  ),
                  SwitchListTile(
                    title: const Text('Can Edit Fertilizers'),
                    value: canEditFertilizers,
                    onChanged: (value) {
                      setState(() => canEditFertilizers = value);
                    },
                    activeColor: const Color(0xFF4CAF50),
                  ),
                  SwitchListTile(
                    title: const Text('Can View Reports'),
                    value: canViewReports,
                    onChanged: (value) {
                      setState(() => canViewReports = value);
                    },
                    activeColor: const Color(0xFF4CAF50),
                  ),
                  SwitchListTile(
                    title: const Text('Can Manage Users'),
                    value: canManageUsers,
                    onChanged: (value) {
                      setState(() => canManageUsers = value);
                    },
                    activeColor: const Color(0xFF4CAF50),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newPermissions = RolePermissions(
                      canApproveStores: canApproveStores,
                      canEditFertilizers: canEditFertilizers,
                      canViewReports: canViewReports,
                      canManageUsers: canManageUsers,
                    );

                    final updatedRole = UserRole(
                      id: role.id,
                      roleName: role.roleName,
                      permissions: newPermissions,
                    );

                    try {
                      await FirebaseFirestore.instance
                          .collection('roles')
                          .doc(role.id)
                          .update(updatedRole.toFirestore());

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Permissions updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
