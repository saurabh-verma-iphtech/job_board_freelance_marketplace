import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/edit_job_client.dart';

// Riverpod provider for the job document stream
final jobDocumentProvider = StreamProvider.family<DocumentSnapshot?, String>((
  ref,
  jobId,
) {
  return FirebaseFirestore.instance.collection('jobs').doc(jobId).snapshots();
});

class ClientJobDetailScreen extends ConsumerWidget {
  final String jobId;
  const ClientJobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDocumentProvider(jobId));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: jobAsync.when(
        loading: () => _buildLoadingScreen(),
        error: (error, _) => _buildErrorScreen(error),
        data:
            (document) =>
                document?.exists == true
                    ? _buildContentScreen(context, document!)
                    : _buildNotFoundScreen(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Loading Job Details...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 20),
            Text(
              'Error loading job: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.blue, size: 50),
            const SizedBox(height: 20),
            Text(
              'Job not found',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentScreen(BuildContext context, DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final title = data['title'] ?? 'Untitled';
    final description = data['description'] ?? '';
    final category = data['category'] ?? 'General';
    final budget = data['budget']?.toString() ?? '0';
    final status = data['status'] ?? 'open';
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
                backgroundColor: theme.scaffoldBackgroundColor,

        actions: _buildAppBarActions(context, document.reference),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedHeader(theme, title),
              const SizedBox(height: 24),
              _buildDetailCards(theme, category, budget, status, createdAt),
              const SizedBox(height: 24),
              _buildDescriptionSection(theme, description),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(
    BuildContext context,
    DocumentReference docRef,
  ) {
    return [
      IconButton(
        onPressed: () => _navigateToEditScreen(context),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: const Icon(Icons.edit,color: Colors.blue, key: ValueKey('edit')),
        ),
      ),
      IconButton(
        onPressed: () => _confirmDelete(context, docRef),
        icon: Icon(Icons.delete,color: Colors.redAccent,),
      ),
    ];
  }

  Widget _buildAnimatedHeader(ThemeData theme, String title) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: 1,
      child: Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDetailCards(
    ThemeData theme,
    String category,
    String budget,
    String status,
    DateTime? createdAt,
  ) {
    return Column(
      children: [
        _buildDetailCard(
          icon: Icons.category,
          title: 'Category',
          value: category,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.attach_money,
          title: 'Budget',
          value: '\$$budget',
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: status == 'open' ? Icons.lock_open : Icons.lock_outline,
          title: 'Status',
          value: status.toUpperCase(),
          color: status == 'open' ? Colors.orange : Colors.red,
        ),
        if (createdAt != null) ...[
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.calendar_today,
            title: 'Posted On',
            value: createdAt.toLocal().toString().split(' ')[0],
            color: Colors.purple,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(description, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => EditJobScreen(jobId: jobId),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DocumentReference docRef,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Job?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await docRef.delete();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
