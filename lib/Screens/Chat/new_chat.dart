// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:job_board_freelance_marketplace/Screens/Chat/chat_screen.dart';

// class NewChatPage extends StatelessWidget {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<void> _startChat(BuildContext context, String freelancerId) async {
//     final currentUid = _auth.currentUser?.uid;
//     if (currentUid == null) return;

//     // Animation for button press
//     await HapticFeedback.lightImpact();

//     final freelancerDoc =
//         await _firestore.collection('users').doc(freelancerId).get();
//     final freelancerName = freelancerDoc.get('name') as String? ?? 'Unknown';

//     final existingChat =
//         await _firestore
//             .collection('chats')
//             .where('participants.clientId', isEqualTo: currentUid)
//             .where('participants.freelancerId', isEqualTo: freelancerId)
//             .get();

//     if (existingChat.docs.isNotEmpty) {
//       Navigator.push(
//         context,
//         PageRouteBuilder(
//           transitionDuration: const Duration(milliseconds: 400),
//           pageBuilder:
//               (_, __, ___) => ChatScreen(
//                 chatId: existingChat.docs.first.id,
//                 otherUserId: freelancerId,
//                 otherUserName: freelancerName,
//               ),
//           transitionsBuilder: (_, animation, __, child) {
//             return SlideTransition(
//               position: Tween<Offset>(
//                 begin: const Offset(1, 0),
//                 end: Offset.zero,
//               ).animate(
//                 CurvedAnimation(parent: animation, curve: Curves.easeInOut),
//               ),
//               child: child,
//             );
//           },
//         ),
//       );
//       return;
//     }

//     final chatRef = await _firestore.collection('chats').add({
//       'participants': {'clientId': currentUid, 'freelancerId': freelancerId},
//       'timestamp': FieldValue.serverTimestamp(),
//       'lastMessage': '',
//     });

//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         transitionDuration: const Duration(milliseconds: 400),
//         pageBuilder:
//             (_, __, ___) => ChatScreen(
//               chatId: chatRef.id,
//               otherUserId: freelancerId,
//               otherUserName: freelancerName,
//             ),
//         transitionsBuilder: (_, animation, __, child) {
//           return ScaleTransition(
//             scale: Tween<double>(begin: 0.5, end: 1).animate(
//               CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
//             ),
//             child: FadeTransition(opacity: animation, child: child),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('New Chat'),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 colorScheme.primary.withOpacity(0.8),
//                 colorScheme.secondary.withOpacity(0.6),
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
//               colorScheme.primary.withOpacity(0.05),
//               colorScheme.background,
//             ],
//           ),
//         ),
//         child: StreamBuilder<QuerySnapshot>(
//           stream:
//               _firestore
//                   .collection('users')
//                   .where('userType', isEqualTo: 'freelancer')
//                   .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation(colorScheme.primary),
//                 ).animate(
//                   effects: [
//                     ScaleEffect(duration: 500.ms, curve: Curves.easeOut),
//                     ShimmerEffect(delay: 300.ms, duration: 800.ms),
//                   ],
//                 ),
//               );
//             }

//             final docs = snapshot.data?.docs ?? [];
//             if (docs.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No freelancers available',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                     ),
//                   ],
//                 ).animate().fadeIn(duration: 500.ms),
//               );
//             }

//             return AnimatedList(
//               padding: const EdgeInsets.all(16),
//               initialItemCount: docs.length,
//               itemBuilder: (context, index, animation) {
//                 final userDoc = docs[index];
//                 final name = userDoc.get('name') as String? ?? 'Unknown';
//                 final email = userDoc.get('email') as String? ?? '';

//                 return SlideTransition(
//                   position: Tween<Offset>(
//                     begin: const Offset(0, 0.5),
//                     end: Offset.zero,
//                   ).animate(
//                     CurvedAnimation(
//                       parent: animation,
//                       curve: Curves.easeOutQuint,
//                     ),
//                   ),
//                   child: FadeTransition(
//                     opacity: animation,
//                     child: _buildFreelancerCard(
//                       context,
//                       name,
//                       email,
//                       userDoc.id,
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildFreelancerCard(
//     BuildContext context,
//     String name,
//     String email,
//     String userId,
//   ) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       margin: const EdgeInsets.only(bottom: 12),      
//       child: InkWell(
//         onTap: () => _startChat(context, userId),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: colorScheme.primary.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Center(
//                   child: Text(
//                     name.isNotEmpty ? name[0] : '?',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       email,
//                       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(Icons.chat_bubble_outline, color: colorScheme.primary),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
