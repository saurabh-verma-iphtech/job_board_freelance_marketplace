
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/job_detail_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/submit_proposal_F.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({Key? key}) : super(key: key);

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  final _scrollController = ScrollController();
  final int _perPage = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<DocumentSnapshot> _allJobs = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<String> _categories = [];
  int _selectedBudgetIndex = 0;

  final List<Map<String, dynamic>> _budgetRanges = [
    {'label': 'Any', 'min': 0, 'max': double.infinity},
    {'label': '0-100', 'min': 0, 'max': 100},
    {'label': '101-500', 'min': 101, 'max': 500},
    {'label': '501-1000', 'min': 501, 'max': 1000},
    {'label': '1001+', 'min': 1001, 'max': double.infinity},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('jobs')
            .where('category', isNotEqualTo: null)
            .get();

    final categories =
        snapshot.docs.map((doc) => doc['category'] as String).toSet().toList();

    setState(() {
      _categories = ['All']..addAll(categories);
    });
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreJobs();
      }
    }
  }

  Future<void> _loadMoreJobs() async {
    if (!_hasMore) return;

    setState(() => _isLoadingMore = true);

    final query = _buildQuery()
        .startAfterDocument(_lastDocument!)
        .limit(_perPage);
    final snapshot = await query.get();

    if (snapshot.docs.length < _perPage) {
      _hasMore = false;
    }

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      _allJobs.addAll(snapshot.docs);
    }

    setState(() => _isLoadingMore = false);
  }

  Query _buildQuery() {
    Query query = FirebaseFirestore.instance
        .collection('jobs')
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true);

    if (_searchQuery.isNotEmpty) {
      query = query.where(
        'searchTitle',
        isGreaterThanOrEqualTo: _searchQuery.toLowerCase(),
        isLessThan: _searchQuery.toLowerCase() + 'z',
      );
    }

    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    final selectedRange = _budgetRanges[_selectedBudgetIndex];
    if (selectedRange['min'] > 0) {
      query = query.where(
        'budget',
        isGreaterThanOrEqualTo: selectedRange['min'],
      );
    }
    if (selectedRange['max'] < double.infinity) {
      query = query.where('budget', isLessThanOrEqualTo: selectedRange['max']);
    }

    return query;
  }

  void _applyFilters() {
    setState(() {
      _allJobs.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    _loadMoreJobs();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Feed'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
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
                stream: _buildQuery().limit(_perPage).snapshots(),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading Jobs...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'Error loading jobs: ${snap.error}',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }

                  if (_allJobs.isEmpty && snap.data != null) {
                    _allJobs.addAll(snap.data!.docs);
                    if (snap.data!.docs.isNotEmpty) {
                      _lastDocument = snap.data!.docs.last;
                    }
                    _hasMore = snap.data!.docs.length >= _perPage;
                  }

                  if (_allJobs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No open jobs available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final groupedJobs = _groupJobsByWeek(_allJobs);

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedJobs.length * 2 + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == groupedJobs.length * 2 && _hasMore) {
                        return _buildLoadingIndicator();
                      }

                      if (index.isOdd) {
                        final weekIndex = index ~/ 2;
                        final weekKey = groupedJobs.keys.elementAt(weekIndex);
                        return _buildWeekDivider(weekKey);
                      }

                      final weekIndex = index ~/ 2;
                      final weekKey = groupedJobs.keys.elementAt(weekIndex);
                      final jobs = groupedJobs[weekKey]!;

                      return Column(
                        children:
                            jobs
                                .map((doc) => _buildJobCard(context, doc))
                                .toList(),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<DocumentSnapshot>> _groupJobsByWeek(
    List<DocumentSnapshot> jobs,
  ) {
    final groupedJobs = <String, List<DocumentSnapshot>>{};
    for (final doc in jobs) {
      final data = doc.data() as Map<String, dynamic>;
      final ts = data['createdAt'] as Timestamp?;
      if (ts != null) {
        final date = ts.toDate();
        final weekKey = _getWeekKey(date);
        groupedJobs.putIfAbsent(weekKey, () => []).add(doc);
      } else {
        groupedJobs.putIfAbsent('Unknown Date', () => []).add(doc);
      }
    }
    return groupedJobs;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Filter Jobs'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items:
                              _categories
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) =>
                                  setState(() => _selectedCategory = value!),
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Budget Range:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_budgetRanges.length, (
                            index,
                          ) {
                            final range = _budgetRanges[index];
                            return ChoiceChip(
                              label: Text(range['label']),
                              selected: _selectedBudgetIndex == index,
                              onSelected:
                                  (selected) => setState(
                                    () => _selectedBudgetIndex = index,
                                  ),
                              selectedColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.2),
                              labelStyle: TextStyle(
                                color:
                                    _selectedBudgetIndex == index
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[600],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
          ),
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

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  String _getWeekKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));

    if (date.isAfter(today)) return 'Today';
    if (date.isAfter(yesterday)) return 'Yesterday';
    if (date.isAfter(weekStart)) return 'This Week';
    if (date.isAfter(lastWeekStart)) return 'Last Week';
    return DateFormat('MMMM yyyy').format(date);
  }

  Widget _buildJobCard(BuildContext context, DocumentSnapshot doc) {
    final theme = Theme.of(context);
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'open';
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final isOpen = status == 'open';
    final statusColor = isOpen ? Colors.green : Colors.red;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap:
            () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => JobDetailScreen(jobId: doc.id),
                transitionsBuilder:
                    (_, a, __, c) => FadeTransition(opacity: a, child: c),
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data['title'] ?? 'Untitled Job',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildStatusBadge(status, statusColor),
                      if (isOpen)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _buildApplyButton(context, doc.id),
                        ),
                      if(!isOpen)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text("Already Applied"),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.category,
                'Category',
                data['category'] ?? 'General',
                Colors.blue,
              ),
              _buildDetailRow(
                Icons.attach_money,
                'Budget',
                '\$${(data['budget'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                Colors.green,
              ),
              if (createdAt != null)
                _buildDetailRow(
                  Icons.calendar_today,
                  'Posted',
                  DateFormat.yMMMd().format(createdAt),
                  Colors.purple,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context, String jobId) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('proposals')
              .where('jobId', isEqualTo: jobId)
              .where(
                'freelancerId',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid,
              )
              .limit(1)
              .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }
        if (snap.data?.docs.isNotEmpty ?? false) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: Text("Already Applied",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
          );
        }
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap:
                  () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => SubmitProposalScreen(),
                      settings: RouteSettings(arguments: jobId),
                      transitionsBuilder:
                          (_, a, __, c) => SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.5),
                              end: Offset.zero,
                            ).animate(a),
                            child: c,
                          ),
                    ),
                  ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Apply Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
