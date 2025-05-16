import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final userDocumentProvider = StreamProvider.family<
  DocumentSnapshot<Map<String, dynamic>>?,
  String
>((ref, userId) {
  return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
});

class ClientDetailScreen extends ConsumerWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDocumentProvider(clientId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Client Profile'), elevation: 0),
      body: userAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (userSnap) {
          if (!userSnap!.exists) return Center(child: Text('Client not found'));
          final userData = userSnap.data()!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(userData, theme),
                const SizedBox(height: 24),
                _buildCompanySection(userData),
                const SizedBox(height: 24),
                _buildContactSection(userData),
                if (userData['description'] != null) ...[
                  const SizedBox(height: 24),
                  _buildDescriptionSection(userData),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData, ThemeData theme) {
    return SizedBox(
      width: 420,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    userData['photoUrl'] != null
                        ? NetworkImage(userData['photoUrl'])
                        : null,
                child:
                    userData['photoUrl'] == null
                        ? Icon(Icons.person, size: 50)
                        : null,
              ),
              const SizedBox(height: 16),
              Text(
                userData['name'] ?? 'Unknown Client',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userData['companyName'] ?? 'No Company',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              if (userData['address'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  userData['address'],
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanySection(Map<String, dynamic> userData) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.business, color: Colors.blue),
              title: Text(userData['company'] ?? 'No company information'),
              subtitle:
                  userData['website'] != null
                      ? TextButton(
                        onPressed: () => _launchWebsite(userData['website']),
                        child: Text(
                          userData['website'],
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(Map<String, dynamic> userData) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text(userData['email'] ?? 'No email provided'),
            ),
            if (userData['phone'] != null)
              ListTile(
                leading: Icon(Icons.phone, color: Colors.blue),
                title: Text(userData['phone']),
              ),
            if (userData['linkedin'] != null && userData['linkedin'] != '-')
              ListTile(
                leading: Icon(Icons.link, color: Colors.blue),
                title: Text('LinkedIn'),
                onTap: () => _launchWebsite(userData['linkedin']),
              ),
            if (userData['twitter'] != null && userData['twitter'] != '-')
              ListTile(
                leading: Icon(Icons.link, color: Colors.blue),
                title: Text('Twitter'),
                onTap: () => _launchWebsite(userData['twitter']),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(Map<String, dynamic> userData) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Company',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              userData['description'] ?? 'No description available',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  void _launchWebsite(String url) {
    // Implement website launching logic
  }
}
