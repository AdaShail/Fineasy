import 'package:flutter/material.dart';
import '../../models/whatsapp_template_model.dart';
import '../../services/whatsapp_service.dart';
import 'whatsapp_templates_screen.dart';
import 'whatsapp_messages_screen.dart';

class WhatsAppScreen extends StatefulWidget {
  const WhatsAppScreen({super.key});

  @override
  State<WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends State<WhatsAppScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WhatsAppMessageModel> _recentMessages = [];
  List<WhatsAppTemplateModel> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load recent messages
      final messagesData = await WhatsAppService.getRecentMessages();
      _recentMessages =
          messagesData
              .map(
                (data) => WhatsAppMessageModel(
                  id: data['id'] ?? '',
                  businessId: data['business_id'] ?? '',
                  messageType: WhatsAppTemplateType.custom,
                  recipientPhone: data['phone_number'] ?? '',
                  recipientName: data['recipient_name'] ?? 'Unknown',
                  messageContent: data['message'] ?? '',
                  sentAt:
                      DateTime.tryParse(data['sent_at'] ?? '') ??
                      DateTime.now(),
                  createdAt: DateTime.now(),
                ),
              )
              .toList();

      // Load templates
      final templatesData = await WhatsAppService.getTemplates();
      _templates =
          templatesData
              .map(
                (data) => WhatsAppTemplateModel(
                  id: data['id'] ?? '',
                  businessId: data['business_id'] ?? '',
                  name: data['name'] ?? '',
                  templateType: WhatsAppTemplateType.values.firstWhere(
                    (type) =>
                        type.toString().split('.').last ==
                        (data['type'] ?? 'custom'),
                    orElse: () => WhatsAppTemplateType.custom,
                  ),
                  messageTemplate: data['content'] ?? '',
                  variables: List<String>.from(data['variables'] ?? []),
                  isActive: data['isActive'] ?? true,
                  isDefault: data['isDefault'] ?? false,
                  createdAt:
                      DateTime.tryParse(data['created_at'] ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(data['updated_at'] ?? '') ??
                      DateTime.now(),
                ),
              )
              .toList();
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading WhatsApp data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Business'),
        backgroundColor: const Color(0xFF25D366), // WhatsApp green
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
            Tab(text: 'Messages', icon: Icon(Icons.message)),
            Tab(text: 'Templates', icon: Icon(Icons.description)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WhatsAppTemplatesScreen(),
                    ),
                  );
                  break;
                case 'help':
                  _showHelpDialog();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'help',
                    child: ListTile(
                      leading: Icon(Icons.help),
                      title: Text('Help'),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildMessagesTab(),
                  _buildTemplatesTab(),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSendMessageDialog,
        backgroundColor: const Color(0xFF25D366),
        icon: const Icon(Icons.send, color: Colors.white),
        label: const Text(
          'Send Message',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Messages Sent',
                  '${_recentMessages.length}',
                  Icons.send,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Templates',
                  '${_templates.length}',
                  Icons.description,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(
                'Send Invoice',
                Icons.receipt,
                Colors.green,
                () => _showSendInvoiceDialog(),
              ),
              _buildActionCard(
                'Payment Reminder',
                Icons.payment,
                Colors.orange,
                () => _showPaymentReminderDialog(),
              ),
              _buildActionCard(
                'Bulk Messages',
                Icons.group,
                Colors.purple,
                () => _showBulkMessageDialog(),
              ),
              _buildActionCard(
                'New Template',
                Icons.add_box,
                Colors.blue,
                () => _showCreateTemplateDialog(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Recent Messages',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (_recentMessages.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text('No messages sent yet'),
                      Text('Start by sending your first WhatsApp message!'),
                    ],
                  ),
                ),
              ),
            )
          else
            Card(
              child: Column(
                children:
                    _recentMessages.take(5).map((message) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF25D366),
                          child: Text(
                            message.recipientName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(message.recipientName),
                        subtitle: Text(
                          message.messageContent,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          '${message.sentAt.hour}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return WhatsAppMessagesScreen(messages: _recentMessages);
  }

  Widget _buildTemplatesTab() {
    return WhatsAppTemplatesScreen(templates: _templates);
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSendMessageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.message, color: Color(0xFF25D366)),
                SizedBox(width: 8),
                Text('Send WhatsApp Message'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixText: '+91 ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(' Opening WhatsApp...'),
                      backgroundColor: Color(0xFF25D366),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  void _showSendInvoiceDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Send Invoice via WhatsApp'),
            content: const Text('Select an invoice to send via WhatsApp'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to invoice selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select invoice to send')),
                  );
                },
                child: const Text('Select Invoice'),
              ),
            ],
          ),
    );
  }

  void _showPaymentReminderDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Send Payment Reminder'),
            content: const Text(
              'Send payment reminders to customers with overdue invoices',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to overdue invoices
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Checking overdue invoices...'),
                    ),
                  );
                },
                child: const Text('Send Reminders'),
              ),
            ],
          ),
    );
  }

  void _showBulkMessageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Send Bulk Messages'),
            content: const Text('Send messages to multiple customers at once'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to bulk message screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(' Opening bulk message composer...'),
                    ),
                  );
                },
                child: const Text('Compose'),
              ),
            ],
          ),
    );
  }

  void _showCreateTemplateDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Template'),
            content: const Text('Create a new WhatsApp message template'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WhatsAppTemplatesScreen(),
                    ),
                  );
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('WhatsApp Business Help'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How to use WhatsApp Business:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Send invoices directly to customers'),
                  Text('• Create and manage message templates'),
                  Text('• Send payment reminders automatically'),
                  Text('• Track message history'),
                  SizedBox(height: 16),
                  Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Use templates for consistent messaging'),
                  Text('• Include customer name for personalization'),
                  Text('• Keep messages professional and clear'),
                  Text('• Follow WhatsApp Business policies'),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }
}
