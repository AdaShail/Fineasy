import 'package:flutter/material.dart';
import '../../models/invoice_model.dart';

/// Quick action buttons for invoice management
/// Can be used in invoice list, detail, or edit screens
class InvoiceQuickActions extends StatelessWidget {
  final InvoiceModel invoice;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onSendWhatsApp;
  final VoidCallback? onGeneratePdf;
  final VoidCallback? onRecordPayment;
  final VoidCallback? onRefresh;
  final bool isCompact;

  const InvoiceQuickActions({
    super.key,
    required this.invoice,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.onSendWhatsApp,
    this.onGeneratePdf,
    this.onRecordPayment,
    this.onRefresh,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactActions(context);
    }
    return _buildFullActions(context);
  }

  Widget _buildCompactActions(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (context) => _buildMenuItems(),
    );
  }

  Widget _buildFullActions(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (onEdit != null)
          _ActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onPressed: onEdit!,
          ),
        if (onRecordPayment != null && invoice.status != InvoiceStatus.paid)
          _ActionButton(
            icon: Icons.payment,
            label: 'Record Payment',
            onPressed: onRecordPayment!,
            color: Colors.green,
          ),
        if (onGeneratePdf != null)
          _ActionButton(
            icon: Icons.picture_as_pdf,
            label: 'PDF',
            onPressed: onGeneratePdf!,
            color: Colors.red,
          ),
        if (onSendWhatsApp != null)
          _ActionButton(
            icon: Icons.message,
            label: 'WhatsApp',
            onPressed: onSendWhatsApp!,
            color: Colors.green.shade700,
          ),
        if (onDuplicate != null)
          _ActionButton(
            icon: Icons.copy,
            label: 'Duplicate',
            onPressed: onDuplicate!,
          ),
        if (onDelete != null)
          _ActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            onPressed: onDelete!,
            color: Colors.red,
          ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    return [
      if (onEdit != null)
        const PopupMenuItem(value: 'edit', child: _MenuItemContent(Icons.edit_outlined, 'Edit')),
      if (onRecordPayment != null && invoice.status != InvoiceStatus.paid)
        const PopupMenuItem(value: 'payment', child: _MenuItemContent(Icons.payment, 'Record Payment')),
      if (onGeneratePdf != null)
        const PopupMenuItem(value: 'pdf', child: _MenuItemContent(Icons.picture_as_pdf, 'Generate PDF')),
      if (onSendWhatsApp != null)
        const PopupMenuItem(value: 'whatsapp', child: _MenuItemContent(Icons.message, 'Send via WhatsApp')),
      if (onDuplicate != null)
        const PopupMenuItem(value: 'duplicate', child: _MenuItemContent(Icons.copy, 'Duplicate')),
      const PopupMenuDivider(),
      if (onDelete != null)
        const PopupMenuItem(
          value: 'delete',
          child: _MenuItemContent(Icons.delete_outline, 'Delete', color: Colors.red),
        ),
    ];
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        onEdit?.call();
        break;
      case 'payment':
        onRecordPayment?.call();
        break;
      case 'pdf':
        onGeneratePdf?.call();
        break;
      case 'whatsapp':
        onSendWhatsApp?.call();
        break;
      case 'duplicate':
        onDuplicate?.call();
        break;
      case 'delete':
        _confirmDelete(context);
        break;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: Text('Are you sure you want to delete invoice ${invoice.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color ?? Colors.grey.shade400),
      ),
    );
  }
}

class _MenuItemContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MenuItemContent(this.icon, this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

/// Floating action button for adding items/groups to invoice
class InvoiceItemFAB extends StatelessWidget {
  final VoidCallback onAddItem;
  final VoidCallback? onAddGroup;
  final bool showGroupOption;

  const InvoiceItemFAB({
    super.key,
    required this.onAddItem,
    this.onAddGroup,
    this.showGroupOption = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showGroupOption || onAddGroup == null) {
      return FloatingActionButton(
        onPressed: onAddItem,
        child: const Icon(Icons.add),
      );
    }

    return FloatingActionButton(
      onPressed: () => _showOptions(context),
      child: const Icon(Icons.add),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_shopping_cart),
              title: const Text('Add Item'),
              subtitle: const Text('Add a new line item to the invoice'),
              onTap: () {
                Navigator.pop(context);
                onAddItem();
              },
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder),
              title: const Text('Add Group'),
              subtitle: const Text('Create a group to organize items'),
              onTap: () {
                Navigator.pop(context);
                onAddGroup?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Status badge widget for invoice items
class InvoiceItemStatusBadge extends StatelessWidget {
  final InvoiceItemStatus status;
  final bool showLabel;

  const InvoiceItemStatusBadge({
    super.key,
    required this.status,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _getStatusInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  (Color, IconData, String) _getStatusInfo() {
    switch (status) {
      case InvoiceItemStatus.pending:
        return (Colors.orange, Icons.schedule, 'Pending');
      case InvoiceItemStatus.partial:
        return (Colors.blue, Icons.timelapse, 'Partial');
      case InvoiceItemStatus.paid:
        return (Colors.green, Icons.check_circle, 'Paid');
      case InvoiceItemStatus.cancelled:
        return (Colors.grey, Icons.cancel, 'Cancelled');
    }
  }
}

/// Due date indicator widget
class DueDateIndicator extends StatelessWidget {
  final DateTime? dueDate;
  final bool isOverdue;
  final bool compact;

  const DueDateIndicator({
    super.key,
    required this.dueDate,
    this.isOverdue = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (dueDate == null) {
      return const SizedBox.shrink();
    }

    final color = isOverdue ? Colors.red : Colors.grey;
    final daysText = _getDaysText();

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${dueDate!.day}/${dueDate!.month}',
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
              ),
              Text(
                daysText,
                style: TextStyle(fontSize: 10, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDaysText() {
    final now = DateTime.now();
    final diff = dueDate!.difference(now).inDays;

    if (diff < 0) {
      return '${-diff} days overdue';
    } else if (diff == 0) {
      return 'Due today';
    } else if (diff == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $diff days';
    }
  }
}
