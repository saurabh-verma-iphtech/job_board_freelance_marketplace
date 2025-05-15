import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  late CollectionReference _messagesCollection;
  late Query _messagesQuery;

  // Selection state
  Set<String> _selectedMessageIds = {};
  bool get _selectionMode => _selectedMessageIds.isNotEmpty;

  // Emoji picker state
  bool _showEmojiPicker = false;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _messagesCollection = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');
    _messagesQuery = _messagesCollection.orderBy('timestamp', descending: true);

     _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() => _showEmojiPicker = false);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;
    if (!_formKey.currentState!.validate()) return;
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await HapticFeedback.lightImpact();
    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      await _messagesCollection.add({
        'senderId': currentUser.uid,
        'content': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: \$e'),
          backgroundColor: Colors.red,
        ),
      );
      _messageController.text = message;
    }
  }

  Future<void> _deleteSelectedMessages() async {
    final batch = _firestore.batch();
    for (var msgId in _selectedMessageIds) {
      final msgRef = _messagesCollection.doc(msgId);
      final snapshot = await msgRef.get();
      final data = snapshot.data() as Map<String, dynamic>? ?? {};
      if (data.containsKey('imageUrl')) {
        try {
          await FirebaseStorage.instance
              .refFromURL(data['imageUrl'] as String)
              .delete();
        } catch (_) {}
      }
      batch.delete(msgRef);
    }
    await batch.commit();

    final remaining =
        await _messagesCollection
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
    final last =
        remaining.docs.isNotEmpty
            ? remaining.docs.first.get('content') as String
            : '';
    await _firestore.collection('chats').doc(widget.chatId).update({
      'lastMessage': last,
    });

    setState(() => _selectedMessageIds.clear());
  }

  void _onMessageTap(String msgId) {
    if (_selectionMode) {
      setState(() {
        if (_selectedMessageIds.contains(msgId)) {
          _selectedMessageIds.remove(msgId);
        } else {
          _selectedMessageIds.add(msgId);
        }
      });
    }
  }

  void _onMessageLongPress(String msgId) {
    setState(() => _selectedMessageIds.add(msgId));
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
    // Close keyboard if it's open
    if (_showEmojiPicker) {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title:
            _selectionMode
                ? Text('${_selectedMessageIds.length} selected')
                : Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primary.withOpacity(0.2),
                      child: Text(
                        widget.otherUserName.isNotEmpty
                            ? widget.otherUserName[0].toUpperCase()
                            : '?',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(widget.otherUserName),
                  ],
                ),
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _deleteSelectedMessages,
            ),
        ],
        elevation: 1,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => _showEmojiPicker = false);
        },
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messagesQuery.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: false,
                    itemCount: docs.length,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemBuilder: (context, index) {
                      final reversedIndex = docs.length - 1 - index;
                      final msg = docs[reversedIndex];
                      final id = msg.id;
                      final content = msg.get('content') as String? ?? '';
                      final senderId = msg.get('senderId') as String?;
                      final timestamp = msg.get('timestamp') as Timestamp?;
                      final isMe = senderId == _auth.currentUser?.uid;
                      final selected = _selectedMessageIds.contains(id);
                      return GestureDetector(
                        onLongPress: () => _onMessageLongPress(id),
                        onTap: () => _onMessageTap(id),
                        child: Container(
                          color:
                              selected
                                  ? colorScheme.error.withOpacity(0.2)
                                  : Colors.transparent,
                          child: _buildMessageBubble(
                            content: content,
                            isMe: isMe,
                            timestamp: timestamp,
                            selected: selected,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_showEmojiPicker)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _messageController.text += emoji.emoji;
                  },
                  config: const Config(
                    emojiViewConfig: EmojiViewConfig(
                      columns: 7,
                      emojiSizeMax: 32,
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                    ),
                  ),
                ),
              ),
            _buildMessageInput(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(ColorScheme colorScheme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: _toggleEmojiPicker,
                  ),
                  Expanded(
                    child: TextFormField(
                      focusNode: _focusNode,
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      validator:
                          (v) =>
                              v?.trim().isEmpty ?? true
                                  ? 'Message cannot be empty'
                                  : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send_rounded, color: colorScheme.primary),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required String content,
    required bool isMe,
    required Timestamp? timestamp,
    required bool selected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary.withOpacity(0.2),
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : '?',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    selected
                        ? colorScheme.error.withOpacity(0.2)
                        : isMe
                        ? colorScheme.primary
                        : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    content,
                    style: TextStyle(
                      color:
                          isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (timestamp != null)
                    Text(
                      DateFormat('h:mm a').format(timestamp.toDate()),
                      style: TextStyle(
                        color: (isMe
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface)
                            .withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isMe)
            Icon(Icons.check_circle, color: colorScheme.primary, size: 16),
        ],
      ),
    );
  }
}
