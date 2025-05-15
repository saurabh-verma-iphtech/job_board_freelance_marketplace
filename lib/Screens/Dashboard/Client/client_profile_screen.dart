// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:job_board_freelance_marketplace/Services/theme_notifier.dart';

// class ClientProfileScreen extends ConsumerStatefulWidget {
//   const ClientProfileScreen({super.key});

//   @override
//   ConsumerState<ClientProfileScreen> createState() =>
//       _ClientProfileScreenState();
// }

// class _ClientProfileScreenState extends ConsumerState<ClientProfileScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _opacityAnimation;
//   late Animation<Offset> _slideAnimation;

//   final _formKey = GlobalKey<FormState>();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final User? user = FirebaseAuth.instance.currentUser;

//   // Controllers
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//   late TextEditingController _phoneController;
//   late TextEditingController _addressController;
//   late TextEditingController _companyController;
//   late TextEditingController _websiteController;
//   late TextEditingController _linkedinController;
//   late TextEditingController _twitterController;

//   bool _isEditing = false;
//   bool _isLoading = true;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _loadUserData();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     _opacityAnimation = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

//     _controller.forward();
//   }

//   void _initializeControllers() {
//     _companyController = TextEditingController();
//     _websiteController = TextEditingController();
//     _linkedinController = TextEditingController();
//     _twitterController = TextEditingController();
//     _nameController = TextEditingController();
//     _emailController = TextEditingController();
//     _phoneController = TextEditingController();
//     _addressController = TextEditingController();
//   }

//   Future<void> _loadUserData() async {
//     if (user == null) return;

//     final doc = await _firestore.collection('users').doc(user!.uid).get();
//     if (doc.exists) {
//       final data = doc.data()!;
//       setState(() {
//         _nameController.text = data['name'] ?? '';
//         _emailController.text = data['email'] ?? '';
//         _phoneController.text = data['phone'] ?? '';
//         _addressController.text = data['address'] ?? '';
//         _companyController.text = data['company'] ?? '';
//         _websiteController.text = data['website'] ?? '';
//         _linkedinController.text = data['linkedin'] ?? '';
//         _twitterController.text = data['twitter'] ?? '';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isSaving = true);

//     try {
//       await _firestore.collection('users').doc(user!.uid).update({
//         'name': _nameController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'address': _addressController.text.trim(),
//         'company': _companyController.text.trim(),
//         'website': _websiteController.text.trim(),
//         'linkedin': _linkedinController.text.trim(),
//         'twitter': _twitterController.text.trim(),
//         'profileCompleted': true,
//       });

//       setState(() => _isEditing = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving profile: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => _isSaving = false);
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _companyController.dispose();
//     _websiteController.dispose();
//     _linkedinController.dispose();
//     _twitterController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final themeNotifier = ref.watch(themeNotifierProvider);
//     final isDark = themeNotifier.mode == ThemeMode.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: theme.scaffoldBackgroundColor,
//         elevation: 0,
//         actions: [
//           if (_isEditing)
//             IconButton(
//               icon:
//                   _isSaving
//                       ? CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation(
//                           theme.colorScheme.onPrimary,
//                         ),
//                       )
//                       : const Icon(Icons.save, color: Colors.orange),
//               onPressed: _isSaving ? null : _saveProfile,
//             )
//           else
//             IconButton(
//               icon: const Icon(Icons.edit, color: Colors.orange),
//               onPressed: () => setState(() => _isEditing = true),
//             ),
//         ],
//       ),
//       body:
//           _isLoading
//               ? Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
//                 ),
//               )
//               : Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       theme.colorScheme.primary.withOpacity(0.1),
//                       theme.colorScheme.background,
//                     ],
//                   ),
//                 ),
//                 child: FadeTransition(
//                   opacity: _opacityAnimation,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.all(16),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           children: [
//                             _buildProfileHeader(theme),
//                             const SizedBox(height: 24),
//                             _buildCompanySection(theme),
//                             const SizedBox(height: 24),
//                             _buildContactSection(theme),
//                             const SizedBox(height: 24),
//                             _buildSocialSection(theme),
//                             const SizedBox(height: 24),
//                             _buildActionButtons(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//     );
//   }

//   Widget _buildProfileHeader(ThemeData theme) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 40,
//               backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//               child: const Icon(Icons.business, size: 40),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _companyController.text.isNotEmpty
//                         ? _companyController.text
//                         : 'Company Name',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _nameController.text,
//                     style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCompanySection(ThemeData theme) {
//     return _buildSection(
//       title: 'Company Information',
//       icon: Icons.business,
//       children: [
//         _buildEditableField(
//           label: 'Company Name',
//           controller: _companyController,
//           icon: Icons.business_center,
//         ),
//         _buildEditableField(
//           label: 'Website',
//           controller: _websiteController,
//           icon: Icons.public,
//           keyboardType: TextInputType.url,
//           validator: (v) => _validateUrl(v),
//         ),
//         _buildEditableField(
//           label: 'Address',
//           controller: _addressController,
//           icon: Icons.location_on,
//           maxLines: 2,
//           validator: (v) => v!.isEmpty ? 'Required' : null,
//         ),
//       ],
//     );
//   }

//   Widget _buildContactSection(ThemeData theme) {
//     return _buildSection(
//       title: 'Contact Information',
//       icon: Icons.contact_mail,
//       children: [
//         _buildEditableField(
//           label: 'Name',
//           controller: _nameController,
//           icon: Icons.person,
//           validator: (v) => v!.isEmpty ? 'Required' : null,
//         ),
//         _buildEditableField(
//           label: 'Email',
//           controller: _emailController,
//           icon: Icons.email,
//           isEditable: false,
//         ),
//         _buildEditableField(
//           label: 'Phone',
//           controller: _phoneController,
//           icon: Icons.phone,
//           keyboardType: TextInputType.phone,
//           validator: (v) => v!.length < 10 ? 'Invalid number' : null,
//         ),
//       ],
//     );
//   }

//   Widget _buildSocialSection(ThemeData theme) {
//     return _buildSection(
//       title: 'Social Media',
//       icon: Icons.link,
//       children: [
//         _buildEditableField(
//           label: 'LinkedIn',
//           controller: _linkedinController,
//           icon: Icons.link,
//           keyboardType: TextInputType.url,
//           validator: (v) => _validateSocialUrl(v, 'linkedin.com'),
//         ),
//         _buildEditableField(
//           label: 'Twitter/X',
//           controller: _twitterController,
//           icon: Icons.link,
//           keyboardType: TextInputType.url,
//           validator: (v) => _validateSocialUrl(v, 'twitter.com'),
//         ),
//       ],
//     );
//   }

//   Widget _buildSection({
//     required String title,
//     required IconData icon,
//     required List<Widget> children,
//   }) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, ),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEditableField({
//     required String label,
//     required TextEditingController controller,
//     required IconData icon,
//     bool isEditable = true,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//     int maxLines = 1,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon, color: Colors.blue),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.grey.withOpacity(0.1),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//         ),
//         keyboardType: keyboardType,
//         maxLines: maxLines,
//         enabled: _isEditing && isEditable,
//         readOnly: !_isEditing || !isEditable,
//         validator: validator,
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         if (_isEditing)
//           ElevatedButton(
//             onPressed: _saveProfile,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child:
//                 _isSaving
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                       'Save Changes',
//                       style: TextStyle(color: Colors.white),
//                     ),
//           ),
//         const SizedBox(height: 16),
//         TextButton.icon(
//           icon: const Icon(Icons.logout),
//           label: const Text('Sign Out'),
//           onPressed: () async {
//             await FirebaseAuth.instance.signOut();
//             Navigator.pushReplacementNamed(context, '/login');
//           },
//         ),
//       ],
//     );
//   }

//   String? _validateUrl(String? value) {
//     if (value == null || value.isEmpty) return null;
//     final uri = Uri.tryParse(value);
//     if (uri == null || !uri.isAbsolute) return 'Enter a valid URL';
//     return null;
//   }

//   String? _validateSocialUrl(String? value, String domain) {
//     if (value == null || value.isEmpty) return null;
//     if (!value.toLowerCase().contains(domain)) return 'Must be a $domain URL';
//     return null;
//   }
// }



import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board_freelance_marketplace/Services/theme_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions, Supabase;

class ClientProfileScreen extends ConsumerStatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  ConsumerState<ClientProfileScreen> createState() =>
      _ClientProfileScreenState();
}

class _ClientProfileScreenState extends ConsumerState<ClientProfileScreen>
    with SingleTickerProviderStateMixin {

      File? _profileImageFile;
  String? _profileImageUrl;
  bool _isUploadingImage = false;

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  // Controllers
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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Select Image Source'),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text('Gallery'),
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
              ),
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                onPressed: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _profileImageFile = File(pickedFile.path));
        await _uploadImageToSupabase();
      }
    }
  }

  Future<void> _uploadImageToSupabase() async {
    if (_profileImageFile == null || user == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final fileName =
          '${user!.uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(_profileImageFile!.path)}';
      final fileBytes = await _profileImageFile!.readAsBytes();

      await Supabase.instance.client.storage
          .from('images')
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final url = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(fileName);

      await _firestore.collection('users').doc(user!.uid).update({
        'profileImageUrl': url,
      });
      setState(() {
        _profileImageUrl = url;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile picture updated')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    } finally {
      setState(() => _isUploadingImage = false);
    }
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
        _profileImageUrl = data['profileImageUrl'] ?? '';
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
    _controller.dispose();
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
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon:
                  _isSaving
                      ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.onPrimary,
                        ),
                      )
                      : const Icon(Icons.save, color: Colors.orange),
              onPressed: _isSaving ? null : _saveProfile,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                ),
              )
              : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.background,
                    ],
                  ),
                ),
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildProfileHeader(theme),
                            const SizedBox(height: 24),
                            _buildCompanySection(theme),
                            const SizedBox(height: 24),
                            _buildContactSection(theme),
                            const SizedBox(height: 24),
                            _buildSocialSection(theme),
                            const SizedBox(height: 24),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage:
                      _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                  child:
                      _profileImageUrl == null || _profileImageUrl!.isEmpty
                          ? const Icon(Icons.business, size: 40)
                          : null,
                ),
                if (_isUploadingImage)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      backgroundColor: Colors.orange,
                      radius: 14,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _companyController.text.isNotEmpty
                        ? _companyController.text
                        : 'Company Name',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _nameController.text,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanySection(ThemeData theme) {
    return _buildSection(
      title: 'Company Information',
      icon: Icons.business,
      children: [
        _buildEditableField(
          label: 'Company Name',
          controller: _companyController,
          icon: Icons.business_center,
        ),
        _buildEditableField(
          label: 'Website',
          controller: _websiteController,
          icon: Icons.public,
          keyboardType: TextInputType.url,
          validator: (v) => _validateUrl(v),
        ),
        _buildEditableField(
          label: 'Address',
          controller: _addressController,
          icon: Icons.location_on,
          maxLines: 2,
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildContactSection(ThemeData theme) {
    return _buildSection(
      title: 'Contact Information',
      icon: Icons.contact_mail,
      children: [
        _buildEditableField(
          label: 'Name',
          controller: _nameController,
          icon: Icons.person,
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
        _buildEditableField(
          label: 'Email',
          controller: _emailController,
          icon: Icons.email,
          isEditable: false,
        ),
        _buildEditableField(
          label: 'Phone',
          controller: _phoneController,
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (v) => v!.length < 10 ? 'Invalid number' : null,
        ),
      ],
    );
  }

  Widget _buildSocialSection(ThemeData theme) {
    return _buildSection(
      title: 'Social Media',
      icon: Icons.link,
      children: [
        _buildEditableField(
          label: 'LinkedIn',
          controller: _linkedinController,
          icon: Icons.link,
          keyboardType: TextInputType.url,
          validator: (v) => _validateSocialUrl(v, 'linkedin.com'),
        ),
        _buildEditableField(
          label: 'Twitter/X',
          controller: _twitterController,
          icon: Icons.link,
          keyboardType: TextInputType.url,
          validator: (v) => _validateSocialUrl(v, 'twitter.com'),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isEditable = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: _isEditing && isEditable,
        readOnly: !_isEditing || !isEditable,
        validator: validator,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isEditing)
          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child:
                _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    ),
          ),
        const SizedBox(height: 16),
        TextButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.isAbsolute) return 'Enter a valid URL';
    return null;
  }

  String? _validateSocialUrl(String? value, String domain) {
    if (value == null || value.isEmpty) return null;
    if (!value.toLowerCase().contains(domain)) return 'Must be a $domain URL';
    return null;
  }
}
