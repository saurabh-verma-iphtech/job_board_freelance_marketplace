// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:job_board_freelance_marketplace/Screens/Auth_Screen/login_screen.dart';
// import 'package:job_board_freelance_marketplace/Screens/Dashboard/Freelancer/profile_screen.dart';
// import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/pendingProposals.dart';
// import 'package:job_board_freelance_marketplace/Screens/Job/completedJob.dart';
// import 'package:job_board_freelance_marketplace/Screens/Job/contract_list_screen.dart';

// class FreelancerDashboard extends StatefulWidget {
//   const FreelancerDashboard({super.key});

//   @override
//   State<FreelancerDashboard> createState() => _FreelancerDashboardState();
// }

// class _FreelancerDashboardState extends State<FreelancerDashboard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _opacityAnimation;
//   late Animation<double> _scaleAnimation;
//   String? role;
//   String userName = 'Freelancer';
//   int activeContracts = 0;
//   int pendingProposals = 0;
//   int completedJobs = 0;
//   double totalEarnings = 0.0;
//   int totalProposals = 0;

//   late StreamSubscription<QuerySnapshot> _contractsSub;
//   late StreamSubscription<QuerySnapshot> _proposalsSub;
//   late StreamSubscription<QuerySnapshot> _completedSub;
//   late StreamSubscription<QuerySnapshot> _allPropsSub;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//     _setupStreamSubscriptions();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     _opacityAnimation = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     _scaleAnimation = Tween<double>(
//       begin: 0.95,
//       end: 1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _controller.forward();
//   }

//   Future<void> _loadInitialData() async {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final userDoc =
//         await FirebaseFirestore.instance.collection('users').doc(uid).get();
//     if (!userDoc.exists || userDoc.data()?['profileCompleted'] != true) {
//       Navigator.pushReplacementNamed(context, '/freelancer-profile');
//       return;
//     }
//     setState(() {
//       role = userDoc.data()!['role'] as String?;
//       userName = userDoc.data()!['name'] as String? ?? 'Freelancer';
//     });
//   }

//   void _setupStreamSubscriptions() {
//     final uid = FirebaseAuth.instance.currentUser!.uid;

//     // Active contracts
//     _contractsSub = FirebaseFirestore.instance
//         .collection('contracts')
//         .where('freelancerId', isEqualTo: uid)
//         .where('status', isEqualTo: 'ongoing')
//         .snapshots()
//         .listen((snapshot) {
//           setState(() => activeContracts = snapshot.docs.length);
//         });

//     _proposalsSub = FirebaseFirestore.instance
//         .collection('proposals')
//         .where('freelancerId', isEqualTo: uid)
//         .where('status', isEqualTo: 'pending')
//         .snapshots()
//         .listen((snapshot) {
//           setState(() => pendingProposals = snapshot.docs.length);
//         });

//     // Completed jobs & earnings
//     _completedSub = FirebaseFirestore.instance
//         .collection('contracts')
//         .where('freelancerId', isEqualTo: uid)
//         .where('status', isEqualTo: 'completed')
//         .snapshots()
//         .listen((snapshot) {
//           final earnings = snapshot.docs.fold<double>(0.0, (sum, doc) {
//             final bid = doc.data()['agreedBid'];
//             return bid is num ? sum + bid.toDouble() : sum;
//           });
//           setState(() {
//             completedJobs = snapshot.docs.length;
//             totalEarnings = earnings;
//           });
//         });

//     _allPropsSub = FirebaseFirestore.instance
//         .collection('proposals')
//         .where('freelancerId', isEqualTo: uid)
//         .snapshots()
//         .listen((snapshot) {
//           setState(() => totalProposals = snapshot.docs.length);
//         });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _contractsSub.cancel();
//     _proposalsSub.cancel();
//     _completedSub.cancel();
//     _allPropsSub.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Scaffold(
//       appBar: _buildAppBar(theme),
//       body: SingleChildScrollView(
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 colorScheme.primary.withOpacity(0.1),
//                 colorScheme.background,
//               ],
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: AnimatedBuilder(
//               animation: _controller,
//               builder: (context, child) {
//                 return Opacity(
//                   opacity: _opacityAnimation.value,
//                   child: Transform.scale(
//                     scale: _scaleAnimation.value,
//                     child: child,
//                   ),
//                 );
//               },
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildWelcomeCard(theme),
//                   const SizedBox(height: 24),
//                   _buildStatsGrid(),
//                   const SizedBox(height: 24),
//                   _buildQuickActions(theme),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: _buildFloatingActionButton(theme),
//     );
//   }


// // AppBar UI.........
//   AppBar _buildAppBar(ThemeData theme) {
//     return AppBar(
//       title: Text(
//         'Welcome, $userName',
//         style: TextStyle(
//           color: theme.colorScheme.primary,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       backgroundColor: theme.scaffoldBackgroundColor,
//       elevation: 0,
//       actions: [
//         IconButton(
//           icon: Icon(Icons.logout, color: theme.colorScheme.error),
//           onPressed: _confirmSignOut,
//         ),
//       ],
//     );
//   }

//   Widget _buildWelcomeCard(ThemeData theme) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Good ${_getGreetingTime()}!',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Check your latest updates',
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.waving_hand, size: 40, color: Colors.amber),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsGrid() {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       crossAxisCount: 2,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       children: [
//         _buildStatCard(
//           title: 'Active Contracts',
//           value: activeContracts.toString(),
//           color: Colors.blue,
//           icon: Icons.assignment_turned_in,
//           onTap: () => _navigateToContracts(),
//         ),
//         _buildStatCard(
//           title: 'Pending Proposals',
//           value: pendingProposals.toString(),
//           color: Colors.orange,
//           icon: Icons.pending_actions,
//           onTap:
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => PendingProposalsScreen()),
//               ),
//         ),
//         _buildStatCard(
//           title: 'Total Proposals',
//           value: totalProposals.toString(),
//           color: Colors.redAccent,
//           icon: Icons.local_grocery_store_outlined,
//           onTap: () => Navigator.pushNamed(context, '/my-proposals'),
//         ),
//         _buildStatCard(
//           title: 'Total Earnings',
//           value: '\$${totalEarnings.toStringAsFixed(2)}',
//           color: Colors.green,
//           icon: Icons.attach_money,
//           onTap: () => (),
//         ),
//         _buildStatCard(
//           title: 'Completed Jobs',
//           value: completedJobs.toString(),
//           color: Colors.purple,
//           icon: Icons.verified,
//           onTap:
//               () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => CompletedJobsScreen()),
//               ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickActions(ThemeData theme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Quick Actions',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: theme.colorScheme.primary,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Wrap(
//           spacing: 12,
//           runSpacing: 12,
//           children: [
//             _buildActionButton(
//               icon: Icons.person,
//               label: 'Profile',
//               onPressed:
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => FreelancerProfileScreen(),
//                     ),
//                   ),
//             ),
//             _buildActionButton(
//               icon: Icons.history,
//               label: 'History',
//               onPressed: () {},
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildFloatingActionButton(ThemeData theme) {
//     return FloatingActionButton(
//       onPressed: () => Navigator.pushNamed(context, '/job-feed'),
//       backgroundColor: theme.colorScheme.primary,
//       foregroundColor: theme.colorScheme.onPrimary,
//       elevation: 6,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: const Icon(Icons.search, size: 28),
//     );
//   }

//   Widget _buildIconButton({
//     required IconData icon,
//     required String tooltip,
//     required VoidCallback onPressed,
//     int badgeCount = 0,
//   }) {
//     return Stack(
//       children: [
//         IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onPressed),
//         if (badgeCount > 0)
//           Positioned(
//             right: 8,
//             top: 8,
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               decoration: const BoxDecoration(
//                 color: Colors.red,
//                 shape: BoxShape.circle,
//               ),
//               child: Text(
//                 badgeCount.toString(),
//                 style: const TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required Color color,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Icon(icon, size: 32, color: color),
//               const SizedBox(height: 12),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 title,
//                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//   }) {
//     return ElevatedButton.icon(
//       icon: Icon(icon, size: 20),
//       label: Text(label),
//       style: ElevatedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       onPressed: onPressed,
//     );
//   }

//   String _getGreetingTime() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return 'Morning';
//     if (hour < 17) return 'Afternoon';
//     return 'Evening';
//   }

//   void _navigateToContracts() {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (_, __, ___) => ContractsListScreen(role: role.toString()),
//         transitionsBuilder: (_, animation, __, child) {
//           return SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(1, 0),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _confirmSignOut() async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: const Text('Sign Out?'),
//             content: const Text('Are you sure you want to sign out?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text(
//                   'Sign Out',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//             ],
//           ),
//     );

//     if (confirmed == true) {
//       await FirebaseAuth.instance.signOut();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//       );
//     }
//   }
// }



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_board_freelance_marketplace/Screens/Auth_Screen/login_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Chat/chat_dashboard.dart';
import 'package:job_board_freelance_marketplace/Screens/Dashboard/Freelancer/profile_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/pendingProposals.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/completedJob.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/contract_list_screen.dart';

class FreelancerDashboard extends StatefulWidget {
  const FreelancerDashboard({super.key});

  @override
  State<FreelancerDashboard> createState() => _FreelancerDashboardState();
}

class _FreelancerDashboardState extends State<FreelancerDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  String? role;
  String userName = 'Freelancer';
  int activeContracts = 0;
  int pendingProposals = 0;
  int completedJobs = 0;
  double totalEarnings = 0.0;
  int totalProposals = 0;
    int _unreadMessagesCount = 0;


  late StreamSubscription<QuerySnapshot> _contractsSub;
  late StreamSubscription<QuerySnapshot> _proposalsSub;
  late StreamSubscription<QuerySnapshot> _completedSub;
  late StreamSubscription<QuerySnapshot> _allPropsSub;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupStreamSubscriptions();

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

  Future<void> _loadInitialData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!userDoc.exists || userDoc.data()?['profileCompleted'] != true) {
      Navigator.pushReplacementNamed(context, '/freelancer-profile');
      return;
    }
    setState(() {
      role = userDoc.data()!['role'] as String?;
      userName = userDoc.data()!['name'] as String? ?? 'Freelancer';
    });
  }

  void _setupStreamSubscriptions() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Active contracts
    _contractsSub = FirebaseFirestore.instance
        .collection('contracts')
        .where('freelancerId', isEqualTo: uid)
        .where('status', isEqualTo: 'ongoing')
        .snapshots()
        .listen((snapshot) {
          setState(() => activeContracts = snapshot.docs.length);
        });

    _proposalsSub = FirebaseFirestore.instance
        .collection('proposals')
        .where('freelancerId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          setState(() => pendingProposals = snapshot.docs.length);
        });

    // Completed jobs & earnings
    _completedSub = FirebaseFirestore.instance
        .collection('contracts')
        .where('freelancerId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .listen((snapshot) {
          final earnings = snapshot.docs.fold<double>(0.0, (sum, doc) {
            final bid = doc.data()['agreedBid'];
            return bid is num ? sum + bid.toDouble() : sum;
          });
          setState(() {
            completedJobs = snapshot.docs.length;
            totalEarnings = earnings;
          });
        });

    _allPropsSub = FirebaseFirestore.instance
        .collection('proposals')
        .where('freelancerId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          setState(() => totalProposals = snapshot.docs.length);
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    _contractsSub.cancel();
    _proposalsSub.cancel();
    _completedSub.cancel();
    _allPropsSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                colorScheme.background,
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
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildQuickActions(theme),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  // AppBar UI.........
  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        'Welcome, $userName',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      actions: [

        _buildIconButton(
          icon: Icons.chat,
          tooltip: 'Messages',
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDashboard(userType: 'freelancer'),
                ),
              ),
          badgeCount: _unreadMessagesCount,
        ),
        IconButton(
          icon: Icon(Icons.logout, color: theme.colorScheme.error),
          onPressed: _confirmSignOut,
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
                    'Check your latest updates',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.waving_hand, size: 40, color: Colors.amber),
          ],
        ),
      ),
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

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          title: 'Active Contracts',
          value: activeContracts.toString(),
          color: Colors.blue,
          icon: Icons.assignment_turned_in,
          onTap: () => _navigateToContracts(),
        ),
        _buildStatCard(
          title: 'Pending Proposals',
          value: pendingProposals.toString(),
          color: Colors.orange,
          icon: Icons.pending_actions,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PendingProposalsScreen()),
              ),
        ),
        _buildStatCard(
          title: 'Total Proposals',
          value: totalProposals.toString(),
          color: Colors.redAccent,
          icon: Icons.local_grocery_store_outlined,
          onTap: () => Navigator.pushNamed(context, '/my-proposals'),
        ),
        _buildStatCard(
          title: 'Total Earnings',
          value: '\$${totalEarnings.toStringAsFixed(2)}',
          color: Colors.green,
          icon: Icons.attach_money,
          onTap: () => (),
        ),
        _buildStatCard(
          title: 'Completed Jobs',
          value: completedJobs.toString(),
          color: Colors.purple,
          icon: Icons.verified,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CompletedJobsScreen()),
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
                    MaterialPageRoute(
                      builder: (_) => FreelancerProfileScreen(),
                    ),
                  ),
            ),
            _buildActionButton(
              icon: Icons.history,
              label: 'History',
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/job-feed'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.search, size: 28),
    );
  }

  // Widget _buildIconButton({
  //   required IconData icon,
  //   required String tooltip,
  //   required VoidCallback onPressed,
  //   int badgeCount = 0,
  // }) {
  //   return Stack(
  //     children: [
  //       IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onPressed),
  //       if (badgeCount > 0)
  //         Positioned(
  //           right: 8,
  //           top: 8,
  //           child: Container(
  //             padding: const EdgeInsets.all(4),
  //             decoration: const BoxDecoration(
  //               color: Colors.red,
  //               shape: BoxShape.circle,
  //             ),
  //             child: Text(
  //               badgeCount.toString(),
  //               style: const TextStyle(color: Colors.white, fontSize: 12),
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
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

  void _navigateToContracts() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ContractsListScreen(role: role.toString()),
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

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Sign Out?'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
}
