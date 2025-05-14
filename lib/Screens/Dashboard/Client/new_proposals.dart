// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:job_board_freelance_marketplace/Screens/Job/Client/detail_proposal.dart';


// /// StreamProvider for the client’s “new” proposals
// final newProposalsProvider = StreamProvider.autoDispose((ref) {
//   final uid = FirebaseAuth.instance.currentUser!.uid;
//   return FirebaseFirestore.instance
//       .collection('proposals')
//       .where('clientId', isEqualTo: uid)
//       .where('status', isEqualTo: 'pending')
//       .orderBy('createdAt', descending: true)
//       .snapshots();
// });

// class NewProposalsScreen extends ConsumerWidget {
//   const NewProposalsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//         final theme = Theme.of(context);
//     final proposalsAsync = ref.watch(newProposalsProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('New Proposals'),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: theme.scaffoldBackgroundColor,
//       ),
//       body: proposalsAsync.when(
//         data: (snap) {
//           if (snap.docs.isEmpty) {
//             return const Center(
//               child: AnimatedOpacity(
//                 opacity: 1,
//                 duration: Duration(milliseconds: 500),
//                 child: Text(
//                   'No new proposals yet!',
//                   style: TextStyle(fontSize: 18, color: Colors.grey),
//                 ),
//               ),
//             );
//           }
//           return AnimatedList(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.all(16),
//             initialItemCount: snap.docs.length,
//             itemBuilder: (context, index, animation) {
//               final doc = snap.docs[index].data();
//               return _buildProposalItem(
//                 doc,
//                 snap.docs[index].id,
//                 index,
//                 animation,
//                 context,
//               );
//             },
//           );
//         },
//         loading:
//             () => Center(
//               child: SizedBox(
//                 width: 50,
//                 height: 50,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 3,
//                   valueColor: AlwaysStoppedAnimation<Color>(
//                     Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//               ),
//             ),
//         error:
//             (e, _) => Center(
//               child: ShakeTransition(
//                 child: Text(
//                   'Error loading proposals',
//                   style: TextStyle(color: Colors.red, fontSize: 16),
//                 ),
//               ),
//             ),
//       ),
//     );
//   }

//   Widget _buildProposalItem(
//     Map<String, dynamic> doc,
//     String id,
//     int index,
//     Animation<double> animation,
//     BuildContext context,
//   ) {
//     return SlideTransition(
//       position: Tween<Offset>(
//         begin: const Offset(1, 0),
//         end: Offset.zero,
//       ).animate(
//         CurvedAnimation(
//           parent: animation,
//           curve: Interval(0.1 * (index + 1), 1.0, curve: Curves.easeOutCubic),
//         ),
//       ),
//       child: FadeTransition(
//         opacity: animation,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Material(
//             borderRadius: BorderRadius.circular(15),
//             elevation: 2,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(15),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   PageRouteBuilder(
//                     transitionDuration: const Duration(milliseconds: 400),
//                     pageBuilder:
//                         (_, __, ___) => ProposalDetailScreen(proposalId: id),
//                     transitionsBuilder: (_, animation, __, child) {
//                       return FadeTransition(opacity: animation, child: child);
//                     },
//                   ),
//                 );
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   color: Theme.of(context).colorScheme.surface,
//                   border: Border.all(
//                     color: Colors.grey.withOpacity(0.2),
//                     width: 1,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Flexible(
//                           child: Row(
//                             children: [
//                               Text("Title: ",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
//                             Text(
//                             doc['title'] ?? '–',
//                             style: Theme.of(
//                               context,
//                             ).textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.w600,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: _getStatusColor(doc['status']),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             doc['status'].toString().toUpperCase(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'By ${doc['freelancerName'] ?? 'Unknown'}',
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       doc['message'] ?? 'Not Got',
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: const Color.fromARGB(255, 54, 5, 5),
//                         fontSize: 14,
//                         height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return Colors.orange;
//       case 'accepted':
//         return Colors.green;
//       case 'rejected':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }

// class ShakeTransition extends StatelessWidget {
//   final Widget child;
//   final Duration duration;

//   const ShakeTransition({
//     super.key,
//     required this.child,
//     this.duration = const Duration(milliseconds: 800),
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: duration,
//       curve: Curves.elasticOut,
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(value * 20 * (1 - value), 0),
//           child: child,
//         );
//       },
//       child: child,
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/detail_proposal.dart';

class NewProposalsScreen extends StatelessWidget {
  const NewProposalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Proposals'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance
                .collection('proposals')
                .where('clientId', isEqualTo: uid)
                .where('status', isEqualTo: 'pending')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No new proposals yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final docData = docs[index].data();
              final id = docs[index].id;
              return _buildProposalItem(context, docData, id);
            },
          );
        },
      ),
    );
  }

  Widget _buildProposalItem(
    BuildContext context,
    Map<String, dynamic> doc,
    String id,
  ) {
    final theme = Theme.of(context);
    return Material(
      borderRadius: BorderRadius.circular(15),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (_, __, ___) => ProposalDetailScreen(proposalId: id),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: theme.colorScheme.surface,
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      doc['title'] ?? 'Untitled',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(doc['status']),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      doc['status'].toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'By ${doc['freelancerName'] ?? 'Unknown'}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                doc['message'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
