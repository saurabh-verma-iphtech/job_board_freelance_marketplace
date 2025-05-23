import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final double rating; // 1-5 rating
  final String comment; // Optional comment
  final String reviewerId; // ID of user giving the review
  final String subjectId; // ID of user receiving the review
  final String reviewerRole; // Role of reviewer (client/freelancer)
  final String subjectRole; // Role of subject (client/freelancer)
  final DateTime createdAt;
  final String jobId; // Associated job ID

  Review({
    required this.rating,
    required this.comment,
    required this.reviewerId,
    required this.subjectId,
    required this.reviewerRole,
    required this.subjectRole,
    required this.jobId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Firestore format
  Map<String, dynamic> toMap() => {
    'rating': rating,
    'comment': comment,
    'reviewerId': reviewerId,
    'subjectId': subjectId,
    'reviewerRole': reviewerRole,
    'subjectRole': subjectRole,
    'createdAt': Timestamp.fromDate(createdAt),
    'jobId': jobId,
  };

  // Create from Firestore document
  // In review_model.dart
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data =
        doc.data() as Map<String, dynamic>; // Extract data from snapshot
    return Review(
      jobId: data['jobId'],
      subjectId: data['subjectId'],
      subjectRole: data['subjectRole'],
      reviewerId: data['reviewerId'],
      reviewerRole: data['reviewerRole'] ?? 'unknown', // Fixes Firestore typo
      rating: (data['rating'] as num).toDouble(),
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
