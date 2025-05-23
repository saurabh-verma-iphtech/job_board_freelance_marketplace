import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

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
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _certificationsController = TextEditingController();
  String? _selectedExperienceLevel;
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
      _phoneController.text = data['phone'] as String? ?? '';
      _locationController.text = data['location'] as String? ?? '';
      _hourlyRateController.text = data['hourlyRate']?.toString() ?? '';
      _portfolioController.text = data['portfolioUrl'] as String? ?? '';
      _linkedinController.text = data['linkedinUrl'] as String? ?? '';
      _githubController.text = data['githubUrl'] as String? ?? '';
      _certificationsController.text = data['certifications']?.join(', ') ?? '';
      _selectedExperienceLevel = data['experienceLevel'] as String?;

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
        'phone': _phoneController.text.trim(),
        'skills': skills,
        'experience': experience,
        'education': education,
        'location': _locationController.text.trim(),
        'experienceLevel': _selectedExperienceLevel,
        'hourlyRate': double.tryParse(_hourlyRateController.text),
        'portfolioUrl': _portfolioController.text.trim(),
        'linkedinUrl': _linkedinController.text.trim(),
        'githubUrl': _githubController.text.trim(),
        'certifications':
            _certificationsController.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorScheme.primary, colorScheme.surface],
            ),
          ),
        ),
        title: const Text('Edit Profile'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
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
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    hintText: 'Enter 10-digit phone number',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                        return 'Enter valid 10-digit number';
                      }
                    }
                    return null;
                  },
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  // validator: (v) => v!.isEmpty ? 'Location is required' : null,
                  validator: (v) => null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedExperienceLevel,
                  decoration: const InputDecoration(
                    labelText: 'Experience Level',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                    DropdownMenuItem(
                      value: 'Intermediate',
                      child: Text('Intermediate'),
                    ),
                    DropdownMenuItem(value: 'Expert', child: Text('Expert')),
                  ],
                  onChanged:
                      (value) => setState(() => _selectedExperienceLevel = value),
                  // validator: (v) => v == null ? 'Select experience level' : null,
                  validator: (v) => null,
                ),
        
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hourlyRateController,
                  decoration: const InputDecoration(
                    labelText: 'Hourly Rate (\$)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // validator: (v) => v!.isEmpty ? 'Enter hourly rate' : null,
                  validator: (v) => null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _portfolioController,
                  decoration: const InputDecoration(
                    labelText: 'Portfolio Website',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  validator: _validateUrl,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _linkedinController,
                  decoration: const InputDecoration(
                    labelText: 'LinkedIn Profile URL',
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.url,
                  validator: _validateUrl,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _githubController,
                  decoration: const InputDecoration(
                    labelText: 'GitHub Profile URL',
                    prefixIcon: Icon(Icons.code),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _certificationsController,
                  decoration: const InputDecoration(
                    labelText: 'Certifications (comma-separated)',
                    prefixIcon: Icon(Icons.verified_user),
                  ),
                  maxLines: 2,
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
      ),
    );
  }
}

String? _validateUrl(String? value) {
  if (value == null || value.isEmpty) return null;
  final urlRegExp = RegExp(
    r'^(http|https):\/\/[\w\-]+(\.[\w\-]+)+([\w\-.,@?^=%&:/~+#]*[\w\-@?^=%&/~+#])?$',
  );
  return urlRegExp.hasMatch(value) ? null : 'Enter valid URL';
}
