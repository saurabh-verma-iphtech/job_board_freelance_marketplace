import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Dashboard/Freelancer/editProfileScreen.dart';

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

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
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

          final userData = snapshot.data!.data()!;
          // Safe extraction of lists which may contain strings or maps
          final skillsRaw = userData['skills'];
          final experienceRaw = userData['experience'];
          final educationRaw = userData['education'];

          final skills = <String>[];
          if (skillsRaw is List) {
            for (var item in skillsRaw) {
              if (item is String) skills.add(item);
            }
          }

          final experience = <dynamic>[];
          if (experienceRaw is List) {
            experience.addAll(experienceRaw);
          }

          final education = <dynamic>[];
          if (educationRaw is List) {
            education.addAll(educationRaw);
          }

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
                      _buildProfileHeader(userData, theme),
                      const SizedBox(height: 24),
                      _buildSection('Bio', Icons.info, [
                        _buildBioContent(userData['bio'] ?? 'No bio added'),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Skills', Icons.code, [
                        _buildSkillsChips(skills),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Experience', Icons.work, [
                        _buildExperienceList(experience),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Education', Icons.school, [
                        _buildEducationList(education),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  userData['photoUrl'] != null
                      ? NetworkImage(userData['photoUrl'] as String)
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
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

  Widget _buildBioContent(String bio) =>
      Text(bio, style: const TextStyle(fontSize: 16, height: 1.4));

  Widget _buildSkillsChips(List<String> skills) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children:
        skills
            .map(
              (skill) => Chip(
                backgroundColor: Colors.blue.withOpacity(0.1),
                label: Text(skill),
              ),
            )
            .toList(),
  );

  Widget _buildExperienceList(List<dynamic> experience) {
    if (experience.isEmpty) {
      return const Text('No experience added');
    }
    return Column(
      children:
          experience.map((exp) {
            if (exp is String) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(exp, style: const TextStyle(fontSize: 16)),
              );
            } else if (exp is Map<String, dynamic>) {
              final start =
                  exp['startDate'] is Timestamp
                      ? (exp['startDate'] as Timestamp).toDate()
                      : null;
              final end =
                  exp['endDate'] is Timestamp
                      ? (exp['endDate'] as Timestamp).toDate()
                      : null;
              return ListTile(
                leading: const Icon(Icons.business_center, color: Colors.green),
                title: Text(exp['position'] ?? 'Unknown position'),
                subtitle: Text(
                  '${exp['company'] ?? 'Unknown company'}\n'
                  '${start != null ? DateFormat.yMMM().format(start) : ''} - '
                  '${end != null ? DateFormat.yMMM().format(end) : 'Present'}',
                ),
              );
            } else {
              return const SizedBox();
            }
          }).toList(),
    );
  }

  Widget _buildEducationList(List<dynamic> education) {
    if (education.isEmpty) {
      return const Text('No education added');
    }
    return Column(
      children:
          education.map((edu) {
            if (edu is String) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(edu, style: const TextStyle(fontSize: 16)),
              );
            } else if (edu is Map<String, dynamic>) {
              final start =
                  edu['startDate'] is Timestamp
                      ? (edu['startDate'] as Timestamp).toDate()
                      : null;
              final end =
                  edu['endDate'] is Timestamp
                      ? (edu['endDate'] as Timestamp).toDate()
                      : null;
              return ListTile(
                leading: const Icon(Icons.school, color: Colors.purple),
                title: Text(edu['degree'] ?? 'Unknown degree'),
                subtitle: Text(
                  '${edu['institution'] ?? 'Unknown institution'}\n'
                  '${start != null ? DateFormat.yMMM().format(start) : ''} - '
                  '${end != null ? DateFormat.yMMM().format(end) : 'Present'}',
                ),
              );
            } else {
              return const SizedBox();
            }
          }).toList(),
    );
  }
}
