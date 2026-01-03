import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced form field with validation and helper text for web
class WebFormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCharacterCount;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final bool dense;

  const WebFormField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCharacterCount = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.dense = false,
  });

  @override
  State<WebFormField> createState() => _WebFormFieldState();
}

class _WebFormFieldState extends State<WebFormField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;
  bool _isFocused = false;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      if (!_isFocused) {
        _validate();
      }
    });
  }

  void _validate() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _errorText != null;

    return Semantics(
      label: widget.label != null 
          ? '${widget.label}${widget.validator != null ? ', required' : ''} input field'
          : null,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.label!,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasError ? theme.colorScheme.error : null,
                ),
              ),
            ),
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText && !_showPassword,
            keyboardType: widget.keyboardType,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            autofocus: widget.autofocus,
            textCapitalization: widget.textCapitalization,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.obscureText
                  ? Semantics(
                      label: _showPassword ? 'Hide password' : 'Show password',
                      button: true,
                      child: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        tooltip: _showPassword ? 'Hide password' : 'Show password',
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    )
                  : widget.suffixIcon,
              errorText: _errorText,
              helperText: widget.helperText,
              counterText: widget.showCharacterCount && widget.maxLength != null
                  ? '${_controller.text.length}/${widget.maxLength}'
                  : null,
              contentPadding: widget.contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: widget.dense ? 12 : 16,
                  ),
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
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2,
                ),
              ),
              filled: !widget.enabled || widget.readOnly,
              fillColor: !widget.enabled || widget.readOnly
                  ? theme.disabledColor.withValues(alpha: 0.05)
                  : null,
            ),
            onChanged: (value) {
              widget.onChanged?.call(value);
              if (_errorText != null) {
                _validate();
              }
            },
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
          ),
        ],
      ),
    );
  }
}

/// Common validators for WebFormField
class WebFormValidators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? Function(String?) minLength(int length) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < length) {
        return 'Must be at least $length characters';
      }
      return null;
    };
  }

  static String? Function(String?) maxLength(int length) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (value.length > length) {
        return 'Must be at most $length characters';
      }
      return null;
    };
  }

  static String? numeric(String? value) {
    if (value == null || value.isEmpty) return null;
    
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  static String? Function(String?) min(double minValue) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      
      final number = double.tryParse(value);
      if (number == null) return 'Please enter a valid number';
      
      if (number < minValue) {
        return 'Must be at least $minValue';
      }
      return null;
    };
  }

  static String? Function(String?) max(double maxValue) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      
      final number = double.tryParse(value);
      if (number == null) return 'Please enter a valid number';
      
      if (number > maxValue) {
        return 'Must be at most $maxValue';
      }
      return null;
    };
  }

  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
