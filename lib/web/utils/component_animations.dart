/// Component animations for web UX
/// Provides animations for buttons, pages, lists, forms, dropdowns, and tooltips
library;

import 'dart:math' show pi, sin;
import 'package:flutter/material.dart';
import '../design_system/tokens/animation_tokens.dart';

/// Button state animations
class ButtonAnimations {
  /// Animated button with hover, active, and disabled states
  static Widget animatedButton({
    required Widget child,
    required VoidCallback? onPressed,
    bool isLoading = false,
    Color? backgroundColor,
    Color? hoverColor,
    Color? activeColor,
    Color? disabledColor,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    BorderRadius? borderRadius,
  }) {
    return _AnimatedButtonWidget(
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      hoverColor: hoverColor,
      activeColor: activeColor,
      disabledColor: disabledColor,
      padding: padding,
      borderRadius: borderRadius,
      child: child,
    );
  }
}

class _AnimatedButtonWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? hoverColor;
  final Color? activeColor;
  final Color? disabledColor;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  const _AnimatedButtonWidget({
    required this.child,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.hoverColor,
    this.activeColor,
    this.disabledColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius,
  });

  @override
  State<_AnimatedButtonWidget> createState() => _AnimatedButtonWidgetState();
}

class _AnimatedButtonWidgetState extends State<_AnimatedButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SemanticAnimations.buttonHover,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: SemanticAnimations.buttonPressCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    if (widget.onPressed == null || widget.isLoading) {
      return widget.disabledColor ?? Colors.grey.shade300;
    }
    if (_isPressed) {
      return widget.activeColor ?? Colors.blue.shade700;
    }
    if (_isHovered) {
      return widget.hoverColor ?? Colors.blue.shade600;
    }
    return widget.backgroundColor ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return MouseRegion(
      onEnter: isDisabled ? null : (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: isDisabled
            ? null
            : (_) {
                setState(() => _isPressed = true);
                _controller.forward();
              },
        onTapUp: isDisabled
            ? null
            : (_) {
                setState(() => _isPressed = false);
                _controller.reverse();
              },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? _scaleAnimation.value : 1.0,
              child: AnimatedContainer(
                duration: SemanticAnimations.buttonHover,
                curve: SemanticAnimations.buttonHoverCurve,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                  boxShadow: _isHovered && !isDisabled
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Page transition animations
class PageTransitionAnimations {
  /// Fade page transition
  static Widget fade({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Slide page transition
  static Widget slide({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.right,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.left:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.right:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.up:
        begin = const Offset(0.0, -1.0);
        break;
      case SlideDirection.down:
        begin = const Offset(0.0, 1.0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: SemanticAnimations.pageTransitionCurve,
      )),
      child: child,
    );
  }

  /// Scale page transition
  static Widget scale({
    required Widget child,
    required Animation<double> animation,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: SemanticAnimations.pageTransitionCurve,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Fade and slide combined
  static Widget fadeSlide({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.right,
  }) {
    return FadeTransition(
      opacity: animation,
      child: slide(
        child: child,
        animation: animation,
        direction: direction,
      ),
    );
  }
}

enum SlideDirection { left, right, up, down }

/// List item animations
class ListItemAnimations {
  /// Animated list item with add animation
  static Widget animatedListItem({
    required Widget child,
    required Animation<double> animation,
    Axis axis = Axis.vertical,
  }) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: SemanticAnimations.listItemCurve,
      ),
      axis: axis,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Slide in list item
  static Widget slideIn({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.left,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.left:
        begin = const Offset(-0.3, 0.0);
        break;
      case SlideDirection.right:
        begin = const Offset(0.3, 0.0);
        break;
      case SlideDirection.up:
        begin = const Offset(0.0, -0.3);
        break;
      case SlideDirection.down:
        begin = const Offset(0.0, 0.3);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: SemanticAnimations.listItemCurve,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Scale in list item
  static Widget scaleIn({
    required Widget child,
    required Animation<double> animation,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: SemanticAnimations.listItemCurve,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Staggered list animation helper
  static Widget staggeredList({
    required List<Widget> children,
    required AnimationController controller,
    Duration staggerDelay = const Duration(milliseconds: 50),
  }) {
    return Column(
      children: List.generate(children.length, (index) {
        final start = (index * staggerDelay.inMilliseconds) /
            (controller.duration?.inMilliseconds ?? 1);
        final end = ((index + 1) * staggerDelay.inMilliseconds) /
            (controller.duration?.inMilliseconds ?? 1);

        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: SemanticAnimations.listItemCurve,
            ),
          ),
        );

        return slideIn(
          child: children[index],
          animation: animation,
        );
      }),
    );
  }
}

/// Form validation animations
class FormValidationAnimations {
  /// Shake animation for errors
  static Widget shake({
    required Widget child,
    required bool trigger,
    Key? key,
  }) {
    return _ShakeWidget(
      key: key,
      trigger: trigger,
      child: child,
    );
  }

  /// Checkmark animation for success
  static Widget checkmark({
    required bool show,
    Color color = Colors.green,
    double size = 24,
  }) {
    return AnimatedScale(
      scale: show ? 1.0 : 0.0,
      duration: SemanticAnimations.formValidation,
      curve: SemanticAnimations.formValidationCurve,
      child: AnimatedOpacity(
        opacity: show ? 1.0 : 0.0,
        duration: SemanticAnimations.formValidation,
        child: Icon(
          Icons.check_circle,
          color: color,
          size: size,
        ),
      ),
    );
  }

  /// Error icon animation
  static Widget errorIcon({
    required bool show,
    Color color = Colors.red,
    double size = 24,
  }) {
    return AnimatedScale(
      scale: show ? 1.0 : 0.0,
      duration: SemanticAnimations.formValidation,
      curve: Curves.elasticOut,
      child: AnimatedOpacity(
        opacity: show ? 1.0 : 0.0,
        duration: SemanticAnimations.formValidation,
        child: Icon(
          Icons.error,
          color: color,
          size: size,
        ),
      ),
    );
  }

  /// Animated error message
  static Widget errorMessage({
    required String? message,
    TextStyle? style,
  }) {
    return AnimatedSize(
      duration: AnimationDurationTokens.fast,
      curve: AnimationEasingTokens.easeOut,
      child: message != null
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                message,
                style: style ?? const TextStyle(color: Colors.red, fontSize: 12),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const _ShakeWidget({
    super.key,
    required this.child,
    required this.trigger,
  });

  @override
  State<_ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<_ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SemanticAnimations.formValidation,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticIn,
      ),
    );
  }

  @override
  void didUpdateWidget(_ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final offset = sin(_animation.value * pi * 2) * 5;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Dropdown and tooltip animations
class DropdownTooltipAnimations {
  /// Animated dropdown
  static Widget dropdown({
    required Widget child,
    required Animation<double> animation,
    Alignment alignment = Alignment.topCenter,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: SemanticAnimations.dropdownCurve,
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: SemanticAnimations.dropdownCurve,
          ),
        ),
        alignment: alignment,
        child: child,
      ),
    );
  }

  /// Animated tooltip
  static Widget tooltip({
    required Widget child,
    required Animation<double> animation,
    Alignment alignment = Alignment.bottomCenter,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: SemanticAnimations.tooltipCurve,
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: SemanticAnimations.tooltipCurve,
          ),
        ),
        alignment: alignment,
        child: child,
      ),
    );
  }

  /// Slide down dropdown
  static Widget slideDown({
    required Widget child,
    required Animation<double> animation,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: SemanticAnimations.dropdownCurve,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// Slide up tooltip
  static Widget slideUp({
    required Widget child,
    required Animation<double> animation,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: SemanticAnimations.tooltipCurve,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Animated container with hover effects
class AnimatedHoverContainer extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? hoverColor;
  final double? elevation;
  final double? hoverElevation;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AnimatedHoverContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.hoverColor,
    this.elevation,
    this.hoverElevation,
    this.borderRadius,
    this.padding,
    this.onTap,
  });

  @override
  State<AnimatedHoverContainer> createState() => _AnimatedHoverContainerState();
}

class _AnimatedHoverContainerState extends State<AnimatedHoverContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AnimationDurationTokens.fast,
          curve: AnimationEasingTokens.easeOut,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.hoverColor ?? widget.backgroundColor?.withOpacity(0.9))
                : widget.backgroundColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: _isHovered
                    ? (widget.hoverElevation ?? 8)
                    : (widget.elevation ?? 2),
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
