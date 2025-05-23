import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board_freelance_marketplace/Screens/Auth_Screen/login_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Chat/chat_dashboard.dart';
import 'package:job_board_freelance_marketplace/Screens/Dashboard/Client/client_profile_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/client_job_list.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/list_proposal_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/spendings_detail.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/completedJob.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/contract_list_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Review%20System/client_review_list.dart';
import 'package:job_board_freelance_marketplace/Services/theme_notifier.dart';

class ClientDashboard extends ConsumerStatefulWidget {
  const ClientDashboard({super.key});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  int _postedJobsCount = 0;
  int _newProposalsCount = 0;
  int _activeContractsCount = 0;
  double _totalSpent = 0.0;
  String _userName = 'Client';
  int _totalProposalsCount = 0; // new
  int _unreadMessagesCount = 0;
  late StreamSubscription _chatsSub;

  late StreamSubscription<QuerySnapshot> _totalPropsSub;
  late StreamSubscription _contractsSub;
  late StreamSubscription _propsSub;
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
    _loadUserData();
    _listenToPostedJobs();
    _listenToNewProposals();
    _listenToActiveContracts();
    _fetchTotalSpent();
    _fetchTotalProposals(); // call new fetch
    _listenToTotalProposals();
    _listenToUnreadMessages();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  void _listenToUnreadMessages() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _chatsSub = FirebaseFirestore.instance
        .collection('chats')
        .where('participants.clientId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          int total = 0;
          for (var doc in snapshot.docs) {
            // total += doc['unreadClient'] ?? 0;
          }
          setState(() => _unreadMessagesCount = total);
        });
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _userName = doc.data()?['name'] ?? 'Client';
    });
  }

  Future<void> _fetchTotalSpent() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final contractsSnap =
        await FirebaseFirestore.instance
            .collection('contracts')
            .where('clientId', isEqualTo: uid)
            .where('status', isEqualTo: 'completed')
            .get();

    double total = contractsSnap.docs.fold(0.0, (sum, doc) {
      final bid = doc.data()['agreedBid'] ?? 0.0;
      return sum + (bid is int ? bid.toDouble() : bid);
    });

    setState(() => _totalSpent = total);
  }

  Future<void> _fetchTotalProposals() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final allSnap =
        await FirebaseFirestore.instance
            .collection('proposals')
            .where('clientId', isEqualTo: uid)
            .get();
    setState(() => _totalProposalsCount = allSnap.size);
  }

  void _listenToActiveContracts() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _contractsSub = FirebaseFirestore.instance
        .collection('contracts')
        .where('clientId', isEqualTo: uid)
        .where('status', isEqualTo: 'ongoing')
        .snapshots()
        .listen(
          (snap) => setState(() => _activeContractsCount = snap.docs.length),
        );
  }

  void _listenToPostedJobs() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _sub = FirebaseFirestore.instance
        .collection('jobs')
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .listen((snap) => setState(() => _postedJobsCount = snap.docs.length));
  }

  void _listenToNewProposals() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _propsSub = FirebaseFirestore.instance
        .collection('proposals')
        .where('clientId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen(
          (snap) => setState(() => _newProposalsCount = snap.docs.length),
        );
  }

  void _listenToTotalProposals() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _totalPropsSub = FirebaseFirestore.instance
        .collection('proposals')
        .where('clientId', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
          setState(() {
            _totalProposalsCount = snap.docs.length;
          });
        });
  }

  void _checkProfileCompletion() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    if (doc.data()?['profileCompleted'] != true) {
      Navigator.pushReplacementNamed(context, '/client-profile');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _sub.cancel();
    _propsSub.cancel();
    _contractsSub.cancel();
    _totalPropsSub.cancel(); // ← new
    _listenToUnreadMessages();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = ref.watch(themeNotifierProvider).mode == ThemeMode.dark;

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.surface,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(theme),
                  const SizedBox(height: 24),
                  _buildQuickActions(theme),
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return AppBar(
      title: Text(
        'Welcome, $_userName',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
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
        _buildIconButton(
          icon: Icons.chat,
          tooltip: 'Messages',
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDashboard(userType: 'client'),
                ),
              ),
          badgeCount: _unreadMessagesCount,
        ),
        _buildIconButton(
          icon: Icons.work,
          tooltip: 'My Jobs',
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ClientJobsScreen()),
              ),
          badgeCount: _postedJobsCount,
        ),
        IconButton(
          icon: Icon(Icons.logout, color: theme.colorScheme.error),
          onPressed: _signOut,
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_getGreetingTime()}!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getClientMotivationalMessage(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.handshake, size: 40, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          title: 'Posted Jobs',
          value: _postedJobsCount.toString(),
          color: Colors.blue,
          icon: Icons.work_outline,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ClientJobsScreen()),
              ),
        ),
        _buildStatCard(
          title: 'Active Contracts',
          value: _activeContractsCount.toString(),
          color: const Color.fromARGB(255, 34, 83, 80),
          icon: Icons.assignment_turned_in,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContractsListScreen(role: 'client'),
                ),
              ),
        ),
        _buildStatCard(
          title: 'New Proposals',
          value: _newProposalsCount.toString(),
          color: const Color.fromARGB(255, 32, 173, 163),
          icon: Icons.pending_actions,
          onTap: () => Navigator.pushNamed(context, '/client-proposals'),
        ),
        _buildStatCard(
          title: 'Total Proposals',
          value: _totalProposalsCount.toString(),
          color: Colors.redAccent,
          icon: Icons.local_grocery_store_outlined,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ClientProposalsScreen()),
              ),
        ),
        _buildStatCard(
          title: 'Total Spent',
          value: '\$${_totalSpent.toStringAsFixed(2)}',
          color: Colors.green,
          icon: Icons.attach_money,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => SpendingDetailsScreen(totalSpent: _totalSpent),
                ),
              ),
        ),
        _buildStatCard(
          title: 'Completed Jobs',
          value: _newProposalsCount.toString(),
          color: Colors.purple,
          icon: Icons.verified,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CompletedJobsScreen()),
              ),
        ),
        _buildStatCard(
          title: 'Rating',
          value: _unreadMessagesCount.toString(),
          color: Colors.purple,
          icon: Icons.chat,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientReviewListScreen(),
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(
              icon: Icons.person,
              label: 'Profile',
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ClientProfileScreen()),
                  ),
            ),
            _buildActionButton(
              icon: Icons.business,
              label: 'Post Job',
              onPressed: () => Navigator.pushNamed(context, '/post-job'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/post-job'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.post_add, size: 28),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    int badgeCount = 0,
  }) {
    return Stack(
      children: [
        IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onPressed),
        if (badgeCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                // blurRadius: 8,
                // offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
    );
  }

  String _getGreetingTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _getClientMotivationalMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '🌅 Good morning! Ready to find great deals today?';
    } else if (hour < 17) {
      return '☀️ Hope your day’s going well! Check out what’s new.';
    } else {
      return '🌙 Wind down with your favorite buys and reviews!';
    }
  }


  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
