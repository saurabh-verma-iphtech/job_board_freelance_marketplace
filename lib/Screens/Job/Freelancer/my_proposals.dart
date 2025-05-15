// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// import 'package:intl/intl.dart';
// import 'package:job_board_freelance_marketplace/Screens/Chat/chat_screen.dart';
// import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/job_detail_screen.dart';

// class MyProposalsScreen extends StatefulWidget {
//   const MyProposalsScreen({super.key});

//   @override
//   State<MyProposalsScreen> createState() => _MyProposalsScreenState();
// }

// class _MyProposalsScreenState extends State<MyProposalsScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final int _perPage = 10;
//   DocumentSnapshot? _lastDocument;
//   bool _isLoadingMore = false;
//   bool _hasMore = true;
//   final List<DocumentSnapshot> _allProposals = [];
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//     @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_scrollListener);
//     _loadInitialProposals();
//   }


// Future<void> _loadInitialProposals() async {
//     final query = _firestore
//         .collection('proposals')
//         .where(
//           'freelancerId',
//           isEqualTo: FirebaseAuth.instance.currentUser!.uid,
//         )
//         .orderBy('createdAt', descending: true)
//         .limit(_perPage);

//     final snapshot = await query.get();
//     setState(() {
//       _allProposals.addAll(snapshot.docs);
//       _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
//       _hasMore = snapshot.docs.length >= _perPage;
//     });
//   }

//     Future<void> _loadMoreProposals() async {
//     if (!_hasMore || _isLoadingMore) return;

//     setState(() => _isLoadingMore = true);

//     final query = _firestore
//         .collection('proposals')
//         .where(
//           'freelancerId',
//           isEqualTo: FirebaseAuth.instance.currentUser!.uid,
//         )
//         .orderBy('createdAt', descending: true)
//         .startAfterDocument(_lastDocument!)
//         .limit(_perPage);

//     final snapshot = await query.get();
//     setState(() {
//       _allProposals.addAll(snapshot.docs);
//       _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
//       _hasMore = snapshot.docs.length >= _perPage;
//       _isLoadingMore = false;
//     });
//   }

//   void _scrollListener() {
//     if (_scrollController.offset >=
//             _scrollController.position.maxScrollExtent &&
//         !_scrollController.position.outOfRange) {
//       _loadMoreProposals();
//     }
//   }



// void _handleEditProposal(
//     BuildContext context,
//     String proposalId,
//     double bid,
//     Map<String, dynamic> data,
//   ) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder:
//             (_) => EditProposalScreen(
//               proposalId: proposalId,
//               currentBid: bid,
//               currentMessage: data['message'] as String? ?? '',
//             ),
//       ),
//     );
//   }

//   void _handleChatButton(
//     BuildContext context,
//     Map<String, dynamic> data,
//     String jobId,
//   ) async {
//     final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
//     if (!jobDoc.exists) return;

//     final clientId = jobDoc.data()?['createdBy'] as String?;
//     if (clientId == null) return;

//     final clientDoc = await _firestore.collection('users').doc(clientId).get();
//     final clientName = clientDoc.data()?['name'] as String? ?? 'Client';

//     _startChatWithClient(context, clientId, clientName);
//   }

//   void _showPopupMenu(
//     BuildContext context,
//     String proposalId,
//     double bid,
//     Map<String, dynamic> data,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       builder:
//           (ctx) => Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   leading: Icon(
//                     Icons.edit,
//                     color: _getStatusColor(data['status']),
//                   ),
//                   title: const Text('Edit Proposal'),
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _handleEditProposal(context, proposalId, bid, data);
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.cancel, color: Colors.red),
//                   title: const Text('Cancel Proposal'),
//                   onTap: () async {
//                     Navigator.pop(ctx);
//                     final confirm = await showDialog<bool>(
//                       context: context,
//                       builder:
//                           (dialogCtx) => AlertDialog(
//                             title: const Text('Confirm Cancellation'),
//                             content: const Text(
//                               'Are you sure you want to cancel this proposal?',
//                             ),
//                             actions: [
//                               TextButton(
//                                 onPressed:
//                                     () => Navigator.pop(dialogCtx, false),
//                                 child: const Text('No'),
//                               ),
//                               TextButton(
//                                 onPressed: () => Navigator.pop(dialogCtx, true),
//                                 child: const Text(
//                                   'Yes',
//                                   style: TextStyle(color: Colors.red),
//                                 ),
//                               ),
//                             ],
//                           ),
//                     );

//                     if (confirm == true) {
//                       await _firestore
//                           .collection('proposals')
//                           .doc(proposalId)
//                           .update({
//                             'status': 'canceled',
//                             'updatedAt': FieldValue.serverTimestamp(),
//                           });
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   // Add the existing _startChatWithClient method
//   Future<void> _startChatWithClient(
//     BuildContext context,
//     String clientId,
//     String otherUserName,
//   ) async {
//     try {
//       final currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser == null) return;

//       final freelancerId = currentUser.uid;
//       final firestore = FirebaseFirestore.instance;

//       final chatQuery =
//           await firestore
//               .collection('chats')
//               .where('participants.clientId', isEqualTo: clientId)
//               .where('participants.freelancerId', isEqualTo: freelancerId)
//               .limit(1)
//               .get();

//       String chatId;

//       if (chatQuery.docs.isNotEmpty) {
//         chatId = chatQuery.docs.first.id;
//       } else {
//         final newChat = await firestore.collection('chats').add({
//           'participants': {'clientId': clientId, 'freelancerId': freelancerId},
//           'lastMessage': 'Chat started',
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//         chatId = newChat.id;
//       }

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder:
//               (context) => ChatScreen(
//                 chatId: chatId,
//                 otherUserId: clientId,
//                 otherUserName: otherUserName,
//               ),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error starting chat: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }



//   Map<String, List<DocumentSnapshot>> _groupProposalsByDate() {
//     final grouped = <String, List<DocumentSnapshot>>{};
//     for (final doc in _allProposals) {
//       final data = doc.data() as Map<String, dynamic>;
//       final ts = data['createdAt'] as Timestamp?;
//       final date = ts?.toDate() ?? DateTime.now();
//       final dateKey = _getDateGroupKey(date);
//       grouped.putIfAbsent(dateKey, () => []).add(doc);
//     }
//     return grouped;
//   }

  

//   String _getDateGroupKey(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));

//     if (date.isAfter(today)) return 'Today';
//     if (date.isAfter(yesterday)) return 'Yesterday';
//     if (date.isAfter(today.subtract(const Duration(days: 7))))
//       return 'This Week';
//     return DateFormat('MMMM yyyy').format(date);
//   }


//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final groupedProposals = _groupProposalsByDate();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Proposals'),
//         centerTitle: true,
//         backgroundColor: theme.scaffoldBackgroundColor,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 colorScheme.primary.withOpacity(0.1),
//                 colorScheme.surface.withOpacity(0.1),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
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
//         child:
//             _allProposals.isEmpty
//                 ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.assignment_outlined,
//                         size: 64,
//                         color: colorScheme.primary.withOpacity(0.3),
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         'No Proposals Found',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//                 : AnimationLimiter(
//                   child: ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(16),
//                     itemCount: groupedProposals.length * 2 + (_hasMore ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (index == groupedProposals.length * 2 && _hasMore) {
//                         return _buildLoadingIndicator();
//                       }

//                       if (index.isOdd) {
//                         final groupIndex = index ~/ 2;
//                         final groupKey = groupedProposals.keys.elementAt(
//                           groupIndex,
//                         );
//                         return _buildDateHeader(groupKey);
//                       }

//                       final groupIndex = index ~/ 2;
//                       final groupKey = groupedProposals.keys.elementAt(
//                         groupIndex,
//                       );
//                       final proposals = groupedProposals[groupKey]!;

//                       return AnimationConfiguration.staggeredList(
//                         position: groupIndex,
//                         duration: const Duration(milliseconds: 500),
//                         child: SlideAnimation(
//                           verticalOffset: 50.0,
//                           child: FadeInAnimation(
//                             child: Column(
//                               children:
//                                   proposals
//                                       .map(
//                                         (doc) =>
//                                             _buildProposalCard(context, doc),
//                                       )
//                                       .toList(),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//       ),
//     );
//   }


//   Widget _buildDateHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: Divider(
//               thickness: 1,
//               color: Colors.grey[300],
//               endIndent: 10,
//             ),
//           ),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[600],
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//           Expanded(
//             child: Divider(thickness: 1, color: Colors.grey[300], indent: 10),
//           ),
//         ],
//       ),
//     );
//   }


//   Widget _buildProposalCard(BuildContext context, DocumentSnapshot doc) {
//     final theme = Theme.of(context);
//     final data = doc.data() as Map<String, dynamic>;
//     final proposalId = doc.id;
//     final jobId = data['jobId'] as String? ?? '';
//     final title = data['title'] as String? ?? 'Untitled Proposal';
//     final bid = (data['bid'] as num?)?.toDouble() ?? 0.0;
//     final status = data['status'] as String? ?? 'pending';
//     final ts = data['createdAt'] as Timestamp?;
//     final date = ts?.toDate();
//     final statusColor = _getStatusColor(status);

//     return AnimationConfiguration.staggeredList(
//       position: _allProposals.indexOf(doc),
//       duration: const Duration(milliseconds: 500),
//       child: SlideAnimation(
//         horizontalOffset: 50.0,
//         child: FadeInAnimation(
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 16),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Material(
//               borderRadius: BorderRadius.circular(16),
//               color: theme.colorScheme.surface,
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(16),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     PageRouteBuilder(
//                       transitionDuration: const Duration(milliseconds: 400),
//                       pageBuilder:
//                           (_, __, ___) => JobDetailScreen(jobId: jobId),
//                       transitionsBuilder: (_, animation, __, child) {
//                         return FadeTransition(
//                           opacity: animation,
//                           child: SlideTransition(
//                             position: Tween<Offset>(
//                               begin: const Offset(0.5, 0),
//                               end: Offset.zero,
//                             ).animate(animation),
//                             child: child,
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Flexible(
//                             child: Text(
//                               title,
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 color: theme.colorScheme.primary,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           _buildStatusIndicator(status, statusColor),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           _buildDetailItem(
//                             icon: Icons.attach_money_rounded,
//                             value: '\$${bid.toStringAsFixed(2)}',
//                             label: 'Bid Amount',
//                             color: Colors.green,
//                           ),
//                           const SizedBox(width: 24),
//                           _buildDetailItem(
//                             icon: Icons.access_time_rounded,
//                             value:
//                                 date != null
//                                     ? DateFormat('MMM dd, yyyy').format(date)
//                                     : 'N/A',
//                             label: 'Submitted',
//                             color: Colors.purple,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           _buildActionButton(
//                             icon: Icons.edit,
//                             label: 'Edit',
//                             color: Colors.blue,
//                             onPressed:
//                                 () => _handleEditProposal(
//                                   context,
//                                   proposalId,
//                                   bid,
//                                   data,
//                                 ),
//                           ),
//                           _buildActionButton(
//                             icon: Icons.chat,
//                             label: 'Chat',
//                             color: Colors.green,
//                             onPressed:
//                                 () => _handleChatButton(context, data, jobId),
//                           ),
//                           _buildActionButton(
//                             icon: Icons.more_vert,
//                             label: 'More',
//                             color: Colors.grey,
//                             onPressed:
//                                 () => _showPopupMenu(
//                                   context,
//                                   proposalId,
//                                   bid,
//                                   data,
//                                 ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusIndicator(String status, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(_getStatusIcon(status), size: 14, color: color),
//           const SizedBox(width: 6),
//           Text(
//             status.toUpperCase(),
//             style: TextStyle(
//               color: color,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailItem({
//     required IconData icon,
//     required String value,
//     required String label,
//     required Color color,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: color),
//         const SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               value,
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//             ),
//             Text(
//               label,
//               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onPressed,
//   }) {
//     return TextButton.icon(
//       icon: Icon(icon, size: 18, color: color),
//       label: Text(label, style: TextStyle(color: color)),
//       onPressed: onPressed,
//       style: TextButton.styleFrom(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator() {
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Center(
//         child: CircularProgressIndicator.adaptive(
//           backgroundColor: Colors.grey[300],
//           valueColor: AlwaysStoppedAnimation(
//             Theme.of(context).colorScheme.primary,
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
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Chat/chat_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/job_detail_screen.dart';

class MyProposalsScreen extends StatefulWidget {
  const MyProposalsScreen({super.key});

  @override
  State<MyProposalsScreen> createState() => _MyProposalsScreenState();
}

class _MyProposalsScreenState extends State<MyProposalsScreen> {
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

  Future<void> _loadInitialProposals() async {
        setState(() => _isInitialLoading = true);
    final query = _firestore
        .collection('proposals')
        .where(
          'freelancerId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
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

  void _handleEditProposal(
    BuildContext context,
    String proposalId,
    double bid,
    Map<String, dynamic> data,
  ) {
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
  }

  void _handleChatButton(
    BuildContext context,
    Map<String, dynamic> data,
    String jobId,
  ) async {
    final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
    if (!jobDoc.exists) return;

    final clientId = jobDoc.data()?['createdBy'] as String?;
    if (clientId == null) return;

    final clientDoc = await _firestore.collection('users').doc(clientId).get();
    final clientName = clientDoc.data()?['name'] as String? ?? 'Client';

    _startChatWithClient(context, clientId, clientName);
  }

  void _showPopupMenu(
    BuildContext context,
    String proposalId,
    double bid,
    Map<String, dynamic> data,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.edit,
                    color: _getStatusColor(data['status']),
                  ),
                  title: const Text('Edit Proposal'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleEditProposal(context, proposalId, bid, data);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('Cancel Proposal'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (dialogCtx) => AlertDialog(
                            title: const Text('Confirm Cancellation'),
                            content: const Text(
                              'Are you sure you want to cancel this proposal?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.pop(dialogCtx, false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx, true),
                                child: const Text(
                                  'Yes',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      await _firestore
                          .collection('proposals')
                          .doc(proposalId)
                          .update({
                            'status': 'canceled',
                            'updatedAt': FieldValue.serverTimestamp(),
                          });
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Add the existing _startChatWithClient method
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
              (context) => ChatScreen(
                chatId: chatId,
                otherUserId: clientId,
                otherUserName: otherUserName,
              ),
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
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
        title: const Text('My Proposals'),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
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
              colorScheme.primary.withOpacity(0.1),
              colorScheme.background,
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
                        Icons.assignment_outlined,
                        size: 64,
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Proposals Found',
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
                                            _buildProposalCard(context, doc),
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

  Widget _buildProposalCard(BuildContext context, DocumentSnapshot doc) {
    final theme = Theme.of(context);
    final data = doc.data() as Map<String, dynamic>;
    final proposalId = doc.id;
    final jobId = data['jobId'] as String? ?? '';
    final title = data['title'] as String? ?? 'Untitled Proposal';
    final bid = (data['bid'] as num?)?.toDouble() ?? 0.0;
    final status = data['status'] as String? ?? 'pending';
    final ts = data['createdAt'] as Timestamp?;
    final date = ts?.toDate();
    final statusColor = _getStatusColor(status);

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
                          _buildStatusIndicator(status, statusColor),
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
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit,
                            label: 'Edit',
                            color: Colors.blue,
                            onPressed:
                                () => _handleEditProposal(
                                  context,
                                  proposalId,
                                  bid,
                                  data,
                                ),
                          ),
                          _buildActionButton(
                            icon: Icons.chat,
                            label: 'Chat',
                            color: Colors.green,
                            onPressed:
                                () => _handleChatButton(context, data, jobId),
                          ),
                          _buildActionButton(
                            icon: Icons.more_vert,
                            label: 'More',
                            color: Colors.grey,
                            onPressed:
                                () => _showPopupMenu(
                                  context,
                                  proposalId,
                                  bid,
                                  data,
                                ),
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

  Widget _buildStatusIndicator(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
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
