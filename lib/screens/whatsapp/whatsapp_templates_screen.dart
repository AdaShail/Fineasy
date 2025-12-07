import 'package:flutter/material.dart';
import '../../models/whatsapp_template_model.dart';

class WhatsAppTemplatesScreen extends StatefulWidget {
  final List<WhatsAppTemplateModel>? templates;

  const WhatsAppTemplatesScreen({super.key, this.templates});

  @override
  State<WhatsAppTemplatesScreen> createState() =>
      _WhatsAppTemplatesScreenState();
}

class _WhatsAppTemplatesScreenState extends State<WhatsAppTemplatesScreen> {
  List<WhatsAppTemplateModel> _templates = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _templates = widget.templates ?? _getDefaultTemplates();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTemplates = _getFilteredTemplates();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Templates'),
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateTemplateDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search templates...',
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
          ),

          // Templates List
          Expanded(
            child:
                filteredTemplates.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTemplates.length,
                      itemBuilder: (context, index) {
                        final template = filteredTemplates[index];
                        return _buildTemplateCard(template);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(WhatsAppTemplateModel template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTemplateTypeColor(template.templateType),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTemplateTypeIcon(template.templateType),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _getTemplateTypeLabel(template.templateType),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (template.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleTemplateAction(value, template),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: ListTile(
                            leading: Icon(Icons.copy),
                            title: Text('Duplicate'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPreviewText(template),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            if (template.variables.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children:
                    template.variables.map((variable) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '{$variable}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  template.isActive ? Icons.check_circle : Icons.pause_circle,
                  color: template.isActive ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  template.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: template.isActive ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _useTemplate(template),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Use Template'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
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
            Icon(Icons.description, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No templates found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search'
                  : 'Create your first WhatsApp template',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateTemplateDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Template'),
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

  List<WhatsAppTemplateModel> _getFilteredTemplates() {
    if (_searchQuery.isEmpty) {
      return _templates;
    }

    final query = _searchQuery.toLowerCase();
    return _templates.where((template) {
      return template.name.toLowerCase().contains(query) ||
          template.messageTemplate.toLowerCase().contains(query) ||
          _getTemplateTypeLabel(
            template.templateType,
          ).toLowerCase().contains(query);
    }).toList();
  }

  Color _getTemplateTypeColor(WhatsAppTemplateType type) {
    switch (type) {
      case WhatsAppTemplateType.invoiceShare:
        return Colors.blue;
      case WhatsAppTemplateType.paymentReminder:
        return Colors.orange;
      case WhatsAppTemplateType.custom:
        return Colors.green;
      case WhatsAppTemplateType.custom:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTemplateTypeIcon(WhatsAppTemplateType type) {
    switch (type) {
      case WhatsAppTemplateType.invoiceShare:
        return Icons.receipt;
      case WhatsAppTemplateType.paymentReminder:
        return Icons.payment;
      case WhatsAppTemplateType.custom:
        return Icons.waving_hand;
      case WhatsAppTemplateType.custom:
        return Icons.follow_the_signs;
      default:
        return Icons.message;
    }
  }

  String _getTemplateTypeLabel(WhatsAppTemplateType type) {
    switch (type) {
      case WhatsAppTemplateType.invoiceShare:
        return 'Invoice Template';
      case WhatsAppTemplateType.paymentReminder:
        return 'Payment Reminder';
      case WhatsAppTemplateType.custom:
        return 'Welcome Message';
      case WhatsAppTemplateType.custom:
        return 'Follow-up Message';
      default:
        return 'Custom Template';
    }
  }

  String _getPreviewText(WhatsAppTemplateModel template) {
    String preview = template.messageTemplate;

    // Replace variables with sample data for preview
    for (String variable in template.variables) {
      switch (variable.toLowerCase()) {
        case 'customer_name':
          preview = preview.replaceAll('{$variable}', 'John Doe');
          break;
        case 'invoice_number':
          preview = preview.replaceAll('{$variable}', 'INV-001');
          break;
        case 'amount':
          preview = preview.replaceAll('{$variable}', '₹5,000');
          break;
        case 'due_date':
          preview = preview.replaceAll('{$variable}', '15/01/2024');
          break;
        case 'business_name':
          preview = preview.replaceAll('{$variable}', 'Your Business');
          break;
        default:
          preview = preview.replaceAll('{$variable}', '[Sample]');
      }
    }

    return preview;
  }

  List<WhatsAppTemplateModel> _getDefaultTemplates() {
    return [
      WhatsAppTemplateModel(
        id: '1',
        businessId: 'default',
        name: 'Invoice Notification',
        templateType: WhatsAppTemplateType.invoiceShare,
        messageTemplate:
            'Hi {customer_name}!\n\nYour invoice {invoice_number} for ₹{amount} is ready.\n\nDue date: {due_date}\n\nThank you for your business!\n\n- {business_name}',
        variables: [
          'customer_name',
          'invoice_number',
          'amount',
          'due_date',
          'business_name',
        ],
        isActive: true,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WhatsAppTemplateModel(
        id: '2',
        businessId: 'default',
        name: 'Payment Reminder',
        templateType: WhatsAppTemplateType.paymentReminder,
        messageTemplate:
            'Hello {customer_name}\n\nFriendly reminder: Invoice {invoice_number} for ₹{amount} is due on {due_date}.\n\nPlease make payment at your earliest convenience.\n\nThank you!\n- {business_name}',
        variables: [
          'customer_name',
          'invoice_number',
          'amount',
          'due_date',
          'business_name',
        ],
        isActive: true,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WhatsAppTemplateModel(
        id: '3',
        businessId: 'default',
        name: 'Welcome Message',
        templateType: WhatsAppTemplateType.custom,
        messageTemplate:
            'Welcome to {business_name}!\n\nThank you for choosing us. We\'re excited to serve you!\n\nIf you have any questions, feel free to reach out.\n\nBest regards,\n{business_name} Team',
        variables: ['business_name'],
        isActive: true,
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  void _handleTemplateAction(String action, WhatsAppTemplateModel template) {
    switch (action) {
      case 'edit':
        _showEditTemplateDialog(template);
        break;
      case 'duplicate':
        _duplicateTemplate(template);
        break;
      case 'delete':
        _showDeleteConfirmation(template);
        break;
    }
  }

  void _showCreateTemplateDialog() {
    _showTemplateDialog();
  }

  void _showEditTemplateDialog(WhatsAppTemplateModel template) {
    _showTemplateDialog(template: template);
  }

  void _showTemplateDialog({WhatsAppTemplateModel? template}) {
    final isEditing = template != null;
    final nameController = TextEditingController(text: template?.name ?? '');
    final messageController = TextEditingController(
      text: template?.messageTemplate ?? '',
    );
    WhatsAppTemplateType selectedType =
        template?.templateType ?? WhatsAppTemplateType.custom;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEditing ? 'Edit Template' : 'Create Template'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Template Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<WhatsAppTemplateType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Template Type',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        WhatsAppTemplateType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getTemplateTypeLabel(type)),
                          );
                        }).toList(),
                    onChanged: (value) {
                      selectedType = value ?? WhatsAppTemplateType.custom;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message Template',
                      border: OutlineInputBorder(),
                      hintText: 'Use {variable_name} for dynamic content',
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Available variables: {customer_name}, {invoice_number}, {amount}, {due_date}, {business_name}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      messageController.text.isNotEmpty) {
                    _saveTemplate(
                      template: template,
                      name: nameController.text,
                      type: selectedType,
                      message: messageController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                ),
                child: Text(isEditing ? 'Update' : 'Create'),
              ),
            ],
          ),
    );
  }

  void _saveTemplate({
    WhatsAppTemplateModel? template,
    required String name,
    required WhatsAppTemplateType type,
    required String message,
  }) {
    final variables = _extractVariables(message);

    if (template != null) {
      // Update existing template
      final index = _templates.indexWhere((t) => t.id == template.id);
      if (index != -1) {
        setState(() {
          _templates[index] = WhatsAppTemplateModel(
            id: template.id,
            businessId: template.businessId,
            name: name,
            templateType: type,
            messageTemplate: message,
            variables: variables,
            isActive: template.isActive,
            isDefault: template.isDefault,
            createdAt: template.createdAt,
            updatedAt: DateTime.now(),
          );
        });
      }
    } else {
      // Create new template
      setState(() {
        _templates.add(
          WhatsAppTemplateModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            businessId: 'current',
            name: name,
            templateType: type,
            messageTemplate: message,
            variables: variables,
            isActive: true,
            isDefault: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          template != null ? 'Template updated!' : 'Template created!',
        ),
        backgroundColor: const Color(0xFF25D366),
      ),
    );
  }

  List<String> _extractVariables(String message) {
    final regex = RegExp(r'\{([^}]+)\}');
    final matches = regex.allMatches(message);
    return matches.map((match) => match.group(1)!).toSet().toList();
  }

  void _duplicateTemplate(WhatsAppTemplateModel template) {
    setState(() {
      _templates.add(
        WhatsAppTemplateModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          businessId: template.businessId,
          name: '${template.name} (Copy)',
          templateType: template.templateType,
          messageTemplate: template.messageTemplate,
          variables: template.variables,
          isActive: template.isActive,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template duplicated!'),
        backgroundColor: Color(0xFF25D366),
      ),
    );
  }

  void _showDeleteConfirmation(WhatsAppTemplateModel template) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Template'),
            content: Text(
              'Are you sure you want to delete "${template.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _templates.removeWhere((t) => t.id == template.id);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Template deleted!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _useTemplate(WhatsAppTemplateModel template) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Use "${template.name}"'),
            content: const Text(
              'This will open WhatsApp with the template message. You can customize it before sending.',
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
                    SnackBar(
                      content: Text(
                        ' Opening WhatsApp with "${template.name}" template...',
                      ),
                      backgroundColor: const Color(0xFF25D366),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Use Template'),
              ),
            ],
          ),
    );
  }
}
