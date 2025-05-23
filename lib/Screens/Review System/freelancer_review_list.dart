import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/clientFreeProfile.dart';

class FreelancerReviewListScreen extends ConsumerWidget {
  const FreelancerReviewListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Reviews'),
        centerTitle: true,
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collectionGroup('reviews')
                .where('subjectId', isEqualTo: currentUserId)
                .where('subjectRole', isEqualTo: 'freelancer')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final reviewDoc = snapshot.data!.docs[index];
              final reviewData = reviewDoc.data() as Map<String, dynamic>;
              final clientId = reviewData['reviewerId'] as String;

              return FutureBuilder(
                future: _getReviewDetails(reviewData),
                builder: (
                  context,
                  AsyncSnapshot<Map<String, dynamic>> details,
                ) {
                  if (details.connectionState == ConnectionState.waiting) {
                    return _buildReviewShimmer();
                  }

                  if (!details.hasData) {
                    return const SizedBox.shrink();
                  }

                  return _ReviewCard(
                    clientName: details.data!['clientName'] ?? 'Unknown Client',
                    jobTitle: details.data!['jobTitle'] ?? 'Completed Job',
                    jobBid: details.data!['jobBid'] ?? 0.0,
                    rating: reviewData['rating'],
                    comment: reviewData['comment'],
                    date: (reviewData['createdAt'] as Timestamp).toDate(),
                    clientId: clientId,
                    isClientVersion: true,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _getReviewDetails(
    Map<String, dynamic> review,
  ) async {
    final clientDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(review['reviewerId'])
            .get();

    final jobDoc =
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(review['jobId'])
            .get();
    final jobData = jobDoc.data()!;

    // Normalize budget to a double, whether it's stored as int or double.
    final rawBudget = jobData['budget'] as num;
    final budget = rawBudget.toDouble();

    return {
      'clientName': clientDoc.data()?['name'],
      'jobTitle': jobDoc.data()?['title'],
      'jobBid': budget,
    };
  }

  Widget _buildReviewShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      height: 150,
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String clientName;
  final String jobTitle;
  final double jobBid;
  final double rating;
  final String comment;
  final DateTime date;
  final bool isClientVersion;
  final String clientId;


  const _ReviewCard({
    required this.clientName,
    required this.jobTitle,
    required this.jobBid,
    required this.rating,
    required this.comment,
    required this.date,
    required this.isClientVersion,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  clientName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              jobTitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Project Budget: \$${jobBid.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.green[700], fontSize: 14),
            ),
            const SizedBox(height: 12),
            RatingBarIndicator(
              rating: rating,
              itemCount: 5,
              itemSize: 20,
              itemBuilder:
                  (context, _) => const Icon(Icons.star, color: Colors.amber),
            ),
            const SizedBox(height: 12),
            Text(
              comment,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
                height: 1.4,
              ),
            ),
            if (isClientVersion) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientDetailScreen(clientId: clientId),
                    ),
                  );
                },
                child: const Text('View Freelancer Profile'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
