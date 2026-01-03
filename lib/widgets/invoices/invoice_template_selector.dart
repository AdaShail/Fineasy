import 'package:flutter/material.dart';
import '../../models/invoice_model.dart';
import '../../services/invoice_service.dart';

/// Widget for selecting and managing invoice templates
class InvoiceTemplateSelector extends StatefulWidget {
  final String businessId;
  final String? selectedTemplateId;
  final Function(InvoiceTemplateModel?) onTemplateSelected;
  final bool showManageButton;

  const InvoiceTemplateSelector({
    super.key,
    required this.businessId,
    this.selectedTemplateId,
    required this.onTemplateSelected,
    this.showManageButton = true,
  });

  @override
  State<InvoiceTemplateSelector> createState() => _InvoiceTemplateSelectorState();
}

class _InvoiceTemplateSelectorState extends State<InvoiceTemplateSelector> {
  List<InvoiceTemplateModel> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    try {
      final templates = await InvoiceService.getInvoiceTemplates(widget.businessId);
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Invoice Template',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            if (widget.showManageButton)
              TextButton.icon(
                onPressed: () => _showTemplateManager(context),
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('Manage'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_templates.isEmpty)
          _buildEmptyState()
        else
          _buildTemplateGrid(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.description_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No templates yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showCreateTemplateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Template'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateGrid() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _templates.length + 1, // +1 for "No Template" option
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildTemplateCard(null);
          }
          return _buildTemplateCard(_templates[index - 1]);
        },
      ),
    );
  }

  Widget _buildTemplateCard(InvoiceTemplateModel? template) {
    final isSelected = template?.id == widget.selectedTemplateId ||
        (template == null && widget.selectedTemplateId == null);

    return GestureDetector(
      onTap: () => widget.onTemplateSelected(template),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (template == null) ...[
              Icon(Icons.description_outlined, size: 32, color: Colors.grey[400]),
              const SizedBox(height: 8),
              const Text('No Template', style: TextStyle(fontSize: 12)),
            ] else ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: template.colorScheme['primary'] != null
                      ? Color(int.parse(template.colorScheme['primary']!.replaceFirst('#', '0xFF')))
                      : Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTemplateIcon(template.templateType),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                template.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (template.isDefault)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(fontSize: 10, color: Colors.green),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getTemplateIcon(TemplateType type) {
    switch (type) {
      case TemplateType.standard:
        return Icons.description;
      case TemplateType.gst:
        return Icons.account_balance;
      case TemplateType.service:
        return Icons.build;
      case TemplateType.product:
        return Icons.inventory;
    }
  }

  void _showTemplateManager(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _TemplateManagerSheet(
          businessId: widget.businessId,
          templates: _templates,
          scrollController: scrollController,
          onTemplatesChanged: _loadTemplates,
        ),
      ),
    );
  }

  void _showCreateTemplateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateTemplateDialog(
        businessId: widget.businessId,
        onCreated: (template) {
          _loadTemplates();
          widget.onTemplateSelected(template);
        },
      ),
    );
  }
}

/// Bottom sheet for managing templates
class _TemplateManagerSheet extends StatelessWidget {
  final String businessId;
  final List<InvoiceTemplateModel> templates;
  final ScrollController scrollController;
  final VoidCallback onTemplatesChanged;

  const _TemplateManagerSheet({
    required this.businessId,
    required this.templates,
    required this.scrollController,
    required this.onTemplatesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Manage Templates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Template list
        Expanded(
          child: templates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No templates created', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: template.colorScheme['primary'] != null
                              ? Color(int.parse(template.colorScheme['primary']!.replaceFirst('#', '0xFF')))
                              : Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.description, color: Colors.white, size: 20),
                      ),
                      title: Row(
                        children: [
                          Text(template.name),
                          if (template.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Default', style: TextStyle(fontSize: 10, color: Colors.green)),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(template.templateType.name.toUpperCase()),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'edit':
                              _showEditDialog(context, template);
                              break;
                            case 'default':
                              await _setAsDefault(template);
                              break;
                            case 'delete':
                              await _deleteTemplate(context, template);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          if (!template.isDefault)
                            const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateTemplateDialog(
        businessId: businessId,
        onCreated: (_) => onTemplatesChanged(),
      ),
    );
  }

  void _showEditDialog(BuildContext context, InvoiceTemplateModel template) {
    showDialog(
      context: context,
      builder: (context) => _CreateTemplateDialog(
        businessId: businessId,
        existingTemplate: template,
        onCreated: (_) => onTemplatesChanged(),
      ),
    );
  }

  Future<void> _setAsDefault(InvoiceTemplateModel template) async {
    await InvoiceService.updateTemplate(template.copyWith(isDefault: true));
    onTemplatesChanged();
  }

  Future<void> _deleteTemplate(BuildContext context, InvoiceTemplateModel template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template?'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await InvoiceService.deleteTemplate(template.id);
      onTemplatesChanged();
    }
  }
}

/// Dialog for creating/editing templates
class _CreateTemplateDialog extends StatefulWidget {
  final String businessId;
  final InvoiceTemplateModel? existingTemplate;
  final Function(InvoiceTemplateModel) onCreated;

  const _CreateTemplateDialog({
    required this.businessId,
    this.existingTemplate,
    required this.onCreated,
  });

  @override
  State<_CreateTemplateDialog> createState() => _CreateTemplateDialogState();
}

class _CreateTemplateDialogState extends State<_CreateTemplateDialog> {
  final _nameController = TextEditingController();
  final _headerController = TextEditingController();
  final _footerController = TextEditingController();
  TemplateType _templateType = TemplateType.standard;
  String _primaryColor = '#2196F3';
  bool _showItemDueDates = true;
  bool _showItemGroups = true;
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingTemplate != null) {
      final t = widget.existingTemplate!;
      _nameController.text = t.name;
      _headerController.text = t.headerText ?? '';
      _footerController.text = t.footerText ?? '';
      _templateType = t.templateType;
      _primaryColor = t.colorScheme['primary'] ?? '#2196F3';
      _showItemDueDates = t.showItemDueDates;
      _showItemGroups = t.showItemGroups;
      _isDefault = t.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a template name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final template = InvoiceTemplateModel(
        id: widget.existingTemplate?.id ?? '',
        businessId: widget.businessId,
        name: _nameController.text.trim(),
        templateType: _templateType,
        headerText: _headerController.text.trim().isEmpty ? null : _headerController.text.trim(),
        footerText: _footerController.text.trim().isEmpty ? null : _footerController.text.trim(),
        colorScheme: {'primary': _primaryColor, 'secondary': '#FFC107', 'text': '#333333'},
        layoutConfig: {
          'showItemDueDates': _showItemDueDates,
          'showItemGroups': _showItemGroups,
          'showItemNotes': true,
          'showSKU': false,
          'showHSN': _templateType == TemplateType.gst,
          'showUnit': true,
        },
        isDefault: _isDefault,
        createdAt: widget.existingTemplate?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      InvoiceTemplateModel? result;
      if (widget.existingTemplate != null) {
        result = await InvoiceService.updateTemplate(template);
      } else {
        result = await InvoiceService.createTemplate(template);
      }

      if (result != null && mounted) {
        widget.onCreated(result);
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTemplate != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Template' : 'Create Template'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Template Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TemplateType>(
                value: _templateType,
                decoration: const InputDecoration(
                  labelText: 'Template Type',
                  border: OutlineInputBorder(),
                ),
                items: TemplateType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _templateType = value);
                },
              ),
              const SizedBox(height: 16),
              const Text('Primary Color', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  '#2196F3', '#4CAF50', '#FF9800', '#E91E63',
                  '#9C27B0', '#00BCD4', '#795548', '#607D8B',
                ].map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _primaryColor = color),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(8),
                        border: _primaryColor == color
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _headerController,
                decoration: const InputDecoration(
                  labelText: 'Header Text',
                  border: OutlineInputBorder(),
                  hintText: 'Text to show at top of invoice',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _footerController,
                decoration: const InputDecoration(
                  labelText: 'Footer Text',
                  border: OutlineInputBorder(),
                  hintText: 'Text to show at bottom of invoice',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              const Text('Options', style: TextStyle(fontWeight: FontWeight.w500)),
              SwitchListTile(
                title: const Text('Show Item Due Dates'),
                value: _showItemDueDates,
                onChanged: (value) => setState(() => _showItemDueDates = value),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Enable Item Groups'),
                value: _showItemGroups,
                onChanged: (value) => setState(() => _showItemGroups = value),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Set as Default'),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
