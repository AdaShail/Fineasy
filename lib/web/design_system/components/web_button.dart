import 'package:flutter/material.dart';
import '../tokens/design_tokens.dart';
import 'token_extensions.dart';

/// Button variant types
enum WebButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
}

/// Button size variants
enum WebButtonSize {
  sm,
  md,
  lg,
}

/// Icon position in button
enum WebButtonIconPosition {
  left,
  right,
}

/// Web Button Component
/// 
/// A comprehensive button component with multiple variants, sizes, and states.
/// Implements WCAG 2.1 AA accessibility standards with proper ARIA attributes
/// and keyboard navigation support.
/// 
/// Example:
/// ```dart
/// WebButton(
///   variant: WebButtonVariant.primary,
///   size: WebButtonSize.md,
///   onPressed: () => print('Clicked'),
///   child: Text('Click Me'),
/// )
/// ```
class WebButton extends StatefulWidget {
  final WebButtonVariant variant;
  final WebButtonSize size;
  final bool disabled;
  final bool loading;
  final bool fullWidth;
  final Widget? icon;
  final WebButtonIconPosition iconPosition;
  final VoidCallback? onPressed;
  final Widget child;
  final String? ariaLabel;

  const WebButton({
    Key? key,
    this.variant = WebButtonVariant.primary,
    this.size = WebButtonSize.md,
    this.disabled = false,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
    this.iconPosition = WebButtonIconPosition.left,
    this.onPressed,
    required this.child,
    this.ariaLabel,
  }) : super(key: key);

  @override
  State<WebButton> createState() => _WebButtonState();
}

class _WebButtonState extends State<WebButton> {
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDisabled = widget.disabled || widget.loading;
    
    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: widget.ariaLabel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: isDisabled ? null : widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: widget.fullWidth ? double.infinity : null,
              padding: _getPadding(tokens),
              decoration: _getDecoration(tokens, isDisabled),
              child: _buildContent(tokens, isDisabled),
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets _getPadding(DesignTokens tokens) {
    switch (widget.size) {
      case WebButtonSize.sm:
        return EdgeInsets.symmetric(
          horizontal: tokens.spacing['3']!,
          vertical: tokens.spacing['2']!,
        );
      case WebButtonSize.md:
        return EdgeInsets.symmetric(
          horizontal: tokens.spacing['4']!,
          vertical: tokens.spacing['3']!,
        );
      case WebButtonSize.lg:
        return EdgeInsets.symmetric(
          horizontal: tokens.spacing['6']!,
          vertical: tokens.spacing['4']!,
        );
    }
  }

  BoxDecoration _getDecoration(DesignTokens tokens, bool isDisabled) {
    final colors = tokens.colors;
    
    Color backgroundColor;
    Color borderColor;
    double borderWidth = 0;

    // Determine base colors based on variant
    switch (widget.variant) {
      case WebButtonVariant.primary:
        backgroundColor = colors.primary.s500;
        borderColor = colors.primary.s500;
        break;
      case WebButtonVariant.secondary:
        backgroundColor = colors.secondary.s500;
        borderColor = colors.secondary.s500;
        break;
      case WebButtonVariant.outline:
        backgroundColor = Colors.transparent;
        borderColor = colors.primary.s500;
        borderWidth = 1;
        break;
      case WebButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        borderColor = Colors.transparent;
        break;
      case WebButtonVariant.danger:
        backgroundColor = colors.error.s500;
        borderColor = colors.error.s500;
        break;
    }

    // Apply state modifications
    if (isDisabled) {
      backgroundColor = colors.neutral.s300;
      borderColor = colors.neutral.s300;
    } else if (_isPressed) {
      backgroundColor = _darkenColor(backgroundColor, 0.2);
      borderColor = _darkenColor(borderColor, 0.2);
    } else if (_isHovered) {
      backgroundColor = _darkenColor(backgroundColor, 0.1);
      borderColor = _darkenColor(borderColor, 0.1);
    }

    return BoxDecoration(
      color: backgroundColor,
      border: borderWidth > 0 ? Border.all(color: borderColor, width: borderWidth) : null,
      borderRadius: BorderRadius.circular(tokens.borderRadius.base),
      boxShadow: _isFocused && !isDisabled
          ? [
              BoxShadow(
                color: colors.primary.s500.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ]
          : null,
    );
  }

  Widget _buildContent(DesignTokens tokens, bool isDisabled) {
    final textColor = _getTextColor(tokens, isDisabled);
    final textStyle = _getTextStyle(tokens).copyWith(color: textColor);

    if (widget.loading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _getIconSize(tokens),
            height: _getIconSize(tokens),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          SizedBox(width: tokens.spacing['2']!),
          DefaultTextStyle(
            style: textStyle,
            child: widget.child,
          ),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.iconPosition == WebButtonIconPosition.left
            ? [
                IconTheme(
                  data: IconThemeData(color: textColor, size: _getIconSize(tokens)),
                  child: widget.icon!,
                ),
                SizedBox(width: tokens.spacing['2']!),
                DefaultTextStyle(
                  style: textStyle,
                  child: widget.child,
                ),
              ]
            : [
                DefaultTextStyle(
                  style: textStyle,
                  child: widget.child,
                ),
                SizedBox(width: tokens.spacing['2']!),
                IconTheme(
                  data: IconThemeData(color: textColor, size: _getIconSize(tokens)),
                  child: widget.icon!,
                ),
              ],
      );
    }

    return DefaultTextStyle(
      style: textStyle,
      child: widget.child,
    );
  }

  Color _getTextColor(DesignTokens tokens, bool isDisabled) {
    final colors = tokens.colors;
    
    if (isDisabled) {
      return colors.neutral.s500;
    }

    switch (widget.variant) {
      case WebButtonVariant.primary:
      case WebButtonVariant.secondary:
      case WebButtonVariant.danger:
        return Colors.white;
      case WebButtonVariant.outline:
        return colors.primary.s500;
      case WebButtonVariant.ghost:
        return colors.neutral.s900;
    }
  }

  TextStyle _getTextStyle(DesignTokens tokens) {
    switch (widget.size) {
      case WebButtonSize.sm:
        return TextStyle(fontSize: tokens.typography.fontSize['sm']!).copyWith(
          fontWeight: tokens.typography.fontWeight['medium']!,
        );
      case WebButtonSize.md:
        return TextStyle(fontSize: tokens.typography.fontSize['base']!).copyWith(
          fontWeight: tokens.typography.fontWeight['medium']!,
        );
      case WebButtonSize.lg:
        return TextStyle(fontSize: tokens.typography.fontSize['lg']!).copyWith(
          fontWeight: tokens.typography.fontWeight['semibold']!,
        );
    }
  }

  double _getIconSize(DesignTokens tokens) {
    switch (widget.size) {
      case WebButtonSize.sm:
        return 16;
      case WebButtonSize.md:
        return 20;
      case WebButtonSize.lg:
        return 24;
    }
  }

  Color _darkenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
}
