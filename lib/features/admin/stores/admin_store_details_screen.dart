import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/admin_data_model.dart';
import 'admin_stores_controller.dart';

class AdminStoreDetailsScreen extends StatefulWidget {
  final StoreData store;

  const AdminStoreDetailsScreen({
    super.key,
    required this.store,
  });

  @override
  State<AdminStoreDetailsScreen> createState() =>
      _AdminStoreDetailsScreenState();
}

class _AdminStoreDetailsScreenState extends State<AdminStoreDetailsScreen> {
  final AdminStoresController _controller = AdminStoresController();
  bool _isUpdating = false;

  Future<void> _approveStore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Store'),
        content: Text(
          'Are you sure you want to approve ${widget.store.storeName}? This will allow them to appear in farmer searches.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isUpdating = true);
      try {
        await _controller.approveStore(
          widget.store.id,
          widget.store.storeName,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Store approved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUpdating = false);
        }
      }
    }
  }

  Future<void> _rejectStore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Store'),
        content: Text(
          'Are you sure you want to reject ${widget.store.storeName}? They will not appear in searches.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isUpdating = true);
      try {
        await _controller.rejectStore(
          widget.store.id,
          widget.store.storeName,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Store rejected'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUpdating = false);
        }
      }
    }
  }

  Future<void> _deleteStore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Store'),
        content: Text(
          'Are you sure you want to permanently delete ${widget.store.storeName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isUpdating = true);
      try {
        await _controller.deleteStore(widget.store.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Store deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUpdating = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Store Details'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'approve') {
                _approveStore();
              } else if (value == 'reject') {
                _rejectStore();
              } else if (value == 'delete') {
                _deleteStore();
              }
            },
            itemBuilder: (context) => [
              if (!widget.store.isVerified)
                const PopupMenuItem(
                  value: 'approve',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text('Approve'),
                    ],
                  ),
                ),
              if (!widget.store.isRejected)
                const PopupMenuItem(
                  value: 'reject',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text('Reject'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isUpdating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  _buildStatusBadge(),
                  const SizedBox(height: 20),

                  // Store Information
                  _buildInfoCard(
                    title: 'Store Information',
                    icon: Icons.store,
                    children: [
                      _buildInfoRow('Store Name', widget.store.storeName),
                      _buildInfoRow('Owner Name', widget.store.ownerName),
                      _buildInfoRow(
                        'Phone',
                        widget.store.phone.isEmpty
                            ? 'Not provided'
                            : widget.store.phone,
                      ),
                      _buildInfoRow(
                        'Registered',
                        DateFormat('MMM dd, yyyy')
                            .format(widget.store.createdAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location Information
                  _buildInfoCard(
                    title: 'Location',
                    icon: Icons.location_on,
                    children: [
                      _buildInfoRow(
                        'State',
                        widget.store.state.isEmpty
                            ? 'Not provided'
                            : widget.store.state,
                      ),
                      _buildInfoRow(
                        'City',
                        widget.store.city.isEmpty
                            ? 'Not provided'
                            : widget.store.city,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (widget.store.isPending) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUpdating ? null : _approveStore,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUpdating ? null : _rejectStore,
                            icon: const Icon(Icons.cancel),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (widget.store.isVerified)
                    ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _rejectStore,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject Store'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),

                  if (widget.store.isRejected)
                    ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _approveStore,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve Store'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),

                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isUpdating ? null : _deleteStore,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Store'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    if (widget.store.isRejected) {
      bgColor = Colors.red[50]!;
      textColor = Colors.red[800]!;
      icon = Icons.cancel;
      text = 'Rejected';
    } else if (widget.store.isVerified) {
      bgColor = Colors.green[50]!;
      textColor = Colors.green[800]!;
      icon = Icons.verified;
      text = 'Verified';
    } else {
      bgColor = Colors.orange[50]!;
      textColor = Colors.orange[800]!;
      icon = Icons.pending;
      text = 'Pending Verification';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
