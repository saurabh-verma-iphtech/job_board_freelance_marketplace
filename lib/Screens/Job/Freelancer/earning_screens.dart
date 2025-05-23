import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  late Stream<QuerySnapshot> _earningsStream;
  double _totalEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    _loadEarningsData();
  }

  void _loadEarningsData() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _earningsStream =
        FirebaseFirestore.instance
            .collection('contracts')
            .where('freelancerId', isEqualTo: uid)
            .where('status', isEqualTo: 'completed')
            .orderBy('completedAt', descending: true)
            .snapshots();
  }

  Future<Map<String, String>> _getJobAndClientInfo(
    String jobId,
    String clientId,
  ) async {
    try {
      final jobDoc =
          await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();
      final clientDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(clientId)
              .get();

      return {
        'jobTitle': jobDoc.data()?['title'] ?? 'Untitled Job',
        'clientName': clientDoc.data()?['name'] ?? 'Unknown Client',
      };
    } catch (e) {
      return {'jobTitle': 'Untitled Job', 'clientName': 'Unknown Client'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorScheme.primary, colorScheme.surface],
            ),
          ),
        ),
        title: const Text('Earnings Overview'), elevation: 0),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _earningsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            final contracts = snapshot.data!.docs;
            _totalEarnings = contracts.fold<double>(0.0, (sum, doc) {
              final data = doc.data() as Map<String, dynamic>;
              return sum + (data['agreedBid'] as num).toDouble();
            });

            return Column(
              children: [
                // Total Earnings Card
                Container(
                  width: double.infinity,
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
                        'Total Earnings',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        NumberFormat.currency(
                          symbol: '\$',
                        ).format(_totalEarnings),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Across all completed contracts',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Contracts List
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
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
                              final contract =
                                  contracts[index].data()
                                      as Map<String, dynamic>;
                              final formattedDate = DateFormat(
                                'MMM dd, yyyy',
                              ).format(
                                (contract['completedAt'] as Timestamp).toDate(),
                              );
                              final amount =
                                  (contract['agreedBid'] as num).toDouble();
                              final jobId = contract['jobId']?.toString() ?? '';
                              final clientId =
                                  contract['clientId']?.toString() ?? '';

                              return FutureBuilder<Map<String, String>>(
                                future: _getJobAndClientInfo(jobId, clientId),
                                builder: (context, snapshot) {
                                  final jobTitle =
                                      snapshot.data?['jobTitle'] ??
                                      'Loading...';
                                  final clientName =
                                      snapshot.data?['clientName'] ??
                                      'Loading...';

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
                                        jobTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Client: $clientName • $formattedDate',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      trailing: Text(
                                        NumberFormat.currency(
                                          symbol: '\$',
                                        ).format(amount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
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
            onPressed: _loadEarningsData,
          ),
        ],
      ),
    );
  }
}
