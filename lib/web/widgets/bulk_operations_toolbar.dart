import 'package:flutter/material.dart';

/// Action definition for bulk operations
class BulkAction<T> {
  final String id;
  final String label;
  final IconData icon;
  final Future<void> Function(List<T> items) onExecute;
  final bool Function(List<T> items)? isEnabled;
  final Color? color;
  final bool requiresConfirmation;
  final String? confirmationMessage;

  const BulkAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.onExecute,
    this.isEnabled,
    this.color,
    this.requiresConfirmation = false,
    this.confirmationMessage,
  });
}

/// Toolbar for bulk operations with multi-select support
class BulkOperationsToolbar<T> extends StatefulWidget {
  final List<T> selectedItems;
  final List<BulkAction<T>> actions;
  final VoidCallback? onClearSelection;
  final String? selectionLabel;
  final Widget? leading;
  final List<Widget>? trailing;

  const BulkOperationsToolbar({
    super.key,
    required this.selectedItems,
    required this.actions,
    this.onClearSelection,
    this.selectionLabel,
    this.leading,
    this.trailing,
  });

  @override
  State<BulkOperationsToolbar<T>> createState() => _BulkOperationsToolbarState<T>();
}

class _BulkOperationsToolbarState<T> extends State<BulkOperationsToolbar<T>> {
  bool _isProcessing = false;

  Future<void> _executeAction(BulkAction<T> action) async {
    if (_isProcessing) return;

    // Check if action is enabled
    if (action.isEnabled != null && !action.isEnabled!(widget.selectedItems)) {
      return;
    }

    // Show confirmation dialog if required
    if (action.requiresConfirmation) {
      final confirmed = await _showConfirmationDialog(action);
      if (!confirmed) return;
    }

    setState(() => _isProcessing = true);

    try {
      await action.onExecute(widget.selectedItems);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${action.label} completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _showConfirmationDialog(BulkAction<T> action) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm ${action.label}'),
        content: Text(
          action.confirmationMessage ??
              'Are you sure you want to ${action.label.toLowerCase()} '
                  '${widget.selectedItems.length} item(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action.color ?? Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = widget.selectedItems.isNotEmpty;

    if (!hasSelection) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: hasSelection ? 64 : 0,
      child: Material(
        elevation: 4,
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Leading widget
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 16),
              ],

              // Selection count
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                widget.selectionLabel ??
                    '${widget.selectedItems.length} item(s) selected',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 24),

              // Action buttons
              if (_isProcessing)
                const CircularProgressIndicator()
              else
                ...widget.actions.map((action) {
                  final isEnabled = action.isEnabled?.call(widget.selectedItems) ?? true;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton.icon(
                      onPressed: isEnabled ? () => _executeAction(action) : null,
                      icon: Icon(action.icon),
                      label: Text(action.label),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: action.color,
                      ),
                    ),
                  );
                }),

              const Spacer(),

              // Trailing widgets
              if (widget.trailing != null) ...widget.trailing!,

              // Clear selection button
              if (widget.onClearSelection != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClearSelection,
                  tooltip: 'Clear selection',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mixin to add multi-select capability to widgets
mixin MultiSelectMixin<T, W extends StatefulWidget> on State<W> {
  final Set<T> selectedItems = {};
  bool isSelectionMode = false;

  void toggleSelection(T item) {
    setState(() {
      if (selectedItems.contains(item)) {
        selectedItems.remove(item);
      } else {
        selectedItems.add(item);
      }
      
      if (selectedItems.isEmpty) {
        isSelectionMode = false;
      }
    });
  }

  void selectAll(List<T> items) {
    setState(() {
      selectedItems.addAll(items);
      isSelectionMode = true;
    });
  }

  void clearSelection() {
    setState(() {
      selectedItems.clear();
      isSelectionMode = false;
    });
  }

  void enterSelectionMode() {
    setState(() {
      isSelectionMode = true;
    });
  }

  bool isSelected(T item) {
    return selectedItems.contains(item);
  }
}

/// Widget for displaying selectable items with checkbox
class SelectableListItem extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final bool showCheckbox;

  const SelectableListItem({
    super.key,
    required this.selected,
    this.onTap,
    this.onLongPress,
    required this.child,
    this.showCheckbox = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : null,
          border: selected
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            if (showCheckbox)
              Checkbox(
                value: selected,
                onChanged: (_) => onTap?.call(),
              ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
