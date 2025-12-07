import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/social_models.dart';
import '../../services/chat_service.dart';
import '../../providers/social_provider.dart';
import '../../utils/logger.dart';
import '../chat/chat_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final ChatService _chatService = ChatService();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socialProvider = Provider.of<SocialProvider>(
        context,
        listen: false,
      );
      logger.d('Loading user groups...');
      socialProvider.loadUserGroups();
    });
  }

  Future<void> _showCreateGroupDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final budgetController = TextEditingController();

    await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Group'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'e.g., Roommates, Trip to Paris',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'What is this group for?',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: budgetController,
                    decoration: const InputDecoration(
                      labelText: 'Group Budget (Optional)',
                      hintText: '0.00',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a group name'),
                      ),
                    );
                    return;
                  }

                  final budget = double.tryParse(budgetController.text) ?? 0.0;

                  final socialProvider = Provider.of<SocialProvider>(
                    context,
                    listen: false,
                  );
                  final group = await socialProvider.createGroup(
                    name: nameController.text.trim(),
                    description:
                        descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                    groupBudget: budget,
                  );

                  if (group != null) {
                    Navigator.pop(context, true);
                    _showInviteCodeDialog(group);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to create group')),
                    );
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  Future<void> _showJoinGroupDialog() async {
    final codeController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Join Group'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter the invite code to join a group:'),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Invite Code',
                    hintText: 'e.g., ABC12345',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final code = codeController.text.trim().toUpperCase();
                  if (code.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter an invite code'),
                      ),
                    );
                    return;
                  }

                  final socialProvider = Provider.of<SocialProvider>(
                    context,
                    listen: false,
                  );
                  final success = await socialProvider.joinGroupByCode(code);
                  Navigator.pop(context);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully joined group!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid invite code or group not found'),
                      ),
                    );
                  }
                },
                child: const Text('Join'),
              ),
            ],
          ),
    );
  }

  void _showInviteCodeDialog(ExpenseGroup group) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Group Created!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your group "${group.name}" has been created.'),
                const SizedBox(height: 16),
                const Text('Share this invite code with others:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        group.inviteCode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: group.inviteCode),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invite code copied!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        final groups = socialProvider.userGroups;
        final isLoading = socialProvider.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Groups'),
            actions: [
              PopupMenuButton(
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'create',
                        child: Row(
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 8),
                            Text('Create Group'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'join',
                        child: Row(
                          children: [
                            Icon(Icons.login),
                            SizedBox(width: 8),
                            Text('Join Group'),
                          ],
                        ),
                      ),
                    ],
                onSelected: (value) {
                  switch (value) {
                    case 'create':
                      _showCreateGroupDialog();
                      break;
                    case 'join':
                      _showJoinGroupDialog();
                      break;
                  }
                },
              ),
            ],
          ),
          body:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : groups.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                    onRefresh: () => socialProvider.loadUserGroups(),
                    child: ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return _buildGroupTile(group);
                      },
                    ),
                  ),
          floatingActionButton: FloatingActionButton(
            heroTag: "groups_create_fab",
            onPressed: _showCreateGroupDialog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No groups yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a group or join one with an invite code',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _showCreateGroupDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Group'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _showJoinGroupDialog,
                icon: const Icon(Icons.login),
                label: const Text('Join Group'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(ExpenseGroup group) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            group.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(group.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.description != null)
              Text(
                group.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Budget: \$${group.groupBudget.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Text(
                  'Code: ${group.inviteCode}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'expenses',
                  child: Row(
                    children: [
                      Icon(Icons.receipt),
                      SizedBox(width: 8),
                      Text('Group Expenses'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'chat',
                  child: Row(
                    children: [
                      Icon(Icons.chat),
                      SizedBox(width: 8),
                      Text('Group Chat'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'invite',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share Invite Code'),
                    ],
                  ),
                ),
              ],
          onSelected: (value) {
            switch (value) {
              case 'view':
                _showGroupDetails(group);
                break;
              case 'expenses':
                // Navigate to group expenses
                break;
              case 'chat':
                _openGroupChat(group);
                break;
              case 'invite':
                _shareInviteCode(group);
                break;
            }
          },
        ),
        onTap: () => _showGroupDetails(group),
      ),
    );
  }

  void _showGroupDetails(ExpenseGroup group) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(group.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (group.description != null) ...[
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(group.description!),
                  const SizedBox(height: 12),
                ],
                const Text(
                  'Group Budget:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('\$${group.groupBudget.toStringAsFixed(2)}'),
                const SizedBox(height: 12),
                const Text(
                  'Invite Code:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      group.inviteCode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: group.inviteCode),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invite code copied!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Created:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_formatDate(group.createdAt)),
                if (group.creator != null) ...[
                  const SizedBox(height: 8),
                  Text('By: ${group.creator!.displayName}'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to group expenses or chat
                },
                child: const Text('View Expenses'),
              ),
            ],
          ),
    );
  }

  void _shareInviteCode(ExpenseGroup group) {
    Clipboard.setData(ClipboardData(text: group.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite code "${group.inviteCode}" copied to clipboard!'),
        action: SnackBarAction(
          label: 'Share',
          onPressed: () {
            // Could integrate with share plugin here
          },
        ),
      ),
    );
  }

  Future<void> _openGroupChat(ExpenseGroup group) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Create or get group chat room
      final chatRoom = await _chatService.createGroupChat(group.id, group.name);

      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      if (chatRoom != null) {
        // Navigate to chat screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chatRoom: chatRoom),
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open group chat. Please try again.'),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);

      logger.e('Error opening group chat', error: e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening chat: $e')));
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
