// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:job_board_freelance_marketplace/Screens/Job/Client/detail_proposal.dart';

// class ClientProposalsScreen extends StatelessWidget {
//   const ClientProposalsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('View Proposals'),
//         backgroundColor: theme.scaffoldBackgroundColor,
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               colorScheme.primary.withOpacity(0.1),
//               colorScheme.background,
//             ],
//           ),
//         ),
//         child: FutureBuilder<QuerySnapshot>(
//           future:
//               FirebaseFirestore.instance
//                   .collection('jobs')
//                   .where('createdBy', isEqualTo: uid)
//                   .get(),
//           builder: (ctx, jobsSnap) {
//             if (jobsSnap.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation(colorScheme.primary),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Loading Jobs...',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance
//                       .collection('proposals')
//                       .where('clientId', isEqualTo: uid)
//                       .orderBy('createdAt', descending: true)
//                       .snapshots(),
//               builder: (ctx, propSnap) {
//                 if (propSnap.connectionState == ConnectionState.waiting) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation(
//                             colorScheme.primary,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Loading Proposals...',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 final docs = propSnap.data?.docs ?? [];
//                 if (docs.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.assignment_outlined,
//                           size: 64,
//                           color: Colors.grey[400],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No proposals received yet',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: docs.length,
//                   itemBuilder: (context, i) {
//                     final data = docs[i].data() as Map<String, dynamic>;
//                     return _buildProposalCard(context, docs[i].id, data);
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildProposalCard(
//     BuildContext context,
//     String proposalId,
//     Map<String, dynamic> data,
//   ) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final bid = (data['bid'] as num?)?.toDouble() ?? 0.0;
//     final status = data['status'] as String? ?? 'pending';
//     final ts = data['createdAt'] as Timestamp?;
//     final date = ts?.toDate();
//     final statusColor = _getStatusColor(status);

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(15),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => ProposalDetailScreen(proposalId: proposalId),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       _getStatusIcon(status),
//                       color: statusColor,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       data['title'] ?? 'Untitled Proposal',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   _buildStatusPopupMenu(context, proposalId, data),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               _buildDetailRow(
//                 Icons.attach_money,
//                 'Bid',
//                 '\$${bid.toStringAsFixed(2)}',
//                 Colors.green,
//               ),
//               if (date != null)
//                 _buildDetailRow(
//                   Icons.calendar_today,
//                   'Received',
//                   DateFormat.yMMMd().format(date),
//                   Colors.blue,
//                 ),
//               const SizedBox(height: 8),
//               _buildStatusBadge(status, statusColor),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(
//     IconData icon,
//     String label,
//     String value,
//     Color color,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: color),
//           const SizedBox(width: 8),
//           Text(
//             '$label: ',
//             style: TextStyle(color: Colors.grey[600], fontSize: 14),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge(String status, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         style: TextStyle(
//           color: color,
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusPopupMenu(
//     BuildContext context,
//     String proposalId,
//     Map<String, dynamic> data,
//   ) {
//     return PopupMenuButton<String>(
//       icon: Icon(Icons.more_vert, color: Colors.grey[600]),
//       onSelected:
//           (value) => _handleStatusChange(context, value, proposalId, data),
//       itemBuilder:
//           (_) => [
//             PopupMenuItem(
//               value: 'accepted',
//               child: Row(
//                 children: [
//                   Icon(Icons.check_circle, color: Colors.green),
//                   const SizedBox(width: 8),
//                   const Text('Accept'),
//                 ],
//               ),
//             ),
//             PopupMenuItem(
//               value: 'rejected',
//               child: Row(
//                 children: [
//                   Icon(Icons.cancel, color: Colors.red),
//                   const SizedBox(width: 8),
//                   const Text('Reject'),
//                 ],
//               ),
//             ),
//           ],
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'accepted':
//         return Colors.green;
//       case 'rejected':
//         return Colors.red;
//       case 'pending':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getStatusIcon(String status) {
//     switch (status.toLowerCase()) {
//       case 'accepted':
//         return Icons.check_circle;
//       case 'rejected':
//         return Icons.cancel;
//       case 'pending':
//         return Icons.access_time;
//       default:
//         return Icons.help_outline;
//     }
//   }

//   Future<void> _handleStatusChange(
//     BuildContext context,
//     String newStatus,
//     String proposalId,
//     Map<String, dynamic> data,
//   ) async {
//     try {
//       // Update proposal status
//       await FirebaseFirestore.instance
//           .collection('proposals')
//           .doc(proposalId)
//           .update({'status': newStatus});

//       // Create contract if accepted
//       if (newStatus == 'accepted') {
//         final uid = FirebaseAuth.instance.currentUser!.uid;
//         await FirebaseFirestore.instance.collection('contracts').add({
//           'jobId': data['jobId'],
//           'clientId': uid,
//           'freelancerId': data['freelancerId'],
//           'agreedBid': data['bid'],
//           'status': 'ongoing',
//           'startedAt': FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error updating status: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/detail_proposal.dart';

class ClientProposalsScreen extends StatefulWidget {
  const ClientProposalsScreen({super.key});

  @override
  State<ClientProposalsScreen> createState() => _ClientProposalsScreenState();
}

class _ClientProposalsScreenState extends State<ClientProposalsScreen> {
  final int _perPage = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<DocumentSnapshot> _allProposals = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreProposals();
      }
    }
  }

  Future<void> _loadMoreProposals() async {
    if (!_hasMore) return;

    setState(() => _isLoadingMore = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final query = FirebaseFirestore.instance
        .collection('proposals')
        .where('clientId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(_lastDocument!)
        .limit(_perPage);

    final snapshot = await query.get();
    if (snapshot.docs.length < _perPage) {
      _hasMore = false;
    }

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      _allProposals.addAll(snapshot.docs);
    }

    setState(() => _isLoadingMore = false);
  }

  Future<void> _deleteProposal(String proposalId) async {
    try {
      await FirebaseFirestore.instance
          .collection('proposals')
          .doc(proposalId)
          .delete();
      setState(() {
        _allProposals.removeWhere((doc) => doc.id == proposalId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposal deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting proposal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Proposals'),
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
        child: FutureBuilder<QuerySnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('jobs')
                  .where(
                    'createdBy',
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                  )
                  .get(),
          builder: (ctx, jobsSnap) {
            if (jobsSnap.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading Jobs...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('proposals')
                      .where(
                        'clientId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                      )
                      .orderBy('createdAt', descending: true)
                      .limit(_perPage)
                      .snapshots(),
              builder: (ctx, propSnap) {
                if (propSnap.connectionState == ConnectionState.waiting) {
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
                          'Loading Proposals...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (propSnap.data == null || propSnap.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No proposals received yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Initialize or update the list
                if (_allProposals.isEmpty) {
                  _allProposals.addAll(propSnap.data!.docs);
                  _lastDocument = propSnap.data!.docs.last;
                  _hasMore = propSnap.data!.docs.length >= _perPage;
                }

                // Group proposals by week
                final Map<String, List<DocumentSnapshot>> groupedProposals = {};
                for (final doc in _allProposals) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ts = data['createdAt'] as Timestamp?;
                  if (ts != null) {
                    final date = ts.toDate();
                    final weekKey = _getWeekKey(date);
                    groupedProposals.putIfAbsent(weekKey, () => []).add(doc);
                  } else {
                    // Handle proposals without a timestamp
                    const weekKey = 'Unknown Date';
                    groupedProposals.putIfAbsent(weekKey, () => []).add(doc);
                  }
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedProposals.length * 2, // *2 for dividers
                  itemBuilder: (context, index) {
                    if (index.isOdd) {
                      // Divider between weeks
                      final weekIndex = index ~/ 2;
                      final weekKey = groupedProposals.keys.elementAt(
                        weekIndex,
                      );
                      return _buildWeekDivider(weekKey);
                    }

                    // Proposal cards
                    final weekIndex = index ~/ 2;
                    final weekKey = groupedProposals.keys.elementAt(weekIndex);
                    final proposals = groupedProposals[weekKey]!;

                    return Column(
                      children:
                          proposals.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return _buildProposalCard(
                              context,
                              doc.id,
                              data,
                              onDelete: () => _deleteProposal(doc.id),
                            );
                          }).toList(),
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

  Widget _buildProposalCard(
    BuildContext context,
    String proposalId,
    Map<String, dynamic> data, {
    required VoidCallback onDelete,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bid = (data['bid'] as num?)?.toDouble() ?? 0.0;
    final status = data['status'] as String? ?? 'pending';
    final ts = data['createdAt'] as Timestamp?;
    final date = ts?.toDate();
    final statusColor = _getStatusColor(status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProposalDetailScreen(proposalId: proposalId),
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
                  Expanded(
                    child: Text(
                      data['title'] ?? 'Untitled Proposal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusPopupMenu(
                    context,
                    proposalId,
                    data,
                    onDelete: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.attach_money,
                'Bid',
                '\$${bid.toStringAsFixed(2)}',
                Colors.green,
              ),
              if (date != null)
                _buildDetailRow(
                  Icons.calendar_today,
                  'Received',
                  DateFormat('MMM dd, yyyy - hh:mm a').format(date),
                  Colors.blue,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(_getStatusIcon(status), color: statusColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value, style: TextStyle(color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildStatusPopupMenu(
    BuildContext context,
    String proposalId,
    Map<String, dynamic> data, {
    required VoidCallback onDelete,
  }) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        } else {
          _handleStatusChange(context, value, proposalId, data);
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'accepted',
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text('Accept'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'rejected',
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('Reject'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('Delete'),
                ],
              ),
            ),
          ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.access_time;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _handleStatusChange(
    BuildContext context,
    String newStatus,
    String proposalId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Update proposal status
      await FirebaseFirestore.instance
          .collection('proposals')
          .doc(proposalId)
          .update({'status': newStatus});

      // Create contract if accepted
      if (newStatus == 'accepted') {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('contracts').add({
          'jobId': data['jobId'],
          'clientId': uid,
          'freelancerId': data['freelancerId'],
          'agreedBid': data['bid'],
          'status': 'ongoing',
          'startedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
