// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:job_board_freelance_marketplace/Screens/Job/Client/detail_proposal.dart';

// class ClientProposalsScreen extends StatelessWidget {
//   const ClientProposalsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     // First get the client’s job IDs
//     final jobsFuture =
//         FirebaseFirestore.instance
//             .collection('jobs')
//             .where('createdBy', isEqualTo: uid)
//             .get();

//     return FutureBuilder<QuerySnapshot>(
//       future: jobsFuture,
//       builder: (ctx, jobsSnap) {
//         if (!jobsSnap.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final propsStream =
//             FirebaseFirestore.instance
//                 .collection('proposals')
//                 .where('clientId', isEqualTo: uid)
//                 .orderBy('createdAt', descending: true)
//                 .snapshots();

//         return Scaffold(
//           appBar: AppBar(title: const Text('View Proposals')),
//           body: StreamBuilder<QuerySnapshot>(
//             stream: propsStream,
//             builder: (ctx, propSnap) {
//               if (!propSnap.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (propSnap.data!.docs.isEmpty) {
//                 return const Center(child: Text('No proposals yet.'));
//               }

//               return ListView.builder(
//                 itemCount: propSnap.data!.docs.length,
//                 itemBuilder: (ctx, i) {
//                   final p =
//                       propSnap.data!.docs[i].data() as Map<String, dynamic>;
//                   final pid = propSnap.data!.docs[i].id;

//                   return Card(
//                     margin: const EdgeInsets.symmetric(
//                       vertical: 6,
//                       horizontal: 12,
//                     ),
//                     child: ListTile(
//                       title: Text('Bid: \$${p['bid']}'),
//                       subtitle: Text(
//                         p['message'],
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       leading: Text(
//                         p['status'].toString().toUpperCase(),
//                         style: TextStyle(
//                           color:
//                               p['status'] == 'accepted'
//                                   ? Colors.green
//                                   : p['status'] == 'rejected'
//                                   ? Colors.red
//                                   : null,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (_) => ProposalDetailScreen(proposalId: pid),
//                           ),
//                         );
//                       },
//                       trailing: PopupMenuButton<String>(
//                         onSelected: (choice) async {
//                           // 1. Update proposal status
//                           await FirebaseFirestore.instance
//                               .collection('proposals')
//                               .doc(pid)
//                               .update({'status': choice});

//                           // 2. If accepted, create a new contract
//                           if (choice == 'accepted') {
//                             await FirebaseFirestore.instance
//                                 .collection('contracts')
//                                 .add({
//                                   'jobId': p['jobId'],
//                                   'clientId': uid,
//                                   'freelancerId': p['freelancerId'],
//                                   'agreedBid': p['bid'],
//                                   'status': 'ongoing',
//                                   'startedAt': FieldValue.serverTimestamp(),
//                                 });
//                           }
//                         },
//                         itemBuilder:
//                             (_) => [
//                               PopupMenuItem(
//                                 value: 'accepted',
//                                 child: Text('Accept'),
//                               ),
//                               PopupMenuItem(
//                                 value: 'rejected',
//                                 child: Text('Reject'),
//                               ),
//                             ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/detail_proposal.dart';

class ClientProposalsScreen extends StatelessWidget {
  const ClientProposalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
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
                  .where('createdBy', isEqualTo: uid)
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
                      .where('clientId', isEqualTo: uid)
                      .orderBy('createdAt', descending: true)
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

                final docs = propSnap.data?.docs ?? [];
                if (docs.isEmpty) {
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return _buildProposalCard(context, docs[i].id, data);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProposalCard(
    BuildContext context,
    String proposalId,
    Map<String, dynamic> data,
  ) {
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data['title'] ?? 'Untitled Proposal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusPopupMenu(context, proposalId, data),
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
                  DateFormat.yMMMd().format(date),
                  Colors.blue,
                ),
              const SizedBox(height: 8),
              _buildStatusBadge(status, statusColor),
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
          Icon(icon, size: 18, color: color),
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

  Widget _buildStatusPopupMenu(
    BuildContext context,
    String proposalId,
    Map<String, dynamic> data,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      onSelected:
          (value) => _handleStatusChange(context, value, proposalId, data),
      itemBuilder:
          (_) => [
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
