import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_board_freelance_marketplace/Payment/payment_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:job_board_freelance_marketplace/Model/contract.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/contract_detail_screen.dart';

class ContractsListScreen extends StatelessWidget {
  final String role;

  const ContractsListScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Contracts',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [Tab(text: '🟢 Ongoing'), Tab(text: '✅ Completed')],
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.background,
                theme.colorScheme.background.withOpacity(0.95),
              ],
            ),
          ),
          child: TabBarView(
            children: [
              _buildContractList(_buildQuery(uid, 'ongoing'), theme),
              _buildContractList(_buildQuery(uid, 'completed'), theme),
            ],
          ),
        ),
      ),
    );
  }

  Query<Map<String, dynamic>> _buildQuery(String uid, String status) {
    final userField =
        role.toLowerCase() == 'client' ? 'clientId' : 'freelancerId';
    return FirebaseFirestore.instance
        .collection('contracts')
        .where(userField, isEqualTo: uid)
        .where('status', isEqualTo: status)
        .orderBy(
          status == 'ongoing' ? 'startedAt' : 'completedAt',
          descending: true,
        );
  }

  Widget _buildContractList(
    Query<Map<String, dynamic>> query,
    ThemeData theme,
  ) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return _ErrorWidget(error: snap.error.toString());
        }

        if (snap.connectionState == ConnectionState.waiting) {
          return _ShimmerLoader();
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return _EmptyState(theme: theme);
        }

        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final doc = docs[i];
              final contract = Contract.fromFirestore(doc);

              return AnimationConfiguration.staggeredList(
                position: i,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _ContractCard(
                      contract: contract,
                      theme: theme,
                      role: role,
                      onMarkCompleted:
                          (id, paymentId) =>
                              _markContractAsCompleted(context, id, paymentId),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // In ContractsListScreen, modify _markContractAsCompleted
  Future<void> _markContractAsCompleted(
    BuildContext context,
    String contractId,
    String paymentId, // Add payment ID parameter
  ) async {
    try {
      final contractRef = FirebaseFirestore.instance
          .collection('contracts')
          .doc(contractId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(contractRef);
        if (!snapshot.exists) throw Exception("Contract not found");

        transaction.update(contractRef, {
          'status': 'completed',
          'completedAt': Timestamp.now(),
          'paymentId': paymentId, // Add payment ID
          'paymentDate': Timestamp.now(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contract completed & payment recorded!'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }
}

class _ContractCard extends StatelessWidget {
  final Contract contract;
  final ThemeData theme;
  final String role;
final Function(String, String)
  onMarkCompleted; // Accepts contractId + paymentId

  const _ContractCard({
    required this.contract,
    required this.theme,
    required this.role,
    required this.onMarkCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('jobs')
              .doc(contract.jobId)
              .get(),
      builder: (context, jobSnap) {
        final jobData = jobSnap.data?.data() as Map<String, dynamic>?;
        final title = jobData?['title'] ?? 'Untitled Job';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ContractDetailScreen(
                          contract: contract,
                          role: role,
                        ),
                  ),
                ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusChip(status: contract.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.attach_money,
                    label: 'Agreed Bid',
                    value: '\$${contract.agreedBid.toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  if (contract.status == 'ongoing' &&
                      role.toLowerCase() == 'client')
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToPayment(context),
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Mark Completed & Pay'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToPayment(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Completion'),
            content: const Text('Mark as completed and proceed to payment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => RazorPayPage(
                            contractId: contract.id,
                            amount: contract.agreedBid,
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            onSuccess:
                                (paymentId) =>
                                    onMarkCompleted(contract.id, paymentId),
                          ),
                    ),
                  );
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }
}

// void _showConfirmationDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder:
//         (ctx) => AlertDialog(
//           title: const Text('Confirm Completion'),
//           content: const Text('Are you sure this contract is completed?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(ctx);
//                 onMarkCompleted(contract.id);
//               },
//               child: const Text(
//                 'Confirm',
//                 style: TextStyle(color: Colors.green),
//               ),
//             ),
//           ],
//         ),
//   );
// }

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'completed';
    final color = isCompleted ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.timer,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ShimmerLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder:
            (_, index) => Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: theme.primaryColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Contracts Found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start new contracts to see them here!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;

  const _ErrorWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load contracts',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
