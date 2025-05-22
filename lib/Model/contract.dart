import 'package:cloud_firestore/cloud_firestore.dart';

class Contract {
  final String id;
  final String jobId;
  final String clientId;
  final String freelancerId;
  final double agreedBid;
  late final String status;
  final DateTime startedAt;
  final DateTime? completedAt;
    final String? paymentId;
  final DateTime? paymentDate;

  Contract({
    required this.id,
    required this.jobId,
    required this.clientId,
    required this.freelancerId,
    required this.agreedBid,
    required this.status,
    required this.startedAt,
      this.paymentId,
    this.paymentDate,
    this.completedAt,
  });

  factory Contract.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Contract(
      id: doc.id,
      jobId: data['jobId'],
      clientId: data['clientId'],
      freelancerId: data['freelancerId'],
      agreedBid: (data['agreedBid'] as num).toDouble(),
      status: data['status'],
      startedAt: (data['startedAt'] as Timestamp).toDate(),
            paymentId: data['paymentId'],
      paymentDate: (data['paymentDate'] as Timestamp?)?.toDate(),

      completedAt:
          data['completedAt'] != null
              ? (data['completedAt'] as Timestamp).toDate()
              : null,
    );
  }
}
