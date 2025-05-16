// // freelancer_profile_screen.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class FreelancerProfileScreen extends StatelessWidget {
//   final String freelancerId;
//   const FreelancerProfileScreen({super.key, required this.freelancerId});

//   @override
//   Widget build(BuildContext context) {
//     // Add validation for freelancerId
//     if (freelancerId.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Error')),
//         body: const Center(child: Text('Invalid freelancer ID')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Freelancer Profile'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future:
//             FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(freelancerId)
//                 .get(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text('Freelancer not found'));
//           }

//           final user = snapshot.data!.data() as Map<String, dynamic>;

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 _buildProfileHeader(user),
//                 const SizedBox(height: 30),
//                 if ((user['bio'] as String?)?.isNotEmpty ?? false) ...[
//                   _buildSectionTitle('About Me'),
//                   _buildBioSection(user),
//                   const SizedBox(height: 25),
//                 ],
//                 if ((user['skills'] as List?)?.isNotEmpty ?? false) ...[
//                   _buildSectionTitle('Skills'),
//                   _buildSkillsSection(user),
//                   const SizedBox(height: 25),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }


//   Widget _buildProfileHeader(Map<String, dynamic> user) {
//     return Column(
//       children: [
//         CircleAvatar(
//           radius: 50,
//           backgroundImage:
//               (user['photoUrl'] as String?)?.isNotEmpty ?? false
//                   ? NetworkImage(user['photoUrl'] as String)
//                   : null,
//           child:
//               (user['photoUrl'] as String?)?.isEmpty ?? true
//                   ? const Icon(Icons.person, size: 50)
//                   : null,
//         ),
//         const SizedBox(height: 20),
//         Text(
//           user['name']?.toString() ?? 'No Name',
//           style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           user['role']?.toString() ?? 'Freelancer',
//           style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Row(
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(width: 10),
//         Container(height: 1, width: 30, color: Colors.blue),
//       ],
//     );
//   }

//   Widget _buildBioSection(Map<String, dynamic> user) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Text(
//           user['bio']?.toString() ?? 'No bio available',
//           style: TextStyle(
//             fontSize: 16,
//             height: 1.5,
//             color: Colors.grey.shade700,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSkillsSection(Map<String, dynamic> user) {
//     final skills = List<String>.from(user['skills'] ?? []);
//     if (skills.isEmpty) {
//       return const Text('No skills listed');
//     }
//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children:
//           skills
//               .map(
//                 (skill) => Chip(
//                   label: Text(skill.toString()),
//                   backgroundColor: Colors.blue.shade50,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               )
//               .toList(),
//     );
//   }

//   Widget _buildExperienceSection(Map<String, dynamic> user) {
//     final experience = user['experience']?.toString() ?? '';

//     if (experience.isEmpty) {
//       return const Text('No experience listed');
//     }

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Text(
//           experience,
//           style: TextStyle(
//             fontSize: 16,
//             height: 1.5,
//             color: Colors.grey.shade700,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEducationSection(Map<String, dynamic> user) {
//     final education = user['education']?.toString() ?? '';

//     if (education.isEmpty) {
//       return const Text('No education listed');
//     }

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Text(
//           education,
//           style: TextStyle(
//             fontSize: 16,
//             height: 1.5,
//             color: Colors.grey.shade700,
//           ),
//         ),
//       ),
//     );
//   }
// }


// freelancer_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FreelancerProfileScreen extends StatelessWidget {
  final String freelancerId;
  const FreelancerProfileScreen({super.key, required this.freelancerId});

  @override
  Widget build(BuildContext context) {
    // Add validation for freelancerId
    if (freelancerId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Invalid freelancer ID')),
      );
    }

    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Freelancer Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('users')
                .doc(freelancerId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Freelancer not found'));
          }

          final user = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 30),
                _buildPersonalInfoSection(user),
                const SizedBox(height: 25),

                // Professional Details
                _buildProfessionalDetailsSection(user),
                const SizedBox(height: 25),

                if ((user['bio'] as String?)?.isNotEmpty ?? false) ...[
                _buildSectionTitle('About Me'),
                _buildBioSection(user),
                  const SizedBox(height: 25),
                ],
                if ((user['skills'] as List?)?.isNotEmpty ?? false) ...[
                  _buildSectionTitle('Skills'),
                  _buildSkillsSection(user),
                  const SizedBox(height: 25),
                ],


                // Experience Section
                if ((user['experience'] is String &&
                        (user['experience'] as String).isNotEmpty) ||
                    (user['experience'] is List &&
                        (user['experience'] as List).isNotEmpty)) ...[
                  _buildSectionTitle('Experience'),
                  _buildExperienceSection(user),
                  const SizedBox(height: 25),
                ],

                // Education Section
                if ((user['education'] is String &&
                        (user['education'] as String).isNotEmpty) ||
                    (user['education'] is List &&
                        (user['education'] as List).isNotEmpty)) ...[
                  _buildSectionTitle('Education'),
                  _buildEducationSection(user),
                  const SizedBox(height: 25),
                ],

                // Certifications
                if ((user['certifications'] as List?)?.isNotEmpty ?? false) ...[
                  _buildSectionTitle('Certifications'),
                  _buildCertificationsSection(user),
                  const SizedBox(height: 25),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:
              (user['photoUrl'] as String?)?.isNotEmpty ?? false
                  ? NetworkImage(user['photoUrl'] as String)
                  : null,
          child:
              (user['photoUrl'] as String?)?.isEmpty ?? true
                  ? const Icon(Icons.person, size: 50)
                  : null,
        ),
        const SizedBox(height: 20),
        Text(
          user['name']?.toString() ?? 'No Name',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          user['role']?.toString() ?? 'Freelancer',
          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 10),
        Container(height: 1, width: 30, color: Colors.blue),
      ],
    );
  }

  Widget _buildBioSection(Map<String, dynamic> user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          user['bio']?.toString() ?? 'No bio available',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsSection(Map<String, dynamic> user) {
    final skills = List<String>.from(user['skills'] ?? []);
    if (skills.isEmpty) {
      return const Text('No skills listed');
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          skills
              .map(
                (skill) => Chip(
                  label: Text(skill.toString()),
                  backgroundColor: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildExperienceSection(Map<String, dynamic> user) {
    final experience = user['experience'];
    String displayText = 'No experience listed';

    if (experience is String && experience.isNotEmpty) {
      displayText = experience;
    } else if (experience is List) {
      displayText = experience.whereType<String>().join('\n• ');
      if (displayText.isNotEmpty) {
        displayText = '• $displayText';
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildEducationSection(Map<String, dynamic> user) {
    final education = user['education'];
    String displayText = 'No education listed';

    if (education is String && education.isNotEmpty) {
      displayText = education;
    } else if (education is List) {
      displayText = education.whereType<String>().join('\n• ');
      if (displayText.isNotEmpty) {
        displayText = '• $displayText';
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

   Widget _buildPersonalInfoSection(Map<String, dynamic> user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(Icons.location_on, 'Location', user['location']),
            _buildInfoRow(
              Icons.work,
              'Experience Level',
              user['experienceLevel'],
            ),
            _buildInfoRow(
              Icons.attach_money,
              'Hourly Rate',
              user['hourlyRate'] != null ? '\$${user['hourlyRate']}/hr' : null,
            ),
            _buildInfoRow(Icons.phone, 'Phone', user['phone']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDetailsSection(Map<String, dynamic> user) {
    // Check if any links exist
    final hasPortfolio = (user['portfolioUrl'] as String?)?.isNotEmpty ?? false;
    final hasGitHub = (user['githubUrl'] as String?)?.isNotEmpty ?? false;
    final hasLinkedIn = (user['linkedinUrl'] as String?)?.isNotEmpty ?? false;

    if (!hasPortfolio && !hasGitHub && !hasLinkedIn) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (hasPortfolio)
              _buildLinkTile(Icons.link, 'Portfolio', user['portfolioUrl']),
            if (hasGitHub)
              _buildLinkTile(Icons.code, 'GitHub', user['githubUrl']),
            if (hasLinkedIn)
              _buildLinkTile(Icons.person, 'LinkedIn', user['linkedinUrl']),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile(IconData icon, String label, String? url) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();

    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      subtitle: Text(url),
      // onTap: () => _launchUrl(url),
    );
  }

  Widget _buildCertificationsSection(Map<String, dynamic> user) {
    final certifications = List<String>.from(user['certifications'] ?? []);
    if (certifications.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          certifications
              .map(
                (cert) => Chip(
                  label: Text(cert),
                  backgroundColor: Colors.green.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
              .toList(),
    );
  }

  
}
