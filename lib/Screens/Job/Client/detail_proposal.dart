
// // lib/screens/proposal_detail_screen.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ProposalDetailScreen extends StatelessWidget {
//   final String proposalId;
//   const ProposalDetailScreen({Key? key, required this.proposalId})
//     : super(key: key);

//   Future<Map<String, dynamic>> _loadProposalData() async {
//     final db = FirebaseFirestore.instance;

//     // 1️ Load the proposal
//     final propSnap = await db.collection('proposals').doc(proposalId).get();
//     if (!propSnap.exists) throw Exception('Proposal not found');
//     final proposal = propSnap.data()!;

//     // 2️ Load the job
//     final jobSnap = await db.collection('jobs').doc(proposal['jobId']).get();
//     if (!jobSnap.exists) throw Exception('Job not found');
//     final job = jobSnap.data()!;

//     // 3️ Load the client (use `createdBy` from the job doc)
//     final clientSnap = await db.collection('users').doc(job['createdBy']).get();
//     if (!clientSnap.exists) throw Exception('Client not found');
//     final client = clientSnap.data()!;

//     // 4️ Load the freelancer
//     final freelancerSnap =
//         await db.collection('users').doc(proposal['freelancerId']).get();
//     if (!freelancerSnap.exists) throw Exception('Freelancer not found');
//     final freelancer = freelancerSnap.data()!;

//     return {
//       'proposal': proposal,
//       'job': job,
//       'client': client,
//       'freelancer': freelancer,
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUid = FirebaseAuth.instance.currentUser!.uid;
//     final propRef = FirebaseFirestore.instance
//         .collection('proposals')
//         .doc(proposalId);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Proposal Details')),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _loadProposalData(),
//         builder: (ctx, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snap.hasError || !snap.hasData) {
//             return Center(child: Text('Error: ${snap.error}'));
//           }

//           final proposal = snap.data!['proposal'] as Map<String, dynamic>;
//           final job = snap.data!['job'] as Map<String, dynamic>;
//           final client = snap.data!['client'] as Map<String, dynamic>;
//           final freelancer = snap.data!['freelancer'] as Map<String, dynamic>;
//           final isClient = currentUid == job['createdBy'];

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Job Info
//                 Text(
//                   job['title'] ?? 'Untitled Job',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(job['description'] ?? ''),

//                 const Divider(height: 32),

//                 // Freelancer Info
//                 Text(
//                   'Freelancer: ${freelancer['name']}',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text('Contact: ${freelancer['email']}'),

//                 const SizedBox(height: 16),

//                 // Client Info
//                 Text(
//                   'Client: ${client['name']}',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text('Contact: ${client['email']}'),

//                 const Divider(height: 32),

//                 // Proposal Info
//                 Text('Bid: \$${proposal['bid']}'),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Cover Letter:',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(proposal['message'] ?? ''),

//                 const Divider(height: 32),

//                 // Status
//                 Text(
//                   'Status: ${proposal['status'].toString().toUpperCase()}',
//                   style: TextStyle(
//                     color:
//                         proposal['status'] == 'accepted'
//                             ? Colors.green
//                             : proposal['status'] == 'rejected'
//                             ? Colors.red
//                             : null,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 SizedBox(height: 20,),

//                 // Accept / Reject (clients only, once)
//                 if (isClient && proposal['status'] == 'pending')
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           child: const Text('Accept'),
//                           onPressed: () async {
//                             // 1. Update proposal status
//                             await propRef.update({'status': 'accepted'});
//                             // 2. Create contract
//                             await FirebaseFirestore.instance
//                                 .collection('contracts')
//                                 .add({
//                                   'jobId': proposal['jobId'],
//                                   'clientId': job['createdBy'],
//                                   'freelancerId': proposal['freelancerId'],
//                                   'agreedBid': proposal['bid'],
//                                   'status': 'ongoing',
//                                   'startedAt': FieldValue.serverTimestamp(),
//                                 });
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: OutlinedButton(
//                           child: const Text('Reject'),
//                           onPressed: () async {
//                             await propRef.update({'status': 'rejected'});
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';

class ProposalDetailScreen extends StatelessWidget {
  final String proposalId;
  const ProposalDetailScreen({Key? key, required this.proposalId})
    : super(key: key);

  // Data loading method remains the same...

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);
    final propRef = FirebaseFirestore.instance
        .collection('proposals')
        .doc(proposalId);
        
  Future<Map<String, dynamic>> _loadProposalData() async {
        final db = FirebaseFirestore.instance;

        // 1️ Load the proposal
        final propSnap = await db.collection('proposals').doc(proposalId).get();
        if (!propSnap.exists) throw Exception('Proposal not found');
        final proposal = propSnap.data()!;

        // 2️ Load the job
        final jobSnap = await db.collection('jobs').doc(proposal['jobId']).get();
        if (!jobSnap.exists) throw Exception('Job not found');
        final job = jobSnap.data()!;

        // 3️ Load the client (use `createdBy` from the job doc)
        final clientSnap = await db.collection('users').doc(job['createdBy']).get();
        if (!clientSnap.exists) throw Exception('Client not found');
        final client = clientSnap.data()!;

        // 4️ Load the freelancer
        final freelancerSnap =
            await db.collection('users').doc(proposal['freelancerId']).get();
        if (!freelancerSnap.exists) throw Exception('Freelancer not found');
        final freelancer = freelancerSnap.data()!;

        return {
          'proposal': proposal,
          'job': job,
          'client': client,
          'freelancer': freelancer,
        };
      }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposal Details'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        // iconTheme: IconThemeData(color: theme.colorScheme.primary),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadProposalData(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return ErrorView(error: snap.error.toString());
          }

          final data = snap.data!;
          final proposal = data['proposal'];
          final job = data['job'];
          final client = data['client'];
          final freelancer = data['freelancer'];
          final isClient = currentUid == job['createdBy'];

          return AnimatedDetailContent(
            proposal: proposal,
            job: job,
            client: client,
            freelancer: freelancer,
            isClient: isClient,
            propRef: propRef,
          );
        },
      ),
    );
  }
}

class AnimatedDetailContent extends StatefulWidget {
  final Map<String, dynamic> proposal;
  final Map<String, dynamic> job;
  final Map<String, dynamic> client;
  final Map<String, dynamic> freelancer;
  final bool isClient;
  final DocumentReference propRef;

  const AnimatedDetailContent({
    required this.proposal,
    required this.job,
    required this.client,
    required this.freelancer,
    required this.isClient,
    required this.propRef,
    Key? key,
  }) : super(key: key);

  @override
  _AnimatedDetailContentState createState() => _AnimatedDetailContentState();
}

class _AnimatedDetailContentState extends State<AnimatedDetailContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _controller.forward(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.translate(
              offset: Offset(0, (1 - _opacity.value) * 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildJobCard(),
                  const SizedBox(height: 20),
                  _buildUserSection('Freelancer', widget.freelancer),
                  const SizedBox(height: 20),
                  // _buildUserSection('Client', widget.client),
                  // const SizedBox(height: 20),
                  _buildProposalDetails(),
                  if (widget.isClient && widget.proposal['status'] == 'pending')
                    _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.job['title'] ?? 'Untitled Job',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ReadMoreText(
              widget.job['description'] ?? '',
              trimLines: 3,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(String role, Map<String, dynamic> user) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, size: 30, color: Colors.blue.shade600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user['email'] ?? 'No email provided',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem('Bid Amount', '\$${widget.proposal['bid']}'),
        _buildDetailItem('Cover Letter', widget.proposal['message'] ?? ''),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _getStatusColor(widget.proposal['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _getStatusColor(widget.proposal['status']),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: _getStatusColor(widget.proposal['status']),
              ),
              const SizedBox(width: 12),
              Text(
                'Status: ${widget.proposal['status'].toString().toUpperCase()}',
                style: TextStyle(
                  color: _getStatusColor(widget.proposal['status']),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.4)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Expanded(
            child: AnimatedButton(
              label: 'Accept',
              color: Colors.green,
              icon: Icons.check_circle,
              onPressed: _handleAccept,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedButton(
              label: 'Reject',
              color: Colors.red,
              icon: Icons.cancel,
              onPressed: _handleReject,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAccept() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => ConfirmationDialog(
            title: 'Accept Proposal',
            content: 'Are you sure you want to accept this proposal?',
          ),
    );

    if (confirmed ?? false) {
      await widget.propRef.update({'status': 'accepted'});
      await FirebaseFirestore.instance.collection('contracts').add({
        'jobId': widget.proposal['jobId'],
        'clientId': widget.job['createdBy'],
        'freelancerId': widget.proposal['freelancerId'],
        'agreedBid': widget.proposal['bid'],
        'status': 'ongoing',
        'startedAt': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    }
  }

  void _handleReject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => ConfirmationDialog(
            title: 'Reject Proposal',
            content: 'Are you sure you want to reject this proposal?',
          ),
    );

    if (confirmed ?? false) {
      await widget.propRef.update({'status': 'rejected'});
      Navigator.pop(context);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

// Custom Components
class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({super.key});

  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.1416,
          child: Icon(
            Icons.hourglass_bottom,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}


class AnimatedButton extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const AnimatedButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.95).animate(_controller),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;

  const ConfirmationDialog({
    required this.title,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(content, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String error;

  const ErrorView({required this.error, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class ReadMoreText extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle style;

  const ReadMoreText(
    this.text, {
    required this.trimLines,
    required this.style,
    super.key,
  });

  @override
  _ReadMoreTextState createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: widget.style);
        final tp = TextPainter(
          text: span,
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);

        if (!tp.didExceedMaxLines) {
          return Text(widget.text, style: widget.style);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: widget.style,
              maxLines: _isExpanded ? null : widget.trimLines,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
            ),
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(
                _isExpanded ? 'Read less' : 'Read more',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
