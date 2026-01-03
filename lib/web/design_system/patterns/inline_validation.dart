import 'package:flutter/material.dart';
import '../tokens/design_tokens.dart';
import '../components/token_extensions.dart';

/// Validation trigger type
enum ValidationTrigger {
  /// Validate on every change
  onChange,
  
  /// Validate when field loses focus
  onBlur,
  
  /// Validate on submit only
  onSubmit,
  
  /// Validate on change after first blur
  onChangeAfterBlur,
}

/// Field validation state
enum FieldValidationState {
  initial,
  validating,
  valid,
  invalid,
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final FieldValidationState state;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.state = FieldValidationState.initial,
  });

  const ValidationResult.valid()
      : isValid = true,
        errorMessage = null,
        state = FieldValidationState.valid;

  const ValidationResult.invalid(this.errorMessage)
      : isValid = false,
        state = FieldValidationState.invalid;

  const ValidationResult.validating()
      : isValid = false,
        errorMessage = null,
        state = FieldValidationState.validating;
}

/// Inline validation controller
class InlineValidationController extends ChangeNotifier {
  final Map<String, ValidationResult> _validationResults = {};
  final Map<String, bool> _hasBlurred = {};
  final ValidationTrigger trigger;

  InlineValidationController({
    this.trigger = ValidationTrigger.onBlur,
  });

  /// Get validation result for a field
  ValidationResult? getValidationResult(String fieldName) {
    return _validationResults[fieldName];
  }

  /// Check if field has been blurred
  bool hasBlurred(String fieldName) {
    return _hasBlurred[fieldName] ?? false;
  }

  /// Mark field as blurred
  void markBlurred(String fieldName) {
    _hasBlurred[fieldName] = true;
    notifyListeners();
  }

  /// Set validation result for a field
  void setValidationResult(String fieldName, ValidationResult result) {
    _validationResults[fieldName] = result;
    notifyListeners();
  }

  /// Clear validation result for a field
  void clearValidationResult(String fieldName) {
    _validationResults.remove(fieldName);
    notifyListeners();
  }

  /// Clear all validation results
  void clearAll() {
    _validationResults.clear();
    _hasBlurred.clear();
    notifyListeners();
  }

  /// Check if all fields are valid
  bool get isValid {
    return _validationResults.values.every((result) => result.isValid);
  }

  /// Get all error messages
  Map<String, String> get errors {
    final errors = <String, String>{};
    _validationResults.forEach((key, value) {
      if (!value.isValid && value.errorMessage != null) {
        errors[key] = value.errorMessage!;
      }
    });
    return errors;
  }

  @override
  void dispose() {
    _validationResults.clear();
    _hasBlurred.clear();
    super.dispose();
  }
}

/// Validated field widget with inline validation
class ValidatedField extends StatefulWidget {
  final String fieldName;
  final String label;
  final String? placeholder;
  final String? helperText;
  final String value;
  final ValueChanged<String> onChanged;
  final List<String? Function(String)> validators;
  final InlineValidationController? controller;
  final ValidationTrigger? trigger;
  final bool required;
  final bool disabled;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final int? maxLines;
  final FocusNode? focusNode;

  const ValidatedField({
    super.key,
    required this.fieldName,
    required this.label,
    this.placeholder,
    this.helperText,
    required this.value,
    required this.onChanged,
    this.validators = const [],
    this.controller,
    this.trigger,
    this.required = false,
    this.disabled = false,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  State<ValidatedField> createState() => _ValidatedFieldState();
}

class _ValidatedFieldState extends State<ValidatedField> {
  late FocusNode _focusNode;
  late TextEditingController _textController;
  ValidationResult? _validationResult;
  bool _hasBlurred = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _textController = TextEditingController(text: widget.value);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(ValidatedField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _textController.text) {
      _textController.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _textController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && !_hasBlurred) {
      setState(() {
        _hasBlurred = true;
      });
      widget.controller?.markBlurred(widget.fieldName);
      _validateField(widget.value);
    }
  }

  ValidationTrigger get _effectiveTrigger {
    return widget.trigger ?? 
           widget.controller?.trigger ?? 
           ValidationTrigger.onBlur;
  }

  bool get _shouldValidate {
    switch (_effectiveTrigger) {
      case ValidationTrigger.onChange:
        return true;
      case ValidationTrigger.onBlur:
        return _hasBlurred;
      case ValidationTrigger.onSubmit:
        return false;
      case ValidationTrigger.onChangeAfterBlur:
        return _hasBlurred;
    }
  }

  void _validateField(String value) {
    if (!_shouldValidate) return;

    // Required validation
    if (widget.required && value.trim().isEmpty) {
      final result = ValidationResult.invalid('This field is required');
      setState(() {
        _validationResult = result;
      });
      widget.controller?.setValidationResult(widget.fieldName, result);
      return;
    }

    // Custom validators
    for (final validator in widget.validators) {
      final error = validator(value);
      if (error != null) {
        final result = ValidationResult.invalid(error);
        setState(() {
          _validationResult = result;
        });
        widget.controller?.setValidationResult(widget.fieldName, result);
        return;
      }
    }

    // Valid
    final result = ValidationResult.valid();
    setState(() {
      _validationResult = result;
    });
    widget.controller?.setValidationResult(widget.fieldName, result);
  }

  void _handleChange(String value) {
    widget.onChanged(value);
    
    if (_effectiveTrigger == ValidationTrigger.onChange ||
        (_effectiveTrigger == ValidationTrigger.onChangeAfterBlur && _hasBlurred)) {
      _validateField(value);
    } else if (_validationResult != null && !_validationResult!.isValid) {
      // Clear error on change if there was an error
      _validateField(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasError = _validationResult != null && !_validationResult!.isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(tokens),
        SizedBox(height: 8),
        _buildInputField(tokens, hasError),
        if (hasError || widget.helperText != null)
          SizedBox(height: 8),
        if (hasError)
          _buildErrorMessage(tokens)
        else if (widget.helperText != null)
          _buildHelperText(tokens),
      ],
    );
  }

  Widget _buildLabel(DesignTokens tokens) {
    return Row(
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: tokens.colors.neutral.s900,
          ),
        ),
        if (widget.required) ...[
          SizedBox(width: 4),
          Text(
            '*',
            style: TextStyle(
              color: tokens.colors.error.s500,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField(DesignTokens tokens, bool hasError) {
    Color borderColor;
    if (widget.disabled) {
      borderColor = tokens.colors.neutral.s300;
    } else if (hasError) {
      borderColor = tokens.colors.error.s500;
    } else if (_focusNode.hasFocus) {
      borderColor = tokens.colors.primary.s500;
    } else if (_validationResult?.state == FieldValidationState.valid) {
      borderColor = tokens.colors.success.s500;
    } else {
      borderColor = tokens.colors.neutral.s400;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.disabled 
            ? tokens.colors.neutral.s100 
            : tokens.colors.surface.background,
        border: Border.all(
          color: borderColor,
          width: _focusNode.hasFocus ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(tokens.borderRadius.base),
      ),
      child: Row(
        children: [
          if (widget.prefixIcon != null) ...[
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: IconTheme(
                data: IconThemeData(
                  color: widget.disabled 
                      ? tokens.colors.neutral.s400 
                      : tokens.colors.neutral.s600,
                  size: 20,
                ),
                child: widget.prefixIcon!,
              ),
            ),
            SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              enabled: !widget.disabled,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              onChanged: _handleChange,
              style: TextStyle(
                color: widget.disabled 
                    ? tokens.colors.neutral.s500 
                    : tokens.colors.neutral.s900,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: TextStyle(
                  color: tokens.colors.neutral.s500,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.prefixIcon != null ? 0 : 12,
                  vertical: 12,
                ),
                counterText: '',
              ),
            ),
          ),
          if (_validationResult?.state == FieldValidationState.valid) ...[
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.check_circle,
                color: tokens.colors.success.s500,
                size: 20,
              ),
            ),
          ] else if (widget.suffixIcon != null) ...[
            SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: IconTheme(
                data: IconThemeData(
                  color: widget.disabled 
                      ? tokens.colors.neutral.s400 
                      : tokens.colors.neutral.s600,
                  size: 20,
                ),
                child: widget.suffixIcon!,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorMessage(DesignTokens tokens) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.error_outline,
          size: 16,
          color: tokens.colors.error.s500,
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            _validationResult!.errorMessage!,
            style: TextStyle(
              color: tokens.colors.error.s500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelperText(DesignTokens tokens) {
    return Text(
      widget.helperText!,
      style: TextStyle(
        color: tokens.colors.neutral.s600,
        fontSize: 12,
      ),
    );
  }
}

/// Validation summary widget
/// 
/// Displays a summary of all validation errors at the top of a form
class ValidationSummary extends StatelessWidget {
  final Map<String, String> errors;
  final VoidCallback? onDismiss;
  final bool showIcon;

  const ValidationSummary({
    super.key,
    required this.errors,
    this.onDismiss,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    if (errors.isEmpty) return const SizedBox.shrink();

    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.colors.error.s50,
        border: Border.all(
          color: tokens.colors.error.s500,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(tokens.borderRadius.base),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showIcon)
                Icon(
                  Icons.error_outline,
                  color: tokens.colors.error.s500,
                  size: 20,
                ),
              if (showIcon) SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please fix the following errors:',
                  style: TextStyle(
                    color: tokens.colors.error.s900,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  color: tokens.colors.error.s500,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 12),
          ...errors.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: tokens.colors.error.s700,
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: tokens.colors.error.s700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Field state indicator widget
/// 
/// Shows visual indicators for field states (default, focus, error, success, disabled)
class FieldStateIndicator extends StatelessWidget {
  final FieldValidationState state;
  final bool isFocused;
  final bool isDisabled;
  final double size;

  const FieldStateIndicator({
    super.key,
    required this.state,
    this.isFocused = false,
    this.isDisabled = false,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (isDisabled) {
      return Icon(
        Icons.block,
        size: size,
        color: tokens.colors.neutral.s400,
      );
    }

    switch (state) {
      case FieldValidationState.valid:
        return Icon(
          Icons.check_circle,
          size: size,
          color: tokens.colors.success.s500,
        );
      
      case FieldValidationState.invalid:
        return Icon(
          Icons.error,
          size: size,
          color: tokens.colors.error.s500,
        );
      
      case FieldValidationState.validating:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(tokens.colors.primary.s500),
          ),
        );
      
      case FieldValidationState.initial:
        if (isFocused) {
          return Icon(
            Icons.edit,
            size: size,
            color: tokens.colors.primary.s500,
          );
        }
        return SizedBox(width: size, height: size);
    }
  }
}
