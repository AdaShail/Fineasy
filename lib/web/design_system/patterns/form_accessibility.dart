import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/design_tokens.dart';
import '../components/token_extensions.dart';

/// Accessible form field with proper label associations and ARIA attributes
/// 
/// Implements WCAG 2.1 AA standards:
/// - Proper label associations
/// - ARIA attributes for validation states
/// - Keyboard navigation support
/// - Focus management
class AccessibleFormField extends StatefulWidget {
  final String id;
  final String label;
  final String? placeholder;
  final String? helperText;
  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool required;
  final bool disabled;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final int? maxLines;
  final FocusNode? focusNode;
  final String? ariaLabel;
  final String? ariaDescribedBy;
  final List<TextInputFormatter>? inputFormatters;

  const AccessibleFormField({
    super.key,
    required this.id,
    required this.label,
    this.placeholder,
    this.helperText,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.required = false,
    this.disabled = false,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.focusNode,
    this.ariaLabel,
    this.ariaDescribedBy,
    this.inputFormatters,
  });

  @override
  State<AccessibleFormField> createState() => _AccessibleFormFieldState();
}

class _AccessibleFormFieldState extends State<AccessibleFormField> {
  late FocusNode _focusNode;
  late TextEditingController _textController;
  final String _helperId = UniqueKey().toString();
  final String _errorId = UniqueKey().toString();

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _textController = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(AccessibleFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _textController.text) {
      _textController.text = widget.value;
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasError = widget.errorText != null;

    return Semantics(
      container: true,
      label: widget.ariaLabel ?? widget.label,
      textField: true,
      enabled: !widget.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with proper association
          _buildLabel(tokens),
          SizedBox(height: 8),
          
          // Input field with ARIA attributes
          _buildInputField(tokens, hasError),
          
          // Helper text or error message
          if (hasError || widget.helperText != null)
            SizedBox(height: 8),
          
          if (hasError)
            _buildErrorMessage(tokens)
          else if (widget.helperText != null)
            _buildHelperText(tokens),
        ],
      ),
    );
  }

  Widget _buildLabel(DesignTokens tokens) {
    return Semantics(
      label: '${widget.label}${widget.required ? ', required' : ''}',
      child: Row(
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
            Semantics(
              label: 'required',
              child: Text(
                '*',
                style: TextStyle(
                  color: tokens.colors.error.s500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
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
    } else {
      borderColor = tokens.colors.neutral.s400;
    }

    return Semantics(
      textField: true,
      enabled: !widget.disabled,
      child: AnimatedContainer(
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
        child: TextField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: !widget.disabled,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
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
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            counterText: '',
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(DesignTokens tokens) {
    return Semantics(
      liveRegion: true,
      label: 'Error: ${widget.errorText}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: tokens.colors.error.s500,
            semanticLabel: 'Error',
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.errorText!,
              key: ValueKey(_errorId),
              style: TextStyle(
                color: tokens.colors.error.s500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperText(DesignTokens tokens) {
    return Semantics(
      label: 'Help: ${widget.helperText}',
      child: Text(
        widget.helperText!,
        key: ValueKey(_helperId),
        style: TextStyle(
          color: tokens.colors.neutral.s600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Skip link widget for long forms
/// 
/// Allows keyboard users to skip to main content or specific form sections
class FormSkipLink extends StatelessWidget {
  final String label;
  final String targetId;
  final GlobalKey targetKey;

  const FormSkipLink({
    super.key,
    required this.label,
    required this.targetId,
    required this.targetKey,
  });

  void _skipToTarget(BuildContext context) {
    final targetContext = targetKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Focus the target if it's focusable
      final focusNode = Focus.of(targetContext);
      focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      button: true,
      label: label,
      child: Focus(
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;
            
            return AnimatedOpacity(
              opacity: isFocused ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: isFocused ? 40 : 0,
                child: isFocused
                    ? ElevatedButton(
                        onPressed: () => _skipToTarget(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.colors.primary.s500,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(label),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Form section with skip link target
class FormSection extends StatelessWidget {
  final GlobalKey sectionKey;
  final String title;
  final String? description;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const FormSection({
    super.key,
    required this.sectionKey,
    required this.title,
    this.description,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      container: true,
      label: title,
      child: Focus(
        child: Container(
          key: sectionKey,
          padding: padding ?? EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: tokens.colors.neutral.s900,
                ),
              ),
              if (description != null) ...[
                SizedBox(height: 8),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: tokens.colors.neutral.s600,
                  ),
                ),
              ],
              SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Focus manager for form error handling
/// 
/// Manages focus when validation errors occur
class FormFocusManager {
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, GlobalKey> _fieldKeys = {};

  /// Register a field with its focus node and key
  void registerField(String fieldName, FocusNode focusNode, GlobalKey fieldKey) {
    _focusNodes[fieldName] = focusNode;
    _fieldKeys[fieldName] = fieldKey;
  }

  /// Unregister a field
  void unregisterField(String fieldName) {
    _focusNodes.remove(fieldName);
    _fieldKeys.remove(fieldName);
  }

  /// Focus the first field with an error
  void focusFirstError(List<String> errorFields) {
    if (errorFields.isEmpty) return;

    final firstErrorField = errorFields.first;
    final focusNode = _focusNodes[firstErrorField];
    final fieldKey = _fieldKeys[firstErrorField];

    if (focusNode != null && fieldKey != null) {
      // Scroll to field
      final context = fieldKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.2, // Position near top of viewport
        );
      }

      // Focus field
      Future.delayed(Duration(milliseconds: 350), () {
        focusNode.requestFocus();
      });
    }
  }

  /// Focus a specific field
  void focusField(String fieldName) {
    final focusNode = _focusNodes[fieldName];
    final fieldKey = _fieldKeys[fieldName];

    if (focusNode != null && fieldKey != null) {
      final context = fieldKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

      Future.delayed(Duration(milliseconds: 350), () {
        focusNode.requestFocus();
      });
    }
  }

  /// Clear all registered fields
  void dispose() {
    _focusNodes.clear();
    _fieldKeys.clear();
  }
}

/// Accessible form with comprehensive accessibility features
class AccessibleForm extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback? onSubmit;
  final String? formLabel;
  final String? formDescription;
  final List<FormSkipLink>? skipLinks;
  final EdgeInsetsGeometry? padding;

  const AccessibleForm({
    super.key,
    required this.children,
    this.onSubmit,
    this.formLabel,
    this.formDescription,
    this.skipLinks,
    this.padding,
  });

  @override
  State<AccessibleForm> createState() => _AccessibleFormState();
}

class _AccessibleFormState extends State<AccessibleForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      container: true,
      label: widget.formLabel ?? 'Form',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skip links
            if (widget.skipLinks != null && widget.skipLinks!.isNotEmpty) ...[
              ...widget.skipLinks!,
              SizedBox(height: 16),
            ],

            // Form description
            if (widget.formDescription != null) ...[
              Semantics(
                label: widget.formDescription,
                child: Text(
                  widget.formDescription!,
                  style: TextStyle(
                    fontSize: 14,
                    color: tokens.colors.neutral.s600,
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],

            // Form content
            Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keyboard navigation helper for forms
class FormKeyboardNavigation {
  /// Handle Tab key navigation
  static KeyEventResult handleTabKey(
    FocusNode currentFocus,
    List<FocusNode> allFocusNodes,
    bool isShiftPressed,
  ) {
    final currentIndex = allFocusNodes.indexOf(currentFocus);
    if (currentIndex == -1) return KeyEventResult.ignored;

    if (isShiftPressed) {
      // Move to previous field
      if (currentIndex > 0) {
        allFocusNodes[currentIndex - 1].requestFocus();
        return KeyEventResult.handled;
      }
    } else {
      // Move to next field
      if (currentIndex < allFocusNodes.length - 1) {
        allFocusNodes[currentIndex + 1].requestFocus();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  /// Handle Enter key for form submission
  static KeyEventResult handleEnterKey(
    FocusNode currentFocus,
    VoidCallback onSubmit,
  ) {
    onSubmit();
    return KeyEventResult.handled;
  }

  /// Handle Escape key to clear/cancel
  static KeyEventResult handleEscapeKey(
    FocusNode currentFocus,
    VoidCallback onCancel,
  ) {
    onCancel();
    return KeyEventResult.handled;
  }
}

/// ARIA live region for form announcements
class FormLiveRegion extends StatelessWidget {
  final String message;
  final bool isPolite;

  const FormLiveRegion({
    super.key,
    required this.message,
    this.isPolite = true,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();

    return Semantics(
      liveRegion: true,
      label: message,
      child: SizedBox(
        width: 0,
        height: 0,
        child: Text(
          message,
          style: TextStyle(fontSize: 0),
        ),
      ),
    );
  }
}
