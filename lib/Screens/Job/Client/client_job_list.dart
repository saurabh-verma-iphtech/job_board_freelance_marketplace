import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/edit_job_client.dart';
import 'package:job_board_freelance_marketplace/Services/theme_notifier.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class ClientJobsScreen extends ConsumerStatefulWidget {
  const ClientJobsScreen({super.key});

  @override
  _ClientJobsScreenState createState() => _ClientJobsScreenState();
}

class _ClientJobsScreenState extends ConsumerState<ClientJobsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeNotifier = ref.watch(themeNotifierProvider);
    final isDark = themeNotifier.mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posted Jobs'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorScheme.primary, colorScheme.surface],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [Colors.grey.shade900, Colors.grey.shade800]
                    : [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.background,
            ],
          ),
        ),
        child: _buildJobList(uid, theme),
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        child: FloatingActionButton(
          backgroundColor: isDark ? Colors.deepPurple : Colors.blue,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 28, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/post-job'),
        ),
      ),
    );
  }

  Widget _buildJobList(String uid, ThemeData theme) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('jobs')
              .where('createdBy', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (ctx, snap) {
        if (snap.hasError) {
          return Center(child: _buildErrorWidget(snap.error.toString(), theme));
        }

        if (snap.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoader();
        }

        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return _buildEmptyState(theme);
        }

        // Group jobs by week
        final Map<String, List<QueryDocumentSnapshot>> groupedJobs = {};
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final ts = data['createdAt'] as Timestamp?;
          if (ts != null) {
            final date = ts.toDate();
            final weekKey = _getWeekKey(date);
            groupedJobs.putIfAbsent(weekKey, () => []).add(doc);
          } else {
            // Handle jobs without a timestamp
            const weekKey = 'Unknown Date';
            groupedJobs.putIfAbsent(weekKey, () => []).add(doc);
          }
        }

        return AnimationLimiter(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: groupedJobs.length * 2, // *2 for dividers
            itemBuilder: (context, index) {
              if (index.isOdd) {
                // Divider between weeks
                final weekIndex = index ~/ 2;
                final weekKey = groupedJobs.keys.elementAt(weekIndex);
                return _buildWeekDivider(weekKey);
              }

              // Job cards for this week
              final weekIndex = index ~/ 2;
              final weekKey = groupedJobs.keys.elementAt(weekIndex);
              final jobs = groupedJobs[weekKey]!;

              return Column(
                children:
                    jobs.map((job) {
                      return AnimationConfiguration.staggeredList(
                        position: jobs.indexOf(job),
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _JobCard(
                                job: job,
                                theme: theme,
                                onDelete: () => _handleDeleteJob(job.id),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWeekDivider(String weekKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: 1, color: Colors.grey[400])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              weekKey,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Divider(thickness: 1, color: Colors.grey[400])),
        ],
      ),
    );
  }

  String _getWeekKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));

    if (date.isAfter(today)) {
      return 'Today';
    } else if (date.isAfter(yesterday)) {
      return 'Yesterday';
    } else if (date.isAfter(weekStart)) {
      return 'This Week';
    } else if (date.isAfter(lastWeekStart)) {
      return 'Last Week';
    } else {
      return DateFormat('MMMM yyyy').format(date);
    }
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder:
            (_, index) => Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 20),
        Text(
          'Error loading jobs:',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.red),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Curves.elasticOut,
            ),
            child: Icon(
              Icons.work_outline,
              size: 120,
              color: theme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Jobs Posted Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Start by posting your first job and find the perfect freelancer for your project!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteJob(String jobId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this job post?',
            ),
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
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Job deleted successfully'),
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

class _JobCard extends StatelessWidget {
  final QueryDocumentSnapshot job;
  final ThemeData theme;
  final VoidCallback onDelete;

  const _JobCard({
    required this.job,
    required this.theme,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final data = job.data() as Map<String, dynamic>;
    final jobId = job.id;
    final status = data['status'] ?? 'open';

    return GestureDetector(
      onTap:
          () => Navigator.pushNamed(
            context,
            '/client-job-detail',
            arguments: jobId,
          ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                theme.cardColor.withOpacity(0.9),
                theme.cardColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        data['title'] ?? 'Untitled Job',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusIndicator(status: status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data['description'] ?? 'No description provided',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.disabledColor,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoChip(
                      icon: Icons.attach_money,
                      value:
                          '\$${data['budget']?.toStringAsFixed(2) ?? '0.00'}',
                      color: Colors.green,
                    ),
                    _JobActionsMenu(
                      jobId: jobId,
                      status: status,
                      onDelete: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = status == 'open';
    final color = isActive ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.circle : Icons.circle_outlined,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobActionsMenu extends StatelessWidget {
  final String jobId;
  final String status;
  final VoidCallback onDelete;

  const _JobActionsMenu({
    required this.jobId,
    required this.status,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      onSelected: (choice) => _handleMenuChoice(choice, context),
      itemBuilder:
          (_) => [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_note, color: theme.primaryColor),
                title: Text('Edit', style: theme.textTheme.bodyMedium),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.redAccent),
                title: Text('Delete', style: theme.textTheme.bodyMedium),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: ListTile(
                leading: Icon(
                  status == 'open' ? Icons.lock_outline : Icons.lock_open,
                  color: status == 'open' ? Colors.orange : Colors.green,
                ),
                title: Text(
                  status == 'open' ? 'Close Job' : 'Reopen Job',
                  style: theme.textTheme.bodyMedium,
                ),
                dense: true,
              ),
            ),
          ],
    );
  }

  void _handleMenuChoice(String choice, BuildContext context) {
    switch (choice) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditJobScreen(jobId: jobId)),
        );
        break;
      case 'delete':
        onDelete();
        break;
      case 'toggle_status':
        _toggleJobStatus();
        break;
    }
  }

  void _toggleJobStatus() async {
    final newStatus = status == 'open' ? 'closed' : 'open';
    await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
      'status': newStatus,
    });
  }
}
