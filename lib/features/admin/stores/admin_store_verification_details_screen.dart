import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'admin_stores_controller.dart';

class AdminStoreVerificationDetailsScreen extends StatefulWidget {
  final String storeId;

  const AdminStoreVerificationDetailsScreen({
    super.key,
    required this.storeId,
  });

  @override
  State<AdminStoreVerificationDetailsScreen> createState() =>
      _AdminStoreVerificationDetailsScreenState();
}

class _AdminStoreVerificationDetailsScreenState
    extends State<AdminStoreVerificationDetailsScreen> {
  final AdminStoresController _controller = AdminStoresController();
  bool _isLoading = true;
  bool _isUpdating = false;
  Map<String, dynamic>? _storeData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStoreDetails();
  }

  Future<void> _loadStoreDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(widget.storeId)
          .get();

      if (doc.exists) {
        setState(() {
          _storeData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Store not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading store details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveStore() async {
    if (_storeData == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Store'),
        content: Text(
          'Are you sure you want to approve ${_storeData!['storeName']}? This will allow them to appear in farmer searches.',
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
          widget.storeId,
          _storeData!['storeName'] ?? 'Unknown Store',
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
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
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
    if (_storeData == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Store'),
        content: Text(
          'Are you sure you want to reject ${_storeData!['storeName']}? They will not appear in searches.',
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
          widget.storeId,
          _storeData!['storeName'] ?? 'Unknown Store',
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
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUpdating = false);
        }
      }
    }
  }

  String _getStatusText() {
    if (_storeData == null) return 'Unknown';
    final isVerified = _storeData!['isVerified'] ?? false;
    final isRejected = _storeData!['isRejected'] ?? false;

    if (isVerified) return 'VERIFIED';
    if (isRejected) return 'REJECTED';
    return 'PENDING';
  }

  Color _getStatusColor() {
    if (_storeData == null) return Colors.grey;
    final isVerified = _storeData!['isVerified'] ?? false;
    final isRejected = _storeData!['isRejected'] ?? false;

    if (isVerified) return const Color(0xFF10B981);
    if (isRejected) return const Color(0xFFEF4444);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Store Verification Details'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadStoreDetails,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildStoreInfo(),
                      const SizedBox(height: 16),
                      _buildLocationInfo(),
                      const SizedBox(height: 16),
                      _buildContactInfo(),
                      const SizedBox(height: 16),
                      _buildDocuments(),
                      const SizedBox(height: 16),
                      _buildActions(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF6366F1).withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _storeData?['storeName'] ?? 'Unknown Store',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                _storeData?['ownerName'] ?? 'Unknown Owner',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                'Registered: ${_formatDate(_storeData?['createdAt'])}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          const Text(
            'STORE INFORMATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.store,
            label: 'Store Name',
            value: _storeData?['storeName'] ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.person,
            label: 'Owner Name',
            value: _storeData?['ownerName'] ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.badge,
            label: 'License Number',
            value: _storeData?['licenseNumber'] ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.receipt,
            label: 'GST Number',
            value: _storeData?['gstNumber'] ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          const Text(
            'LOCATION DETAILS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Address',
            value: _storeData?['address'] ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.location_city,
            label: 'City',
            value: _storeData?['city'] ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.map,
            label: 'State',
            value: _storeData?['state'] ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.pin_drop,
            label: 'Pincode',
            value: _storeData?['pincode'] ?? 'N/A',
          ),
          if (_storeData?['latitude'] != null && _storeData?['longitude'] != null)
            _buildInfoRow(
              icon: Icons.my_location,
              label: 'Coordinates',
              value:
                  '${_storeData!['latitude']?.toStringAsFixed(6)}, ${_storeData!['longitude']?.toStringAsFixed(6)}',
            ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          const Text(
            'CONTACT INFORMATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.email,
            label: 'Email',
            value: _storeData?['email'] ?? 'N/A',
          ),
          _buildInfoRow(
            icon: Icons.phone,
            label: 'Phone',
            value: _storeData?['phone'] ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildDocuments() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          const Text(
            'DOCUMENTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          if (_storeData?['licenseImageUrl'] != null)
            _buildDocumentRow(
              icon: Icons.description,
              label: 'License Document',
              url: _storeData!['licenseImageUrl'],
            ),
          if (_storeData?['gstImageUrl'] != null)
            _buildDocumentRow(
              icon: Icons.receipt_long,
              label: 'GST Document',
              url: _storeData!['gstImageUrl'],
            ),
          if (_storeData?['licenseImageUrl'] == null &&
              _storeData?['gstImageUrl'] == null)
            const Text(
              'No documents uploaded',
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final isVerified = _storeData?['isVerified'] ?? false;
    final isRejected = _storeData?['isRejected'] ?? false;
    final isPending = !isVerified && !isRejected;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          const Text(
            'ACTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          if (isPending || isRejected)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : _approveStore,
                icon: _isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isUpdating ? 'Processing...' : 'Approve Store'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          if (isPending || isVerified) ...[
            if (isPending || isRejected) const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : _rejectStore,
                icon: _isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cancel),
                label: Text(_isUpdating ? 'Processing...' : 'Reject Store'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
          if (isVerified)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This store is verified and appears in farmer searches',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isRejected)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This store is rejected and will not appear in searches',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6366F1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow({
    required IconData icon,
    required String label,
    required String url,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6366F1)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Open document viewer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document viewer coming soon'),
                ),
              );
            },
            child: const Text('VIEW'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = (timestamp as Timestamp).toDate();
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }
}
