import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/whatsapp_template_model.dart';
import '../../services/whatsapp_service.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';

class WhatsAppTemplatesScreen extends StatefulWidget {
  const WhatsAppTemplatesScreen({super.key});

  @override
  State<WhatsAppTemplatesScreen> createState() =>
      _WhatsAppTemplatesScreenState();
}

class _WhatsAppTemplatesScreenState extends State<WhatsAppTemplatesScreen> {
  List<WhatsAppTemplateModel> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    if (businessProvider.business != null) {
      final templatesData = await WhatsAppService.getTemplates();
      final templates =
          templatesData
              .map(
                (data) => WhatsAppTemplateModel(
                  id: data['id'] ?? '',
                  businessId: businessProvider.business!.id,
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
                      DateTime.tryParse(data['createdAt'] ?? '') ??
                      DateTime.now(),
                  updatedAt:
                      DateTime.tryParse(data['updatedAt'] ?? '') ??
                      DateTime.now(),
                ),
              )
              .toList();
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showTemplateEditor(),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _templates.isEmpty
              ? _buildEmptyState()
              : _buildTemplatesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No WhatsApp Templates',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create templates to send consistent messages',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showTemplateEditor(),
            icon: const Icon(Icons.add),
            label: const Text('Create Template'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesList() {
    final groupedTemplates =
        <WhatsAppTemplateType, List<WhatsAppTemplateModel>>{};

    for (final template in _templates) {
      groupedTemplates
          .putIfAbsent(template.templateType, () => [])
          .add(template);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...groupedTemplates.entries.map(
          (entry) => _buildTemplateGroup(entry.key, entry.value),
        ),
      ],
    );
  }

  Widget _buildTemplateGroup(
    WhatsAppTemplateType type,
    List<WhatsAppTemplateModel> templates,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(_getTemplateTypeIcon(type), color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  _getTemplateTypeTitle(type),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showTemplateEditor(templateType: type),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...templates.map((template) => _buildTemplateItem(template)),
        ],
      ),
    );
  }

  Widget _buildTemplateItem(WhatsAppTemplateModel template) {
    return ListTile(
      title: Text(template.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            template.messageTemplate.length > 100
                ? '${template.messageTemplate.substring(0, 100)}...'
                : template.messageTemplate,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: [
              if (template.isDefault)
                Chip(
                  label: const Text('Default', style: TextStyle(fontSize: 10)),
                  backgroundColor: AppTheme.successColor.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: AppTheme.successColor),
                ),
              if (!template.isActive)
                Chip(
                  label: const Text('Inactive', style: TextStyle(fontSize: 10)),
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: Colors.grey),
                ),
              ...template.variables
                  .take(3)
                  .map(
                    (variable) => Chip(
                      label: Text(
                        variable,
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ),
              if (template.variables.length > 3)
                Text('+${template.variables.length - 3} more'),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _showTemplateEditor(template: template);
              break;
            case 'duplicate':
              _duplicateTemplate(template);
              break;
            case 'delete':
              _deleteTemplate(template);
              break;
            case 'test':
              _testTemplate(template);
              break;
          }
        },
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('Duplicate'),
                ),
              ),
              const PopupMenuItem(
                value: 'test',
                child: ListTile(leading: Icon(Icons.send), title: Text('Test')),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
      ),
    );
  }

  IconData _getTemplateTypeIcon(WhatsAppTemplateType type) {
    switch (type) {
      case WhatsAppTemplateType.invoiceShare:
        return Icons.receipt;
      case WhatsAppTemplateType.paymentReminder:
        return Icons.schedule;
      case WhatsAppTemplateType.overdueNotice:
        return Icons.warning;
      case WhatsAppTemplateType.paymentReceived:
        return Icons.check_circle;
      case WhatsAppTemplateType.custom:
        return Icons.message;
    }
  }

  String _getTemplateTypeTitle(WhatsAppTemplateType type) {
    switch (type) {
      case WhatsAppTemplateType.invoiceShare:
        return 'Invoice Sharing';
      case WhatsAppTemplateType.paymentReminder:
        return 'Payment Reminders';
      case WhatsAppTemplateType.overdueNotice:
        return 'Overdue Notices';
      case WhatsAppTemplateType.paymentReceived:
        return 'Payment Received';
      case WhatsAppTemplateType.custom:
        return 'Custom Messages';
    }
  }

  void _showTemplateEditor({
    WhatsAppTemplateModel? template,
    WhatsAppTemplateType? templateType,
  }) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) => WhatsAppTemplateEditorScreen(
                  template: template,
                  initialType: templateType,
                ),
          ),
        )
        .then((_) => _loadTemplates());
  }

  void _duplicateTemplate(WhatsAppTemplateModel template) {
    final duplicated = template.copyWith(
      id: '',
      name: '${template.name} (Copy)',
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _showTemplateEditor(template: duplicated);
  }

  void _deleteTemplate(WhatsAppTemplateModel template) {
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final success = await WhatsAppService.deleteTemplate(
                    template.id,
                  );
                  if (success) {
                    _loadTemplates();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Template deleted')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _testTemplate(WhatsAppTemplateModel template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WhatsAppTemplateTestScreen(template: template),
      ),
    );
  }
}

class WhatsAppTemplateEditorScreen extends StatefulWidget {
  final WhatsAppTemplateModel? template;
  final WhatsAppTemplateType? initialType;

  const WhatsAppTemplateEditorScreen({
    super.key,
    this.template,
    this.initialType,
  });

  @override
  State<WhatsAppTemplateEditorScreen> createState() =>
      _WhatsAppTemplateEditorScreenState();
}

class _WhatsAppTemplateEditorScreenState
    extends State<WhatsAppTemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();

  WhatsAppTemplateType _selectedType = WhatsAppTemplateType.custom;
  bool _isActive = true;
  bool _isDefault = false;
  List<String> _variables = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      final template = widget.template!;
      _nameController.text = template.name;
      _messageController.text = template.messageTemplate;
      _selectedType = template.templateType;
      _isActive = template.isActive;
      _isDefault = template.isDefault;
      _variables = List.from(template.variables);
    } else if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    _updateVariables();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _updateVariables() {
    setState(() {
      _variables = WhatsAppTemplateModel.extractVariables(
        _messageController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.template != null ? 'Edit Template' : 'Create Template',
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTemplate,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                hintText: 'e.g., Payment Reminder - Friendly',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a template name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<WhatsAppTemplateType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(labelText: 'Template Type'),
              items:
                  WhatsAppTemplateType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message Template',
                hintText: 'Use {{variable_name}} for dynamic content',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              onChanged: (_) => _updateVariables(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a message template';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            if (_variables.isNotEmpty) ...[
              const Text(
                'Variables Found:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    _variables
                        .map(
                          (variable) => Chip(
                            label: Text('{{$variable}}'),
                            backgroundColor: AppTheme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Active'),
                    subtitle: const Text('Template can be used'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Default'),
                    subtitle: const Text('Use as default for this type'),
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Variables:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text('• {{customer_name}} - Customer name'),
                    const Text('• {{invoice_number}} - Invoice number'),
                    const Text('• {{invoice_date}} - Invoice date'),
                    const Text('• {{due_date}} - Due date'),
                    const Text('• {{total_amount}} - Total amount'),
                    const Text('• {{outstanding_amount}} - Outstanding amount'),
                    const Text('• {{days_overdue}} - Days overdue'),
                    const Text('• {{days_until_due}} - Days until due'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      if (businessProvider.business == null) {
        throw Exception('Business not found');
      }

      final template = WhatsAppTemplateModel(
        id: widget.template?.id ?? '',
        businessId: businessProvider.business!.id,
        name: _nameController.text.trim(),
        templateType: _selectedType,
        messageTemplate: _messageController.text.trim(),
        variables: _variables,
        isActive: _isActive,
        isDefault: _isDefault,
        createdAt: widget.template?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await WhatsAppService.saveTemplate(
        name: template.name,
        content: template.messageTemplate,
        type: template.templateType.toString(),
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.template != null
                  ? 'Template updated successfully'
                  : 'Template created successfully',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save template'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class WhatsAppTemplateTestScreen extends StatefulWidget {
  final WhatsAppTemplateModel template;

  const WhatsAppTemplateTestScreen({super.key, required this.template});

  @override
  State<WhatsAppTemplateTestScreen> createState() =>
      _WhatsAppTemplateTestScreenState();
}

class _WhatsAppTemplateTestScreenState
    extends State<WhatsAppTemplateTestScreen> {
  final _phoneController = TextEditingController();
  final Map<String, TextEditingController> _variableControllers = {};
  String _previewMessage = '';

  @override
  void initState() {
    super.initState();
    for (final variable in widget.template.variables) {
      _variableControllers[variable] = TextEditingController();
    }
    _updatePreview();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (final controller in _variableControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updatePreview() {
    final values = <String, String>{};
    for (final entry in _variableControllers.entries) {
      values[entry.key] = entry.value.text;
    }

    setState(() {
      _previewMessage = widget.template.generateMessage(values);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Template'),
        actions: [
          TextButton(onPressed: _sendTestMessage, child: const Text('Send')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Test Phone Number',
              hintText: '+91 9876543210',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),

          if (widget.template.variables.isNotEmpty) ...[
            const Text(
              'Template Variables:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...widget.template.variables.map(
              (variable) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _variableControllers[variable],
                  decoration: InputDecoration(
                    labelText: variable.replaceAll('_', ' ').toUpperCase(),
                    hintText: 'Enter $variable',
                  ),
                  onChanged: (_) => _updatePreview(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          const Text(
            'Message Preview:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Text(
              _previewMessage.isEmpty
                  ? 'Enter values to see preview'
                  : _previewMessage,
              style: TextStyle(
                color: _previewMessage.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestMessage() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    if (businessProvider.business == null) return;

    final variables = <String, String>{};
    for (final entry in _variableControllers.entries) {
      variables[entry.key] = entry.value.text;
    }

    final success = await WhatsAppService.sendCustomMessage(
      phoneNumber: _phoneController.text.trim(),
      message: widget.template.messageTemplate,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Test message sent!' : 'Failed to send message',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
