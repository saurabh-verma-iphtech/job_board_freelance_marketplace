// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:job_board_freelance_marketplace/Model/contract.dart'; // Required import

// class ContractDetailScreen extends StatefulWidget {
//   final Contract contract;
//   final String role;

//   const ContractDetailScreen({
//     Key? key,
//     required this.contract,
//     required this.role,
//   }) : super(key: key);

//   @override
//   State<ContractDetailScreen> createState() => _ContractDetailScreenState();
// }

// class _ContractDetailScreenState extends State<ContractDetailScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _opacityAnimation;
//   late Animation<Offset> _slideAnimation;
//   String counterpartyName = '';
//   String jobTitle = '';
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
//       ),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
//       ),
//     );

//     _controller.forward();
//     _fetchAdditionalDetails();
//   }

//   Future<void> _fetchAdditionalDetails() async {
//     final contract = widget.contract;
//     final isClient = widget.role == 'client';
//     final userId = isClient ? contract.freelancerId : contract.clientId;

//     try {
//       // Fetch job title
//       final jobSnap =
//           await FirebaseFirestore.instance
//               .collection('jobs')
//               .doc(contract.jobId)
//               .get();
//       jobTitle = jobSnap.data()?['title'] ?? 'Unknown Job Title';

//       // Fetch user name
//       final userSnap =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(userId)
//               .get();
//       counterpartyName = userSnap.data()?['name'] ?? 'Unknown User';

//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print('Error fetching job/user details: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isClient = widget.role == 'client';
//     final statusColor =
//         widget.contract.status == 'completed' ? Colors.green : Colors.orange;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Contract Details',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               theme.colorScheme.primary.withOpacity(0.05),
//               theme.colorScheme.background.withOpacity(0.8),
//             ],
//           ),
//         ),

//         child: FadeTransition(
//           opacity: _opacityAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildContractCard(theme, statusColor, isClient),
//                     const SizedBox(height: 24),
//                     _buildActionButtons(context, isClient, statusColor),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildContractCard(ThemeData theme, Color statusColor, bool isClient) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.work_outline, color: theme.primaryColor),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     'Job Contract',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.primaryColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 30),
//             _buildDetailRow(Icons.description, 'Job Title:', jobTitle, theme),
//             _buildDetailRow(
//               Icons.attach_money,
//               'Agreed Bid:',
//               '\$${widget.contract.agreedBid.toStringAsFixed(2)}',
//               theme,
//             ),
//             _buildDetailRow(
//               Icons.account_circle,
//               '${isClient ? 'Freelancer' : 'Client'} Name:',
//               counterpartyName,
//               theme,
//             ),
//             const SizedBox(height: 15),
//             _buildStatusBadge(statusColor, theme),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(
//     IconData icon,
//     String label,
//     String value,
//     ThemeData theme,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 22, color: theme.primaryColor),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: theme.textTheme.bodyLarge?.copyWith(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge(Color color, ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             widget.contract.status == 'completed'
//                 ? Icons.check_circle
//                 : Icons.timer,
//             size: 18,
//             color: color,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             widget.contract.status.toUpperCase(),
//             style: theme.textTheme.labelLarge?.copyWith(
//               color: color,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(
//     BuildContext context,
//     bool isClient,
//     Color statusColor,
//   ) {
//     return Column(
//       children: [
//         if (widget.contract.status != 'completed')
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             child: ElevatedButton.icon(
//               icon: const Icon(Icons.message, size: 20),
//               label: Text('Message $counterpartyName'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueAccent,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: () => _handleMessageAction(context),
//             ),
//           ),
//         if (widget.contract.status != 'completed' && isClient)
//           const SizedBox(height: 15),
//         if (widget.contract.status != 'completed' && isClient)
//           ElevatedButton.icon(
//             icon: const Icon(Icons.check_circle, size: 20),
//             label: const Text('Mark as Completed'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: statusColor,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             onPressed: () => _confirmCompletion(context),
//           ),
//       ],
//     );
//   }

//   void _handleMessageAction(BuildContext context) {
//     // TODO: Navigate to messaging screen or open chat UI
//   }

//   void _confirmCompletion(BuildContext context) {
//     showDialog(
//       context: context,
//       builder:
//           (ctx) => AlertDialog(
//             title: const Text('Confirm Completion'),
//             content: const Text('Are you sure this contract is completed?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   Navigator.pop(ctx);
//                   try {
//                     await FirebaseFirestore.instance
//                         .collection('contracts')
//                         .doc(widget.contract.id)
//                         .update({
//                           'status': 'completed',
//                           'completedAt': Timestamp.now(),
//                         });

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: const Text('Contract marked as completed!'),
//                         backgroundColor: Colors.green.shade800,
//                         behavior: SnackBarBehavior.floating,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     );
//                     setState(() {
//                       widget.contract.status =
//                           'completed'; // Ensure this is mutable or use a reload
//                     });
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Error: ${e.toString()}'),
//                         backgroundColor: Colors.red.shade800,
//                       ),
//                     );
//                   }
//                 },
//                 child: const Text(
//                   'Confirm',
//                   style: TextStyle(color: Colors.green),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }
// }


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_board_freelance_marketplace/Model/contract.dart'; // Required import

class ContractDetailScreen extends StatefulWidget {
  final Contract contract;
  final String role;

  const ContractDetailScreen({
    Key? key,
    required this.contract,
    required this.role,
  }) : super(key: key);

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  String counterpartyName = '';
  String jobTitle = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _fetchAdditionalDetails();
  }

  Future<void> _fetchAdditionalDetails() async {
    final contract = widget.contract;
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Determine which ID is *the counterparty* (the other person)
    final isCurrentUserClient = currentUserId == contract.clientId;
    final counterpartyId =
        isCurrentUserClient ? contract.freelancerId : contract.clientId;

    try {
      // 1️⃣ Fetch the job document
      final jobSnap =
          await FirebaseFirestore.instance
              .collection('jobs')
              .doc(contract.jobId)
              .get();

      // ✅ Use jobSnap.exists, not jobSnap itself
      if (jobSnap.exists) {
        final data = jobSnap.data()!;
        jobTitle = data['title'] as String? ?? 'Untitled Job';
      } else {
        jobTitle = 'Deleted Job';
      }

      // 2️⃣ Fetch the user document
      final userSnap =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(counterpartyId)
              .get();

      // ✅ Use userSnap.exists, not userSnap itself
      if (userSnap.exists) {
        final u = userSnap.data()!;
        counterpartyName = u['name'] as String? ?? 'Unknown User';
      } else {
        counterpartyName = 'Deleted User';
      }

      if (mounted) setState(() => isLoading = false);
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint('Error fetching contract details: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
final isClient =
        widget.contract.clientId == FirebaseAuth.instance.currentUser!.uid;
        final statusColor = widget.contract.status == 'completed' ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contract Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),

        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContractCard(theme, statusColor, isClient),
                    const SizedBox(height: 24),
                    _buildActionButtons(context, isClient, statusColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContractCard(ThemeData theme, Color statusColor, bool isClient) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work_outline, color: theme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Job Contract',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            _buildDetailRow(Icons.description, 'Job Title:', jobTitle, theme),
            _buildDetailRow(
              Icons.attach_money,
              'Agreed Bid:',
              '\$${widget.contract.agreedBid.toStringAsFixed(2)}',
              theme,
            ),
            _buildDetailRow(
              Icons.account_circle,
              '${isClient ? 'Freelancer' : 'Client'} Name:',
              counterpartyName,
              theme,
            ),
            const SizedBox(height: 15),
            _buildStatusBadge(statusColor, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: theme.primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.contract.status == 'completed'
                ? Icons.check_circle
                : Icons.timer,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            widget.contract.status.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    bool isClient,
    Color statusColor,
  ) {
    return Column(
      children: [
        if (widget.contract.status != 'completed')
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.message, size: 20),
              label: Text('Message $counterpartyName'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _handleMessageAction(context),
            ),
          ),
        if (widget.contract.status != 'completed' && isClient)
          const SizedBox(height: 15),
        if (widget.contract.status != 'completed' && isClient)
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle, size: 20),
            label: const Text('Mark as Completed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: statusColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _confirmCompletion(context),
          ),
      ],
    );
  }

  void _handleMessageAction(BuildContext context) {
    // TODO: Navigate to messaging screen or open chat UI
  }

  void _confirmCompletion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Completion'),
            content: const Text('Are you sure this contract is completed?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await FirebaseFirestore.instance
                        .collection('contracts')
                        .doc(widget.contract.id)
                        .update({
                          'status': 'completed',
                          'completedAt': Timestamp.now(),
                        });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Contract marked as completed!'),
                        backgroundColor: Colors.green.shade800,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    setState(() {
                      widget.contract.status =
                          'completed'; // Ensure this is mutable or use a reload
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red.shade800,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
    );
  }
}
