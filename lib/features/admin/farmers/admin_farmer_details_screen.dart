import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/admin_data_model.dart';
import 'admin_farmers_controller.dart';

class AdminFarmerDetailsScreen extends StatefulWidget {
  final FarmerData farmer;

  const AdminFarmerDetailsScreen({
    super.key,
    required this.farmer,
  });

  @override
  State<AdminFarmerDetailsScreen> createState() =>
      _AdminFarmerDetailsScreenState();
}

class _AdminFarmerDetailsScreenState extends State<AdminFarmerDetailsScreen> {
  final AdminFarmersController _controller = AdminFarmersController();
  bool _isUpdating = false;

  Future<void> _toggleStatus() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.farmer.isActive ? 'Deactivate Farmer' : 'Activate Farmer'),
        content: Text(
          widget.farmer.isActive
              ? 'Are you sure you want to deactivate ${widget.farmer.name}? They won\'t be able to access the app.'
              : 'Are you sure you want to activate ${widget.farmer.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.farmer.isActive ? Colors.orange : Colors.green,
            ),
            child: Text(widget.farmer.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isUpdating = true);
      try {
        await _controller.toggleFarmerStatus(
          widget.farmer.id,
          widget.farmer.isActive,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.farmer.isActive
                    ? 'Farmer deactivated successfully'
                    : 'Farmer activated successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to refresh list
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

  Future<void> _deleteFarmer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farmer'),
        content: Text(
          'Are you sure you want to permanently delete ${widget.farmer.name}? This action cannot be undone.',
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
        await _controller.deleteFarmer(widget.farmer.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Farmer deleted successfully'),
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
        title: const Text('Farmer Details'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle') {
                _toggleStatus();
              } else if (value == 'delete') {
                _deleteFarmer();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      widget.farmer.isActive
                          ? Icons.block
                          : Icons.check_circle,
                      color: widget.farmer.isActive ? Colors.orange : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.farmer.isActive ? 'Deactivate' : 'Activate',
                    ),
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

                  // Personal Information
                  _buildInfoCard(
                    title: 'Personal Information',
                    icon: Icons.person,
                    children: [
                      _buildInfoRow('Name', widget.farmer.name),
                      _buildInfoRow('Phone', widget.farmer.phone.isEmpty ? 'Not provided' : widget.farmer.phone),
                      _buildInfoRow(
                        'Joined',
                        DateFormat('MMM dd, yyyy').format(widget.farmer.createdAt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location Information
                  _buildInfoCard(
                    title: 'Location',
                    icon: Icons.location_on,
                    children: [
                      _buildInfoRow('State', widget.farmer.state.isEmpty ? 'Not provided' : widget.farmer.state),
                      _buildInfoRow('City', widget.farmer.city.isEmpty ? 'Not provided' : widget.farmer.city),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Crops Information
                  _buildInfoCard(
                    title: 'Crops',
                    icon: Icons.grass,
                    children: [
                      if (widget.farmer.crops.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No crops added yet',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        ...widget.farmer.crops.map((crop) => _buildCropTile(crop)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isUpdating ? null : _toggleStatus,
                          icon: Icon(
                            widget.farmer.isActive ? Icons.block : Icons.check_circle,
                          ),
                          label: Text(
                            widget.farmer.isActive ? 'Deactivate' : 'Activate',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: widget.farmer.isActive
                                ? Colors.orange
                                : Colors.green,
                            side: BorderSide(
                              color: widget.farmer.isActive
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating ? null : _deleteFarmer,
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.farmer.isActive ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.farmer.isActive ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.farmer.isActive ? Icons.check_circle : Icons.block,
            color: widget.farmer.isActive ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.farmer.isActive ? 'Active Account' : 'Inactive Account',
            style: TextStyle(
              color: widget.farmer.isActive ? Colors.green[800] : Colors.orange[800],
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

  Widget _buildCropTile(Crop crop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              crop.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${crop.acres} acres',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
