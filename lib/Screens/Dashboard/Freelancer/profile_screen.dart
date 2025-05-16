// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart' as path;
// import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
// import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

// import 'editProfileScreen.dart';

// class FreelancerProfileScreen extends StatefulWidget {
//   const FreelancerProfileScreen({super.key});

//   @override
//   _FreelancerProfileScreenState createState() =>
//       _FreelancerProfileScreenState();
// }

// class _FreelancerProfileScreenState extends State<FreelancerProfileScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _opacityAnimation;
//   late Animation<Offset> _slideAnimation;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final firebase_auth.User? user =
//       firebase_auth.FirebaseAuth.instance.currentUser;

//   bool _isUploadingImage = false;
//   File? _profileImageFile;
//   String? _profileImageUrl;

//   @override
//   void initState() {
//     super.initState();
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

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final source = await showDialog<ImageSource>(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: const Text('Select Image Source'),
//             actions: [
//               TextButton.icon(
//                 icon: const Icon(Icons.photo),
//                 label: const Text('Gallery'),
//                 onPressed: () => Navigator.pop(context, ImageSource.gallery),
//               ),
//               TextButton.icon(
//                 icon: const Icon(Icons.camera_alt),
//                 label: const Text('Camera'),
//                 onPressed: () => Navigator.pop(context, ImageSource.camera),
//               ),
//             ],
//           ),
//     );

//     if (source != null) {
//       final pickedFile = await picker.pickImage(source: source);
//       if (pickedFile != null) {
//         setState(() => _profileImageFile = File(pickedFile.path));
//         await _uploadImageToSupabase();
//       }
//     }
//   }

//   Future<void> _uploadImageToSupabase() async {
//     if (_profileImageFile == null || user == null) return;

//     setState(() => _isUploadingImage = true);

//     try {
//       final ext = path.extension(_profileImageFile!.path).replaceFirst('.', '');
//       final fileName =
//           'profile_${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.$ext';

//       // Upload to Supabase with upsert
//       await Supabase.instance.client.storage
//           .from('images')
//           .upload(
//             fileName,
//             _profileImageFile!,
//             fileOptions: supabase.FileOptions(
//               contentType: _getMimeType(ext),
//               upsert: true, // Add upsert option
//             ),
//           );

//       // Retrieve public URL
//       final publicUrl = Supabase.instance.client.storage
//           .from('images')
//           .getPublicUrl(fileName);

//       // Update Firestore
//       await _firestore.collection('users').doc(user!.uid).update({
//         'photoUrl': publicUrl,
//       });

//       setState(() => _profileImageUrl = publicUrl);
//     } catch (e) {
//       debugPrint('Supabase upload error: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Could not upload image: $e')));
//     } finally {
//       setState(() => _isUploadingImage = false);
//     }
//   }

//   String _getMimeType(String extension) {
//     switch (extension) {
//       case 'jpg':
//       case 'jpeg':
//         return 'image/jpeg';
//       case 'png':
//         return 'image/png';
//       default:
//         return 'image/*';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userId = firebase_auth.FirebaseAuth.instance.currentUser!.uid;
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Profile'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit, color: Colors.orange),
//             onPressed:
//                 () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const EditProfileScreen()),
//                 ),
//           ),
//         ],
//       ),
//       body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//         stream:
//             FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(userId)
//                 .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
//               ),
//             );
//           }
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text('User not found'));
//           }

//           final data = snapshot.data!.data()!;
//           final skillsRaw = data['skills'];
//           final expRaw = data['experience'];
//           final eduRaw = data['education'];

//           final skills = <String>[];
//           if (skillsRaw is List) {
//             for (var s in skillsRaw) if (s is String) skills.add(s);
//           }

//           final experience = <dynamic>[];
//           if (expRaw is List) experience.addAll(expRaw);

//           final education = <dynamic>[];
//           if (eduRaw is List) education.addAll(eduRaw);

//           return Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   theme.colorScheme.primary.withOpacity(0.1),
//                   theme.colorScheme.background,
//                 ],
//               ),
//             ),
//             child: FadeTransition(
//               opacity: _opacityAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       _buildProfileHeader(data, theme),
//                       const SizedBox(height: 24),
//                       _buildSection('Bio', Icons.info, [
//                         Text(
//                           data['bio'] ?? 'No bio added',
//                           style: const TextStyle(fontSize: 16, height: 1.4),
//                         ),
//                       ]),
//                       const SizedBox(height: 24),
//                       _buildContactSection(data),
//                       const SizedBox(height: 24),
//                       _buildSection('Skills', Icons.code, [
//                         Wrap(
//                           spacing: 8,
//                           runSpacing: 8,
//                           children:
//                               skills
//                                   .map(
//                                     (s) => Chip(
//                                       backgroundColor: Colors.blue.withOpacity(
//                                         0.1,
//                                       ),
//                                       label: Text(s),
//                                     ),
//                                   )
//                                   .toList(),
//                         ),
//                       ]),
//                       const SizedBox(height: 24),
//                       _buildSection('Experience', Icons.work, [
//                         if (experience.isEmpty)
//                           const Text('No experience added')
//                         else
//                           ...experience.map((exp) {
//                             if (exp is String) {
//                               return Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8,
//                                 ),
//                                 child: Text(
//                                   exp,
//                                   style: const TextStyle(fontSize: 16),
//                                 ),
//                               );
//                             } else {
//                               final start =
//                                   exp['startDate'] is Timestamp
//                                       ? (exp['startDate'] as Timestamp).toDate()
//                                       : null;
//                               final end =
//                                   exp['endDate'] is Timestamp
//                                       ? (exp['endDate'] as Timestamp).toDate()
//                                       : null;
//                               return ListTile(
//                                 leading: const Icon(
//                                   Icons.business_center,
//                                   color: Colors.green,
//                                 ),
//                                 title: Text(exp['position'] ?? 'Unknown'),
//                                 subtitle: Text(
//                                   '${exp['company'] ?? 'Unknown'}\n'
//                                   '${start != null ? DateFormat.yMMM().format(start) : ''}'
//                                   ' - '
//                                   '${end != null ? DateFormat.yMMM().format(end) : 'Present'}',
//                                 ),
//                               );
//                             }
//                           }),
//                       ]),
//                       const SizedBox(height: 24),
//                       _buildSection('Education', Icons.school, [
//                         if (education.isEmpty)
//                           const Text('No education added')
//                         else
//                           ...education.map((edu) {
//                             if (edu is String) {
//                               return Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8,
//                                 ),
//                                 child: Text(
//                                   edu,
//                                   style: const TextStyle(fontSize: 16),
//                                 ),
//                               );
//                             } else {
//                               final start =
//                                   edu['startDate'] is Timestamp
//                                       ? (edu['startDate'] as Timestamp).toDate()
//                                       : null;
//                               final end =
//                                   edu['endDate'] is Timestamp
//                                       ? (edu['endDate'] as Timestamp).toDate()
//                                       : null;
//                               return ListTile(
//                                 leading: const Icon(
//                                   Icons.school,
//                                   color: Colors.purple,
//                                 ),
//                                 title: Text(edu['degree'] ?? 'Unknown'),
//                                 subtitle: Text(
//                                   '${edu['institution'] ?? 'Unknown'}\n'
//                                   '${start != null ? DateFormat.yMMM().format(start) : ''}'
//                                   ' - '
//                                   '${end != null ? DateFormat.yMMM().format(end) : 'Present'}',
//                                 ),
//                               );
//                             }
//                           }),
//                       ]),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildContactSection(Map<String, dynamic> userData) {
//     return _buildSection('Contact Information', Icons.contact_phone, [
//       ListTile(
//         leading: Icon(
//           Icons.phone,
//           // grey out if missing
//           color: userData['phone'] != null ? Colors.blue : Colors.grey,
//         ),
//         title: Text(
//           // use actual or default text
//           userData['phone'] ?? 'Not provided',
//           style: TextStyle(
//             // optional: grey text when missing
//             color: userData['phone'] != null ? Colors.black : Colors.grey,
//           ),
//         ),
//       ),

//        ListTile(
//         leading: Icon(
//           Icons.email,
//           color: userData['email'] != null ? Colors.blue : Colors.grey,
//         ),
//         title: Text(
//           userData['email'] ?? 'Not provided',
//           style: TextStyle(
//             color: userData['email'] != null ? Colors.black : Colors.grey,
//           ),
//         ),
//       ),
//     ]);
//   }

//   Widget _buildProfileHeader(Map<String, dynamic> userData, ThemeData theme) {
//     final photoUrl = userData['photoUrl'] as String?;
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Stack(
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//                   backgroundImage:
//                       photoUrl != null && photoUrl.isNotEmpty
//                           ? NetworkImage(photoUrl)
//                           : const AssetImage('assets/images/avatar.png')
//                               as ImageProvider,
//                 ),
//                 if (_isUploadingImage)
//                   const Positioned.fill(
//                     child: Center(
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     ),
//                   ),
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: GestureDetector(
//                     onTap: _pickImage,
//                     child: CircleAvatar(
//                       radius: 14,
//                       backgroundColor: Colors.orange,
//                       child: const Icon(
//                         Icons.camera_alt,
//                         size: 14,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     userData['name'] ?? 'No name',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     userData['title'] ?? 'Freelancer',
//                     style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                   ),
//                   if (userData['phone'] != null) ...[
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Icon(Icons.phone, size: 16, color: Colors.grey[600]),
//                         const SizedBox(width: 4),
//                         Text(
//                           userData['phone'],
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSection(String title, IconData icon, List<Widget> children) =>
//       Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(icon, color: Colors.blue),
//                   const SizedBox(width: 8),
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               ...children,
//             ],
//           ),
//         ),
//       );
// }

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'package:url_launcher/url_launcher.dart';
import 'editProfileScreen.dart';

class FreelancerProfileScreen extends StatefulWidget {
  const FreelancerProfileScreen({super.key});

  @override
  _FreelancerProfileScreenState createState() =>
      _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.User? user =
      firebase_auth.FirebaseAuth.instance.currentUser;

  bool _isUploadingImage = false;
  File? _profileImageFile;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      final ext = path.extension(_profileImageFile!.path).replaceFirst('.', '');
      final fileName =
          'profile_${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      // Upload to Supabase with upsert
      await Supabase.instance.client.storage
          .from('images')
          .upload(
            fileName,
            _profileImageFile!,
            fileOptions: supabase.FileOptions(
              contentType: _getMimeType(ext),
              upsert: true, // Add upsert option
            ),
          );

      // Retrieve public URL
      final publicUrl = Supabase.instance.client.storage
          .from('images')
          .getPublicUrl(fileName);

      // Update Firestore
      await _firestore.collection('users').doc(user!.uid).update({
        'photoUrl': publicUrl,
      });

      setState(() => _profileImageUrl = publicUrl);
    } catch (e) {
      debugPrint('Supabase upload error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not upload image: $e')));
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'image/*';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = firebase_auth.FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          final data = snapshot.data!.data()!;
          final skillsRaw = data['skills'];
          final expRaw = data['experience'];
          final eduRaw = data['education'];

          final skills = <String>[];
          if (skillsRaw is List) {
            for (var s in skillsRaw) if (s is String) skills.add(s);
          }

          final experience = <dynamic>[];
          if (expRaw is List) experience.addAll(expRaw);

          final education = <dynamic>[];
          if (eduRaw is List) education.addAll(eduRaw);

          return Container(
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
                  child: Column(
                    children: [
                      _buildProfileHeader(data, theme),
                      const SizedBox(height: 24),
                      _buildSection('Bio', Icons.info, [
                        Text(
                          data['bio'] ?? 'No bio added',
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Skills', Icons.code, [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              skills
                                  .map(
                                    (s) => Chip(
                                      backgroundColor: Colors.blue.withOpacity(
                                        0.1,
                                      ),
                                      label: Text(s),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      
                      _buildContactSection(data),
                                            const SizedBox(height: 24),

                      _buildProfessionalDetails(data),
                      const SizedBox(height: 24),
                      
                      _buildCertificationsSection(data),
                      const SizedBox(height: 24),
                      _buildSection('Experience', Icons.work, [
                        if (experience.isEmpty)
                          const Text('No experience added')
                        else
                          ...experience.map((exp) {
                            if (exp is String) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  exp,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            } else {
                              final start =
                                  exp['startDate'] is Timestamp
                                      ? (exp['startDate'] as Timestamp).toDate()
                                      : null;
                              final end =
                                  exp['endDate'] is Timestamp
                                      ? (exp['endDate'] as Timestamp).toDate()
                                      : null;
                              return ListTile(
                                leading: const Icon(
                                  Icons.business_center,
                                  color: Colors.green,
                                ),
                                title: Text(exp['position'] ?? 'Unknown'),
                                subtitle: Text(
                                  '${exp['company'] ?? 'Unknown'}\n'
                                  '${start != null ? DateFormat.yMMM().format(start) : ''}'
                                  ' - '
                                  '${end != null ? DateFormat.yMMM().format(end) : 'Present'}',
                                ),
                              );
                            }
                          }),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Education', Icons.school, [
                        if (education.isEmpty)
                          const Text('No education added')
                        else
                          ...education.map((edu) {
                            if (edu is String) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  edu,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            } else {
                              final start =
                                  edu['startDate'] is Timestamp
                                      ? (edu['startDate'] as Timestamp).toDate()
                                      : null;
                              final end =
                                  edu['endDate'] is Timestamp
                                      ? (edu['endDate'] as Timestamp).toDate()
                                      : null;
                              return ListTile(
                                leading: const Icon(
                                  Icons.school,
                                  color: Colors.purple,
                                ),
                                title: Text(edu['degree'] ?? 'Unknown'),
                                subtitle: Text(
                                  '${edu['institution'] ?? 'Unknown'}\n'
                                  '${start != null ? DateFormat.yMMM().format(start) : ''}'
                                  ' - '
                                  '${end != null ? DateFormat.yMMM().format(end) : 'Present'}',
                                ),
                              );
                            }
                          }),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactSection(Map<String, dynamic> userData) {
    return _buildSection('Contact Information', Icons.contact_phone, [
      ListTile(
        leading: const Icon(Icons.home, color: Colors.blue),
        title: Text(userData['location'] ?? 'Unknown'),
      ),
      ListTile(
        leading: Icon(
          Icons.phone,
          // grey out if missing
          color: userData['phone'] != null ? Colors.blue : Colors.grey,
        ),
        title: Text(
          // use actual or default text
          userData['phone'] ?? 'Not provided',
          style: TextStyle(
            // optional: grey text when missing
            color: userData['phone'] != null ? Colors.black : Colors.grey,
          ),
        ),
      ),

      ListTile(
        leading: Icon(
          Icons.email,
          color: userData['email'] != null ? Colors.blue : Colors.grey,
        ),
        title: Text(
          userData['email'] ?? 'Not provided',
          style: TextStyle(
            color: userData['email'] != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    ]);
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData, ThemeData theme) {
    final photoUrl = userData['photoUrl'] as String?;
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
                      photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : const AssetImage('assets/images/avatar.png')
                              as ImageProvider,
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
                      radius: 14,
                      backgroundColor: Colors.orange,
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
                    userData['name'] ?? 'No name',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['title'] ?? 'Freelancer',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  // Text(
                  //   userData['location'] ?? '',
                  //   style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  // ),
                  const SizedBox(height: 4),

                  // Experience Level – always show, with default text:
                  Row(
                    children: [
                      Icon(Icons.work_outline, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        userData['experienceLevel'] ?? 'Not specified',
                        style: TextStyle(color: Colors.blue[600], fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Hourly Rate – always show, with default text:
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        userData['hourlyRate'] != null
                            ? '\$${userData['hourlyRate']}/hour'
                            : 'Rate not set',
                        style: TextStyle(color: Colors.blue[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalDetails(Map<String, dynamic> userData) {
    return _buildSection('Professional Details', Icons.business_center, [
      if (userData['portfolioUrl'] != null)
        ListTile(
          leading: const Icon(Icons.link, color: Colors.blue),
          title: const Text('Portfolio'),
          subtitle: Text(userData['portfolioUrl']),
          onTap: () => _launchUrl(userData['portfolioUrl']),
        ),
      if (userData['linkedinUrl'] != null)
        ListTile(
          leading: const Icon(Icons.person, color: Colors.blue),
          title: const Text('LinkedIn'),
          subtitle: Text(userData['linkedinUrl']),
          onTap: () => _launchUrl(userData['linkedinUrl']),
        ),
      if (userData['githubUrl'] != null)
        ListTile(
          leading: const Icon(Icons.code, color: Colors.blue),
          title: const Text('GitHub'),
          subtitle: Text(userData['githubUrl']),
          onTap: () => _launchUrl(userData['githubUrl']),
        ),
    ]);
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
    }
  }

  Widget _buildCertificationsSection(Map<String, dynamic> userData) {
    final certifications =
        userData['certifications'] is List
            ? userData['certifications'].cast<String>()
            : <String>[];

    return _buildSection('Certifications', Icons.verified_user, [
      if (certifications.isEmpty)
        const Text('No certifications added')
      else
        Wrap(
          spacing: 8,
          children:
              certifications
                  .map(
                    (cert) => Chip(
                      label: Text(cert),
                      backgroundColor: Colors.green.withOpacity(0.1),
                    ),
                  )
                  .toList(),
        ),
    ]);
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) =>
      Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.blue),
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
