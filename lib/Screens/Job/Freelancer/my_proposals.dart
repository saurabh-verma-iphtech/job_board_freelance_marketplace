// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/job_detail_screen.dart';

// class MyProposalsScreen extends StatelessWidget {
//   const MyProposalsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Proposals'),
//         centerTitle: true,
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
//         child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//           stream:
//               FirebaseFirestore.instance
//                   .collection('proposals')
//                   .where('freelancerId', isEqualTo: uid)
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//           builder: (context, snap) {
//             if (snap.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation(colorScheme.primary),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Loading Proposals...',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             final docs = snap.data?.docs ?? [];
//             if (docs.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.assignment_outlined,
//                       size: 64,
//                       color: Colors.grey[400],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No proposals submitted yet',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: docs.length,
//               itemBuilder: (context, i) {
//                 final data = docs[i].data();
//                 return _buildProposalCard(context, docs[i].id, data);
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
//     final jobId = data['jobId'] as String? ?? '';
//     final title = data['title'] as String? ?? 'Untitled';
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
//             MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: jobId)),
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
//                       title,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   _buildStatusPopupMenu(context, proposalId, bid, data),
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
//                   'Submitted',
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
//     double bid,
//     Map<String, dynamic> data,
//   ) {
//     return PopupMenuButton<String>(
//       icon: Icon(Icons.more_vert, color: Colors.grey[600]),
//       onSelected:
//           (value) =>
//               _handlePopupSelection(context, value, proposalId, bid, data),
//       itemBuilder:
//           (_) => [
//             PopupMenuItem(
//               value: 'edit',
//               child: Row(
//                 children: [
//                   Icon(Icons.edit, color: _getStatusColor(data['status'])),
//                   const SizedBox(width: 8),
//                   const Text('Edit'),
//                 ],
//               ),
//             ),
//             PopupMenuItem(
//               value: 'cancel',
//               child: Row(
//                 children: [
//                   Icon(Icons.cancel, color: Colors.red),
//                   const SizedBox(width: 8),
//                   const Text('Cancel'),
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
//       case 'canceled':
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
//       case 'canceled':
//         return Icons.cancel;
//       case 'pending':
//         return Icons.access_time;
//       default:
//         return Icons.help_outline;
//     }
//   }

//   void _handlePopupSelection(
//     BuildContext context,
//     String value,
//     String proposalId,
//     double bid,
//     Map<String, dynamic> data,
//   ) async {
//     if (value == 'edit') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder:
//               (_) => EditProposalScreen(
//                 proposalId: proposalId,
//                 currentBid: bid,
//                 currentMessage: data['message'] as String? ?? '',
//               ),
//         ),
//       );
//     } else {
//       final confirm = await showDialog<bool>(
//         context: context,
//         builder:
//             (ctx) => AlertDialog(
//               title: const Text('Cancel Proposal?'),
//               content: const Text(
//                 'Are you sure you want to cancel this proposal?',
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx, false),
//                   child: const Text('No'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx, true),
//                   child: const Text('Yes', style: TextStyle(color: Colors.red)),
//                 ),
//               ],
//             ),
//       );
//       if (confirm == true) {
//         await FirebaseFirestore.instance
//             .collection('proposals')
//             .doc(proposalId)
//             .update({'status': 'canceled'});
//       }
//     }
//   }
// }

// class EditProposalScreen extends StatefulWidget {
//   final String proposalId;
//   final double currentBid;
//   final String currentMessage;
//   const EditProposalScreen({
//     Key? key,
//     required this.proposalId,
//     required this.currentBid,
//     required this.currentMessage,
//   }) : super(key: key);

//   @override
//   _EditProposalScreenState createState() => _EditProposalScreenState();
// }

// class _EditProposalScreenState extends State<EditProposalScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late double _bid;
//   late String _message;
//   bool _saving = false;

//   @override
//   void initState() {
//     super.initState();
//     _bid = widget.currentBid;
//     _message = widget.currentMessage;
//   }

//   Future<void> _saveChanges() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _saving = true);
//     try {
//       await FirebaseFirestore.instance
//           .collection('proposals')
//           .doc(widget.proposalId)
//           .update({
//             'bid': _bid,
//             'message': _message,
//             'updatedAt': FieldValue.serverTimestamp(),
//             'status': 'pending',
//           });
//       Navigator.pop(context);
//     } catch (e) {
//       setState(() => _saving = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Proposal'),
//         backgroundColor: theme.scaffoldBackgroundColor,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 initialValue: _bid.toStringAsFixed(2),
//                 decoration: const InputDecoration(
//                   labelText: 'Your Bid (USD)',
//                   prefixText: '\$',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//                 onChanged: (v) => _bid = double.tryParse(v) ?? 0,
//                 validator:
//                     (v) =>
//                         (double.tryParse(v!) ?? 0) > 0
//                             ? null
//                             : 'Enter a valid amount',
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 initialValue: _message,
//                 decoration: const InputDecoration(
//                   labelText: 'Cover Letter',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 5,
//                 onChanged: (v) => _message = v.trim(),
//                 validator:
//                     (v) =>
//                         v != null && v.length >= 10
//                             ? null
//                             : 'At least 10 characters',
//               ),
//               const Spacer(),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _saving ? null : _saveChanges,
//                   child:
//                       _saving
//                           ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                           : const Text('Save Changes'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Chat/chat_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/job_detail_screen.dart';

class MyProposalsScreen extends StatelessWidget {
  const MyProposalsScreen({Key? key}) : super(key: key);

  Future<void> _startChatWithClient(
    BuildContext context,
    String clientId,
    String otherUserName,
  ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final freelancerId = currentUser.uid;
      final firestore = FirebaseFirestore.instance;

      // Check for existing chat
      final chatQuery =
          await firestore
              .collection('chats')
              .where('participants.clientId', isEqualTo: clientId)
              .where('participants.freelancerId', isEqualTo: freelancerId)
              .limit(1)
              .get();

      String chatId;

      if (chatQuery.docs.isNotEmpty) {
        chatId = chatQuery.docs.first.id;
      } else {
        // Create new chat document
        final newChat = await firestore.collection('chats').add({
          'participants': {'clientId': clientId, 'freelancerId': freelancerId},
          'lastMessage': 'Chat started',
          'timestamp': FieldValue.serverTimestamp(),
        });
        chatId = newChat.id;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChatScreen(chatId: chatId,otherUserId: clientId,  otherUserName: otherUserName,),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting chat: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Proposals'),
        centerTitle: true,
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
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              FirebaseFirestore.instance
                  .collection('proposals')
                  .where('freelancerId', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading Proposals...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            final docs = snap.data?.docs ?? [];
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
                      'No proposals submitted yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final data = docs[i].data();
                return _buildProposalCard(context, docs[i].id, data);
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
    Theme.of(context);
    final jobId = data['jobId'] as String? ?? '';
    final title = data['title'] as String? ?? 'Untitled';
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
            MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: jobId)),
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
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('jobs')
                            .doc(jobId)
                            .get(),
                    builder: (context, jobSnapshot) {
                      if (!jobSnapshot.hasData || jobSnapshot.data == null) {
                        return const SizedBox.shrink();
                      }

                      final jobData =
                          jobSnapshot.data!.data() as Map<String, dynamic>;
                      final clientId = jobData['createdBy'] as String?;

                      // Fetch client name from users collection
                      if (clientId != null) {
                        return FutureBuilder<DocumentSnapshot>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(clientId)
                                  .get(),
                          builder: (context, clientSnapshot) {
                            if (!clientSnapshot.hasData ||
                                clientSnapshot.data == null) {
                              return const SizedBox.shrink();
                            }

                            final clientData =
                                clientSnapshot.data!.data()
                                    as Map<String, dynamic>;
                            final clientName =
                                clientData['name'] as String? ?? 'Client';

                            return IconButton(
                              icon: Icon(Icons.chat, color: Colors.blue[600]),
                              onPressed:
                                  () => _startChatWithClient(
                                    context,
                                    clientId,
                                    clientName,
                                  ),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  _buildStatusPopupMenu(context, proposalId, bid, data),
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
                  'Submitted',
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
    double bid,
    Map<String, dynamic> data,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      onSelected:
          (value) =>
              _handlePopupSelection(context, value, proposalId, bid, data),
      itemBuilder:
          (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: _getStatusColor(data['status'])),
                  const SizedBox(width: 8),
                  const Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('Cancel'),
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
      case 'canceled':
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
      case 'canceled':
        return Icons.cancel;
      case 'pending':
        return Icons.access_time;
      default:
        return Icons.help_outline;
    }
  }

  void _handlePopupSelection(
    BuildContext context,
    String value,
    String proposalId,
    double bid,
    Map<String, dynamic> data,
  ) async {
    if (value == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => EditProposalScreen(
                proposalId: proposalId,
                currentBid: bid,
                currentMessage: data['message'] as String? ?? '',
              ),
        ),
      );
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Cancel Proposal?'),
              content: const Text(
                'Are you sure you want to cancel this proposal?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Yes', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
      );
      if (confirm == true) {
        await FirebaseFirestore.instance
            .collection('proposals')
            .doc(proposalId)
            .update({'status': 'canceled'});
      }
    }
  }
}

class EditProposalScreen extends StatefulWidget {
  final String proposalId;
  final double currentBid;
  final String currentMessage;
  const EditProposalScreen({
    Key? key,
    required this.proposalId,
    required this.currentBid,
    required this.currentMessage,
  }) : super(key: key);

  @override
  _EditProposalScreenState createState() => _EditProposalScreenState();
}

class _EditProposalScreenState extends State<EditProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _bid;
  late String _message;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bid = widget.currentBid;
    _message = widget.currentMessage;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('proposals')
          .doc(widget.proposalId)
          .update({
            'bid': _bid,
            'message': _message,
            'updatedAt': FieldValue.serverTimestamp(),
            'status': 'pending',
          });
      Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Proposal'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _bid.toStringAsFixed(2),
                decoration: const InputDecoration(
                  labelText: 'Your Bid (USD)',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _bid = double.tryParse(v) ?? 0,
                validator:
                    (v) =>
                        (double.tryParse(v!) ?? 0) > 0
                            ? null
                            : 'Enter a valid amount',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _message,
                decoration: const InputDecoration(
                  labelText: 'Cover Letter',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                onChanged: (v) => _message = v.trim(),
                validator:
                    (v) =>
                        v != null && v.length >= 10
                            ? null
                            : 'At least 10 characters',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveChanges,
                  child:
                      _saving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
