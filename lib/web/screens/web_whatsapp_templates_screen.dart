import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/whatsapp_template_model.dart';
import '../../services/whatsapp_service.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';
import '../widgets/web_card.dart';
import '../widgets/web_form_field.dart';

/// Web-optimized WhatsApp template management interface
/// Provides enhanced template editing with split-view layout
class WebWhatsAppTemplatesScreen extends StatefulWidget {
  const WebWhatsAppTemplatesScreen({super.key});

  @override
  State<WebWhatsAppTemplatesScreen> createState() =>
      _WebWhatsAppTemplatesScreenState();
}

class _WebWhatsAppTemplatesScreenState
    extends State<WebWhatsAppTemplatesScreen> {
  List<WhatsAppTemplateModel> _templates = [];
  WhatsAppTemplateModel? _selectedTemplate;
  bool _isLoading = true;
  bool _isEditing = false;

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
      final templates = templatesData
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
                  DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
              updatedAt:
                  DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
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
    return Row(
      children: [
        // Templates list (left side)
        Expanded(
          flex: 2,
          child: _buildTemplatesList(),
        ),
        // Template editor (right side)
        Expanded(
          flex: 3,
          child: _buildTemplateEditor(),
        ),
      ],
    );
  }

  Widget _buildTemplatesList() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WhatsApp Templates',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage message templates',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _createNewTemplate,
                  icon: const Icon(Icons.add),
                  label: const Text('New Template'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Templates list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _templates.isEmpty
                    ? _buildEmptyState()
                    : _buildGroupedTemplates(),
          ),
        ],
      ),
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
            'No Templates Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first template to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedTemplates() {
    final groupedTemplates =
        <WhatsAppTemplateType, List<WhatsAppTemplateModel>>{};

    for (final template in _templates) {
      groupedTemplates
          .putIfAbsent(template.templateType, () => [])
          .add(template);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groupedTemplates.entries.map((entry) {
        return _buildTemplateGroup(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildTemplateGroup(
    WhatsAppTemplateType type,
    List<WhatsAppTemplateModel> templates,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(_getTemplateTypeIcon(type), size: 20),
              const SizedBox(width: 8),
              Text(
                _getTemplateTypeTitle(type),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...templates.map((template) => _buildTemplateItem(template)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTemplateItem(WhatsAppTemplateModel template) {
    final isSelected = _selectedTemplate?.id == template.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
      child: ListTile(
        title: Text(
          template.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          template.messageTemplate.length > 60
              ? '${template.messageTemplate.substring(0, 60)}...'
              : template.messageTemplate,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (template.isDefault)
              const Chip(
                label: Text('Default', style: TextStyle(fontSize: 10)),
                padding: EdgeInsets.symmetric(horizontal: 4),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleTemplateAction(value, template),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 20),
                      SizedBox(width: 8),
                      Text('Duplicate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedTemplate = template;
            _isEditing = false;
          });
        },
      ),
    );
  }

  Widget _buildTemplateEditor() {
    if (_selectedTemplate == null && !_isEditing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Select a template to view or edit',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return _isEditing
        ? _TemplateEditorForm(
            template: _selectedTemplate,
            onSave: (template) async {
              await _saveTemplate(template);
              setState(() {
                _isEditing = false;
              });
            },
            onCancel: () {
              setState(() {
                _isEditing = false;
                _selectedTemplate = null;
              });
            },
          )
        : _buildTemplateViewer();
  }

  Widget _buildTemplateViewer() {
    final template = _selectedTemplate!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTemplateTypeTitle(template.templateType),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          WebCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Message Template',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(template.messageTemplate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (template.variables.isNotEmpty)
            WebCard(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Variables',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: template.variables
                        .map(
                          (variable) => Chip(
                            label: Text('{{$variable}}'),
                            backgroundColor:
                                AppTheme.primaryColor.withValues(alpha: 0.1),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _createNewTemplate() {
    setState(() {
      _selectedTemplate = null;
      _isEditing = true;
    });
  }

  void _handleTemplateAction(String action, WhatsAppTemplateModel template) {
    switch (action) {
      case 'edit':
        setState(() {
          _selectedTemplate = template;
          _isEditing = true;
        });
        break;
      case 'duplicate':
        final duplicated = template.copyWith(
          id: '',
          name: '${template.name} (Copy)',
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        setState(() {
          _selectedTemplate = duplicated;
          _isEditing = true;
        });
        break;
      case 'delete':
        _deleteTemplate(template);
        break;
    }
  }

  Future<void> _saveTemplate(WhatsAppTemplateModel template) async {
    final success = await WhatsAppService.saveTemplate(
      name: template.name,
      content: template.messageTemplate,
      type: template.templateType.toString(),
    );

    if (success) {
      await _loadTemplates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template saved successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteTemplate(WhatsAppTemplateModel template) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await WhatsAppService.deleteTemplate(template.id);
      if (success) {
        await _loadTemplates();
        setState(() {
          _selectedTemplate = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Template deleted'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    }
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
}

class _TemplateEditorForm extends StatefulWidget {
  final WhatsAppTemplateModel? template;
  final Function(WhatsAppTemplateModel) onSave;
  final VoidCallback onCancel;

  const _TemplateEditorForm({
    this.template,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_TemplateEditorForm> createState() => _TemplateEditorFormState();
}

class _TemplateEditorFormState extends State<_TemplateEditorForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _messageController;
  late WhatsAppTemplateType _selectedType;
  late bool _isActive;
  late bool _isDefault;
  List<String> _variables = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _messageController = TextEditingController(
      text: widget.template?.messageTemplate ?? '',
    );
    _selectedType = widget.template?.templateType ?? WhatsAppTemplateType.custom;
    _isActive = widget.template?.isActive ?? true;
    _isDefault = widget.template?.isDefault ?? false;
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.template != null ? 'Edit Template' : 'New Template',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            WebCard(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WebFormField(
                    controller: _nameController,
                    label: 'Template Name',
                    hint: 'e.g., Payment Reminder - Friendly',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a template name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<WhatsAppTemplateType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Template Type',
                      border: OutlineInputBorder(),
                    ),
                    items: WhatsAppTemplateType.values.map((type) {
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
                      border: OutlineInputBorder(),
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
                      children: _variables
                          .map(
                            (variable) => Chip(
                              label: Text('{{$variable}}'),
                              backgroundColor:
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Active'),
                          subtitle: const Text('Template can be used'),
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value ?? true;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Default'),
                          subtitle: const Text('Use as default for this type'),
                          value: _isDefault,
                          onChanged: (value) {
                            setState(() {
                              _isDefault = value ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            WebCard(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Variables:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
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
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      if (businessProvider.business == null) return;

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

      widget.onSave(template);
    }
  }
}
