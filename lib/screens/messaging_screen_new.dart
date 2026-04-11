import 'package:flutter/material.dart';
import 'dart:async';
import '../models/models.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';

// ─── Kindergarten theme palette ───────────────────────────────────────────────
class _KGTheme {
  static const Color bg         = Color(0xFFFFF8F0);      // warm cream
  static const Color primary    = Color(0xFFFF7043);      // playful orange
  static const Color primaryDark= Color(0xFFE64A19);
  static const Color accent     = Color(0xFF66BB6A);      // mint green
  static const Color bubbleMe   = Color(0xFFFF8A65);     // sent bubble
  static const Color bubbleThem = Color(0xFFFFFFFF);     // received bubble
  static const Color divider    = Color(0xFFFFCCBC);
  static const Color textDark   = Color(0xFF4E342E);
  static const Color textMuted  = Color(0xFF8D6E63);
}

class MessagingScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String userRole;

  const MessagingScreen({
    required this.userId,
    required this.userName,
    required this.userRole,
  });

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  // Hard-coded admin conversation (ID = 1 for admin user)
  static const int ADMIN_USER_ID = 1;
  static const String ADMIN_NAME = 'Administration';

  List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Auto-refresh every 4 seconds with mounted check
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        _loadMessages();
      }
    });
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoadingMessages = true);

    try {
      final response = await ApiService.getMessages(
        widget.userId,
        widget.userRole,
      );

      if (!mounted) return;

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        final allMessages = data
            .map((msg) => Message.fromJson(msg as Map<String, dynamic>))
            .toList();

        // Filter messages for admin conversation
        final filteredMessages = allMessages.where((msg) {
          // Get messages with admin (sender or receiver)
          return msg.receiverId == ADMIN_USER_ID || msg.senderId == ADMIN_USER_ID;
        }).toList();

        // Sort by timestamp (newest first)
        filteredMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        setState(() {
          _messages = filteredMessages;
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingMessages = false);
      }
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.sendMessage(
        senderId: widget.userId,
        senderRole: widget.userRole,
        receiverId: ADMIN_USER_ID,
        receiverRole: 'admin',
        message: _messageController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        _messageController.clear();
        await _loadMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result['message']}'),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(label: 'Fermer', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'Fermer', onPressed: () {}),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _KGTheme.bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildChatHeader(),
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [BoxShadow(color: Color(0x33FF7043), blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.message_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Support', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Parlez avec l\'administration', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      const Text(
                        'Parent',
                        style: TextStyle(color: Colors.white, fontSize: 12),
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
  }

  Widget _buildChatHeader() {
    const avatarColor = Color(0xFFEF9A9A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _KGTheme.divider, width: 1.5)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(color: avatarColor, shape: BoxShape.circle),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ADMIN_NAME,
                  style: TextStyle(color: _KGTheme.textDark, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 7,
                      height: 7,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: _KGTheme.accent, shape: BoxShape.circle),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text('En ligne', style: TextStyle(color: _KGTheme.accent, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _KGTheme.primary),
            tooltip: 'Actualiser',
            onPressed: _loadMessages,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoadingMessages) {
      return Center(child: CircularProgressIndicator(color: _KGTheme.primary));
    }
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: _KGTheme.textMuted.withOpacity(0.4)),
            const SizedBox(height: 10),
            const Text('Aucun message pour l\'instant', style: TextStyle(color: _KGTheme.textMuted, fontSize: 13)),
          ],
        ),
      );
    }
    return Scrollbar(
      child: ListView.builder(
        reverse: true,
        shrinkWrap: false,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];
          final isFromMe = msg.senderId == widget.userId;
          return _buildMessageBubble(msg, isFromMe);
        },
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, bool isFromMe) {
    Color roleColor;
    String roleLabel;
    IconData roleIcon;

    if (msg.senderRole == 'educateur') {
      roleColor = const Color(0xFFAB47BC);
      roleLabel = 'Éducateur';
      roleIcon = Icons.school_rounded;
    } else if (msg.senderRole == 'admin') {
      roleColor = _KGTheme.primary;
      roleLabel = 'Admin';
      roleIcon = Icons.admin_panel_settings_rounded;
    } else {
      roleColor = _KGTheme.accent;
      roleLabel = 'Parent';
      roleIcon = Icons.person_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Align(
        alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Role badge (received only)
            if (!isFromMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: roleColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(roleIcon, size: 11, color: roleColor),
                      const SizedBox(width: 3),
                      Text(
                        roleLabel,
                        style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            // Bubble
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
              decoration: BoxDecoration(
                color: isFromMe ? _KGTheme.bubbleMe : _KGTheme.bubbleThem,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isFromMe ? 18 : 4),
                  bottomRight: Radius.circular(isFromMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isFromMe ? _KGTheme.primary : Colors.black).withOpacity(0.10),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.message,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isFromMe ? Colors.white : _KGTheme.textDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(msg.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: isFromMe ? Colors.white70 : _KGTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _KGTheme.divider, width: 1.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _KGTheme.bg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _KGTheme.divider, width: 1.5),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 13.5, color: _KGTheme.textDark),
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Écrire un message...',
                  hintStyle: TextStyle(color: _KGTheme.textMuted, fontSize: 13),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: _isLoading ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_KGTheme.primary, Color(0xFFFF8A65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _KGTheme.primary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final msgDay = DateTime(dt.year, dt.month, dt.day);

      if (msgDay == today) {
        return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (msgDay == yesterday) {
        return 'Hier';
      } else {
        return '${dt.day}/${dt.month}';
      }
    } catch (e) {
      return timestamp;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
