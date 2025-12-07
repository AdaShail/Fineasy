import 'package:flutter/material.dart';
import '../../models/whatsapp_template_model.dart';

class WhatsAppMessagesScreen extends StatefulWidget {
  final List<WhatsAppMessageModel> messages;

  const WhatsAppMessagesScreen({super.key, required this.messages});

  @override
  State<WhatsAppMessagesScreen> createState() => _WhatsAppMessagesScreenState();
}

class _WhatsAppMessagesScreenState extends State<WhatsAppMessagesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final filteredMessages = _getFilteredMessages();

    return Column(
      children: [
        // Search and Filter
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Today', 'today'),
                    const SizedBox(width: 8),
                    _buildFilterChip('This Week', 'week'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Invoices', 'invoices'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Reminders', 'reminders'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Messages List
        Expanded(
          child:
              filteredMessages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredMessages.length,
                    itemBuilder: (context, index) {
                      final message = filteredMessages[index];
                      return _buildMessageCard(message);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
      selectedColor: const Color(0xFF25D366).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF25D366),
    );
  }

  Widget _buildMessageCard(WhatsAppMessageModel message) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF25D366),
                  radius: 20,
                  child: Text(
                    message.recipientName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.recipientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        message.recipientPhone,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(message.sentAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getMessageTypeColor(message.messageType),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getMessageTypeLabel(message.messageType),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                message.messageContent,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFF25D366),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Sent',
                  style: TextStyle(
                    color: const Color(0xFF25D366),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _resendMessage(message),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Resend'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _shareMessage(message),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No messages found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Start sending WhatsApp messages to see them here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to send message
              },
              icon: const Icon(Icons.send),
              label: const Text('Send Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<WhatsAppMessageModel> _getFilteredMessages() {
    var filtered =
        widget.messages.where((message) {
          // Search filter
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            if (!message.recipientName.toLowerCase().contains(query) &&
                !message.messageContent.toLowerCase().contains(query) &&
                !message.recipientPhone.contains(query)) {
              return false;
            }
          }

          // Date filter
          final now = DateTime.now();
          switch (_selectedFilter) {
            case 'today':
              return message.sentAt.day == now.day &&
                  message.sentAt.month == now.month &&
                  message.sentAt.year == now.year;
            case 'week':
              final weekAgo = now.subtract(const Duration(days: 7));
              return message.sentAt.isAfter(weekAgo);
            case 'invoices':
              return message.messageContent.toLowerCase().contains('invoice') ||
                  message.messageType == WhatsAppTemplateType.invoiceShare;
            case 'reminders':
              return message.messageContent.toLowerCase().contains(
                    'reminder',
                  ) ||
                  message.messageType == WhatsAppTemplateType.paymentReminder;
            default:
              return true;
          }
        }).toList();

    // Sort by date (newest first)
    filtered.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return filtered;
  }

  Color _getMessageTypeColor(WhatsAppTemplateType type) {
    switch (type) {
      case WhatsAppTemplateType.invoiceShare:
        return Colors.blue;
      case WhatsAppTemplateType.paymentReminder:
        return Colors.orange;
      case WhatsAppTemplateType.custom:
        return Colors.green;
      // case WhatsAppTemplateType.custom:
      //   return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getMessageTypeLabel(WhatsAppTemplateType type) {
    switch (type) {
      case WhatsAppTemplateType.invoiceShare:
        return 'Invoice';
      case WhatsAppTemplateType.paymentReminder:
        return 'Reminder';
      case WhatsAppTemplateType.custom:
        return 'Welcome';
      // case WhatsAppTemplateType.custom:
      //   return 'Follow-up';
      default:
        return 'Message';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _resendMessage(WhatsAppMessageModel message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Resend Message'),
            content: Text('Resend this message to ${message.recipientName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Resending message to ${message.recipientName}...',
                      ),
                      backgroundColor: const Color(0xFF25D366),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Resend'),
              ),
            ],
          ),
    );
  }

  void _shareMessage(WhatsAppMessageModel message) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sharing message...')));
  }
}
