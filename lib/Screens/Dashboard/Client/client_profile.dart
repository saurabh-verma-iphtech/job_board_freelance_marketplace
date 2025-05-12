// lib/screens/client_profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({Key? key}) : super(key: key);

  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _companyName = '', _website = '', _description = '';
  bool _saving = false;

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'companyName': _companyName.trim(),
      'website': _website.trim(),
      'description': _description.trim(),
      'profileCompleted': true,
    });
    setState(() => _saving = false);
    Navigator.pushReplacementNamed(context, '/client-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Client Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Company Name'),
                onChanged: (v) => _companyName = v,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Website'),
                onChanged: (v) => _website = v,
                validator: (v) => v!.contains('.') ? null : 'Enter a valid URL',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (v) => _description = v,
                maxLines: 3,
                validator:
                    (v) => v!.length >= 10 ? null : 'At least 10 characters',
              ),
              const Spacer(),
              _saving
                  ? const CircularProgressIndicator()
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
      ),
    );
  }
}
