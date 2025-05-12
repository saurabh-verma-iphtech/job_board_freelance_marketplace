import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board_freelance_marketplace/Services/theme_notifier.dart';

class ClientProfileScreen extends ConsumerStatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  ConsumerState<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends ConsumerState<ClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _companyController;
  late TextEditingController _websiteController;
  late TextEditingController _linkedinController;
  late TextEditingController _twitterController;

  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _companyController = TextEditingController();
    _websiteController = TextEditingController();
    _linkedinController = TextEditingController();
    _twitterController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _companyController.text = data['company'] ?? '';
        _websiteController.text = data['website'] ?? '';
        _linkedinController.text = data['linkedin'] ?? '';
        _twitterController.text = data['twitter'] ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await _firestore.collection('users').doc(user!.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'company': _companyController.text.trim(),
        'website': _websiteController.text.trim(),
        'linkedin': _linkedinController.text.trim(),
        'twitter': _twitterController.text.trim(),
        'profileCompleted': true,
      });

      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _companyController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = ref.watch(themeNotifierProvider);
    final isDark = themeNotifier.mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            IconButton(
              icon:
                  _isSaving
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        isDark
                            ? [
                              Colors.deepPurple.shade900,
                              Colors.indigo.shade900,
                            ]
                            : [Colors.blue.shade50, Colors.purple.shade50],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            _buildProfileField(
                              icon: Icons.person,
                              label: 'Name',
                              controller: _nameController,
                              isEditable: _isEditing,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            _buildProfileField(
                              icon: Icons.email,
                              label: 'Email',
                              controller: _emailController,
                              isEditable: false,
                            ),
                            _buildSectionHeader('Company Information'),
                            _buildProfileField(
                              icon: Icons.business,
                              label: 'Company Name',
                              controller: _companyController,
                              isEditable: _isEditing,
                            ),
                            _buildProfileField(
                              icon: Icons.public,
                              label: 'Website',
                              controller: _websiteController,
                              isEditable: _isEditing,
                              keyboardType: TextInputType.url,
                              validator: (v) => _validateUrl(v),
                            ),

                            // Social Media Section
                            _buildSectionHeader('Social Media'),
                            _buildProfileField(
                              icon: Icons.link,
                              label: 'LinkedIn Profile',
                              controller: _linkedinController,
                              isEditable: _isEditing,
                              keyboardType: TextInputType.url,
                              validator:
                                  (v) => _validateSocialUrl(v, 'linkedin.com'),
                            ),
                            _buildProfileField(
                              icon: Icons.link,
                              label: 'Twitter/X Profile',
                              controller: _twitterController,
                              isEditable: _isEditing,
                              keyboardType: TextInputType.url,
                              validator:
                                  (v) => _validateSocialUrl(v, 'twitter.com'),
                            ),
                            _buildProfileField(
                              icon: Icons.phone,
                              label: 'Phone Number',
                              controller: _phoneController,
                              isEditable: _isEditing,
                              keyboardType: TextInputType.phone,
                              validator:
                                  (v) =>
                                      v!.length < 10 ? 'Invalid number' : null,
                            ),
                            _buildProfileField(
                              icon: Icons.location_on,
                              label: 'Address',
                              controller: _addressController,
                              isEditable: _isEditing,
                              maxLines: 3,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 20),
                            if (_isEditing)
                              ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text('Save Changes'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                                onPressed: _saveProfile,
                              ),
                            const SizedBox(height: 10),
                            TextButton.icon(
                              icon: const Icon(Icons.logout),
                              label: const Text('Sign Out'),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditable,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: !isEditable,
          fillColor: Colors.grey.shade100,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: isEditable,
        readOnly: !isEditable,
        validator: validator,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.isAbsolute) {
      return 'Enter a valid URL';
    }
    return null;
  }

  String? _validateSocialUrl(String? value, String domain) {
    if (value == null || value.isEmpty) return null;
    if (!value.toLowerCase().contains(domain)) {
      return 'Must be a $domain URL';
    }
    return null;
  }
}
