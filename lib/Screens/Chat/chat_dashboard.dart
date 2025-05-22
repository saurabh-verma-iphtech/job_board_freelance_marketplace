import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:job_board_freelance_marketplace/Screens/Chat/chat_screen.dart';

class ChatDashboard extends StatefulWidget {
  final String userType;

  const ChatDashboard({super.key, required this.userType});

  @override
  _ChatDashboardState createState() => _ChatDashboardState();
}

class _ChatDashboardState extends State<ChatDashboard>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  late Query _chatsQuery;

  @override
  void initState() {
    super.initState();
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );

    _fabController.forward();

    final participantField =
        widget.userType == 'client' ? 'clientId' : 'freelancerId';

    _chatsQuery = _firestore
        .collection('chats')
        .where('participants.$participantField', isEqualTo: uid)
        .orderBy('timestamp', descending: true);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface.withOpacity(0.8),
              colorScheme.surface.withOpacity(0.4),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _chatsQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoader();
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final chatDoc = docs[index];
                final participants =
                    chatDoc.get('participants') as Map<String, dynamic>;
                final otherUserId =
                    widget.userType == 'client'
                        ? participants['freelancerId']
                        : participants['clientId'];

                return _ChatListItem(
                  chatDoc: chatDoc,
                  otherUserId: otherUserId,
                  userType: widget.userType,
                  firestore: _firestore,
                  auth: _auth,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          height: 80,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_rounded,
            size: 96,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new conversation Total Proposals',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatListItem extends StatefulWidget {
  final QueryDocumentSnapshot chatDoc;
  final String? otherUserId;
  final String userType;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  const _ChatListItem({
    required this.chatDoc,
    required this.otherUserId,
    required this.userType,
    required this.firestore,
    required this.auth,
  });

  @override
  __ChatListItemState createState() => __ChatListItemState();
}

class __ChatListItemState extends State<_ChatListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _controller,
        child: FutureBuilder<DocumentSnapshot>(
          future:
              widget.firestore
                  .collection('users')
                  .doc(widget.otherUserId)
                  .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoader();
            }

            // 2) Did we get a document?
            if (!userSnapshot.hasData ||
                !(userSnapshot.data?.exists ?? false)) {
              // You can return a placeholder tile, or simply skip rendering:
              return _buildMissingUserTile();
            }

            // 3) Now it’s safe to read
            final data = userSnapshot.data!.data() as Map<String, dynamic>?;

            final userName = (data?['name'] as String?) ?? 'Unknown User';
            final userImage = (data?['photoUrl'] as String?) ?? '';

            final lastMessage =
            widget.chatDoc.get('lastMessage') as String? ?? '';
            final timestamp = widget.chatDoc.get('timestamp') as Timestamp?;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _navigateToChat(context, userName),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // inside your Row children
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              userImage.isNotEmpty
                                  ? NetworkImage(userImage)
                                  : null,
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          child:
                              userImage.isEmpty
                                  ? Text(
                                    userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    userName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                  if (timestamp != null)
                                    Text(
                                      DateFormat(
                                        'HH:mm',
                                      ).format(timestamp.toDate()),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.6),
                                          ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context, String userName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: ChatScreen(
              chatId: widget.chatDoc.id,
              otherUserId: widget.otherUserId!,
              otherUserName: userName,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMissingUserTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'User not found',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ),
      ),
    );
  }
    Widget _buildShimmerLoader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 10,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }


}
