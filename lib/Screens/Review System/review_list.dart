// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:job_board_freelance_marketplace/Screens/Review%20System/review_provider.dart';
// import 'package:job_board_freelance_marketplace/Screens/Review%20System/review_model.dart';

// class ReviewListScreen extends ConsumerWidget {
//   final String subjectId;
//     final String subjectRole; // "client" or "freelancer"

//   const ReviewListScreen({required this.subjectId, required this.subjectRole, super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final reviewsAsync = ref.watch(userReviewsProvider(subjectId));

//     return Scaffold(
//       appBar: AppBar(title: const Text('User Reviews'), elevation: 4),
//       body: reviewsAsync.when(
//         data: (reviews) => _buildReviewList(reviews),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text('Error loading reviews: $e')),
//       ),
//     );
//   }

//   Widget _buildReviewList(List<Review> reviews) {
//     if (reviews.isEmpty) {
//       return const Center(
//         child: Text('No reviews yet.', style: TextStyle(fontSize: 18)),
//       );
//     }

//     return ListView.separated(
//       padding: const EdgeInsets.all(16),
//       separatorBuilder: (_, __) => const Divider(height: 32),
//       itemCount: reviews.length,
//       itemBuilder: (context, i) => _ReviewTile(review: reviews[i]),
//     );
//   }
// }

// class _ReviewTile extends StatelessWidget {
//   final Review review;
//   const _ReviewTile({required this.review});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.amber.shade100,
//         child: Text(review.rating.toStringAsFixed(1)),
//       ),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(review.comment, style: Theme.of(context).textTheme.bodyLarge),
//           const SizedBox(height: 8),
//           RatingBarIndicator(
//             rating: review.rating,
//             itemCount: 5,
//             itemSize: 20,
//             itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
//           ),
//         ],
//       ),
//       subtitle: Padding(
//         padding: const EdgeInsets.only(top: 8),
//         child: Text(
//           '${review.reviewerRole.capitalize()} • '
//           '${DateFormat.yMMMd().format(review.createdAt)}',
//           style: Theme.of(context).textTheme.bodySmall,
//         ),
//       ),
//     );
//   }
// }

// extension on String {
//   String capitalize() => isEmpty ? '' : this[0].toUpperCase() + substring(1);
// }


import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Review%20System/review_provider.dart';
import 'package:job_board_freelance_marketplace/Screens/Review%20System/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewListScreen extends ConsumerWidget {
  final String subjectId;
  final String subjectRole;

  const ReviewListScreen({
    required this.subjectId,
    required this.subjectRole,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(
      userReviewsProvider({'subjectId': subjectId, 'subjectRole': subjectRole}),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${subjectRole.capitalize()} Reviews'),
        elevation: 4,
      ),
      body: reviewsAsync.when(
        data: (reviews) => _buildReviewList(reviews),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading reviews: ${e.toString()}')),
      ),
    );
  }

  Widget _buildReviewList(List<Review> reviews) {
    if (reviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet.', style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const Divider(height: 32),
      itemCount: reviews.length,
      itemBuilder: (context, i) => _ReviewTile(review: reviews[i]),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  Future<Map<String, dynamic>> _getJobDetails() async {
    final jobDoc =
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(review.jobId)
            .get();

    return {
      'title': jobDoc.data()?['title'] ?? 'Completed Job',
      'budget': (jobDoc.data()?['budget'] as num?)?.toDouble() ?? 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getJobDetails(),
      builder: (context, snapshot) {
        final jobTitle = snapshot.data?['title'] ?? 'Loading...';
        final jobBudget = snapshot.data?['budget'] ?? 0.0;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.amber.shade100,
            child: Text(review.rating.toStringAsFixed(1)),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jobTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Project Budget: \$${jobBudget.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.green.shade700, fontSize: 14),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              RatingBarIndicator(
                rating: review.rating,
                itemCount: 5,
                itemSize: 20,
                itemBuilder:
                    (_, __) => const Icon(Icons.star, color: Colors.amber),
              ),
              const SizedBox(height: 8),
              Text(
                review.comment,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'By ${review.reviewerRole.capitalize()} • '
                '${DateFormat.yMMMd().format(review.createdAt)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension on String {
  String capitalize() => isEmpty ? '' : this[0].toUpperCase() + substring(1);
}
