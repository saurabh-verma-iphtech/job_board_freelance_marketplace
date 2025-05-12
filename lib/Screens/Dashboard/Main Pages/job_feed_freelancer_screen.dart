// // lib/screens/job_feed_screen.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class JobFeedScreen extends StatelessWidget {
//   const JobFeedScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final jobsQuery = FirebaseFirestore.instance
//         .collection('jobs')
//         .where('status', isEqualTo: 'open')
//         .orderBy('createdAt', descending: true);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Job Feed')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: jobsQuery.snapshots(),
//         builder: (ctx, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snap.hasData || snap.data!.docs.isEmpty) {
//             return const Center(child: Text('No open jobs right now.'));
//           }

//           return ListView.builder(
//             itemCount: snap.data!.docs.length,
//             itemBuilder: (ctx, i) {
//               final data = snap.data!.docs[i].data() as Map<String, dynamic>;
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 child: ListTile(
//                   title: Text(data['title'] ?? ''),
//                   subtitle: Text('${data['category']} • \$${data['budget']}'),
//                   onTap: () {
//                     // TODO: navigate to JobDetailScreen
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/job_detail_screen.dart';

class JobFeedScreen extends StatelessWidget {
  const JobFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jobsQuery = FirebaseFirestore.instance
        .collection('jobs')
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Job Feed')),
      body: StreamBuilder<QuerySnapshot>(
        stream: jobsQuery.snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('No open jobs right now.'));
          }

          final docs = snap.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(data['title'] ?? 'No title'),
                  subtitle: Text('${data['category']} • \$${data['budget']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobDetailScreen(jobId: doc.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
