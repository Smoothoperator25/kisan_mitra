import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAccessControlScreen extends StatelessWidget {
  const UserAccessControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'User Access Control',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF4CAF50),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF4CAF50),
            tabs: [
              Tab(text: 'Admin Users'),
              Tab(text: 'Store Users'),
            ],
          ),
        ),
        body: const TabBarView(children: [_AdminUsersTab(), _StoreUsersTab()]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddUserDialog(context),
          backgroundColor: const Color(0xFF4CAF50),
          label: const Text('Add User'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    String selectedRole = 'Admin';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Admin', 'Moderator', 'Viewer']
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      // In production, you would create the user in Firebase Auth first
                      // For now, we'll just add to adminUsers collection
                      await FirebaseFirestore.instance
                          .collection('adminUsers')
                          .add({
                            'name': nameController.text,
                            'email': emailController.text,
                            'role': selectedRole.toLowerCase(),
                            'accessLevel': selectedRole == 'Admin'
                                ? 'FULL ACCESS'
                                : 'LIMITED ACCESS',
                            'isOnline': false,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User added successfully'),
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
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AdminUsersTab extends StatelessWidget {
  const _AdminUsersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('adminUsers')
          .where('role', isEqualTo: 'admin')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data?.docs ?? [];

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'No admin users found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final userId = users[index].id;
            return _buildUserCard(context, userData, userId, 'admin');
          },
        );
      },
    );
  }
}

class _StoreUsersTab extends StatelessWidget {
  const _StoreUsersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('stores').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final stores = snapshot.data?.docs ?? [];

        if (stores.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'No store users found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final storeData = stores[index].data() as Map<String, dynamic>;
            final storeId = stores[index].id;
            return _buildUserCard(context, storeData, storeId, 'store');
          },
        );
      },
    );
  }
}

Widget _buildUserCard(
  BuildContext context,
  Map<String, dynamic> userData,
  String userId,
  String userType,
) {
  final name = userData['name'] ?? userData['storeName'] ?? 'Unknown';
  final email = userData['email'] ?? 'No email';
  final role = userData['role'] ?? userType;
  final status =
      userData['status'] ?? userData['verificationStatus'] ?? 'active';

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
    child: Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFE8F5E9),
          child: Icon(
            userType == 'admin' ? Icons.admin_panel_settings : Icons.store,
            color: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: status == 'approved' || status == 'active'
                          ? const Color(0xFF4CAF50)
                          : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Actions
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) async {
            if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete User'),
                    content: const Text(
                      'Are you sure you want to delete this user?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true && context.mounted) {
                try {
                  await FirebaseFirestore.instance
                      .collection(userType == 'admin' ? 'adminUsers' : 'stores')
                      .doc(userId)
                      .delete();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            } else if (value == 'disable') {
              try {
                await FirebaseFirestore.instance
                    .collection(userType == 'admin' ? 'adminUsers' : 'stores')
                    .doc(userId)
                    .update({'status': 'disabled'});

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User disabled successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'disable',
              child: Text('Disable User'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete User'),
            ),
          ],
        ),
      ],
    ),
  );
}
