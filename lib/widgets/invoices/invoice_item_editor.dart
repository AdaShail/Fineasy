import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/invoice_model.dart';
import '../../utils/constants.dart';

/// Shared invoice item editor widget for both mobile and web
/// Supports item grouping, due dates, and flexible editing
class InvoiceItemEditor extends StatefulWidget {
  final List<InvoiceItemModel> items;
  final List<InvoiceItemGroup> groups;
  final Function(List<InvoiceItemModel>, List<InvoiceItemGroup>) onChanged;
  final bool showDueDates;
  final bool showGroups;
  final bool showNotes;
  final bool isCompact;
  final DateTime? invoiceDueDate;

  const InvoiceItemEditor({
    super.key,
    required this.items,
    required this.groups,
    required this.onChanged,
    this.showDueDates = true,
    this.showGroups = true,
    this.showNotes = true,
    this.isCompact = false,
    this.invoiceDueDate,
  });

  @override
  State<InvoiceItemEditor> createState() => _InvoiceItemEditorState();
}

class _InvoiceItemEditorState extends State<InvoiceItemEditor> {
  late List<InvoiceItemModel> _items;
  late List<InvoiceItemGroup> _groups;
  final _uuid = const Uuid();
  String? _expandedGroupId;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _groups = List.from(widget.groups);
  }

  @override
  void didUpdateWidget(InvoiceItemEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _items = List.from(widget.items);
    }
    if (oldWidget.groups != widget.groups) {
      _groups = List.from(widget.groups);
    }
  }

  void _notifyChange() {
    widget.onChanged(_items, _groups);
  }

  void _addItem({String? groupId}) {
    final newItem = InvoiceItemModel(
      id: _uuid.v4(),
      invoiceId: '',
      groupId: groupId,
      name: '',
      unitPrice: 0,
      quantity: 1,
      totalAmount: 0,
      sortOrder: _items.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    setState(() {
      _items.add(newItem);
    });
    _notifyChange();
  }

  void _updateItem(int index, InvoiceItemModel item) {
    setState(() {
      _items[index] = item.copyWith(
        totalAmount: item.calculatedTotal,
        updatedAt: DateTime.now(),
      );
    });
    _notifyChange();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _notifyChange();
  }

  void _addGroup() {
    final newGroup = InvoiceItemGroup(
      id: _uuid.v4(),
      invoiceId: '',
      name: 'New Group',
      sortOrder: _groups.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    setState(() {
      _groups.add(newGroup);
      _expandedGroupId = newGroup.id;
    });
    _notifyChange();
  }

  void _updateGroup(int index, InvoiceItemGroup group) {
    setState(() {
      _groups[index] = group.copyWith(updatedAt: DateTime.now());
    });
    _notifyChange();
  }

  void _removeGroup(int index) {
    final groupId = _groups[index].id;
    setState(() {
      // Move items from this group to ungrouped
      _items = _items.map((item) {
        if (item.groupId == groupId) {
          return item.copyWith(groupId: null);
        }
        return item;
      }).toList();
      _groups.removeAt(index);
    });
    _notifyChange();
  }

  void _moveItemToGroup(int itemIndex, String? groupId) {
    setState(() {
      _items[itemIndex] = _items[itemIndex].copyWith(groupId: groupId);
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        if (widget.showGroups) ...[
          ..._buildGroupedItems(),
          const SizedBox(height: 8),
        ],
        _buildUngroupedItems(),
        const SizedBox(height: 16),
        _buildTotals(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Invoice Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (widget.showGroups)
          TextButton.icon(
            onPressed: _addGroup,
            icon: const Icon(Icons.folder_outlined, size: 18),
            label: const Text('Add Group'),
          ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _addItem(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Item'),
        ),
      ],
    );
  }

  List<Widget> _buildGroupedItems() {
    return _groups.asMap().entries.map((entry) {
      final index = entry.key;
      final group = entry.value;
      final groupItems = _items.where((item) => item.groupId == group.id).toList();
      final isExpanded = _expandedGroupId == group.id;

      return _InvoiceItemGroupCard(
        group: group,
        items: groupItems,
        isExpanded: isExpanded,
        showDueDates: widget.showDueDates,
        showNotes: widget.showNotes,
        isCompact: widget.isCompact,
        onToggleExpand: () {
          setState(() {
            _expandedGroupId = isExpanded ? null : group.id;
          });
        },
        onGroupChanged: (updated) => _updateGroup(index, updated),
        onGroupDeleted: () => _removeGroup(index),
        onAddItem: () => _addItem(groupId: group.id),
        onItemChanged: (itemIndex, item) {
          final globalIndex = _items.indexWhere((i) => i.id == item.id);
          if (globalIndex >= 0) {
            _updateItem(globalIndex, item);
          }
        },
        onItemDeleted: (itemIndex) {
          final item = groupItems[itemIndex];
          final globalIndex = _items.indexWhere((i) => i.id == item.id);
          if (globalIndex >= 0) {
            _removeItem(globalIndex);
          }
        },
        onMoveItem: (itemIndex, newGroupId) {
          final item = groupItems[itemIndex];
          final globalIndex = _items.indexWhere((i) => i.id == item.id);
          if (globalIndex >= 0) {
            _moveItemToGroup(globalIndex, newGroupId);
          }
        },
        availableGroups: _groups,
      );
    }).toList();
  }

  Widget _buildUngroupedItems() {
    final ungroupedItems = _items.where((item) => item.groupId == null).toList();

    if (ungroupedItems.isEmpty && _groups.isNotEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_groups.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Ungrouped Items',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ),
            if (ungroupedItems.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No items added yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _addItem(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Item'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...ungroupedItems.asMap().entries.map((entry) {
                final item = entry.value;
                final globalIndex = _items.indexWhere((i) => i.id == item.id);

                return _InvoiceItemRow(
                  item: item,
                  showDueDate: widget.showDueDates,
                  showNotes: widget.showNotes,
                  isCompact: widget.isCompact,
                  onChanged: (updated) => _updateItem(globalIndex, updated),
                  onDeleted: () => _removeItem(globalIndex),
                  onMoveToGroup: widget.showGroups && _groups.isNotEmpty
                      ? (groupId) => _moveItemToGroup(globalIndex, groupId)
                      : null,
                  availableGroups: _groups,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTotals() {
    double subtotal = 0;
    double taxAmount = 0;
    double discountAmount = 0;

    for (final item in _items) {
      subtotal += item.subtotal;
      taxAmount += item.taxAmount;
      discountAmount += item.discountAmount;
    }

    final total = subtotal + taxAmount - discountAmount;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal', subtotal),
            if (taxAmount > 0) _buildTotalRow('Tax', taxAmount),
            if (discountAmount > 0) _buildTotalRow('Discount', -discountAmount),
            const Divider(),
            _buildTotalRow('Total', total, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            '${AppConstants.defaultCurrency}${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: amount < 0 ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}


/// Card widget for displaying a group of invoice items
class _InvoiceItemGroupCard extends StatelessWidget {
  final InvoiceItemGroup group;
  final List<InvoiceItemModel> items;
  final bool isExpanded;
  final bool showDueDates;
  final bool showNotes;
  final bool isCompact;
  final VoidCallback onToggleExpand;
  final Function(InvoiceItemGroup) onGroupChanged;
  final VoidCallback onGroupDeleted;
  final VoidCallback onAddItem;
  final Function(int, InvoiceItemModel) onItemChanged;
  final Function(int) onItemDeleted;
  final Function(int, String?) onMoveItem;
  final List<InvoiceItemGroup> availableGroups;

  const _InvoiceItemGroupCard({
    required this.group,
    required this.items,
    required this.isExpanded,
    required this.showDueDates,
    required this.showNotes,
    required this.isCompact,
    required this.onToggleExpand,
    required this.onGroupChanged,
    required this.onGroupDeleted,
    required this.onAddItem,
    required this.onItemChanged,
    required this.onItemDeleted,
    required this.onMoveItem,
    required this.availableGroups,
  });

  @override
  Widget build(BuildContext context) {
    final groupTotal = items.fold<double>(0, (sum, item) => sum + item.calculatedTotal);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: group.colorCode != null
          ? Color(int.parse(group.colorCode!.replaceFirst('#', '0xFF'))).withOpacity(0.05)
          : null,
      child: Column(
        children: [
          // Group header
          InkWell(
            onTap: onToggleExpand,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (group.dueDate != null)
                          Text(
                            'Due: ${group.dueDate!.day}/${group.dueDate!.month}/${group.dueDate!.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: group.isOverdue ? Colors.red : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${items.length} items',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${AppConstants.defaultCurrency}${groupTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditGroupDialog(context);
                          break;
                        case 'set_due_date':
                          _showDueDatePicker(context);
                          break;
                        case 'set_color':
                          _showColorPicker(context);
                          break;
                        case 'delete':
                          _confirmDelete(context);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit Group')),
                      const PopupMenuItem(value: 'set_due_date', child: Text('Set Due Date')),
                      const PopupMenuItem(value: 'set_color', child: Text('Set Color')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Group', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Group items
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No items in this group',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  else
                    ...items.asMap().entries.map((entry) {
                      return _InvoiceItemRow(
                        item: entry.value,
                        showDueDate: showDueDates,
                        showNotes: showNotes,
                        isCompact: isCompact,
                        onChanged: (updated) => onItemChanged(entry.key, updated),
                        onDeleted: () => onItemDeleted(entry.key),
                        onMoveToGroup: (groupId) => onMoveItem(entry.key, groupId),
                        availableGroups: availableGroups,
                        currentGroupId: group.id,
                      );
                    }),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onAddItem,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Item to Group'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context) {
    final nameController = TextEditingController(text: group.name);
    final descController = TextEditingController(text: group.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Group Name'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 2,
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
              onGroupChanged(group.copyWith(
                name: nameController.text.trim(),
                description: descController.text.trim().isEmpty ? null : descController.text.trim(),
              ));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDueDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: group.dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      onGroupChanged(group.copyWith(dueDate: date));
    }
  }

  void _showColorPicker(BuildContext context) {
    final colors = [
      '#2196F3', '#4CAF50', '#FF9800', '#E91E63',
      '#9C27B0', '#00BCD4', '#795548', '#607D8B',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return InkWell(
              onTap: () {
                onGroupChanged(group.copyWith(colorCode: color));
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(8),
                  border: group.colorCode == color
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onGroupChanged(group.copyWith(colorCode: null));
              Navigator.pop(context);
            },
            child: const Text('Clear Color'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group?'),
        content: Text(
          'This will delete the group "${group.name}". '
          'Items in this group will be moved to ungrouped items.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onGroupDeleted();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}


/// Row widget for a single invoice item
class _InvoiceItemRow extends StatefulWidget {
  final InvoiceItemModel item;
  final bool showDueDate;
  final bool showNotes;
  final bool isCompact;
  final Function(InvoiceItemModel) onChanged;
  final VoidCallback onDeleted;
  final Function(String?)? onMoveToGroup;
  final List<InvoiceItemGroup> availableGroups;
  final String? currentGroupId;

  const _InvoiceItemRow({
    required this.item,
    required this.showDueDate,
    required this.showNotes,
    required this.isCompact,
    required this.onChanged,
    required this.onDeleted,
    this.onMoveToGroup,
    this.availableGroups = const [],
    this.currentGroupId,
  });

  @override
  State<_InvoiceItemRow> createState() => _InvoiceItemRowState();
}

class _InvoiceItemRowState extends State<_InvoiceItemRow> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  late TextEditingController _taxController;
  late TextEditingController _discountController;
  late TextEditingController _notesController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.item.name);
    _descController = TextEditingController(text: widget.item.description ?? '');
    _qtyController = TextEditingController(text: widget.item.quantity.toString());
    _priceController = TextEditingController(text: widget.item.unitPrice.toString());
    _taxController = TextEditingController(text: widget.item.taxRate.toString());
    _discountController = TextEditingController(text: widget.item.discountRate.toString());
    _notesController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void didUpdateWidget(_InvoiceItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _initControllers();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _taxController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateItem() {
    widget.onChanged(widget.item.copyWith(
      name: _nameController.text,
      description: _descController.text.isEmpty ? null : _descController.text,
      quantity: double.tryParse(_qtyController.text) ?? 1,
      unitPrice: double.tryParse(_priceController.text) ?? 0,
      taxRate: double.tryParse(_taxController.text) ?? 0,
      discountRate: double.tryParse(_discountController.text) ?? 0,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactRow();
    }
    return _buildExpandableRow();
  }

  Widget _buildCompactRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Item name',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (_) => _updateItem(),
            ),
          ),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _qtyController,
              decoration: const InputDecoration(
                hintText: 'Qty',
                border: InputBorder.none,
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (_) => _updateItem(),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                hintText: 'Price',
                border: InputBorder.none,
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              onChanged: (_) => _updateItem(),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '${AppConstants.defaultCurrency}${widget.item.calculatedTotal.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            onPressed: widget.onDeleted,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableRow() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          // Main row
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name.isEmpty ? 'New Item' : widget.item.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (widget.item.description?.isNotEmpty == true)
                          Text(
                            widget.item.description!,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (widget.item.dueDate != null)
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 12,
                                color: widget.item.isOverdue ? Colors.red : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${widget.item.dueDate!.day}/${widget.item.dueDate!.month}/${widget.item.dueDate!.year}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.item.isOverdue ? Colors.red : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.item.quantity} × ${AppConstants.defaultCurrency}${widget.item.unitPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${AppConstants.defaultCurrency}${widget.item.calculatedTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  _buildItemMenu(),
                ],
              ),
            ),
          ),

          // Expanded details
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Name and description
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateItem(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (_) => _updateItem(),
                  ),
                  const SizedBox(height: 12),

                  // Quantity and price row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _qtyController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateItem(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: 'Unit Price',
                            border: const OutlineInputBorder(),
                            prefixText: AppConstants.defaultCurrency,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateItem(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tax and discount row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taxController,
                          decoration: const InputDecoration(
                            labelText: 'Tax Rate (%)',
                            border: OutlineInputBorder(),
                            suffixText: '%',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateItem(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _discountController,
                          decoration: const InputDecoration(
                            labelText: 'Discount (%)',
                            border: OutlineInputBorder(),
                            suffixText: '%',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateItem(),
                        ),
                      ),
                    ],
                  ),

                  // Due date
                  if (widget.showDueDate) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _selectDueDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Item Due Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          widget.item.dueDate != null
                              ? '${widget.item.dueDate!.day}/${widget.item.dueDate!.month}/${widget.item.dueDate!.year}'
                              : 'Not set (uses invoice due date)',
                          style: TextStyle(
                            color: widget.item.dueDate != null ? null : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Notes
                  if (widget.showNotes) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        hintText: 'Additional notes for this item',
                      ),
                      maxLines: 2,
                      onChanged: (_) => _updateItem(),
                    ),
                  ],

                  // Calculated totals
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildCalcRow('Subtotal', widget.item.subtotal),
                        if (widget.item.taxAmount > 0)
                          _buildCalcRow('Tax', widget.item.taxAmount),
                        if (widget.item.discountAmount > 0)
                          _buildCalcRow('Discount', -widget.item.discountAmount),
                        const Divider(),
                        _buildCalcRow('Total', widget.item.calculatedTotal, isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (value) {
        switch (value) {
          case 'duplicate':
            _duplicateItem();
            break;
          case 'set_due_date':
            _selectDueDate();
            break;
          case 'move_to_group':
            _showMoveToGroupDialog();
            break;
          case 'delete':
            widget.onDeleted();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
        if (widget.showDueDate)
          const PopupMenuItem(value: 'set_due_date', child: Text('Set Due Date')),
        if (widget.onMoveToGroup != null && widget.availableGroups.isNotEmpty)
          const PopupMenuItem(value: 'move_to_group', child: Text('Move to Group')),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildCalcRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : null)),
          Text(
            '${AppConstants.defaultCurrency}${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : null,
              color: amount < 0 ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.item.dueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      widget.onChanged(widget.item.copyWith(dueDate: date));
    }
  }

  void _duplicateItem() {
    // Parent will handle duplication
    widget.onChanged(widget.item.copyWith(
      id: const Uuid().v4(),
      name: '${widget.item.name} (Copy)',
    ));
  }

  void _showMoveToGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Ungrouped'),
              leading: const Icon(Icons.folder_off_outlined),
              selected: widget.currentGroupId == null,
              onTap: () {
                widget.onMoveToGroup?.call(null);
                Navigator.pop(context);
              },
            ),
            ...widget.availableGroups.map((group) => ListTile(
              title: Text(group.name),
              leading: const Icon(Icons.folder_outlined),
              selected: widget.currentGroupId == group.id,
              onTap: () {
                widget.onMoveToGroup?.call(group.id);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
