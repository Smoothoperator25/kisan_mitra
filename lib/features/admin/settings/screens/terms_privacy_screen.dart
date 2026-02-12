import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({super.key});

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  final _termsController = TextEditingController();
  final _privacyController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _termsController.dispose();
    _privacyController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);

    try {
      final termsDoc = await FirebaseFirestore.instance
          .collection('legalDocuments')
          .doc('terms')
          .get();

      final privacyDoc = await FirebaseFirestore.instance
          .collection('legalDocuments')
          .doc('privacy')
          .get();

      if (mounted) {
        _termsController.text = termsDoc.data()?['content'] ?? '';
        _privacyController.text = privacyDoc.data()?['content'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading documents: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveDocuments() async {
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('legalDocuments')
          .doc('terms')
          .set({
            'content': _termsController.text,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance
          .collection('legalDocuments')
          .doc('privacy')
          .set({
            'content': _privacyController.text,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documents saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving documents: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

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
            'Terms & Privacy Policy',
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
              Tab(text: 'Terms of Service'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildEditor(
                    'Terms of Service',
                    _termsController,
                    'Enter terms of service content...',
                  ),
                  _buildEditor(
                    'Privacy Policy',
                    _privacyController,
                    'Enter privacy policy content...',
                  ),
                ],
              ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(
    String title,
    TextEditingController controller,
    String hint,
  ) {
    return ListView(
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                maxLines: 20,
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Changes will be visible to all users immediately after saving',
                  style: TextStyle(fontSize: 13, color: Color(0xFF2196F3)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
