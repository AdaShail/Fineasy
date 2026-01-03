import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcut action definition
class KeyboardShortcut {
  final String id;
  final String label;
  final String description;
  final LogicalKeySet keys;
  final VoidCallback action;
  final bool enabled;

  const KeyboardShortcut({
    required this.id,
    required this.label,
    required this.description,
    required this.keys,
    required this.action,
    this.enabled = true,
  });
}

/// Service for managing keyboard shortcuts across the web platform
class KeyboardShortcutsService {
  static final KeyboardShortcutsService _instance = KeyboardShortcutsService._internal();
  factory KeyboardShortcutsService() => _instance;
  KeyboardShortcutsService._internal();

  final Map<String, KeyboardShortcut> _shortcuts = {};
  final Map<String, VoidCallback> _listeners = {};

  /// Register a keyboard shortcut
  void registerShortcut(KeyboardShortcut shortcut) {
    _shortcuts[shortcut.id] = shortcut;
  }

  /// Unregister a keyboard shortcut
  void unregisterShortcut(String id) {
    _shortcuts.remove(id);
  }

  /// Get all registered shortcuts
  List<KeyboardShortcut> getAllShortcuts() {
    return _shortcuts.values.toList();
  }

  /// Get shortcuts by category
  List<KeyboardShortcut> getShortcutsByCategory(String category) {
    return _shortcuts.values
        .where((s) => s.id.startsWith(category))
        .toList();
  }

  /// Clear all shortcuts
  void clearAll() {
    _shortcuts.clear();
    _listeners.clear();
  }

  /// Register default application shortcuts
  void registerDefaultShortcuts(BuildContext context) {
    // Navigation shortcuts
    registerShortcut(KeyboardShortcut(
      id: 'nav.dashboard',
      label: 'Go to Dashboard',
      description: 'Navigate to the dashboard',
      keys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyD,
      ),
      action: () => Navigator.of(context).pushNamed('/dashboard'),
    ));

    registerShortcut(KeyboardShortcut(
      id: 'nav.invoices',
      label: 'Go to Invoices',
      description: 'Navigate to invoices',
      keys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyI,
      ),
      action: () => Navigator.of(context).pushNamed('/invoices'),
    ));

    registerShortcut(KeyboardShortcut(
      id: 'nav.customers',
      label: 'Go to Customers',
      description: 'Navigate to customers',
      keys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyC,
      ),
      action: () => Navigator.of(context).pushNamed('/customers'),
    ));

    registerShortcut(KeyboardShortcut(
      id: 'nav.transactions',
      label: 'Go to Transactions',
      description: 'Navigate to transactions',
      keys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyT,
      ),
      action: () => Navigator.of(context).pushNamed('/transactions'),
    ));

    // Action shortcuts
    registerShortcut(KeyboardShortcut(
      id: 'action.search',
      label: 'Search',
      description: 'Open search',
      keys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyK,
      ),
      action: () {
        // Trigger search - implementation depends on context
      },
    ));

    registerShortcut(KeyboardShortcut(
      id: 'action.new',
      label: 'New Item',
      description: 'Create new item',
      keys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyN,
      ),
      action: () {
        // Trigger new item - implementation depends on context
      },
    ));

    registerShortcut(KeyboardShortcut(
      id: 'action.save',
      label: 'Save',
      description: 'Save current item',
      keys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyS,
      ),
      action: () {
        // Trigger save - implementation depends on context
      },
    ));

    registerShortcut(KeyboardShortcut(
      id: 'action.refresh',
      label: 'Refresh',
      description: 'Refresh current view',
      keys: LogicalKeySet(
        LogicalKeyboardKey.f5,
      ),
      action: () {
        // Trigger refresh - implementation depends on context
      },
    ));

    // Selection shortcuts
    registerShortcut(KeyboardShortcut(
      id: 'select.all',
      label: 'Select All',
      description: 'Select all items',
      keys: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyA,
      ),
      action: () {
        // Trigger select all - implementation depends on context
      },
    ));

    registerShortcut(KeyboardShortcut(
      id: 'select.none',
      label: 'Deselect All',
      description: 'Deselect all items',
      keys: LogicalKeySet(
        LogicalKeyboardKey.escape,
      ),
      action: () {
        // Trigger deselect all - implementation depends on context
      },
    ));
  }
}

/// Intent for keyboard shortcuts
class KeyboardShortcutIntent extends Intent {
  final VoidCallback action;
  const KeyboardShortcutIntent(this.action);
}

/// Widget that provides keyboard shortcut handling
class KeyboardShortcutHandler extends StatefulWidget {
  final Widget child;
  final Map<LogicalKeySet, VoidCallback>? shortcuts;
  final bool enabled;

  const KeyboardShortcutHandler({
    super.key,
    required this.child,
    this.shortcuts,
    this.enabled = true,
  });

  @override
  State<KeyboardShortcutHandler> createState() => _KeyboardShortcutHandlerState();
}

class _KeyboardShortcutHandlerState extends State<KeyboardShortcutHandler> {
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || widget.shortcuts == null) {
      return widget.child;
    }

    // Convert shortcuts to proper format
    final Map<ShortcutActivator, Intent> shortcutMap = {};
    final Map<Type, Action<Intent>> actionMap = {};

    for (var entry in widget.shortcuts!.entries) {
      final intent = KeyboardShortcutIntent(entry.value);
      shortcutMap[entry.key] = intent;
      actionMap[KeyboardShortcutIntent] = CallbackAction<KeyboardShortcutIntent>(
        onInvoke: (intent) {
          intent.action();
          return null;
        },
      );
    }

    return Shortcuts(
      shortcuts: shortcutMap,
      child: Actions(
        actions: actionMap,
        child: Focus(
          autofocus: true,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Dialog to display available keyboard shortcuts
class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcuts = KeyboardShortcutsService().getAllShortcuts();
    final theme = Theme.of(context);

    // Group shortcuts by category
    final Map<String, List<KeyboardShortcut>> grouped = {};
    for (var shortcut in shortcuts) {
      final category = shortcut.id.split('.').first;
      grouped.putIfAbsent(category, () => []).add(shortcut);
    }

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.keyboard,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Keyboard Shortcuts',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatCategory(entry.key),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...entry.value.map((shortcut) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  shortcut.label,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Expanded(
                                child: _buildKeyDisplay(
                                  context,
                                  shortcut.keys,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategory(String category) {
    return category[0].toUpperCase() + category.substring(1);
  }

  Widget _buildKeyDisplay(BuildContext context, LogicalKeySet keys) {
    final theme = Theme.of(context);
    final keyLabels = keys.triggers.map((key) {
      return _getKeyLabel(key);
    }).toList();

    return Wrap(
      spacing: 4,
      children: keyLabels.map((label) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getKeyLabel(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.control) return 'Ctrl';
    if (key == LogicalKeyboardKey.shift) return 'Shift';
    if (key == LogicalKeyboardKey.alt) return 'Alt';
    if (key == LogicalKeyboardKey.meta) return 'Cmd';
    if (key == LogicalKeyboardKey.escape) return 'Esc';
    if (key == LogicalKeyboardKey.f5) return 'F5';
    
    // For letter keys
    final label = key.keyLabel;
    return label.toUpperCase();
  }
}
