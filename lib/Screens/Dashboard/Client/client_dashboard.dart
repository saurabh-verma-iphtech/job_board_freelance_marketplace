import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board_freelance_marketplace/Screens/Auth_Screen/login_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Dashboard/Client/client_profile_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Dashboard/Client/new_proposals.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/client_job_list.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/list_proposal_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/spendings_detail.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/contract_list_screen.dart';
import 'package:job_board_freelance_marketplace/Services/theme_notifier.dart';

class ClientDashboard extends ConsumerStatefulWidget {
  const ClientDashboard({super.key});

  @override
  ConsumerState<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends ConsumerState<ClientDashboard> {
  int _selectedIndex = 0;
  int _postedJobsCount = 0;
  int _newProposalsCount = 0;
  int _activeContractsCount = 0;
  double _totalSpent = 0.0;
  String _userName = 'Loading…';

  late StreamSubscription _contractsSub;
  late StreamSubscription _propsSub;
  late final StreamSubscription _sub;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
    _listenToPostedJobs();
    _listenToNewProposals();
    _listenToActiveContracts();
    _fetchTotalSpent(); // Add this
    _loadUserName;
  }

  @override
  void dispose() {
    _sub.cancel();
    _propsSub.cancel();
    _contractsSub.cancel();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final name = doc.data()?['name'] as String?;
      setState(() {
        _userName = name == null || name.isEmpty ? 'Unnamed User' : name;
      });
    } catch (_) {
      setState(() {
        _userName = 'Unnamed User';
      });
    }
  }

  Future<void> _fetchTotalSpent() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final contractsSnap =
        await FirebaseFirestore.instance
            .collection('contracts')
            .where('clientId', isEqualTo: uid)
            .where('status', isEqualTo: 'completed')
            .get();

    double total = 0.0;
    for (var doc in contractsSnap.docs) {
      final data = doc.data();
      final bid = data['agreedBid'] ?? 0.0;
      total += bid is int ? bid.toDouble() : bid;
    }

    setState(() {
      _totalSpent = total;
    });
  }

  void _listenToActiveContracts() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _contractsSub = FirebaseFirestore.instance
        .collection('contracts')
        .where('clientId', isEqualTo: uid)
        .where('status', isEqualTo: 'ongoing')
        .snapshots()
        .listen((snap) {
          setState(() => _activeContractsCount = snap.docs.length);
        });
  }

  void _listenToPostedJobs() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _sub = FirebaseFirestore.instance
        .collection('jobs')
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .listen((snap) {
          setState(() {
            _postedJobsCount = snap.docs.length;
          });
        });
  }

  void _listenToNewProposals() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _propsSub = FirebaseFirestore.instance
        .collection('proposals')
        .where(
          'clientId', // ← adjust to your field name: e.g. 'clientId' or 'jobOwner'
          isEqualTo: uid,
        )
        .where(
          'status', // ← only “new” or “pending” ones
          isEqualTo: 'pending',
        )
        .snapshots()
        .listen((snap) {
          setState(() => _newProposalsCount = snap.docs.length);
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

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = ref.watch(themeNotifierProvider);
    final isDark = themeNotifier.mode == ThemeMode.dark;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,

        title: const Text('Client Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: _buildNavigationDrawer(theme, isDark),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDark
                    ? [Colors.deepPurple.shade900, Colors.indigo.shade900]
                    : [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome, ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                    builder: (context, snap) {
                      final name =
                          (snap.hasData && snap.data!.data()?['name'] != null)
                              ? snap.data!.data()!['name'] as String
                              : 'Unnamed User';
                      return Text(
                        name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDashboardCards(theme),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        tooltip: 'Post Job',
        onPressed: () => Navigator.pushNamed(context, '/post-job'),
        child: const Icon(Icons.post_add, color: Colors.white),
      ),
    );
  }

  Widget _buildNavigationDrawer(ThemeData theme, bool isDark) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.8),
              ),
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                builder: (context, snap) {
                  final name =
                      (snap.hasData && snap.data!.data()?['name'] != null)
                          ? snap.data!.data()!['name'] as String
                          : 'Unnamed User';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 50),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            _buildDrawerItem(Icons.person, 'My Profile', 0),
            _buildDrawerItem(Icons.folder_shared, 'My Contracts', 1),
            _buildDrawerItem(Icons.list_alt, 'View Proposals', 2),
            const Divider(),
            _buildDrawerItem(Icons.logout, 'Log Out', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index ? Theme.of(context).primaryColor : null,
      ),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        _onItemTapped(index);
        _navigateToScreen(index);
      },
    );
  }

  void _navigateToScreen(int index) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 1️⃣ Fetch the user doc just once here
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = userDoc.data()?['role'] as String? ?? 'client';
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ClientProfileScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContractsListScreen(role: role)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClientProposalsScreen()),
        );
        break;
      case 3:
        _signOut();
        break;
    }
  }

  Widget _buildDashboardCards(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardCardItem(
            title: 'Posted Jobs',
            value: _postedJobsCount.toString(),
            icon: Icons.work,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ClientJobsScreen()),
                ),
          ),
          _buildDashboardCardItem(
            title: 'Active Contracts',
            value: _activeContractsCount.toString(),
            icon: Icons.assignment_turned_in,
            onTap: () async {
              final uid = FirebaseAuth.instance.currentUser!.uid;
              final userDoc =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get();
              final role = userDoc.data()?['role'] ?? 'client';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContractsListScreen(role: role),
                ),
              );
            },
          ),
          _buildDashboardCardItem(
            title: 'New Proposals',
            value: _newProposalsCount.toString(),
            icon: Icons.markunread,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NewProposalsScreen()),
                ),
          ),
          _buildDashboardCardItem(
            title: 'Total Spent',
            value: '\$${_totalSpent.toStringAsFixed(2)}',
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
        ],
      ),
    );
  }


  Widget _buildDashboardCardItem({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: theme.primaryColor),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
