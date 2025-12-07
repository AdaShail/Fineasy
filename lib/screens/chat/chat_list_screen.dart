import 'package:flutter/material.dart';
import '../../models/chat_models.dart';
import '../../services/chat_service.dart';
import '../../utils/logger.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();

  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;
  Map<String, int> _unreadCounts = {};

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    setState(() => _isLoading = true);

    try {
      final rooms = await _chatService.getUserChatRooms();

      // Load unread counts for each room
      final Map<String, int> unreadCounts = {};
      for (final room in rooms) {
        try {
          final count = await _chatService.getUnreadCount(room.id);
          unreadCounts[room.id] = count;
        } catch (e) {
          logger.e('Error loading unread count for room ${room.id}', error: e);
          unreadCounts[room.id] = 0;
        }
      }

      if (mounted) {
        setState(() {
          _chatRooms = rooms;
          _unreadCounts = unreadCounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      logger.e('Error loading chat rooms', error: e);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load chats: $e'),
            action: SnackBarAction(label: 'Retry', onPressed: _loadChatRooms),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () {
              // Show dialog to start new chat
              _showNewChatDialog();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _chatRooms.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _loadChatRooms,
                child: ListView.builder(
                  itemCount: _chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = _chatRooms[index];
                    return _buildChatRoomTile(room);
                  },
                ),
              ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No chats yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Start a conversation with your friends or groups',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomTile(ChatRoom room) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            room.avatarUrl != null ? NetworkImage(room.avatarUrl!) : null,
        child:
            room.avatarUrl == null
                ? Text(room.displayName.substring(0, 1).toUpperCase())
                : null,
      ),
      title: Text(room.displayName),
      subtitle:
          room.lastMessage != null
              ? Text(
                room.lastMessage!.displayContent,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
              : Text(
                room.roomType == 'group' ? 'Group chat' : 'Direct message',
                style: TextStyle(color: Colors.grey[600]),
              ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (room.lastMessage != null)
            Text(
              _formatTime(room.lastMessage!.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 4),
          // Unread count badge
          if (_unreadCounts[room.id] != null && _unreadCounts[room.id]! > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _unreadCounts[room.id]!.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        // Navigate to chat screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(chatRoom: room)),
        );
      },
    );
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Start New Chat'),
            content: const Text(
              'Feature coming soon! You can start chats from the Friends screen.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - show time
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Older - show date
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
