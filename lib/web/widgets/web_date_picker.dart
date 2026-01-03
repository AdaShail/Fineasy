import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Enhanced date picker with calendar popup for web
class WebDatePicker extends StatefulWidget {
  final String? label;
  final String? hint;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime?)? onChanged;
  final String? Function(DateTime?)? validator;
  final bool enabled;
  final bool required;
  final DateFormat? dateFormat;
  final bool showQuickSelects;
  final EdgeInsetsGeometry? contentPadding;

  const WebDatePicker({
    Key? key,
    this.label,
    this.hint,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.required = false,
    this.dateFormat,
    this.showQuickSelects = true,
    this.contentPadding,
  }) : super(key: key);

  @override
  State<WebDatePicker> createState() => _WebDatePickerState();
}

class _WebDatePickerState extends State<WebDatePicker> {
  DateTime? _selectedDate;
  String? _errorText;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _updateController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateController() {
    if (_selectedDate != null) {
      final format = widget.dateFormat ?? DateFormat('MMM dd, yyyy');
      _controller.text = format.format(_selectedDate!);
    } else {
      _controller.text = '';
    }
  }

  void _validate() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_selectedDate);
      });
    } else if (widget.required && _selectedDate == null) {
      setState(() {
        _errorText = 'Please select a date';
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }
  }

  Future<void> _showDatePickerDialog() async {
    if (!widget.enabled) return;

    final theme = Theme.of(context);
    final now = DateTime.now();
    
    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
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
                      widget.label ?? 'Select Date',
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

              // Quick selects
              if (widget.showQuickSelects)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickSelectChip(
                        label: 'Today',
                        onTap: () => Navigator.of(context).pop(now),
                      ),
                      _QuickSelectChip(
                        label: 'Yesterday',
                        onTap: () => Navigator.of(context).pop(
                          now.subtract(const Duration(days: 1)),
                        ),
                      ),
                      _QuickSelectChip(
                        label: 'Last Week',
                        onTap: () => Navigator.of(context).pop(
                          now.subtract(const Duration(days: 7)),
                        ),
                      ),
                      _QuickSelectChip(
                        label: 'Last Month',
                        onTap: () => Navigator.of(context).pop(
                          DateTime(now.year, now.month - 1, now.day),
                        ),
                      ),
                    ],
                  ),
                ),

              // Calendar
              CalendarDatePicker(
                initialDate: _selectedDate ?? now,
                firstDate: widget.firstDate ?? DateTime(1900),
                lastDate: widget.lastDate ?? DateTime(2100),
                onDateChanged: (date) => Navigator.of(context).pop(date),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    if (_selectedDate != null)
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        child: const Text('Clear'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null || result == null && _selectedDate != null) {
      setState(() {
        _selectedDate = result;
        _updateController();
        _validate();
      });
      widget.onChanged?.call(_selectedDate);
    }
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
        TextField(
          controller: _controller,
          readOnly: true,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Select date',
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedDate != null && widget.enabled)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                        _updateController();
                        _validate();
                      });
                      widget.onChanged?.call(null);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: widget.enabled ? _showDatePickerDialog : null,
                ),
              ],
            ),
            errorText: _errorText,
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1,
              ),
            ),
            filled: !widget.enabled,
            fillColor: !widget.enabled
                ? theme.disabledColor.withOpacity(0.05)
                : null,
          ),
          onTap: _showDatePickerDialog,
        ),
      ],
    );
  }
}

class _QuickSelectChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickSelectChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}
