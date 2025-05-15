import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/job_detail_screen.dart';

class PendingProposalsScreen extends StatefulWidget {
  const PendingProposalsScreen({super.key});

  @override
  State<PendingProposalsScreen> createState() => _PendingProposalsScreenState();
}

class _PendingProposalsScreenState extends State<PendingProposalsScreen> {
  final ScrollController _scrollController = ScrollController();
  final int _perPage = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
    bool _isInitialLoading = true;

  final List<DocumentSnapshot> _allProposals = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadInitialProposals();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProposals() async {
        setState(() => _isInitialLoading = true);

    final query = _firestore
        .collection('proposals')
        .where(
          'freelancerId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .limit(_perPage);

    final snapshot = await query.get();
    setState(() {
      _allProposals.addAll(snapshot.docs);
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length >= _perPage;
            _isInitialLoading = false;

    });
  }

  Future<void> _loadMoreProposals() async {
    if (!_hasMore || _isLoadingMore || _lastDocument == null) return;

    setState(() => _isLoadingMore = true);

    final query = _firestore
        .collection('proposals')
        .where(
          'freelancerId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(_lastDocument!)
        .limit(_perPage);

    final snapshot = await query.get();
    setState(() {
      _allProposals.addAll(snapshot.docs);
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length >= _perPage;
      _isLoadingMore = false;
    });
  }

   void _scrollListener() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      // ---------------------------------------------------------
      // Load more only when at bottom (not at top)
      _loadMoreProposals();
    }
  }

  // void _scrollListener() {
  //   if (_scrollController.offset >=
  //           _scrollController.position.maxScrollExtent &&
  //       !_scrollController.position.outOfRange) {
  //     _loadMoreProposals();
  //   }
  // }

  Map<String, List<DocumentSnapshot>> _groupProposalsByDate() {
    final grouped = <String, List<DocumentSnapshot>>{};
    for (final doc in _allProposals) {
      final data = doc.data() as Map<String, dynamic>;
      final ts = data['createdAt'] as Timestamp?;
      final date = ts?.toDate() ?? DateTime.now();
      final dateKey = _getDateGroupKey(date);
      grouped.putIfAbsent(dateKey, () => []).add(doc);
    }
    return grouped;
  }

  String _getDateGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAfter(today)) return 'Today';
    if (date.isAfter(yesterday)) return 'Yesterday';
    if (date.isAfter(today.subtract(const Duration(days: 7))))
      return 'This Week';
    return DateFormat('MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isInitialLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Proposals')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final groupedProposals = _groupProposalsByDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Proposals'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.surface.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
              colorScheme.primary.withOpacity(0.05),
              colorScheme.surface.withOpacity(0.1),
            ],
          ),
        ),
        child:
            _allProposals.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        size: 64,
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Pending Proposals',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : AnimationLimiter(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedProposals.length * 2 + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == groupedProposals.length * 2 && _hasMore) {
                        return _buildLoadingIndicator();
                      }

                      if (index.isOdd) {
                        final groupIndex = index ~/ 2;
                        final groupKey = groupedProposals.keys.elementAt(
                          groupIndex,
                        );
                        return _buildDateHeader(groupKey);
                      }

                      final groupIndex = index ~/ 2;
                      final groupKey = groupedProposals.keys.elementAt(
                        groupIndex,
                      );
                      final proposals = groupedProposals[groupKey]!;

                      return AnimationConfiguration.staggeredList(
                        position: groupIndex,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Column(
                              children:
                                  proposals
                                      .map(
                                        (doc) =>
                                            _buildProposalCard(doc, context),
                                      )
                                      .toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }

  Widget _buildDateHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 1,
              color: Colors.grey[300],
              endIndent: 10,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Expanded(
            child: Divider(thickness: 1, color: Colors.grey[300], indent: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalCard(DocumentSnapshot doc, BuildContext context) {
    final theme = Theme.of(context);
    final data = doc.data() as Map<String, dynamic>;
    final jobId = data['jobId'] as String? ?? '';
    final title = data['title'] as String? ?? 'Untitled Proposal';
    final bid = (data['bid'] as num?)?.toDouble() ?? 0.0;
    final ts = data['createdAt'] as Timestamp?;
    final date = ts?.toDate();

    return AnimationConfiguration.staggeredList(
      position: _allProposals.indexOf(doc),
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        horizontalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surface,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 400),
                      pageBuilder:
                          (_, __, ___) => JobDetailScreen(jobId: jobId),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.5, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
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
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.hourglass_top_rounded,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'PENDING',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildDetailItem(
                            icon: Icons.attach_money_rounded,
                            value: '\$${bid.toStringAsFixed(2)}',
                            label: 'Bid Amount',
                            color: Colors.green,
                          ),
                          const SizedBox(width: 24),
                          _buildDetailItem(
                            icon: Icons.access_time_rounded,
                            value:
                                date != null
                                    ? DateFormat('MMM dd, yyyy').format(date)
                                    : 'N/A',
                            label: 'Submitted',
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
