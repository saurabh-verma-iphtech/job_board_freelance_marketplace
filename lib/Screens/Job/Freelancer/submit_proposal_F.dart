import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SubmitProposalScreen extends StatefulWidget {
  const SubmitProposalScreen({super.key});

  @override
  _SubmitProposalScreenState createState() => _SubmitProposalScreenState();
}

class _SubmitProposalScreenState extends State<SubmitProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  double _bid = 0;
  String _message = '';
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final jobId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Proposal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Your Bid (USD)',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _bid = double.tryParse(v) ?? 0,
                validator:
                    (v) =>
                        (double.tryParse(v!) ?? 0) > 0
                            ? null
                            : 'Enter a valid amount',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cover Letter'),
                maxLines: 4,
                onChanged: (v) => _message = v.trim(),
                validator:
                    (v) =>
                        v != null && v.length >= 10
                            ? null
                            : 'At least 10 characters',
              ),
              Spacer(),
              _saving
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _saving = true);

                        final uid = FirebaseAuth.instance.currentUser!.uid;
                        final firestore = FirebaseFirestore.instance;

                        try {
                          // 1️⃣ Fetch the job doc (to get clientId & title)
                          final jobSnap =
                              await firestore
                                  .collection('jobs')
                                  .doc(jobId)
                                  .get();
                          final jobData = jobSnap.data();
                          final clientId = jobData?['createdBy'] as String;
                          final jobTitle = jobData?['title'] ?? 'Untitled Job';

                          // 2️⃣ Fetch the freelancer name
                          final userSnap =
                              await firestore
                                  .collection('users')
                                  .doc(uid)
                                  .get();
                          final freelancerName =
                              userSnap.data()?['name'] ?? 'Unknown Freelancer';

                          // 3️⃣ Write the proposal, now with title and freelancerName
                          await firestore.collection('proposals').add({
                            'jobId': jobId,
                            'freelancerId': uid,
                            'freelancerName': freelancerName,
                            'clientId': clientId,
                            'title': jobTitle,
                            'bid': _bid,
                            'message': _message,
                            'status': 'pending',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          setState(() => _saving = false);
                          Navigator.pop(context);
                        } catch (e) {
                          setState(() => _saving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to submit proposal: $e'),
                            ),
                          );
                        }
                      },
                      child: const Text('Send Proposal'),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
