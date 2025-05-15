import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/client_job_detail.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/job_detail_screen.dart';

class CompletedJobsScreen extends StatefulWidget {
  const CompletedJobsScreen({super.key});

  @override
  State<CompletedJobsScreen> createState() => _CompletedJobsScreenState();
}

class _CompletedJobsScreenState extends State<CompletedJobsScreen> {
  final ScrollController _scrollController = ScrollController();
  final int _perPage = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<DocumentSnapshot> _allContracts = [];

  String? _userRole;
  String? _uid;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _initializeUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    setState(() {
      _isInitialLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isInitialLoading = false;
      });
      return;
    }

    _uid = user.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    final role = userDoc.data()?['role']?.toString().toLowerCase();
    if (role == 'client' || role == 'freelancer') {
      setState(() => _userRole = role);
      await _loadInitialContracts();
    }

    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _loadInitialContracts() async {
    if (_userRole == null || _uid == null) return;

    final field = _userRole == 'client' ? 'clientId' : 'freelancerId';
    final query = FirebaseFirestore.instance
        .collection('contracts')
        .where(field, isEqualTo: _uid)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .limit(_perPage);

    final snapshot = await query.get();
    setState(() {
      _allContracts.addAll(snapshot.docs);
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length >= _perPage;
    });
  }

  Future<void> _loadMoreContracts() async {
    if (!_hasMore || _isLoadingMore || _userRole == null || _uid == null)
      return;

    setState(() => _isLoadingMore = true);

    final field = _userRole == 'client' ? 'clientId' : 'freelancerId';
    final query = FirebaseFirestore.instance
        .collection('contracts')
        .where(field, isEqualTo: _uid)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .startAfterDocument(_lastDocument!)
        .limit(_perPage);

    final snapshot = await query.get();
    setState(() {
      _allContracts.addAll(snapshot.docs);
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length >= _perPage;
      _isLoadingMore = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMoreContracts();
    }
  }

  Map<String, List<DocumentSnapshot>> _groupContractsByDate() {
    final grouped = <String, List<DocumentSnapshot>>{};
    for (final doc in _allContracts) {
      final data = doc.data() as Map<String, dynamic>;
      final ts = data['completedAt'] as Timestamp?;
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
    if (date.isAfter(today.subtract(const Duration(days: 7)))) {
      return 'This Week';
    }
    return DateFormat('MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final groupedContracts = _groupContractsByDate();

    // Full-screen loading while initializing
    if (_isInitialLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Completed Jobs')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // User not logged in
    if (_uid == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    // Invalid or unknown role
    if (_userRole == null) {
      return const Scaffold(
        body: Center(child: Text('Invalid or unknown role')),
      );
    }

    // No completed jobs found
    if (_allContracts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Completed Jobs')),
        body: const Center(child: Text('No completed jobs found')),
      );
    }

    // Render list of completed jobs
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Jobs')),
      body: AnimationLimiter(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: groupedContracts.length * 2 + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == groupedContracts.length * 2 && _hasMore) {
              return _buildLoadingIndicator();
            }

            if (index.isOdd) {
              final groupIndex = index ~/ 2;
              final groupKey = groupedContracts.keys.elementAt(groupIndex);
              return _buildDateHeader(groupKey);
            }

            final groupIndex = index ~/ 2;
            final groupKey = groupedContracts.keys.elementAt(groupIndex);
            final contracts = groupedContracts[groupKey]!;

            return AnimationConfiguration.staggeredList(
              position: groupIndex,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Column(
                    children:
                        contracts
                            .map((doc) => _buildContractCard(context, doc))
                            .toList(),
                  ),
                ),
              ),
            );
          },
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

  Widget _buildContractCard(BuildContext context, DocumentSnapshot doc) {
    final contract = doc.data() as Map<String, dynamic>;
    final jobId = contract['jobId'] as String? ?? '';
    final agreedBid = (contract['agreedBid'] as num?)?.toDouble() ?? 0.0;
    final completedTs = contract['completedAt'] as Timestamp?;
    final completedDate = completedTs?.toDate();

    return AnimationConfiguration.staggeredList(
      position: _allContracts.indexOf(doc),
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
              color: Theme.of(context).colorScheme.surface,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              _userRole == 'client'
                                  ? ClientJobDetailScreen(jobId: jobId)
                                  : JobDetailScreen(jobId: jobId),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future:
                        FirebaseFirestore.instance
                            .collection('jobs')
                            .doc(jobId)
                            .get(),
                    builder: (context, jobSnap) {
                      if (!jobSnap.hasData || !jobSnap.data!.exists) {
                        return const ListTile(
                          title: Text('Loading job details...'),
                        );
                      }
                      final jobData = jobSnap.data!.data()!;
                      final jobTitle =
                          jobData['title'] as String? ?? 'Untitled';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jobTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildDetailItem(
                                icon: Icons.attach_money_rounded,
                                value: '\$${agreedBid.toStringAsFixed(2)}',
                                label: 'Earnings',
                                color: Colors.green,
                              ),
                              const SizedBox(width: 24),
                              _buildDetailItem(
                                icon: Icons.calendar_month,
                                value:
                                    completedDate != null
                                        ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(completedDate)
                                        : 'N/A',
                                label: 'Completed',
                                color: Colors.purple,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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
