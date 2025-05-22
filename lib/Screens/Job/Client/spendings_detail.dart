import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class SpendingDetailsScreen extends StatefulWidget {
  final double totalSpent;
  const SpendingDetailsScreen({Key? key, required this.totalSpent})
    : super(key: key);

  @override
  State<SpendingDetailsScreen> createState() => _SpendingDetailsScreenState();
}

class _SpendingDetailsScreenState extends State<SpendingDetailsScreen> {
  late Future<List<Map<String, dynamic>>> _contractsFuture;

  @override
  void initState() {
    _contractsFuture = _fetchCompletedContracts();
    super.initState();
  }

  Future<List<Map<String, dynamic>>> _fetchCompletedContracts() async {
    try {
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
        final bid = (data['agreedBid'] as num).toDouble(); // Handle int/double

        result.add({
          'title': jobTitle,
          'agreedBid': bid,
          'completedAt': (data['completedAt'] as Timestamp).toDate(),
        });
      }

      return result;
    } catch (e) {
      throw Exception('Failed to load contracts: $e');
    }
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder:
            (_, index) => Container(
              margin: const EdgeInsets.all(8),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            onPressed:
                () => setState(
                  () => _contractsFuture = _fetchCompletedContracts(),
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spending Details'), elevation: 0),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contractsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final contracts = snapshot.data ?? [];
          final totalSpent = contracts.fold<double>(
            0.0,
            (sum, item) => sum + (item['agreedBid'] ?? 0.0),
          );

          return Column(
            children: [
              // Header Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Spent',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(symbol: '\$').format(totalSpent),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // List of Contracts
              Expanded(
                child:
                    contracts.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No completed contracts',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: contracts.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final contract = contracts[index];
                            final formattedDate = DateFormat(
                              'MMM dd, yyyy',
                            ).format(contract['completedAt']);

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.assignment_turned_in,
                                  color: Colors.green,
                                ),
                                title: Text(
                                  contract['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'Completed: $formattedDate',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: Text(
                                  NumberFormat.currency(
                                    symbol: '\$',
                                  ).format(contract['agreedBid']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
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
