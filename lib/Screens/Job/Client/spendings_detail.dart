import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpendingDetailsScreen extends StatefulWidget {

    final double totalSpent;
  const SpendingDetailsScreen({Key?key, required this.totalSpent}): super(key: key);

  @override
  State<SpendingDetailsScreen> createState() => _SpendingDetailsScreenState();
}

class _SpendingDetailsScreenState extends State<SpendingDetailsScreen> {
  late Future<List<Map<String, dynamic>>> _contractsFuture;

  @override
  void initState() {
      _contractsFuture = _fetchCompletedContracts(); // <- Initialize it here
    super.initState();
  }


  Future<List<Map<String, dynamic>>> _fetchCompletedContracts() async {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final contractQuery =
          await FirebaseFirestore.instance
              .collection('contracts')
              .where('clientId', isEqualTo: uid)
              .where('status', isEqualTo: 'completed')
              .orderBy('completedAt', descending: true)
              .get();

      List<Map<String, dynamic>> result = [];

      for (var doc in contractQuery.docs) {
        final data = doc.data();
        final jobSnapshot =
            await FirebaseFirestore.instance
                .collection('jobs')
                .doc(data['jobId'])
                .get();

        final jobTitle = jobSnapshot.data()?['title'] ?? 'Untitled Job';

        result.add({
          'title': jobTitle,
          'agreedBid': data['agreedBid'],
          'completedAt': (data['completedAt'] as Timestamp).toDate(),
        });
      }

      return result;
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spending Details')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contractsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final contracts = snapshot.data ?? [];
          // final totalSpent = contracts.fold<double>(
          //   0.0,
          //   (sum, item) => sum + (item['agreedBid'] ?? 0.0),
          // );

          if (contracts.isEmpty) {
            return const Center(child: Text('No completed contracts found.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.blue.shade50,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Spent',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${widget.totalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: contracts.length,
                  itemBuilder: (context, index) {
                    final contract = contracts[index];
                    final formattedDate = DateFormat(
                      'MMM dd, yyyy',
                    ).format(contract['completedAt']);

                    return ListTile(
                      title: Text(contract['title']),
                      subtitle: Text('Completed on: $formattedDate'),
                      trailing: Text(
                        '\$${(contract['agreedBid'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
