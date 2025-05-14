// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({Key? key}) : super(key: key);

//   @override
//   _EditProfileScreenState createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _bioController = TextEditingController();
//   final _skillsController = TextEditingController();
//   final _experienceController = TextEditingController();
//   final _educationController = TextEditingController();
//   bool _saving = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentProfile();
//   }

//   Future<void> _loadCurrentProfile() async {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final doc =
//         await FirebaseFirestore.instance.collection('users').doc(uid).get();
//     final data = doc.data();
//     if (data != null) {
//       _bioController.text = data['bio'] as String? ?? '';
//       _skillsController.text =
//           (data['skills'] as List<dynamic>?)?.join(', ') ?? '';
//       _experienceController.text =
//           (data['experience'] as List<dynamic>?)?.join(', ') ?? '';
//       _educationController.text =
//           (data['education'] as List<dynamic>?)?.join(', ') ?? '';
//     }
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _saving = true);
//     try {
//       final uid = FirebaseAuth.instance.currentUser!.uid;
//       final skills =
//           _skillsController.text
//               .split(',')
//               .map((s) => s.trim())
//               .where((s) => s.isNotEmpty)
//               .toList();
//       final experience =
//           _experienceController.text
//               .split(',')
//               .map((s) => s.trim())
//               .where((s) => s.isNotEmpty)
//               .toList();
//       final education =
//           _educationController.text
//               .split(',')
//               .map((s) => s.trim())
//               .where((s) => s.isNotEmpty)
//               .toList();

//       await FirebaseFirestore.instance.collection('users').doc(uid).update({
//         'bio': _bioController.text.trim(),
//         'skills': skills,
//         'experience': experience,
//         'education': education,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully')),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       setState(() => _saving = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
//     }
//   }

//   @override
//   void dispose() {
//     _bioController.dispose();
//     _skillsController.dispose();
//     _experienceController.dispose();
//     _educationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Profile')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 controller: _bioController,
//                 decoration: const InputDecoration(
//                   labelText: 'Bio',
//                   alignLabelWithHint: true,
//                 ),
//                 maxLines: 4,
//                 validator: (v) => null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _skillsController,
//                 decoration: const InputDecoration(
//                   labelText: 'Skills (comma-separated)',
//                 ),
//                 validator: (v) => null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _experienceController,
//                 decoration: const InputDecoration(
//                   labelText: 'Experience (comma-separated)',
//                 ),
//                 validator: (v) => null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _educationController,
//                 decoration: const InputDecoration(
//                   labelText: 'Education (comma-separated)',
//                 ),
//                 validator: (v) => null,
//               ),
//               const SizedBox(height: 24),
//               _saving
//                   ? Center(child: CircularProgressIndicator())
//                   : ElevatedButton(
//                     onPressed: _saveProfile,
//                     child: const Text('Save Profile'),
//                   ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      _bioController.text = data['bio'] as String? ?? '';

      // Handle skills field (could be List, String, or other)
      final skillsRaw = data['skills'];
      if (skillsRaw is List) {
        _skillsController.text = skillsRaw.join(', ');
      } else if (skillsRaw is String) {
        _skillsController.text = skillsRaw;
      } else {
        _skillsController.text = '';
      }

      // Handle experience field
      final expRaw = data['experience'];
      if (expRaw is List) {
        _experienceController.text = expRaw.join(', ');
      } else if (expRaw is String) {
        _experienceController.text = expRaw;
      } else if (expRaw is int || expRaw is double) {
        _experienceController.text = expRaw.toString();
      } else {
        _experienceController.text = '';
      }

      // Handle education field
      final eduRaw = data['education'];
      if (eduRaw is List) {
        _educationController.text = eduRaw.join(', ');
      } else if (eduRaw is String) {
        _educationController.text = eduRaw;
      } else {
        _educationController.text = '';
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final skills =
          _skillsController.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
      final experience =
          _experienceController.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
      final education =
          _educationController.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'bio': _bioController.text.trim(),
        'skills': skills,
        'experience': experience,
        'education': education,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) => null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Skills (comma-separated)',
                ),
                validator: (v) => null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: 'Experience (comma-separated)',
                ),
                validator: (v) => null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _educationController,
                decoration: const InputDecoration(
                  labelText: 'Education (comma-separated)',
                ),
                validator: (v) => null,
              ),
              const SizedBox(height: 24),
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
