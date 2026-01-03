import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/design_tokens.dart';
import 'token_extensions.dart';

/// Input icon position
enum WebInputIconPosition {
  left,
  right,
}

/// Web Input Component
/// 
/// A comprehensive input component with validation, error states, and accessibility.
/// Implements WCAG 2.1 AA standards with proper labels and ARIA attributes.
/// 
/// Example:
/// ```dart
/// WebInput(
///   label: 'Email',
///   type: TextInputType.emailAddress,
///   value: email,
///   onChanged: (value) => setState(() => email = value),
///   error: emailError,
/// )
/// ```
class WebInput extends StatefulWidget {
  final String label;
  final String? placeholder;
  final String value;
  final ValueChanged<String> onChanged;
  final String? error;
  final String? helperText;
  final bool required;
  final bool disabled;
  final Widget? icon;
  final WebInputIconPosition iconPosition;
  final int? maxLength;
  final bool showCharCount;
  final TextInputType type;
  final bool obscureText;
  final String? autoComplete;
  final String? ariaDescribedBy;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const WebInput({
    Key? key,
    required this.label,
    this.placeholder,
    required this.value,
    required this.onChanged,
    this.error,
    this.helperText,
    this.required = false,
    this.disabled = false,
    this.icon,
    this.iconPosition = WebInputIconPosition.left,
    this.maxLength,
    this.showCharCount = false,
    this.type = TextInputType.text,
    this.obscureText = false,
    this.autoComplete,
    this.ariaDescribedBy,
    this.inputFormatters,
    this.focusNode,
  }) : super(key: key);

  @override
  State<WebInput> createState() => _WebInputState();
}

class _WebInputState extends State<WebInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(WebInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    return Semantics(
      label: widget.label,
      textField: true,
      enabled: !widget.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLabel(tokens),
          SizedBox(height: tokens.spacing['2']!),
          _buildInputField(tokens, hasError),
          if (hasError || widget.helperText != null || widget.showCharCount)
            SizedBox(height: tokens.spacing['1']!),
          if (hasError)
            _buildErrorMessage(tokens)
          else if (widget.helperText != null)
            _buildHelperText(tokens),
          if (widget.showCharCount && widget.maxLength != null)
            _buildCharCount(tokens),
        ],
      ),
    );
  }

  Widget _buildLabel(DesignTokens tokens) {
    return Row(
      children: [
        Text(
          widget.label,
          style: TextStyle(fontSize: tokens.typography.fontSize['sm']!).copyWith(
            fontWeight: tokens.typography.fontWeight['medium']!,
            color: tokens.colors.neutral.s900,
          ),
        ),
        if (widget.required) ...[
          SizedBox(width: tokens.spacing['1']!),
          Text(
            '*',
            style: TextStyle(fontSize: tokens.typography.fontSize['sm']!).copyWith(
              color: tokens.colors.error.s500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField(DesignTokens tokens, bool hasError) {
    final colors = tokens.colors;
    
    Color borderColor;
    if (widget.disabled) {
      borderColor = colors.neutral.s300;
    } else if (hasError) {
      borderColor = colors.error.s500;
    } else if (_isFocused) {
      borderColor = colors.primary.s500;
    } else {
      borderColor = colors.neutral.s400;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.disabled ? colors.neutral.s100 : colors.surface.background,
        border: Border.all(
          color: borderColor,
          width: _isFocused ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(tokens.borderRadius.base),
        boxShadow: _isFocused && !widget.disabled
            ? [
                BoxShadow(
                  color: (hasError ? colors.error.s500 : colors.primary.s500)
                      .withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          if (widget.icon != null && widget.iconPosition == WebInputIconPosition.left) ...[
            Padding(
              padding: EdgeInsets.only(left: tokens.spacing['3']!),
              child: IconTheme(
                data: IconThemeData(
                  color: widget.disabled ? colors.neutral.s400 : colors.neutral.s600,
                  size: 20,
                ),
                child: widget.icon!,
              ),
            ),
            SizedBox(width: tokens.spacing['2']!),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !widget.disabled,
              obscureText: widget.obscureText,
              keyboardType: widget.type,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              onChanged: widget.onChanged,
              style: TextStyle(fontSize: tokens.typography.fontSize['base']!).copyWith(
                color: widget.disabled ? colors.neutral.s500 : colors.neutral.s900,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: TextStyle(fontSize: tokens.typography.fontSize['base']!).copyWith(
                  color: colors.neutral.s500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: widget.icon != null && widget.iconPosition == WebInputIconPosition.left
                      ? 0
                      : tokens.spacing['3']!,
                  vertical: tokens.spacing['3']!,
                ),
                counterText: '', // Hide default counter
              ),
            ),
          ),
          if (widget.icon != null && widget.iconPosition == WebInputIconPosition.right) ...[
            SizedBox(width: tokens.spacing['2']!),
            Padding(
              padding: EdgeInsets.only(right: tokens.spacing['3']!),
              child: IconTheme(
                data: IconThemeData(
                  color: widget.disabled ? colors.neutral.s400 : colors.neutral.s600,
                  size: 20,
                ),
                child: widget.icon!,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorMessage(DesignTokens tokens) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          size: 16,
          color: tokens.colors.error.s500,
        ),
        SizedBox(width: tokens.spacing['1']!),
        Expanded(
          child: Text(
            widget.error!,
            style: TextStyle(fontSize: tokens.typography.fontSize['sm']!).copyWith(
              color: tokens.colors.error.s500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelperText(DesignTokens tokens) {
    return Text(
      widget.helperText!,
      style: TextStyle(fontSize: tokens.typography.fontSize['sm']!).copyWith(
        color: tokens.colors.neutral.s600,
      ),
    );
  }

  Widget _buildCharCount(DesignTokens tokens) {
    final currentLength = widget.value.length;
    final maxLength = widget.maxLength!;
    final isNearLimit = currentLength > maxLength * 0.9;

    return Text(
      '$currentLength / $maxLength',
      style: TextStyle(fontSize: tokens.typography.fontSize['sm']!).copyWith(
        color: isNearLimit ? tokens.colors.warning.s500 : tokens.colors.neutral.s600,
      ),
    );
  }
}
