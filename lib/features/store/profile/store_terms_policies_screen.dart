import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../l10n/app_localizations.dart';

class StoreTermsPoliciesScreen extends StatelessWidget {
  const StoreTermsPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).termsOfService,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF2E7D32),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2E7D32),
            tabs: [
              Tab(text: AppLocalizations.of(context).termsOfService),
              Tab(text: AppLocalizations.of(context).privacyPolicy),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LegalDocumentView(documentId: 'terms'),
            _LegalDocumentView(documentId: 'privacy'),
          ],
        ),
      ),
    );
  }
}

class _LegalDocumentView extends StatelessWidget {
  final String documentId;

  const _LegalDocumentView({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('legalDocuments')
          .doc(documentId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              AppLocalizations.of(
                context,
              ).errorPrefix(snapshot.error.toString()),
            ),
          );
        }

        final content = snapshot.data?.data() as Map<String, dynamic>?;
        final text =
            content?['content'] as String? ??
            AppLocalizations.of(context).noContentAvailable;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }
}
