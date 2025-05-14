import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/client_job_detail.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/job_detail_screen.dart';

/// Screen: List completed jobs for both Client and Freelancer
class CompletedJobsScreen extends StatelessWidget {
  const CompletedJobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Completed Jobs')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnap.data?.data();
          final value = userData?['role'] as String?;
          final role = value?.toLowerCase();

          if (role != 'client' && role != 'freelancer') {
            return const Center(child: Text('Invalid or unknown role'));
          }

          final field = role == 'client' ? 'clientId' : 'freelancerId';

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance
                    .collection('contracts')
                    .where(field, isEqualTo: uid)
                    .where('status', isEqualTo: 'completed')
                    .orderBy('completedAt', descending: true)
                    .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snap.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(child: Text('No completed jobs found'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final contract = docs[i].data();
                  final jobId = contract['jobId'] as String? ?? '';
                  final agreedBid =
                      (contract['agreedBid'] as num?)?.toDouble() ?? 0.0;
                  final completedTs = contract['completedAt'] as Timestamp?;
                  final completedDate = completedTs?.toDate();

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title:
                          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            future:
                                FirebaseFirestore.instance
                                    .collection('jobs')
                                    .doc(jobId)
                                    .get(),
                            builder: (context, jobSnap) {
                              if (!jobSnap.hasData || !jobSnap.data!.exists) {
                                return const Text('Loading...');
                              }
                              final jobData = jobSnap.data!.data();
                              final jobTitle =
                                  jobData?['title'] as String? ?? 'Untitled';
                              return Text(
                                jobTitle,
                                style: const TextStyle(fontSize: 18),
                              );
                            },
                          ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Earnings: \$${agreedBid.toStringAsFixed(2)}'),
                          if (completedDate != null)
                            Text(
                              'Completed: ${DateFormat.yMMMd().format(completedDate)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    role == 'client'
                                        ? ClientJobDetailScreen(jobId: jobId)
                                        : JobDetailScreen(jobId: jobId),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
