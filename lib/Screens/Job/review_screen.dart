// lib/screens/leave_review_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaveReviewScreen extends StatefulWidget {
  final String contractId;
  const LeaveReviewScreen({Key? key, required this.contractId})
    : super(key: key);

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  double _rating = 3.0;
  final _reviewController = TextEditingController();
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave a Review')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Rate your freelancer:', style: TextStyle(fontSize: 18)),
            Slider(
              value: _rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _rating.toString(),
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(labelText: 'Write a review'),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            _submitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _submitReview,
                  child: const Text('Submit'),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    setState(() => _submitting = true);
    await FirebaseFirestore.instance
        .collection('contracts')
        .doc(widget.contractId)
        .update({'rating': _rating, 'review': _reviewController.text.trim()});
    setState(() => _submitting = false);
    Navigator.pop(context); // go back to contract details or list
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Review submitted!')));
  }
}
