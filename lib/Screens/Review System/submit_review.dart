// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:job_board_freelance_marketplace/Screens/Review%20System/auth_provider.dart';
// import 'package:job_board_freelance_marketplace/Screens/Review%20System/review_model.dart';
// import 'package:job_board_freelance_marketplace/Screens/Review%20System/review_provider.dart';

// class SubmitReviewScreen extends ConsumerStatefulWidget {
//   final String jobId;
//   final String subjectId; // ID of the user being reviewed
//   final String reviewerRole; // Role of the reviewer ("client" or "freelancer")
//   final String subjectRole; // Role of the subject being reviewed

//   const SubmitReviewScreen({
//     required this.jobId,
//     required this.subjectId,
//     required this.reviewerRole,
//     required this.subjectRole,
//     super.key,
//   });

//   @override
//   ConsumerState<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
// }

// class _SubmitReviewScreenState extends ConsumerState<SubmitReviewScreen> {
//   double _rating = 5;
//   final _commentCtl = TextEditingController();
//   bool _isSubmitting = false;

//   Future<void> _submit(String reviewerId) async {
//       if (widget.reviewerRole == widget.subjectRole) {
//       throw 'Cannot review same role user';
//     }
    
//     try {
//       setState(() => _isSubmitting = true);
      
//       final review = Review(
//         rating: _rating,
//         comment: _commentCtl.text.trim(),
//         reviewerId: reviewerId,
//         subjectId: widget.subjectId,
//         reviewerRole: widget.reviewerRole,
//         subjectRole: widget.subjectRole,
//         jobId: widget.jobId, // Added jobId to Review model
//       );

//       await ref.read(reviewControllerProvider.notifier)
//           .submitReview(review)
//           .timeout(const Duration(seconds: 10));

//       if (mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Review submitted successfully!')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to submit review: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authAsync = ref.watch(authStateChangesProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Review ${widget.subjectRole.capitalize()}'),
//         elevation: 4,
//       ),
//       body: authAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, _) => Center(child: Text('Authentication Error: $e')),
//         data: (user) {
//           if (user == null) {
//             return const AuthRequiredMessage();
//           }
//           return _buildReviewForm(user.uid);
//         },
//       ),
//     );
//   }

//   Widget _buildReviewForm(String userId) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Text(
//             'Rate your ${widget.subjectRole}',
//             style: Theme.of(context).textTheme.titleLarge,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 24),
//           Center(
//             child: RatingBar.builder(
//               initialRating: _rating,
//               minRating: 1,
//               allowHalfRating: true,
//               itemPadding: const EdgeInsets.symmetric(horizontal: 4),
//               itemBuilder: (_, __) => const Icon(
//                 Icons.star,
//                 color: Colors.amber,
//                 size: 36,
//               ),
//               onRatingUpdate: (r) => setState(() => _rating = r),
//             ),
//           ),
//           const SizedBox(height: 32),
//           TextField(
//             controller: _commentCtl,
//             maxLines: 4,
//             maxLength: 500,
//             decoration: InputDecoration(
//               border: const OutlineInputBorder(),
//               labelText: 'Comments (optional)',
//               hintText: 'Share details about your experience...',
//               alignLabelWithHint: true,
//             ),
//             onChanged: (_) => setState(() {}),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             icon: _isSubmitting
//                 ? const SizedBox.shrink()
//                 : const Icon(Icons.send_outlined),
//             label: _isSubmitting
//                 ? const CircularProgressIndicator()
//                 : const Text('Submit Review'),
//             onPressed: _isSubmitting ? null : () => _submit(userId),
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AuthRequiredMessage extends StatelessWidget {
//   const AuthRequiredMessage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline, size: 48, color: Colors.red),
//             const SizedBox(height: 16),
//             Text(
//               'You must be logged in to submit a review.',
//               style: Theme.of(context).textTheme.titleMedium,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/login'),
//               child: const Text('Go to Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// extension on String {
//   String capitalize() => isEmpty ? '' : this[0].toUpperCase() + substring(1);
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:job_board_freelance_marketplace/Screens/Review%20System/auth_provider.dart';
import 'package:job_board_freelance_marketplace/Screens/Review%20System/review_model.dart';
import 'package:job_board_freelance_marketplace/Screens/Review%20System/review_provider.dart';

class SubmitReviewScreen extends ConsumerStatefulWidget {
  final String jobId;
  final String subjectId;
  final String reviewerRole;
  final String subjectRole;

  const SubmitReviewScreen({
    required this.jobId,
    required this.subjectId,
    required this.reviewerRole,
    required this.subjectRole,
    super.key,
  });

  @override
  ConsumerState<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends ConsumerState<SubmitReviewScreen> {
  double _rating = 5;
  final _commentCtl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit(String reviewerId) async {
    if (widget.reviewerRole == widget.subjectRole) {
      _showError(
        'You cannot review a ${widget.subjectRole} as a ${widget.reviewerRole}',
      );
      return;
    }

    if (_commentCtl.text.trim().isEmpty && _rating < 4) {
      _showError('Please add comments for ratings below 4 stars');
      return;
    }

    try {
      setState(() => _isSubmitting = true);

      final review = Review(
        rating: _rating,
        comment: _commentCtl.text.trim(),
        reviewerId: reviewerId,
        subjectId: widget.subjectId,
        reviewerRole: widget.reviewerRole,
        subjectRole: widget.subjectRole,
        jobId: widget.jobId,
      );

      await ref
          .read(reviewControllerProvider.notifier)
          .submitReview(review)
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${widget.subjectRole.capitalize()}'),
        elevation: 4,
      ),
      body: authAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) =>
                Center(child: Text('Authentication Error: ${e.toString()}')),
        data:
            (user) =>
                user == null
                    ? const _AuthRequiredMessage()
                    : _buildReviewForm(user.uid),
      ),
    );
  }

  Widget _buildReviewForm(String userId) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How was your experience with this ${widget.subjectRole}?',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Center(
            child: RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              allowHalfRating: true,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder:
                  (_, __) =>
                      const Icon(Icons.star, color: Colors.amber, size: 36),
              onRatingUpdate: (r) => setState(() => _rating = r),
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _commentCtl,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Share your experience (optional)',
              hintText: 'What did you like about working with them?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon:
                _isSubmitting
                    ? const SizedBox.shrink()
                    : const Icon(Icons.send_outlined),
            label:
                _isSubmitting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Submit Review'),
            onPressed: _isSubmitting ? null : () => _submit(userId),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthRequiredMessage extends StatelessWidget {
  const _AuthRequiredMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'You must be logged in to submit a review',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() => isEmpty ? '' : this[0].toUpperCase() + substring(1);
}
