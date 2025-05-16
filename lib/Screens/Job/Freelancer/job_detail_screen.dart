import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/clientFreeProfile.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/submit_proposal_F.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId;
  JobDetailScreen({super.key, required this.jobId});

  /// Riverpod provider: stream a single job document by ID
  final jobDocumentProvider = StreamProvider.family<
    DocumentSnapshot<Map<String, dynamic>>?,
    String
  >((ref, jobId) {
    return FirebaseFirestore.instance.collection('jobs').doc(jobId).snapshots();
  });

  /// Riverpod provider: stream a single user document by ID
  final userDocumentProvider =
      StreamProvider.family<DocumentSnapshot<Map<String, dynamic>>?, String>((
        ref,
        userId,
      ) {
        return FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots();
      });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDocumentProvider(jobId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: jobAsync.when(
        loading: () => _buildLoadingScreen(theme),
        error: (error, _) => _buildErrorScreen(error),
        data: (jobSnap) {
          if (jobSnap == null || !jobSnap.exists) {
            return _buildNotFoundScreen();
          }
          final jobData = jobSnap.data()!;
          final clientId = jobData['createdBy'] as String? ?? '';
          final status = jobData['status'] as String?;

          final clientAsync = ref.watch(userDocumentProvider(clientId));
          return clientAsync.when(
            loading: () => _buildLoadingScreen(theme),
            error: (error, _) => _buildErrorScreen(error),
            data: (userSnap) {
              if (userSnap == null || !userSnap.exists) {
                return _buildNotFoundScreen(message: 'Client not found');
              }
              final userData = userSnap.data()!;

              return Scaffold(
                appBar: AppBar(
                  title: const Text('Job & Client Details'),
                  backgroundColor: theme.scaffoldBackgroundColor,
                  elevation: 0,
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
                        _buildClientProfileCard(userData, context,clientId),
                        const SizedBox(height: 24),
                        _buildSectionHeader(theme, 'Job Information'),
                        _buildJobDetails(theme, jobData),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // only show Apply FAB if job is open and freelancer hasn't applied
                floatingActionButton:
                    status == 'open'
                        ? FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('proposals')
                                  .where('jobId', isEqualTo: jobId)
                                  .where(
                                    'freelancerId',
                                    isEqualTo:
                                        FirebaseAuth.instance.currentUser!.uid,
                                  )
                                  .limit(1)
                                  .get(),
                          builder: (context, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox();
                            }

                            final jobStatus =
                                jobData['status'] as String? ?? '';
                            final hasApplied =
                                snap.data?.docs.isNotEmpty ?? false;
                            final isEligible =
                                !hasApplied && jobStatus == 'open';

                            return isEligible
                                ? FloatingActionButton.extended(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SubmitProposalScreen(),
                                        settings: RouteSettings(
                                          arguments: jobId,
                                        ),
                                      ),
                                    );
                                  },
                                  label: const Text('Apply Now'),
                                  icon: const Icon(Icons.send),
                                )
                                : const SizedBox();
                          },
                        )
                        : null,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildClientProfileCard(
    Map<String, dynamic> userData,
    BuildContext context,
      String clientId, // Add this parameter
  ) {
    final photoUrl = userData['photoUrl'] as String?;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClientDetailScreen(clientId: clientId,),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData['name'] ?? 'Unknown Client',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['title'] ?? 'Client',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(ThemeData theme) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading Details...',
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
              'Error: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundScreen({String message = 'Job not found'}) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.blue, size: 50),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildJobDetails(ThemeData theme, Map<String, dynamic> jobData) {
    return Column(
      children: [
        _buildDetailCard(
          icon: Icons.work_outline,
          title: 'Title',
          value: jobData['title'] as String? ?? '—',
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.category,
          title: 'Category',
          value: jobData['category'] as String? ?? '—',
          color: Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.attach_money,
          title: 'Budget',
          value: '\$${jobData['budget']?.toString() ?? '0'}',
          color: Colors.redAccent,
        ),
        const SizedBox(height: 12),

        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(235, 208, 208, 206),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.description),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (jobData['description'] as String? ?? '—')
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: _getStatusIcon(jobData['status'] as String?),
          title: 'Status',
          value: (jobData['status'] as String? ?? '—').toUpperCase(),
          color: _getStatusColor(jobData['status'] as String?),
        ),
        if (jobData['createdAt'] is Timestamp) ...[
          const SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.calendar_today,
            title: 'Posted On',
            value: DateFormat.yMMMd().format(
              (jobData['createdAt'] as Timestamp).toDate(),
            ),
            color: Colors.orange,
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
            Expanded(
              child: Column(
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return Icons.lock_open;
      case 'closed':
        return Icons.lock_outline;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
