// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:job_board_freelance_marketplace/Screens/Review%20System/auth_provider.dart';
// import 'package:job_board_freelance_marketplace/Screens/Review%20System/review_model.dart';

// final firestoreProvider = Provider<FirebaseFirestore>(
//   (_) => FirebaseFirestore.instance,
// );

// // StateNotifier for handling review operations
// final reviewControllerProvider =
//     StateNotifierProvider<ReviewController, AsyncValue<void>>((ref) {
//       return ReviewController(ref);
//     });

// class ReviewController extends StateNotifier<AsyncValue<void>> {
//   final Ref ref;
//   ReviewController(this.ref) : super(const AsyncValue.data(null));

//   Future<void> submitReview(Review review) async {
//     state = const AsyncValue.loading();
//     try {
//       final db = ref.read(firestoreProvider);

//       // Check for existing review
//       final existingReview =
//           await db
//               .collectionGroup('reviews')
//               .where('jobId', isEqualTo: review.jobId)
//               .where('reviewerId', isEqualTo: review.reviewerId)
//               .get();

//       if (existingReview.docs.isNotEmpty) {
//         throw 'You already submitted a review for this job';
//       }

//       // Add new review
//       final reviewRef =
//           db.collection('jobs').doc(review.jobId).collection('reviews').doc();
//       await reviewRef.set(review.toMap());

//       // Update user stats
//       final userRef = db.collection('users').doc(review.subjectId);
//       await db.runTransaction((transaction) async {
//         final userDoc = await transaction.get(userRef);
//         final currentReviews = userDoc.data()?['totalReviews'] ?? 0;
//         final currentRating = userDoc.data()?['averageRating'] ?? 0.0;

//         final newTotal = currentReviews + 1;
//         final newAverage =
//             ((currentRating * currentReviews) + review.rating) / newTotal;

//         transaction.update(userRef, {
//           'totalReviews': newTotal,
//           'averageRating': newAverage,
//         });
//       });

//       // In review_provider.dart
//       final hasReviewedProvider = FutureProvider.family<bool, String>((
//         ref,
//         String jobId,
//       ) async {
//         final user = ref.watch(authUserProvider);
//         final db = ref.watch(firestoreProvider);

//         final query =
//             await db
//                 .collectionGroup('reviews')
//                 .where('jobId', isEqualTo: jobId)
//                 .where('reviewerId', isEqualTo: user.uid)
//                 .limit(1)
//                 .get();

//         return query.docs.isNotEmpty;
//       });

//       state = const AsyncValue.data(null);
//     } catch (e) {
//       state = AsyncValue.error(e, StackTrace.current);
//       rethrow;
//     }
//   }
// }

// // In review_provider.dart
// final hasReviewedProvider = FutureProvider.family<bool, String>((
//   ref,
//   String jobId,
// ) async {
//   final user = ref.watch(authUserProvider);
//   final db = ref.watch(firestoreProvider);

//   final query =
//       await db
//           .collectionGroup('reviews')
//           .where('jobId', isEqualTo: jobId)
//           .where('reviewerId', isEqualTo: user.uid)
//           .limit(1)
//           .get();

//   return query.docs.isNotEmpty;
// });

// // Stream of reviews for a specific user
// final userReviewsProvider = StreamProvider.family<List<Review>, String>((
//   ref,
//   String userId,
// ) {
//   final db = ref.watch(firestoreProvider);
//   return db
//       .collectionGroup('reviews')
//       .where('subjectId', isEqualTo: userId)
//       .orderBy('createdAt', descending: true)
//       .snapshots()
//       .map(
//         (snapshot) =>
//             snapshot.docs
//                 .map((doc) => Review.fromFirestore(doc.data()))
//                 .toList(),
//       );
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_board_freelance_marketplace/Screens/Review%20System/auth_provider.dart';
import 'package:job_board_freelance_marketplace/Screens/Review%20System/review_model.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

// StateNotifier for handling review operations
final reviewControllerProvider =
    StateNotifierProvider<ReviewController, AsyncValue<void>>((ref) {
      return ReviewController(ref);
    });

class ReviewController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ReviewController(this.ref) : super(const AsyncValue.data(null));

  Future<void> submitReview(Review review) async {
    state = const AsyncValue.loading();
    try {
      final db = ref.read(firestoreProvider);

      // Check for existing review
      final existingReview =
          await db
              .collectionGroup('reviews')
              .where('jobId', isEqualTo: review.jobId)
              .where('reviewerId', isEqualTo: review.reviewerId)
              .get();

      if (existingReview.docs.isNotEmpty) {
        throw 'You already submitted a review for this job';
      }

      // Add new review
      final reviewRef =
          db.collection('jobs').doc(review.jobId).collection('reviews').doc();
      await reviewRef.set(review.toMap());

      // Update user stats
      final userRef = db.collection('users').doc(review.subjectId);
      await db.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final currentReviews = userDoc.data()?['totalReviews'] ?? 0;
        final currentRating = userDoc.data()?['averageRating'] ?? 0.0;

        final newTotal = currentReviews + 1;
        final newAverage =
            ((currentRating * currentReviews) + review.rating) / newTotal;

        transaction.update(userRef, {
          'totalReviews': newTotal,
          'averageRating': newAverage,
        });
      });

      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}

// In review_provider.dart
final hasReviewedProvider = FutureProvider.family<bool, String>((
  ref,
  String jobId,
) async {
  final user = ref.watch(authUserProvider);
  final db = ref.watch(firestoreProvider);

  final query =
      await db
          .collectionGroup('reviews')
          .where('jobId', isEqualTo: jobId)
          .where('reviewerId', isEqualTo: user.uid)
          .limit(1)
          .get();

  return query.docs.isNotEmpty;
});

final userReviewsProvider =
    StreamProvider.family<List<Review>, Map<String, String>>((ref, params) {
      final db = ref.watch(firestoreProvider);
      final subjectId = params['subjectId']!;
      final subjectRole = params['subjectRole']!;
      return db
          .collectionGroup('reviews')
          .where('subjectId', isEqualTo: subjectId)
          .where('subjectRole', isEqualTo: subjectRole)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snap) => snap.docs.map((d) => Review.fromFirestore(d)).toList(),
          );
    });

