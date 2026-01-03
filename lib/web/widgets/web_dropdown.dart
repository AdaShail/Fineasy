import 'package:flutter/material.dart';

/// Option for WebDropdown
class WebDropdownOption<T> {
  final T value;
  final String label;
  final Widget? leading;
  final String? subtitle;
  final bool enabled;

  const WebDropdownOption({
    required this.value,
    required this.label,
    this.leading,
    this.subtitle,
    this.enabled = true,
  });
}

/// Enhanced dropdown with search and multi-select for web
class WebDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final List<WebDropdownOption<T>> options;
  final T? value;
  final List<T>? values;
  final void Function(T?)? onChanged;
  final void Function(List<T>)? onMultiChanged;
  final bool multiSelect;
  final bool searchable;
  final String? searchHint;
  final bool enabled;
  final bool required;
  final String? Function(T?)? validator;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxHeight;

  const WebDropdown({
    Key? key,
    this.label,
    this.hint,
    required this.options,
    this.value,
    this.values,
    this.onChanged,
    this.onMultiChanged,
    this.multiSelect = false,
    this.searchable = false,
    this.searchHint,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.contentPadding,
    this.maxHeight,
  }) : super(key: key);

  @override
  State<WebDropdown<T>> createState() => _WebDropdownState<T>();
}

class _WebDropdownState<T> extends State<WebDropdown<T>> {
  String? _errorText;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<T> _selectedValues = {};

  @override
  void initState() {
    super.initState();
    if (widget.multiSelect && widget.values != null) {
      _selectedValues.addAll(widget.values!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _validate() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(widget.value);
      });
    } else if (widget.required && widget.value == null && _selectedValues.isEmpty) {
      setState(() {
        _errorText = 'Please select an option';
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }
  }

  List<WebDropdownOption<T>> get _filteredOptions {
    if (_searchQuery.isEmpty) return widget.options;
    
    return widget.options.where((option) {
      return option.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (option.subtitle?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  String get _displayText {
    if (widget.multiSelect) {
      if (_selectedValues.isEmpty) return widget.hint ?? 'Select options';
      if (_selectedValues.length == 1) {
        final option = widget.options.firstWhere((o) => o.value == _selectedValues.first);
        return option.label;
      }
      return '${_selectedValues.length} selected';
    } else {
      if (widget.value == null) return widget.hint ?? 'Select option';
      final option = widget.options.firstWhere((o) => o.value == widget.value);
      return option.label;
    }
  }

  Future<void> _showDropdownDialog() async {
    if (!widget.enabled) return;

    final theme = Theme.of(context);
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: widget.maxHeight?.toDouble() ?? 500,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.label ?? 'Select',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onPrimary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Search
                  if (widget.searchable)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: widget.searchHint ?? 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setDialogState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setDialogState(() => _searchQuery = value);
                        },
                      ),
                    ),

                  // Options list
                  Expanded(
                    child: _filteredOptions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No options found',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredOptions.length,
                            itemBuilder: (context, index) {
                              final option = _filteredOptions[index];
                              final isSelected = widget.multiSelect
                                  ? _selectedValues.contains(option.value)
                                  : widget.value == option.value;

                              return ListTile(
                                enabled: option.enabled,
                                leading: widget.multiSelect
                                    ? Checkbox(
                                        value: isSelected,
                                        onChanged: option.enabled
                                            ? (selected) {
                                                setDialogState(() {
                                                  if (selected == true) {
                                                    _selectedValues.add(option.value);
                                                  } else {
                                                    _selectedValues.remove(option.value);
                                                  }
                                                });
                                              }
                                            : null,
                                      )
                                    : option.leading,
                                title: Text(option.label),
                                subtitle: option.subtitle != null
                                    ? Text(option.subtitle!)
                                    : null,
                                selected: isSelected,
                                onTap: option.enabled
                                    ? () {
                                        if (widget.multiSelect) {
                                          setDialogState(() {
                                            if (_selectedValues.contains(option.value)) {
                                              _selectedValues.remove(option.value);
                                            } else {
                                              _selectedValues.add(option.value);
                                            }
                                          });
                                        } else {
                                          widget.onChanged?.call(option.value);
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    : null,
                              );
                            },
                          ),
                  ),

                  // Actions (for multi-select)
                  if (widget.multiSelect)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setDialogState(() => _selectedValues.clear());
                            },
                            child: const Text('Clear All'),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    widget.onMultiChanged?.call(_selectedValues.toList());
                                    _validate();
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Done'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );

    // Reset search after dialog closes
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text(
                  widget.label!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: hasError ? theme.colorScheme.error : null,
                  ),
                ),
                if (widget.required)
                  Text(
                    ' *',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        InkWell(
          onTap: widget.enabled ? _showDropdownDialog : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError
                    ? theme.colorScheme.error
                    : theme.dividerColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: !widget.enabled
                  ? theme.disabledColor.withOpacity(0.05)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _displayText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: (widget.value == null && _selectedValues.isEmpty)
                          ? theme.textTheme.bodySmall?.color
                          : null,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: widget.enabled
                      ? theme.iconTheme.color
                      : theme.disabledColor,
                ),
              ],
            ),
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              _errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
