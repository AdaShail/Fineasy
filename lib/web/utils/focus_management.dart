import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Focus management utilities for accessibility
class FocusManagement {
  /// Create a focus trap that keeps focus within a widget
  static Widget createFocusTrap({
    required Widget child,
    required FocusNode focusNode,
    bool enabled = true,
  }) {
    return FocusTrap(
      enabled: enabled,
      focusNode: focusNode,
      child: child,
    );
  }

  /// Return focus to a previous element
  static void returnFocus(FocusNode? previousFocus) {
    if (previousFocus != null && previousFocus.canRequestFocus) {
      previousFocus.requestFocus();
    }
  }

  /// Find all focusable elements in a context
  static List<FocusNode> findFocusableElements(BuildContext context) {
    final List<FocusNode> focusableNodes = [];
    
    void visitor(Element element) {
      final widget = element.widget;
      if (widget is Focus) {
        final focusNode = widget.focusNode;
        if (focusNode != null && focusNode.canRequestFocus) {
          focusableNodes.add(focusNode);
        }
      }
      element.visitChildren(visitor);
    }
    
    context.visitChildElements(visitor);
    return focusableNodes;
  }

  /// Move focus to the next focusable element
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to the previous focusable element
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Focus the first element in a context
  static void focusFirst(BuildContext context) {
    final focusableElements = findFocusableElements(context);
    if (focusableElements.isNotEmpty) {
      focusableElements.first.requestFocus();
    }
  }

  /// Focus the last element in a context
  static void focusLast(BuildContext context) {
    final focusableElements = findFocusableElements(context);
    if (focusableElements.isNotEmpty) {
      focusableElements.last.requestFocus();
    }
  }
}

/// Widget that traps focus within its children
class FocusTrap extends StatefulWidget {
  final Widget child;
  final FocusNode focusNode;
  final bool enabled;

  const FocusTrap({
    super.key,
    required this.child,
    required this.focusNode,
    this.enabled = true,
  });

  @override
  State<FocusTrap> createState() => _FocusTrapState();
}

class _FocusTrapState extends State<FocusTrap> {
  late FocusScopeNode _focusScopeNode;

  @override
  void initState() {
    super.initState();
    _focusScopeNode = FocusScopeNode();
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return FocusScope(
      node: _focusScopeNode,
      child: Focus(
        focusNode: widget.focusNode,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            // Handle Tab key to trap focus
            if (event.logicalKey == LogicalKeyboardKey.tab) {
              final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
              if (isShiftPressed) {
                // Shift+Tab - move to previous
                if (!_focusScopeNode.hasPrimaryFocus) {
                  _focusScopeNode.previousFocus();
                } else {
                  // Wrap to last element
                  _focusScopeNode.focusInDirection(TraversalDirection.up);
                }
              } else {
                // Tab - move to next
                if (!_focusScopeNode.hasPrimaryFocus) {
                  _focusScopeNode.nextFocus();
                } else {
                  // Wrap to first element
                  _focusScopeNode.focusInDirection(TraversalDirection.down);
                }
              }
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: widget.child,
      ),
    );
  }
}

/// Widget that manages focus return when disposed
class FocusReturnScope extends StatefulWidget {
  final Widget child;
  final FocusNode? returnFocusTo;

  const FocusReturnScope({
    super.key,
    required this.child,
    this.returnFocusTo,
  });

  @override
  State<FocusReturnScope> createState() => _FocusReturnScopeState();
}

class _FocusReturnScopeState extends State<FocusReturnScope> {
  FocusNode? _previousFocus;

  @override
  void initState() {
    super.initState();
    // Store the currently focused node
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _previousFocus = FocusManager.instance.primaryFocus;
    });
  }

  @override
  void dispose() {
    // Return focus to the previous element
    final returnTo = widget.returnFocusTo ?? _previousFocus;
    if (returnTo != null && returnTo.canRequestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        returnTo.requestFocus();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Enhanced focus indicator widget
class EnhancedFocusIndicator extends StatefulWidget {
  final Widget child;
  final FocusNode? focusNode;
  final Color? focusColor;
  final double focusWidth;
  final BorderRadius? borderRadius;
  final bool showOnlyOnKeyboard;

  const EnhancedFocusIndicator({
    super.key,
    required this.child,
    this.focusNode,
    this.focusColor,
    this.focusWidth = 3.0,
    this.borderRadius,
    this.showOnlyOnKeyboard = true,
  });

  @override
  State<EnhancedFocusIndicator> createState() => _EnhancedFocusIndicatorState();
}

class _EnhancedFocusIndicatorState extends State<EnhancedFocusIndicator> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isKeyboardFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(EnhancedFocusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
      // In a real implementation, we'd detect if focus came from keyboard
      // For now, assume keyboard focus if focus is gained
      _isKeyboardFocus = _isFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusColor = widget.focusColor ?? theme.colorScheme.primary;

    final shouldShowIndicator = _isFocused && 
        (!widget.showOnlyOnKeyboard || _isKeyboardFocus);

    return Focus(
      focusNode: _focusNode,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: shouldShowIndicator
              ? Border.all(
                  color: focusColor,
                  width: widget.focusWidth,
                )
              : null,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
          boxShadow: shouldShowIndicator
              ? [
                  BoxShadow(
                    color: focusColor.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Skip link component for bypassing navigation
class SkipLink extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final FocusNode? focusNode;

  const SkipLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100, // Hidden off-screen by default
      left: 0,
      child: Focus(
        focusNode: focusNode,
        onFocusChange: (hasFocus) {
          // When focused, move on-screen
          // This would require state management in a real implementation
        },
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

/// Skip links container that shows links when focused
class SkipLinksContainer extends StatefulWidget {
  final List<SkipLinkData> links;

  const SkipLinksContainer({
    super.key,
    required this.links,
  });

  @override
  State<SkipLinksContainer> createState() => _SkipLinksContainerState();
}

class _SkipLinksContainerState extends State<SkipLinksContainer> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            children: widget.links.map((link) {
              return Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isVisible = hasFocus || 
                        widget.links.any((l) => l.focusNode?.hasFocus ?? false);
                  });
                },
                child: ElevatedButton(
                  onPressed: link.onPressed,
                  focusNode: link.focusNode,
                  child: Text(link.label),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Data class for skip links
class SkipLinkData {
  final String label;
  final VoidCallback onPressed;
  final FocusNode? focusNode;

  const SkipLinkData({
    required this.label,
    required this.onPressed,
    this.focusNode,
  });
}

/// Mixin for managing focus state
mixin FocusManagementMixin<T extends StatefulWidget> on State<T> {
  final List<FocusNode> _managedFocusNodes = [];
  FocusNode? _previousFocus;

  /// Register a focus node to be managed
  void registerFocusNode(FocusNode node) {
    _managedFocusNodes.add(node);
  }

  /// Store the current focus for later restoration
  void storeFocus() {
    _previousFocus = FocusManager.instance.primaryFocus;
  }

  /// Restore the previously stored focus
  void restoreFocus() {
    if (_previousFocus != null && _previousFocus!.canRequestFocus) {
      _previousFocus!.requestFocus();
    }
  }

  /// Dispose all managed focus nodes
  @override
  void dispose() {
    for (final node in _managedFocusNodes) {
      node.dispose();
    }
    _managedFocusNodes.clear();
    super.dispose();
  }
}
