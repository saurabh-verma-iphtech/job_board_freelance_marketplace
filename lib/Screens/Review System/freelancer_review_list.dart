import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/clientFreeProfile.dart';

class FreelancerReviewListScreen extends ConsumerWidget {
  const FreelancerReviewListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Reviews'),
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.background,
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collectionGroup('reviews')
                  .where('subjectId', isEqualTo: currentUserId)
                  .where('subjectRole', isEqualTo: 'freelancer')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No reviews yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final reviewDoc = snapshot.data!.docs[index];
                final reviewData = reviewDoc.data() as Map<String, dynamic>;
                final clientId = reviewData['reviewerId'] as String;

                return FutureBuilder(
                  future: _getReviewDetails(reviewData),
                  builder: (
                    context,
                    AsyncSnapshot<Map<String, dynamic>> details,
                  ) {
                    if (details.connectionState == ConnectionState.waiting) {
                      return _buildReviewShimmer();
                    }

                    if (!details.hasData) {
                      return const SizedBox.shrink();
                    }

                    return _ReviewCard(
                      clientName:
                          details.data!['clientName'] ?? 'Unknown Client',
                      jobTitle: details.data!['jobTitle'] ?? 'Completed Job',
                      jobBid: details.data!['jobBid'] ?? 0.0,
                      rating: reviewData['rating'],
                      comment: reviewData['comment'],
                      date: (reviewData['createdAt'] as Timestamp).toDate(),
                      clientId: clientId,
                      isClientVersion: true,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getReviewDetails(
    Map<String, dynamic> review,
  ) async {
    final clientDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(review['reviewerId'])
            .get();

    final jobDoc =
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(review['jobId'])
            .get();
    final jobData = jobDoc.data()!;

    // Normalize budget to a double, whether it's stored as int or double.
    final rawBudget = jobData['budget'] as num;
    final budget = rawBudget.toDouble();

    return {
      'clientName': clientDoc.data()?['name'],
      'jobTitle': jobDoc.data()?['title'],
      'jobBid': budget,
    };
  }

  Widget _buildReviewShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      height: 150,
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final String clientName;
  final String jobTitle;
  final double jobBid;
  final double rating;
  final String comment;
  final DateTime date;
  final bool isClientVersion;
  final String clientId;

  const _ReviewCard({
    required this.clientName,
    required this.jobTitle,
    required this.jobBid,
    required this.rating,
    required this.comment,
    required this.date,
    required this.isClientVersion,
    required this.clientId,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovering) {
    setState(() => _isHovering = isHovering);
    if (isHovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.isClientVersion)
                        Flexible(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (_) => _handleHover(true),
                            onExit: (_) => _handleHover(false),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 1.0,
                                end: _isHovering ? 1.05 : 1.0,
                              ),
                              duration: const Duration(milliseconds: 150),
                              builder: (context, scale, child) {
                                return Transform.scale(
                                  scale: scale,
                                  child: child,
                                );
                              },
                              child: ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.person_outline,
                                  size: 18,
                                ),
                                label: Text(widget.clientName),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary
                                      .withOpacity(0.1),
                                  foregroundColor: colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (_, __, ___) => ClientDetailScreen(
                                            clientId: widget.clientId,
                                          ),
                                      transitionsBuilder: (
                                        _,
                                        animation,
                                        __,
                                        child,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      Text(
                        DateFormat('MMM dd, yy').format(widget.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Job Details
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.jobTitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade800,
                        ),
                      ),
                      // const SizedBox(width: 8),
                      Spacer(),
                      Text(
                        '\$${widget.jobBid.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating Bar
                  RatingBarIndicator(
                    rating: widget.rating,
                    itemCount: 5,
                    itemSize: 18,
                    itemBuilder:
                        (context, _) =>
                            Icon(Icons.star, color: Colors.amber.shade700),
                  ),
                  const SizedBox(height: 8),

                  // Comment
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      widget.comment,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
