// lib/screens/freelancer_profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FreelancerProfileScreen extends StatefulWidget {
  const FreelancerProfileScreen({super.key});

  @override
  _FreelancerProfileScreenState createState() =>
      _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen> {
  final _skillController = TextEditingController();
  List<String> _skills = [];
  bool _saving = false;

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() => _skills.add(skill));
      _skillController.clear();
    }
  }

  Future<void> _saveProfile() async {
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least one skill')));
      return;
    }
    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'skills': _skills,
      'profileCompleted': true,
    });
    setState(() => _saving = false);
    Navigator.pushReplacementNamed(context, '/freelancer-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Freelancer Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add your skills:', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Flutter, Firebase, UI/UX',
                    ),
                    onSubmitted: (_) => _addSkill(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addSkill),
              ],
            ),
            Wrap(
              spacing: 8,
              children:
                  _skills
                      .map(
                        (s) => Chip(
                          label: Text(s),
                          onDeleted: () => setState(() => _skills.remove(s)),
                        ),
                      )
                      .toList(),
            ),
            const Spacer(),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
