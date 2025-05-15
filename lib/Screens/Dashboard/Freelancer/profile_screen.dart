// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:job_board_freelance_marketplace/Screens/Dashboard/Freelancer/editProfileScreen.dart';

// class FreelancerProfileScreen extends StatefulWidget {
//   const FreelancerProfileScreen({Key? key}) : super(key: key);

//   @override
//   _FreelancerProfileScreenState createState() =>
//       _FreelancerProfileScreenState();
// }

// class _FreelancerProfileScreenState extends State<FreelancerProfileScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _opacityAnimation;
//   late Animation<Offset> _slideAnimation;

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

//   @override
//   Widget build(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser!.uid;
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

//           final userData = snapshot.data!.data()!;
//           // Safe extraction of lists which may contain strings or maps
//           final skillsRaw = userData['skills'];
//           final experienceRaw = userData['experience'];
//           final educationRaw = userData['education'];

//           final skills = <String>[];
//           if (skillsRaw is List) {
//             for (var item in skillsRaw) {
//               if (item is String) skills.add(item);
//             }
//           }

//           final experience = <dynamic>[];
//           if (experienceRaw is List) {
//             experience.addAll(experienceRaw);
//           }

//           final education = <dynamic>[];
//           if (educationRaw is List) {
//             education.addAll(educationRaw);
//           }

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
//                       _buildProfileHeader(userData, theme),
//                       const SizedBox(height: 24),
//                       _buildSection('Bio', Icons.info, [
//                         _buildBioContent(userData['bio'] ?? 'No bio added'),
//                       ]),
//                       const SizedBox(height: 24),
//                       _buildSection('Skills', Icons.code, [
//                         _buildSkillsChips(skills),
//                       ]),
//                       const SizedBox(height: 24),
//                       _buildSection('Experience', Icons.work, [
//                         _buildExperienceList(experience),
//                       ]),
//                       const SizedBox(height: 24),
//                       _buildSection('Education', Icons.school, [
//                         _buildEducationList(education),
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

//   Widget _buildProfileHeader(Map<String, dynamic> userData, ThemeData theme) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 40,
//               backgroundImage:
//                   userData['photoUrl'] != null
//                       ? NetworkImage(userData['photoUrl'] as String)
//                       : const AssetImage('assets/default_avatar.png')
//                           as ImageProvider,
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

//   Widget _buildBioContent(String bio) =>
//       Text(bio, style: const TextStyle(fontSize: 16, height: 1.4));

//   Widget _buildSkillsChips(List<String> skills) => Wrap(
//     spacing: 8,
//     runSpacing: 8,
//     children:
//         skills
//             .map(
//               (skill) => Chip(
//                 backgroundColor: Colors.blue.withOpacity(0.1),
//                 label: Text(skill),
//               ),
//             )
//             .toList(),
//   );

//   Widget _buildExperienceList(List<dynamic> experience) {
//     if (experience.isEmpty) {
//       return const Text('No experience added');
//     }
//     return Column(
//       children:
//           experience.map((exp) {
//             if (exp is String) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Text(exp, style: const TextStyle(fontSize: 16)),
//               );
//             } else if (exp is Map<String, dynamic>) {
//               final start =
//                   exp['startDate'] is Timestamp
//                       ? (exp['startDate'] as Timestamp).toDate()
//                       : null;
//               final end =
//                   exp['endDate'] is Timestamp
//                       ? (exp['endDate'] as Timestamp).toDate()
//                       : null;
//               return ListTile(
//                 leading: const Icon(Icons.business_center, color: Colors.green),
//                 title: Text(exp['position'] ?? 'Unknown position'),
//                 subtitle: Text(
//                   '${exp['company'] ?? 'Unknown company'}\n'
//                   '${start != null ? DateFormat.yMMM().format(start) : ''} - '
//                   '${end != null ? DateFormat.yMMM().format(end) : 'Present'}',
//                 ),
//               );
//             } else {
//               return const SizedBox();
//             }
//           }).toList(),
//     );
//   }

//   Widget _buildEducationList(List<dynamic> education) {
//     if (education.isEmpty) {
//       return const Text('No education added');
//     }
//     return Column(
//       children:
//           education.map((edu) {
//             if (edu is String) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 child: Text(edu, style: const TextStyle(fontSize: 16)),
//               );
//             } else if (edu is Map<String, dynamic>) {
//               final start =
//                   edu['startDate'] is Timestamp
//                       ? (edu['startDate'] as Timestamp).toDate()
//                       : null;
//               final end =
//                   edu['endDate'] is Timestamp
//                       ? (edu['endDate'] as Timestamp).toDate()
//                       : null;
//               return ListTile(
//                 leading: const Icon(Icons.school, color: Colors.purple),
//                 title: Text(edu['degree'] ?? 'Unknown degree'),
//                 subtitle: Text(
//                   '${edu['institution'] ?? 'Unknown institution'}\n'
//                   '${start != null ? DateFormat.yMMM().format(start) : ''} - '
//                   '${end != null ? DateFormat.yMMM().format(end) : 'Present'}',
//                 ),
//               );
//             } else {
//               return const SizedBox();
//             }
//           }).toList(),
//     );
//   }
// }



import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'editProfileScreen.dart';

class FreelancerProfileScreen extends StatefulWidget {
  const FreelancerProfileScreen({Key? key}) : super(key: key);

  @override
  _FreelancerProfileScreenState createState() =>
      _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  File? _pickedImage;
  bool _isUploadingImage = false;

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
    final source = await showDialog<ImageSource>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Select Image Source'),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text('Gallery'),
                onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                onPressed: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
    );

    if (source == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() => _pickedImage = File(picked.path));
    await _uploadImageToSupabase();
  }

  Future<void> _uploadImageToSupabase() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null || _pickedImage == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final bytes = await _pickedImage!.readAsBytes();
      final fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}${p.extension(_pickedImage!.path)}';

      // upload as binary to allow upsert
      await supabase.Supabase.instance.client.storage
          .from('profile_pictures')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const supabase.FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      // get the public URL
      final publicUrl = supabase.Supabase.instance.client.storage
          .from('profile_pictures')
          .getPublicUrl(fileName);

      // save into Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'photoUrl': publicUrl},
      );

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
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
