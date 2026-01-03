import 'package:flutter/material.dart';
import '../tokens/design_tokens.dart';
import 'token_extensions.dart';

/// Toast notification type
enum WebToastType {
  success,
  error,
  warning,
  info,
}

/// Toast action button configuration
class WebToastAction {
  final String label;
  final VoidCallback onClick;

  const WebToastAction({
    required this.label,
    required this.onClick,
  });
}

/// Web Toast Component
/// 
/// A toast notification component with auto-dismiss and manual dismiss options.
/// Implements WCAG 2.1 AA accessibility with ARIA live regions.
/// 
/// Example:
/// ```dart
/// WebToast(
///   id: 'toast-1',
///   type: WebToastType.success,
///   message: 'Changes saved successfully',
///   onDismiss: (id) => removeToast(id),
/// )
/// ```
class WebToast extends StatefulWidget {
  final String id;
  final WebToastType type;
  final String message;
  final String? description;
  final int duration; // milliseconds, 0 = manual dismiss only
  final WebToastAction? action;
  final ValueChanged<String> onDismiss;

  const WebToast({
    Key? key,
    required this.id,
    required this.type,
    required this.message,
    this.description,
    this.duration = 5000,
    this.action,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<WebToast> createState() => _WebToastState();
}

class _WebToastState extends State<WebToast> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    // Auto-dismiss if duration > 0
    if (widget.duration > 0) {
      Future.delayed(Duration(milliseconds: widget.duration), () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Semantics(
          liveRegion: true,
          child: Container(
            margin: EdgeInsets.only(bottom: tokens.spacing['3']!),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: _getBackgroundColor(tokens),
              borderRadius: BorderRadius.circular(tokens.borderRadius.base),
              border: Border.all(
                color: _getBorderColor(tokens),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(tokens.spacing['4']!),
                  child: Icon(
                    _getIcon(),
                    color: _getIconColor(tokens),
                    size: 24,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: tokens.spacing['4']!,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message,
                          style: TextStyle(fontSize: tokens.typography.fontSize['base']!).copyWith(
                            fontWeight: tokens.typography.fontWeight['semibold']!,
                            color: tokens.colors.neutral.s900,
                          ),
                        ),
                        if (widget.description != null) ...[
                          SizedBox(height: tokens.spacing['1']!),
                          Text(
                            widget.description!,
                            style: TextStyle(fontSize: tokens.typography.fontSize['sm']!).copyWith(
                              color: tokens.colors.neutral.s700,
                            ),
                          ),
                        ],
                        if (widget.action != null) ...[
                          SizedBox(height: tokens.spacing['2']!),
                          TextButton(
                            onPressed: () {
                              widget.action!.onClick();
                              _dismiss();
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              widget.action!.label,
                              style: TextStyle(fontSize: tokens.typography.fontSize['sm']!).copyWith(
                                color: _getIconColor(tokens),
                                fontWeight: tokens.typography.fontWeight['semibold']!,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                  onPressed: _dismiss,
                  tooltip: 'Dismiss',
                  color: tokens.colors.neutral.s600,
                  padding: EdgeInsets.all(tokens.spacing['2']!),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(DesignTokens tokens) {
    switch (widget.type) {
      case WebToastType.success:
        return tokens.colors.success.s50;
      case WebToastType.error:
        return tokens.colors.error.s50;
      case WebToastType.warning:
        return tokens.colors.warning.s50;
      case WebToastType.info:
        return tokens.colors.info.s50;
    }
  }

  Color _getBorderColor(DesignTokens tokens) {
    switch (widget.type) {
      case WebToastType.success:
        return tokens.colors.success.s200;
      case WebToastType.error:
        return tokens.colors.error.s200;
      case WebToastType.warning:
        return tokens.colors.warning.s200;
      case WebToastType.info:
        return tokens.colors.info.s200;
    }
  }

  Color _getIconColor(DesignTokens tokens) {
    switch (widget.type) {
      case WebToastType.success:
        return tokens.colors.success.s600;
      case WebToastType.error:
        return tokens.colors.error.s600;
      case WebToastType.warning:
        return tokens.colors.warning.s600;
      case WebToastType.info:
        return tokens.colors.info.s600;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case WebToastType.success:
        return Icons.check_circle;
      case WebToastType.error:
        return Icons.error;
      case WebToastType.warning:
        return Icons.warning;
      case WebToastType.info:
        return Icons.info;
    }
  }
}
