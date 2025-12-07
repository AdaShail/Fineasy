import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';

class GSTValidationField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isRequired;
  final Function(String)? onChanged;
  final Function(bool, String?)? onValidationChanged;

  const GSTValidationField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.isRequired = false,
    this.onChanged,
    this.onValidationChanged,
  });

  @override
  State<GSTValidationField> createState() => _GSTValidationFieldState();
}

class _GSTValidationFieldState extends State<GSTValidationField> {
  bool _isValidating = false;
  bool? _isValid;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _isValid = null;
        _validationMessage = null;
        _isValidating = false;
      });
      widget.onValidationChanged?.call(true, null);
      return;
    }

    // Immediate format validation
    _validateGSTFormat(text);
    widget.onChanged?.call(text);
  }

  void _validateGSTFormat(String gstin) {
    setState(() {
      _isValidating = true;
    });

    // Basic format validation
    final isFormatValid = _isValidGSTFormat(gstin);

    setState(() {
      _isValidating = false;
      _isValid = isFormatValid;
      _validationMessage =
          isFormatValid
              ? 'Valid GST format'
              : 'Invalid GST format. Must be 15 characters (e.g., 27AAPFU0939F1ZV)';
    });

    widget.onValidationChanged?.call(isFormatValid, _validationMessage);
  }

  bool _isValidGSTFormat(String gstin) {
    if (gstin.length != 15) return false;

    // GST format: 2 digits + 5 letters + 4 digits + 1 letter + 1 digit/letter + Z + 1 letter/digit
    final pattern = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[0-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    return pattern.hasMatch(gstin);
  }

  Color _getValidationColor() {
    if (_isValid == null) return Colors.grey;
    return _isValid! ? AppTheme.successColor : AppTheme.errorColor;
  }

  IconData _getValidationIcon() {
    if (_isValidating) return Icons.hourglass_empty;
    if (_isValid == null) return Icons.help_outline;
    return _isValid! ? Icons.check_circle : Icons.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: widget.labelText + (widget.isRequired ? ' *' : ''),
            hintText: widget.hintText ?? 'e.g., 27AAPFU0939F1ZV',
            prefixIcon: const Icon(Icons.business),
            suffixIcon:
                widget.controller.text.isNotEmpty
                    ? _isValidating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : Icon(
                          _getValidationIcon(),
                          color: _getValidationColor(),
                        )
                    : null,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: _getValidationColor()),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _isValid == false ? AppTheme.errorColor : Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    _isValid == false
                        ? AppTheme.errorColor
                        : AppTheme.primaryColor,
                width: 2,
              ),
            ),
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(15),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (widget.isRequired && (value == null || value.trim().isEmpty)) {
              return 'Please enter ${widget.labelText.toLowerCase()}';
            }
            if (value != null &&
                value.isNotEmpty &&
                !_isValidGSTFormat(value)) {
              return 'Invalid GST format';
            }
            return null;
          },
        ),
        if (_validationMessage != null &&
            widget.controller.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                _getValidationIcon(),
                size: 16,
                color: _getValidationColor(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _validationMessage!,
                  style: TextStyle(fontSize: 12, color: _getValidationColor()),
                ),
              ),
            ],
          ),
        ],
        if (widget.controller.text.isNotEmpty && _isValid == true) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 14, color: AppTheme.successColor),
                const SizedBox(width: 4),
                Text(
                  'GST format verified',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
