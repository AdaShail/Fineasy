import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/invoice_model.dart';
import '../../utils/constants.dart';

/// Web-optimized invoice item editor with drag-drop, bulk operations, and table view
class WebInvoiceItemEditor extends StatefulWidget {
  final List<InvoiceItemModel> items;
  final List<InvoiceItemGroup> groups;
  final Function(List<InvoiceItemModel>, List<InvoiceItemGroup>) onChanged;
  final bool showDueDates;
  final bool showGroups;
  final DateTime? invoiceDueDate;

  const WebInvoiceItemEditor({
    super.key,
    required this.items,
    required this.groups,
    required this.onChanged,
    this.showDueDates = true,
    this.showGroups = true,
    this.invoiceDueDate,
  });

  @override
  State<WebInvoiceItemEditor> createState() => _WebInvoiceItemEditorState();
}

class _WebInvoiceItemEditorState extends State<WebInvoiceItemEditor> {
  late List<InvoiceItemModel> _items;
  late List<InvoiceItemGroup> _groups;
  final _uuid = const Uuid();
  final Set<String> _selectedItemIds = {};
  String? _editingItemId;
  bool _showTableView = true;
  String? _expandedGroupId;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _groups = List.from(widget.groups);
  }

  @override
  void didUpdateWidget(WebInvoiceItemEditor oldWidget) {
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
      _editingItemId = newItem.id;
    });
    _notifyChange();
  }

  void _updateItem(String itemId, InvoiceItemModel item) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      setState(() {
        _items[index] = item.copyWith(
          totalAmount: item.calculatedTotal,
          updatedAt: DateTime.now(),
        );
      });
      _notifyChange();
    }
  }

  void _removeItem(String itemId) {
    setState(() {
      _items.removeWhere((i) => i.id == itemId);
      _selectedItemIds.remove(itemId);
    });
    _notifyChange();
  }

  void _bulkDelete() {
    setState(() {
      _items.removeWhere((i) => _selectedItemIds.contains(i.id));
      _selectedItemIds.clear();
    });
    _notifyChange();
  }

  void _bulkMoveToGroup(String? groupId) {
    setState(() {
      _items = _items.map((item) {
        if (_selectedItemIds.contains(item.id)) {
          return item.copyWith(groupId: groupId);
        }
        return item;
      }).toList();
      _selectedItemIds.clear();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToolbar(),
        if (_selectedItemIds.isNotEmpty) _buildBulkActionsBar(),
        const SizedBox(height: 12),
        if (_showTableView)
          _buildTableView()
        else
          _buildCardView(),
        const SizedBox(height: 16),
        _buildTotalsCard(),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Text(
            'Invoice Items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Chip(
            label: Text('${_items.length} items'),
            backgroundColor: Colors.blue.shade100,
          ),
          const Spacer(),
          // View toggle
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, icon: Icon(Icons.table_rows), label: Text('Table')),
              ButtonSegment(value: false, icon: Icon(Icons.view_agenda), label: Text('Cards')),
            ],
            selected: {_showTableView},
            onSelectionChanged: (value) {
              setState(() => _showTableView = value.first);
            },
          ),
          const SizedBox(width: 16),
          if (widget.showGroups)
            OutlinedButton.icon(
              onPressed: _addGroup,
              icon: const Icon(Icons.create_new_folder_outlined, size: 18),
              label: const Text('Add Group'),
            ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _addItem(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedItemIds.length} selected',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          if (widget.showGroups && _groups.isNotEmpty)
            PopupMenuButton<String?>(
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.drive_file_move_outline, size: 18),
                  SizedBox(width: 4),
                  Text('Move to Group'),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
              onSelected: _bulkMoveToGroup,
              itemBuilder: (context) => [
                const PopupMenuItem(value: null, child: Text('Ungrouped')),
                ..._groups.map((g) => PopupMenuItem(value: g.id, child: Text(g.name))),
              ],
            ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _bulkSetDueDate,
            icon: const Icon(Icons.event, size: 18),
            label: const Text('Set Due Date'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _bulkDelete,
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _selectedItemIds.clear()),
            child: const Text('Clear Selection'),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView() {
    return Card(
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Checkbox(
                    value: _selectedItemIds.length == _items.length && _items.isNotEmpty,
                    tristate: true,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedItemIds.addAll(_items.map((i) => i.id));
                        } else {
                          _selectedItemIds.clear();
                        }
                      });
                    },
                  ),
                ),
                const Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.w600))),
                const SizedBox(width: 80, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                const SizedBox(width: 100, child: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                const SizedBox(width: 80, child: Text('Tax %', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                if (widget.showDueDates)
                  const SizedBox(width: 120, child: Text('Due Date', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                const SizedBox(width: 100, child: Text('Total', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                const SizedBox(width: 60),
              ],
            ),
          ),
          // Groups and items
          if (widget.showGroups && _groups.isNotEmpty) ...[
            ..._groups.map((group) => _buildGroupSection(group)),
            if (_items.any((i) => i.groupId == null))
              _buildUngroupedSection(),
          ] else
            ..._items.map((item) => _buildTableRow(item)),
          // Empty state
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('No items added', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupSection(InvoiceItemGroup group) {
    final groupItems = _items.where((i) => i.groupId == group.id).toList();
    final isExpanded = _expandedGroupId == group.id;
    final groupTotal = groupItems.fold<double>(0, (sum, i) => sum + i.calculatedTotal);

    return Column(
      children: [
        // Group header
        InkWell(
          onTap: () => setState(() => _expandedGroupId = isExpanded ? null : group.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: group.colorCode != null
                  ? Color(int.parse(group.colorCode!.replaceFirst('#', '0xFF'))).withOpacity(0.1)
                  : Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
                const SizedBox(width: 8),
                Icon(Icons.folder, size: 18, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Text(group.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text('${groupItems.length}'),
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (group.dueDate != null) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.event, size: 14, color: group.isOverdue ? Colors.red : Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${group.dueDate!.day}/${group.dueDate!.month}/${group.dueDate!.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: group.isOverdue ? Colors.red : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '${AppConstants.defaultCurrency}${groupTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => _addItem(groupId: group.id),
                  tooltip: 'Add item to group',
                ),
                _buildGroupMenu(group),
              ],
            ),
          ),
        ),
        // Group items
        if (isExpanded)
          ...groupItems.map((item) => _buildTableRow(item)),
      ],
    );
  }

  Widget _buildUngroupedSection() {
    final ungroupedItems = _items.where((i) => i.groupId == null).toList();
    if (ungroupedItems.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              const Icon(Icons.folder_off_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text('Ungrouped Items', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 8),
              Chip(
                label: Text('${ungroupedItems.length}'),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        ...ungroupedItems.map((item) => _buildTableRow(item)),
      ],
    );
  }

  Widget _buildTableRow(InvoiceItemModel item) {
    final isSelected = _selectedItemIds.contains(item.id);
    final isEditing = _editingItemId == item.id;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : null,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: isEditing
          ? _buildEditableRow(item)
          : _buildReadOnlyRow(item, isSelected),
    );
  }

  Widget _buildReadOnlyRow(InvoiceItemModel item, bool isSelected) {
    return InkWell(
      onDoubleTap: () => setState(() => _editingItemId = item.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedItemIds.add(item.id);
                    } else {
                      _selectedItemIds.remove(item.id);
                    }
                  });
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name.isEmpty ? 'Unnamed Item' : item.name),
                  if (item.description?.isNotEmpty == true)
                    Text(
                      item.description!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            SizedBox(width: 80, child: Text(item.quantity.toString(), textAlign: TextAlign.center)),
            SizedBox(
              width: 100,
              child: Text(
                '${AppConstants.defaultCurrency}${item.unitPrice.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(width: 80, child: Text('${item.taxRate}%', textAlign: TextAlign.center)),
            if (widget.showDueDates)
              SizedBox(
                width: 120,
                child: item.dueDate != null
                    ? Text(
                        '${item.dueDate!.day}/${item.dueDate!.month}/${item.dueDate!.year}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: item.isOverdue ? Colors.red : null),
                      )
                    : Text('-', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400])),
              ),
            SizedBox(
              width: 100,
              child: Text(
                '${AppConstants.defaultCurrency}${item.calculatedTotal.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              width: 60,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => setState(() => _editingItemId = item.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    onPressed: () => _removeItem(item.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow(InvoiceItemModel item) {
    return _InlineItemEditor(
      item: item,
      showDueDate: widget.showDueDates,
      onSave: (updated) {
        _updateItem(item.id, updated);
        setState(() => _editingItemId = null);
      },
      onCancel: () => setState(() => _editingItemId = null),
    );
  }

  Widget _buildGroupMenu(InvoiceItemGroup group) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            _editGroup(group);
            break;
          case 'due_date':
            final date = await showDatePicker(
              context: context,
              initialDate: group.dueDate ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              final index = _groups.indexWhere((g) => g.id == group.id);
              if (index >= 0) {
                setState(() => _groups[index] = group.copyWith(dueDate: date));
                _notifyChange();
              }
            }
            break;
          case 'delete':
            _deleteGroup(group);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit Group')),
        const PopupMenuItem(value: 'due_date', child: Text('Set Due Date')),
        const PopupMenuItem(value: 'delete', child: Text('Delete Group', style: TextStyle(color: Colors.red))),
      ],
    );
  }

  void _editGroup(InvoiceItemGroup group) {
    final nameController = TextEditingController(text: group.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Group Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final index = _groups.indexWhere((g) => g.id == group.id);
              if (index >= 0) {
                setState(() => _groups[index] = group.copyWith(name: nameController.text));
                _notifyChange();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteGroup(InvoiceItemGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group?'),
        content: const Text('Items will be moved to ungrouped.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() {
                _items = _items.map((i) => i.groupId == group.id ? i.copyWith(groupId: null) : i).toList();
                _groups.removeWhere((g) => g.id == group.id);
              });
              _notifyChange();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _bulkSetDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _items = _items.map((item) {
          if (_selectedItemIds.contains(item.id)) {
            return item.copyWith(dueDate: date);
          }
          return item;
        }).toList();
        _selectedItemIds.clear();
      });
      _notifyChange();
    }
  }

  Widget _buildCardView() {
    // Card view implementation - similar to mobile
    return Column(
      children: _items.map((item) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(item.name.isEmpty ? 'Unnamed Item' : item.name),
          subtitle: Text('${item.quantity} × ${AppConstants.defaultCurrency}${item.unitPrice}'),
          trailing: Text(
            '${AppConstants.defaultCurrency}${item.calculatedTotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () => setState(() => _editingItemId = item.id),
        ),
      )).toList(),
    );
  }

  Widget _buildTotalsCard() {
    double subtotal = 0, taxAmount = 0, discountAmount = 0;
    for (final item in _items) {
      subtotal += item.subtotal;
      taxAmount += item.taxAmount;
      discountAmount += item.discountAmount;
    }
    final total = subtotal + taxAmount - discountAmount;

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildTotalColumn('Subtotal', subtotal),
            const SizedBox(width: 32),
            _buildTotalColumn('Tax', taxAmount),
            const SizedBox(width: 32),
            _buildTotalColumn('Discount', discountAmount),
            const SizedBox(width: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    '${AppConstants.defaultCurrency}${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalColumn(String label, double amount) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          '${AppConstants.defaultCurrency}${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}


/// Inline editor for a single item in table view
class _InlineItemEditor extends StatefulWidget {
  final InvoiceItemModel item;
  final bool showDueDate;
  final Function(InvoiceItemModel) onSave;
  final VoidCallback onCancel;

  const _InlineItemEditor({
    required this.item,
    required this.showDueDate,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_InlineItemEditor> createState() => _InlineItemEditorState();
}

class _InlineItemEditorState extends State<_InlineItemEditor> {
  late TextEditingController _nameController;
  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  late TextEditingController _taxController;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _qtyController = TextEditingController(text: widget.item.quantity.toString());
    _priceController = TextEditingController(text: widget.item.unitPrice.toString());
    _taxController = TextEditingController(text: widget.item.taxRate.toString());
    _dueDate = widget.item.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(widget.item.copyWith(
      name: _nameController.text,
      quantity: double.tryParse(_qtyController.text) ?? 1,
      unitPrice: double.tryParse(_priceController.text) ?? 0,
      taxRate: double.tryParse(_taxController.text) ?? 0,
      dueDate: _dueDate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.yellow.shade50,
      child: Row(
        children: [
          const SizedBox(width: 40), // Checkbox placeholder
          Expanded(
            flex: 3,
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Item name',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              autofocus: true,
              onSubmitted: (_) => _save(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _qtyController,
              decoration: const InputDecoration(
                hintText: 'Qty',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                hintText: 'Price',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _taxController,
              decoration: const InputDecoration(
                hintText: 'Tax %',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.showDueDate) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _dueDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _dueDate != null
                              ? '${_dueDate!.day}/${_dueDate!.month}'
                              : 'Due date',
                          style: TextStyle(
                            fontSize: 13,
                            color: _dueDate != null ? null : Colors.grey,
                          ),
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          const SizedBox(width: 100), // Total placeholder
          SizedBox(
            width: 60,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, size: 18, color: Colors.green),
                  onPressed: _save,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28),
                  tooltip: 'Save',
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                  onPressed: widget.onCancel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28),
                  tooltip: 'Cancel',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
