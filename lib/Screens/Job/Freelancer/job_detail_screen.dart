import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;
  const JobDetailScreen({Key? key, required this.jobId}) : super(key: key);

  Future<bool> _hasSubmittedProposal(String jobId, String freelancerId) async {
    final proposals =
        await FirebaseFirestore.instance
            .collection('proposals')
            .where('jobId', isEqualTo: jobId)
            .where('freelancerId', isEqualTo: freelancerId)
            .get();
    return proposals.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final docRef = FirebaseFirestore.instance.collection('jobs').doc(jobId);

    return FutureBuilder<DocumentSnapshot>(
      future: docRef.get(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        final isClient = data['clientId'] == userId;

        return Scaffold(
          appBar: AppBar(title: Text(data['title'] ?? 'Job Details')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Description: $data['description']", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Text('Category: ${data['category']}'),
                Text('Budget: \$${data['budget']}'),
                const Spacer(),
                if (!isClient)
                  FutureBuilder<bool>(
                    future: _hasSubmittedProposal(jobId, userId!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.data!) {
                        return const Text(
                          'You have already submitted a proposal.',
                          style: TextStyle(color: Colors.grey),
                        );
                      }
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/submit-proposal',
                              arguments: jobId,
                            );
                          },
                          child: const Text('Apply for this Job'),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
