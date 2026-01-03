import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'keyboard_shortcuts_service.dart';
import '../widgets/bulk_operations_toolbar.dart';
import '../widgets/side_panel.dart';
import '../widgets/desktop_modal_dialog.dart';
import 'print_service.dart';
import 'drag_drop_service.dart';

/// Example screen demonstrating all desktop features
class DesktopFeaturesExampleScreen extends StatefulWidget {
  const DesktopFeaturesExampleScreen({super.key});

  @override
  State<DesktopFeaturesExampleScreen> createState() =>
      _DesktopFeaturesExampleScreenState();
}

class _DesktopFeaturesExampleScreenState
    extends State<DesktopFeaturesExampleScreen>
    with MultiSelectMixin<String, DesktopFeaturesExampleScreen> {
  bool _showSidePanel = false;
  final List<String> _items = List.generate(20, (i) => 'Item ${i + 1}');

  @override
  void initState() {
    super.initState();
    // Register keyboard shortcuts
    KeyboardShortcutsService().registerDefaultShortcuts(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desktop Features Demo'),
        actions: [
          // Keyboard shortcuts help
          IconButton(
            icon: const Icon(Icons.keyboard),
            onPressed: () => _showKeyboardShortcuts(),
            tooltip: 'Keyboard Shortcuts',
          ),
          // Print button
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _handlePrint(),
            tooltip: 'Print',
          ),
        ],
      ),
      body: KeyboardShortcutHandler(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP):
              () => _handlePrint(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA):
              () => selectAll(_items),
          LogicalKeySet(LogicalKeyboardKey.escape): () => clearSelection(),
          LogicalKeySet(LogicalKeyboardKey.delete): () => _deleteSelected(),
        },
        child: SidePanelLayout(
          mainContent: Column(
            children: [
              // Bulk operations toolbar
              BulkOperationsToolbar<String>(
                selectedItems: selectedItems.toList(),
                onClearSelection: clearSelection,
                actions: [
                  BulkAction<String>(
                    id: 'delete',
                    label: 'Delete',
                    icon: Icons.delete,
                    color: Colors.red,
                    requiresConfirmation: true,
                    onExecute: (items) async {
                      await Future.delayed(const Duration(seconds: 1));
                      setState(() {
                        _items.removeWhere((item) => items.contains(item));
                        clearSelection();
                      });
                    },
                  ),
                  BulkAction<String>(
                    id: 'export',
                    label: 'Export',
                    icon: Icons.download,
                    onExecute: (items) async {
                      await Future.delayed(const Duration(seconds: 1));
                      // Export logic here
                    },
                  ),
                ],
              ),

              // Main content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
          sidePanel: _showSidePanel ? _buildSidePanel() : null,
          showSidePanel: _showSidePanel,
          onCloseSidePanel: () => setState(() => _showSidePanel = false),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'side_panel',
            onPressed: () => setState(() => _showSidePanel = !_showSidePanel),
            tooltip: 'Toggle Side Panel',
            child: const Icon(Icons.menu),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _showAddDialog(),
            tooltip: 'Add Item',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return DragDropReorderableList<String>(
      items: _items,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          final item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
      },
      itemBuilder: (context, item, index) {
        return SelectableListItem(
          selected: isSelected(item),
          onTap: () => toggleSelection(item),
          onLongPress: () => enterSelectionMode(),
          child: ListTile(
            leading: const Icon(Icons.drag_indicator),
            title: Text(item),
            trailing: IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                setState(() => _showSidePanel = true);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidePanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text('This is a side panel with detailed information.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showConfirmationDialog(),
            child: const Text('Show Confirmation'),
          ),
        ],
      ),
    );
  }

  void _showKeyboardShortcuts() {
    showDialog(
      context: context,
      builder: (context) => const KeyboardShortcutsDialog(),
    );
  }

  Future<void> _handlePrint() async {
    await PrintService().printTable(
      headers: ['Item', 'Status'],
      rows: _items.map((item) => [item, 'Active']).toList(),
      title: 'Items List',
      subtitle: 'Generated on ${DateTime.now()}',
    );
  }

  void _deleteSelected() {
    if (selectedItems.isEmpty) return;

    ConfirmationDialog.show(
      context: context,
      title: 'Delete Items',
      message: 'Are you sure you want to delete ${selectedItems.length} item(s)?',
      confirmText: 'Delete',
      confirmColor: Colors.red,
      icon: Icons.delete,
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          _items.removeWhere((item) => selectedItems.contains(item));
          clearSelection();
        });
      }
    });
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Item Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _items.add(nameController.text);
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    ConfirmationDialog.show(
      context: context,
      title: 'Confirm Action',
      message: 'Are you sure you want to proceed?',
      confirmText: 'Yes',
      cancelText: 'No',
      icon: Icons.warning,
    );
  }
}

/// Example of using split view
class SplitViewExample extends StatelessWidget {
  const SplitViewExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split View Example')),
      body: SplitView(
        left: Container(
          color: Colors.blue.shade50,
          child: const Center(child: Text('Left Panel')),
        ),
        right: Container(
          color: Colors.green.shade50,
          child: const Center(child: Text('Right Panel')),
        ),
        initialLeftWidth: 300,
        minLeftWidth: 200,
        minRightWidth: 300,
      ),
    );
  }
}

/// Example of file drop zone
class FileDropExample extends StatefulWidget {
  const FileDropExample({super.key});

  @override
  State<FileDropExample> createState() => _FileDropExampleState();
}

class _FileDropExampleState extends State<FileDropExample> {
  final List<String> _uploadedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Drop Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: FileDropZone(
                hintText: 'Drop files here to upload',
                allowedExtensions: ['.pdf', '.jpg', '.png'],
                onFilesDropped: (files) {
                  setState(() {
                    _uploadedFiles.addAll(files);
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_uploadedFiles.isNotEmpty) ...[
              const Text('Uploaded Files:'),
              ..._uploadedFiles.map((file) => ListTile(
                    leading: const Icon(Icons.file_present),
                    title: Text(file),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
