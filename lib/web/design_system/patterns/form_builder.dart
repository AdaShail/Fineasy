import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/web_button.dart';
import '../tokens/design_tokens.dart';
import '../components/token_extensions.dart';

/// Form field type enumeration
enum FormFieldType {
  text,
  email,
  password,
  number,
  tel,
  url,
  search,
  textarea,
  select,
  checkbox,
  radio,
  date,
  time,
  dateTime,
}

/// Form field configuration
class FormFieldConfig {
  final String name;
  final String label;
  final FormFieldType type;
  final bool required;
  final String? placeholder;
  final String? helperText;
  final dynamic initialValue;
  final List<FormFieldValidator> validators;
  final List<FormFieldOption>? options; // For select, radio, checkbox
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? icon;
  final bool disabled;
  final String? dependsOn; // Show field only if another field has value
  final bool Function(Map<String, dynamic> formValues)? visibilityCondition;

  const FormFieldConfig({
    required this.name,
    required this.label,
    required this.type,
    this.required = false,
    this.placeholder,
    this.helperText,
    this.initialValue,
    this.validators = const [],
    this.options,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.keyboardType,
    this.inputFormatters,
    this.icon,
    this.disabled = false,
    this.dependsOn,
    this.visibilityCondition,
  });
}

/// Form field option for select, radio, checkbox
class FormFieldOption {
  final String label;
  final dynamic value;
  final bool disabled;

  const FormFieldOption({
    required this.label,
    required this.value,
    this.disabled = false,
  });
}

/// Form field validator function type
typedef FormFieldValidator = String? Function(dynamic value);

/// Form submission callback
typedef FormSubmitCallback = Future<void> Function(Map<String, dynamic> values);

/// Form Builder Widget
/// 
/// A comprehensive form builder that creates forms from configuration.
/// Handles validation, state management, and submission.
/// 
/// Example:
/// ```dart
/// WebFormBuilder(
///   fields: [
///     FormFieldConfig(
///       name: 'email',
///       label: 'Email',
///       type: FormFieldType.email,
///       required: true,
///       validators: [FormValidators.email],
///     ),
///   ],
///   onSubmit: (values) async {
///     // Handle form submission
///   },
/// )
/// ```
class WebFormBuilder extends StatefulWidget {
  final List<FormFieldConfig> fields;
  final FormSubmitCallback onSubmit;
  final VoidCallback? onCancel;
  final String submitLabel;
  final String? cancelLabel;
  final bool loading;
  final Map<String, dynamic>? initialValues;
  final EdgeInsetsGeometry? padding;
  final double fieldSpacing;
  final CrossAxisAlignment crossAxisAlignment;

  const WebFormBuilder({
    super.key,
    required this.fields,
    required this.onSubmit,
    this.onCancel,
    this.submitLabel = 'Submit',
    this.cancelLabel,
    this.loading = false,
    this.initialValues,
    this.padding,
    this.fieldSpacing = 24.0,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  @override
  State<WebFormBuilder> createState() => _WebFormBuilderState();
}

class _WebFormBuilderState extends State<WebFormBuilder> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formValues;
  late Map<String, String?> _fieldErrors;
  late Map<String, FocusNode> _focusNodes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeFormState();
  }

  void _initializeFormState() {
    _formValues = {};
    _fieldErrors = {};
    _focusNodes = {};

    for (final field in widget.fields) {
      // Initialize form values
      _formValues[field.name] = widget.initialValues?[field.name] ?? 
                                 field.initialValue ?? 
                                 _getDefaultValue(field.type);
      
      // Initialize error state
      _fieldErrors[field.name] = null;
      
      // Initialize focus nodes
      _focusNodes[field.name] = FocusNode();
    }
  }

  dynamic _getDefaultValue(FormFieldType type) {
    switch (type) {
      case FormFieldType.checkbox:
        return false;
      case FormFieldType.select:
      case FormFieldType.radio:
        return null;
      default:
        return '';
    }
  }

  @override
  void dispose() {
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  bool _isFieldVisible(FormFieldConfig field) {
    // Check visibility condition
    if (field.visibilityCondition != null) {
      return field.visibilityCondition!(_formValues);
    }

    // Check dependsOn condition
    if (field.dependsOn != null) {
      final dependentValue = _formValues[field.dependsOn];
      return dependentValue != null && 
             dependentValue.toString().isNotEmpty &&
             dependentValue != false;
    }

    return true;
  }

  String? _validateField(FormFieldConfig field, dynamic value) {
    // Required validation
    if (field.required) {
      if (value == null || 
          (value is String && value.trim().isEmpty) ||
          (value is bool && !value)) {
        return 'This field is required';
      }
    }

    // Custom validators
    for (final validator in field.validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }

    return null;
  }

  void _handleFieldChange(String fieldName, dynamic value) {
    setState(() {
      _formValues[fieldName] = value;
      
      // Clear error on change
      if (_fieldErrors[fieldName] != null) {
        _fieldErrors[fieldName] = null;
      }
    });
  }

  void _handleFieldBlur(String fieldName) {
    final field = widget.fields.firstWhere((f) => f.name == fieldName);
    final error = _validateField(field, _formValues[fieldName]);
    
    setState(() {
      _fieldErrors[fieldName] = error;
    });
  }

  bool _validateForm() {
    bool isValid = true;
    final errors = <String, String?>{};

    for (final field in widget.fields) {
      if (!_isFieldVisible(field)) continue;

      final error = _validateField(field, _formValues[field.name]);
      errors[field.name] = error;
      
      if (error != null) {
        isValid = false;
      }
    }

    setState(() {
      _fieldErrors = errors;
    });

    // Focus first error field
    if (!isValid) {
      final firstErrorField = widget.fields.firstWhere(
        (field) => _fieldErrors[field.name] != null,
      );
      _focusNodes[firstErrorField.name]?.requestFocus();
    }

    return isValid;
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting || widget.loading) return;

    if (!_validateForm()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Only submit visible fields
      final visibleValues = <String, dynamic>{};
      for (final field in widget.fields) {
        if (_isFieldVisible(field)) {
          visibleValues[field.name] = _formValues[field.name];
        }
      }

      await widget.onSubmit(visibleValues);
    } catch (e) {
      // Error handling is done by parent
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Form(
      key: _formKey,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.all(tokens.spacing[24] ?? 24),
        child: Column(
          crossAxisAlignment: widget.crossAxisAlignment,
          children: [
            // Form fields
            ...widget.fields.map((field) {
              if (!_isFieldVisible(field)) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.only(bottom: widget.fieldSpacing),
                child: _buildField(field),
              );
            }),

            // Form actions
            SizedBox(height: tokens.spacing[16] ?? 16),
            _buildFormActions(tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildField(FormFieldConfig field) {
    switch (field.type) {
      case FormFieldType.text:
      case FormFieldType.email:
      case FormFieldType.password:
      case FormFieldType.number:
      case FormFieldType.tel:
      case FormFieldType.url:
      case FormFieldType.search:
        return _buildTextInput(field);
      
      case FormFieldType.textarea:
        return _buildTextArea(field);
      
      case FormFieldType.select:
        return _buildSelect(field);
      
      case FormFieldType.checkbox:
        return _buildCheckbox(field);
      
      case FormFieldType.radio:
        return _buildRadioGroup(field);
      
      case FormFieldType.date:
      case FormFieldType.time:
      case FormFieldType.dateTime:
        return _buildDateTimeField(field);
    }
  }

  Widget _buildTextInput(FormFieldConfig field) {
    return WebFormField(
      label: field.label,
      hint: field.placeholder,
      helperText: field.helperText,
      initialValue: _formValues[field.name]?.toString() ?? '',
      enabled: !field.disabled,
      obscureText: field.type == FormFieldType.password,
      keyboardType: _getKeyboardType(field),
      maxLength: field.maxLength,
      showCharacterCount: field.maxLength != null,
      prefixIcon: field.icon,
      inputFormatters: field.inputFormatters,
      focusNode: _focusNodes[field.name],
      validator: (value) => _fieldErrors[field.name],
      onChanged: (value) => _handleFieldChange(field.name, value),
      onSubmitted: (_) => _handleFieldBlur(field.name),
    );
  }

  Widget _buildTextArea(FormFieldConfig field) {
    return WebFormField(
      label: field.label,
      hint: field.placeholder,
      helperText: field.helperText,
      initialValue: _formValues[field.name]?.toString() ?? '',
      enabled: !field.disabled,
      maxLines: field.maxLines ?? 5,
      minLines: field.minLines ?? 3,
      maxLength: field.maxLength,
      showCharacterCount: field.maxLength != null,
      focusNode: _focusNodes[field.name],
      validator: (value) => _fieldErrors[field.name],
      onChanged: (value) => _handleFieldChange(field.name, value),
    );
  }

  Widget _buildSelect(FormFieldConfig field) {
    final tokens = context.tokens;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              field.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (field.required)
              Text(
                ' *',
                style: TextStyle(color: tokens.colors.error.s500),
              ),
          ],
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<dynamic>(
          value: _formValues[field.name],
          decoration: InputDecoration(
            hintText: field.placeholder,
            helperText: field.helperText,
            errorText: _fieldErrors[field.name],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.borderRadius.base),
            ),
          ),
          items: field.options?.map((option) {
            return DropdownMenuItem(
              value: option.value,
              enabled: !option.disabled,
              child: Text(option.label),
            );
          }).toList(),
          onChanged: field.disabled
              ? null
              : (value) => _handleFieldChange(field.name, value),
          focusNode: _focusNodes[field.name],
        ),
      ],
    );
  }

  Widget _buildCheckbox(FormFieldConfig field) {
    final tokens = context.tokens;
    
    return CheckboxListTile(
      title: Text(field.label),
      subtitle: field.helperText != null ? Text(field.helperText!) : null,
      value: _formValues[field.name] as bool? ?? false,
      enabled: !field.disabled,
      onChanged: (value) => _handleFieldChange(field.name, value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      secondary: _fieldErrors[field.name] != null
          ? Icon(Icons.error, color: tokens.colors.error.s500)
          : null,
    );
  }

  Widget _buildRadioGroup(FormFieldConfig field) {
    final tokens = context.tokens;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              field.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (field.required)
              Text(
                ' *',
                style: TextStyle(color: tokens.colors.error.s500),
              ),
          ],
        ),
        if (field.helperText != null) ...[
          SizedBox(height: 4),
          Text(
            field.helperText!,
            style: TextStyle(fontSize: 12, color: tokens.colors.neutral.s600),
          ),
        ],
        SizedBox(height: 8),
        ...?field.options?.map((option) {
          return RadioListTile<dynamic>(
            title: Text(option.label),
            value: option.value,
            groupValue: _formValues[field.name],
            enabled: !field.disabled && !option.disabled,
            onChanged: (value) => _handleFieldChange(field.name, value),
          );
        }),
        if (_fieldErrors[field.name] != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              _fieldErrors[field.name]!,
              style: TextStyle(
                color: tokens.colors.error.s500,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateTimeField(FormFieldConfig field) {
    return WebFormField(
      label: field.label,
      hint: field.placeholder,
      helperText: field.helperText,
      initialValue: _formValues[field.name]?.toString() ?? '',
      enabled: !field.disabled,
      readOnly: true,
      suffixIcon: Icon(Icons.calendar_today),
      focusNode: _focusNodes[field.name],
      validator: (value) => _fieldErrors[field.name],
      onChanged: (value) => _handleFieldChange(field.name, value),
    );
  }

  Widget _buildFormActions(DesignTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.cancelLabel != null && widget.onCancel != null) ...[
          WebButton(
            variant: WebButtonVariant.outline,
            size: WebButtonSize.md,
            onPressed: widget.onCancel,
            disabled: _isSubmitting || widget.loading,
            child: Text(widget.cancelLabel!),
          ),
          SizedBox(width: tokens.spacing[12] ?? 12),
        ],
        WebButton(
          variant: WebButtonVariant.primary,
          size: WebButtonSize.md,
          onPressed: _handleSubmit,
          loading: _isSubmitting || widget.loading,
          disabled: _isSubmitting || widget.loading,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType(FormFieldConfig field) {
    if (field.keyboardType != null) return field.keyboardType!;

    switch (field.type) {
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.number:
        return TextInputType.number;
      case FormFieldType.tel:
        return TextInputType.phone;
      case FormFieldType.url:
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }
}

/// Common form validators
class FormValidators {
  /// Required field validator
  static String? required(dynamic value) {
    if (value == null ||
        (value is String && value.trim().isEmpty) ||
        (value is bool && !value)) {
      return 'This field is required';
    }
    return null;
  }

  /// Email validator
  static String? email(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.toString())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// URL validator
  static String? url(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value.toString())) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Phone number validator
  static String? phone(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');

    if (!phoneRegex.hasMatch(value.toString())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Minimum length validator
  static FormFieldValidator minLength(int length) {
    return (dynamic value) {
      if (value == null || value.toString().isEmpty) return null;

      if (value.toString().length < length) {
        return 'Must be at least $length characters';
      }
      return null;
    };
  }

  /// Maximum length validator
  static FormFieldValidator maxLength(int length) {
    return (dynamic value) {
      if (value == null || value.toString().isEmpty) return null;

      if (value.toString().length > length) {
        return 'Must be at most $length characters';
      }
      return null;
    };
  }

  /// Numeric validator
  static String? numeric(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;

    if (double.tryParse(value.toString()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Minimum value validator
  static FormFieldValidator min(double minValue) {
    return (dynamic value) {
      if (value == null || value.toString().isEmpty) return null;

      final number = double.tryParse(value.toString());
      if (number == null) return 'Please enter a valid number';

      if (number < minValue) {
        return 'Must be at least $minValue';
      }
      return null;
    };
  }

  /// Maximum value validator
  static FormFieldValidator max(double maxValue) {
    return (dynamic value) {
      if (value == null || value.toString().isEmpty) return null;

      final number = double.tryParse(value.toString());
      if (number == null) return 'Please enter a valid number';

      if (number > maxValue) {
        return 'Must be at most $maxValue';
      }
      return null;
    };
  }

  /// Pattern validator
  static FormFieldValidator pattern(RegExp regex, String message) {
    return (dynamic value) {
      if (value == null || value.toString().isEmpty) return null;

      if (!regex.hasMatch(value.toString())) {
        return message;
      }
      return null;
    };
  }

  /// Combine multiple validators
  static FormFieldValidator combine(List<FormFieldValidator> validators) {
    return (dynamic value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

/// WebFormField widget (simplified version for form builder)
class WebFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? initialValue;
  final bool enabled;
  final bool obscureText;
  final bool readOnly;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCharacterCount;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const WebFormField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.initialValue,
    this.enabled = true,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCharacterCount = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final errorText = validator?.call(initialValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        TextFormField(
          initialValue: initialValue,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            counterText: showCharacterCount && maxLength != null ? '' : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.borderRadius.base),
            ),
          ),
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
        ),
      ],
    );
  }
}
