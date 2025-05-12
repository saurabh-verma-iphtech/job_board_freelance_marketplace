import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/detail_proposal.dart';

class ClientProposalsScreen extends StatelessWidget {
  const ClientProposalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // First get the client’s job IDs
    final jobsFuture =
        FirebaseFirestore.instance
            .collection('jobs')
            .where('createdBy', isEqualTo: uid)
            .get();

    return FutureBuilder<QuerySnapshot>(
      future: jobsFuture,
      builder: (ctx, jobsSnap) {
        if (!jobsSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final propsStream =
            FirebaseFirestore.instance
                .collection('proposals')
                .where('clientId', isEqualTo: uid)
                .orderBy('createdAt', descending: true)
                .snapshots();

        return Scaffold(
          appBar: AppBar(title: const Text('View Proposals')),
          body: StreamBuilder<QuerySnapshot>(
            stream: propsStream,
            builder: (ctx, propSnap) {
              if (!propSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (propSnap.data!.docs.isEmpty) {
                return const Center(child: Text('No proposals yet.'));
              }

              return ListView.builder(
                itemCount: propSnap.data!.docs.length,
                itemBuilder: (ctx, i) {
                  final p =
                      propSnap.data!.docs[i].data() as Map<String, dynamic>;
                  final pid = propSnap.data!.docs[i].id;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: ListTile(
                      title: Text('Bid: \$${p['bid']}'),
                      subtitle: Text(
                        p['message'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: Text(
                        p['status'].toString().toUpperCase(),
                        style: TextStyle(
                          color:
                              p['status'] == 'accepted'
                                  ? Colors.green
                                  : p['status'] == 'rejected'
                                  ? Colors.red
                                  : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ProposalDetailScreen(proposalId: pid),
                          ),
                        );
                      },
                      trailing: PopupMenuButton<String>(
                        onSelected: (choice) async {
                          // 1. Update proposal status
                          await FirebaseFirestore.instance
                              .collection('proposals')
                              .doc(pid)
                              .update({'status': choice});

                          // 2. If accepted, create a new contract
                          if (choice == 'accepted') {
                            await FirebaseFirestore.instance
                                .collection('contracts')
                                .add({
                                  'jobId': p['jobId'],
                                  'clientId': uid,
                                  'freelancerId': p['freelancerId'],
                                  'agreedBid': p['bid'],
                                  'status': 'ongoing',
                                  'startedAt': FieldValue.serverTimestamp(),
                                });
                          }
                        },
                        itemBuilder:
                            (_) => [
                              PopupMenuItem(
                                value: 'accepted',
                                child: Text('Accept'),
                              ),
                              PopupMenuItem(
                                value: 'rejected',
                                child: Text('Reject'),
                              ),
                            ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
