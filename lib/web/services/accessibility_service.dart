import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Service for managing web accessibility features
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  // Track keyboard navigation state
  bool _keyboardNavigationActive = false;
  final List<AccessibilityViolation> _violations = [];

  /// Check if keyboard navigation is currently active
  bool get isKeyboardNavigationActive => _keyboardNavigationActive;

  /// Get list of accessibility violations
  List<AccessibilityViolation> get violations => List.unmodifiable(_violations);

  /// Set keyboard navigation state
  void setKeyboardNavigationActive(bool active) {
    _keyboardNavigationActive = active;
  }

  /// Run WCAG compliance check on a widget tree
  WCAGComplianceReport runWCAGComplianceCheck(BuildContext context) {
    _violations.clear();
    
    // Check color contrast
    _checkColorContrast(context);
    
    // Check touch target sizes
    _checkTouchTargetSizes(context);
    
    // Check text sizes
    _checkTextSizes(context);
    
    // Check focus indicators
    _checkFocusIndicators(context);
    
    return WCAGComplianceReport(
      violations: List.from(_violations),
      passedChecks: _calculatePassedChecks(),
      complianceLevel: _determineComplianceLevel(),
    );
  }

  void _checkColorContrast(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Check primary text on background
    if (!hasValidContrast(colorScheme.onSurface, colorScheme.surface)) {
      _violations.add(AccessibilityViolation(
        type: ViolationType.colorContrast,
        severity: Severity.critical,
        message: 'Primary text does not meet WCAG AA contrast requirements',
        wcagCriterion: '1.4.3',
      ));
    }
    
    // Check button text on button background
    if (!hasValidContrast(colorScheme.onPrimary, colorScheme.primary)) {
      _violations.add(AccessibilityViolation(
        type: ViolationType.colorContrast,
        severity: Severity.critical,
        message: 'Button text does not meet WCAG AA contrast requirements',
        wcagCriterion: '1.4.3',
      ));
    }
  }

  void _checkTouchTargetSizes(BuildContext context) {
    // This would require widget tree inspection in a real implementation
    // For now, we'll provide a method to validate individual widgets
  }

  void _checkTextSizes(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    // Check if body text is at least 16px
    final bodySize = textTheme.bodyMedium?.fontSize ?? 14.0;
    if (bodySize < 16.0) {
      _violations.add(AccessibilityViolation(
        type: ViolationType.textSize,
        severity: Severity.warning,
        message: 'Body text size is below recommended 16px minimum',
        wcagCriterion: '1.4.4',
      ));
    }
  }

  void _checkFocusIndicators(BuildContext context) {
    // This would require checking if focus indicators are visible
    // Implementation depends on widget tree inspection
  }

  int _calculatePassedChecks() {
    // In a real implementation, track total checks performed
    return 10 - _violations.length;
  }

  WCAGLevel _determineComplianceLevel() {
    if (_violations.any((v) => v.severity == Severity.critical)) {
      return WCAGLevel.none;
    }
    if (_violations.any((v) => v.severity == Severity.major)) {
      return WCAGLevel.a;
    }
    if (_violations.any((v) => v.severity == Severity.minor)) {
      return WCAGLevel.aa;
    }
    return WCAGLevel.aaa;
  }

  /// Validate ARIA attributes for a widget
  ARIAValidationResult validateARIAAttributes({
    required String? semanticLabel,
    required String? tooltip,
    required bool isButton,
    required bool isLink,
    required bool isInput,
    required bool hasOnTap,
  }) {
    final issues = <String>[];
    
    // Check if interactive elements have labels
    if (hasOnTap && (semanticLabel == null || semanticLabel.isEmpty)) {
      issues.add('Interactive element missing semantic label');
    }
    
    // Check if buttons have appropriate labels
    if (isButton && (semanticLabel == null || semanticLabel.isEmpty)) {
      issues.add('Button missing semantic label');
    }
    
    // Check if links have descriptive text
    if (isLink && (semanticLabel == null || semanticLabel.isEmpty)) {
      issues.add('Link missing descriptive text');
    }
    
    // Check if inputs have labels
    if (isInput && (semanticLabel == null || semanticLabel.isEmpty)) {
      issues.add('Input field missing label');
    }
    
    return ARIAValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }

  /// Detect keyboard navigation usage
  KeyboardNavigationReport detectKeyboardNavigation(BuildContext context) {
    return KeyboardNavigationReport(
      isActive: _keyboardNavigationActive,
      supportedKeys: [
        'Tab',
        'Shift+Tab',
        'Enter',
        'Space',
        'Escape',
        'Arrow Keys',
      ],
      recommendations: _keyboardNavigationActive
          ? []
          : ['Enable keyboard navigation for better accessibility'],
    );
  }

  /// Calculate contrast ratio (public method)
  double calculateContrastRatio(Color foreground, Color background) {
    return _calculateContrastRatio(foreground, background);
  }

  /// Announce message to screen readers
  void announce(BuildContext context, String message, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) {
    if (kIsWeb) {
      // Use Semantics widget to announce to screen readers
      // In Flutter web, announcements are handled through Semantics widgets
      // with liveRegion property
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 100),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Check if high contrast mode is enabled
  bool isHighContrastMode(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Check if bold text is enabled
  bool isBoldTextEnabled(BuildContext context) {
    return MediaQuery.of(context).boldText;
  }

  /// Get text scale factor
  double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// Check if animations should be reduced
  bool shouldReduceAnimations(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Validate color contrast ratio (WCAG AA requires 4.5:1 for normal text)
  bool hasValidContrast(Color foreground, Color background, {
    double requiredRatio = 4.5,
  }) {
    final ratio = _calculateContrastRatio(foreground, background);
    return ratio >= requiredRatio;
  }

  /// Calculate contrast ratio between two colors
  double _calculateContrastRatio(Color color1, Color color2) {
    final l1 = _relativeLuminance(color1);
    final l2 = _relativeLuminance(color2);
    
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calculate relative luminance of a color
  double _relativeLuminance(Color color) {
    final r = _linearize(color.red / 255.0);
    final g = _linearize(color.green / 255.0);
    final b = _linearize(color.blue / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  double _linearize(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return math.pow(((channel + 0.055) / 1.055), 2.4).toDouble();
  }
}

/// Assertiveness level for screen reader announcements
enum Assertiveness {
  polite,
  assertive,
}

/// Mixin for keyboard navigation support
mixin KeyboardNavigationMixin<T extends StatefulWidget> on State<T> {
  final Map<LogicalKeySet, VoidCallback> _shortcuts = {};
  
  /// Register a keyboard shortcut
  void registerShortcut(LogicalKeySet keys, VoidCallback callback) {
    _shortcuts[keys] = callback;
  }

  /// Unregister a keyboard shortcut
  void unregisterShortcut(LogicalKeySet keys) {
    _shortcuts.remove(keys);
  }

  /// Build widget with keyboard shortcuts
  Widget buildWithShortcuts(Widget child) {
    if (_shortcuts.isEmpty) return child;
    
    return Shortcuts(
      shortcuts: _shortcuts.map((key, value) => MapEntry(
        key,
        VoidCallbackIntent(value),
      )),
      child: Actions(
        actions: {
          VoidCallbackIntent: CallbackAction<VoidCallbackIntent>(
            onInvoke: (intent) => intent.callback(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

/// Intent for void callbacks
class VoidCallbackIntent extends Intent {
  final VoidCallback callback;
  const VoidCallbackIntent(this.callback);
}

/// Accessibility configuration
class AccessibilityConfig {
  final bool enableKeyboardNavigation;
  final bool enableScreenReaderSupport;
  final bool enableFocusIndicators;
  final bool enableHighContrastMode;
  final double minimumTouchTargetSize;
  final Duration focusAnimationDuration;

  const AccessibilityConfig({
    this.enableKeyboardNavigation = true,
    this.enableScreenReaderSupport = true,
    this.enableFocusIndicators = true,
    this.enableHighContrastMode = false,
    this.minimumTouchTargetSize = 44.0, // WCAG 2.1 Level AAA
    this.focusAnimationDuration = const Duration(milliseconds: 200),
  });

  static const AccessibilityConfig standard = AccessibilityConfig();
  
  static const AccessibilityConfig enhanced = AccessibilityConfig(
    minimumTouchTargetSize: 48.0,
    enableHighContrastMode: true,
  );
}

/// Widget that ensures minimum touch target size
class AccessibleTouchTarget extends StatelessWidget {
  final Widget child;
  final double minimumSize;

  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.minimumSize = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minimumSize,
        minHeight: minimumSize,
      ),
      child: child,
    );
  }
}

/// Widget that provides enhanced focus indicators
class AccessibleFocusIndicator extends StatefulWidget {
  final Widget child;
  final FocusNode? focusNode;
  final Color? focusColor;
  final double focusWidth;
  final BorderRadius? borderRadius;

  const AccessibleFocusIndicator({
    super.key,
    required this.child,
    this.focusNode,
    this.focusColor,
    this.focusWidth = 3.0,
    this.borderRadius,
  });

  @override
  State<AccessibleFocusIndicator> createState() => _AccessibleFocusIndicatorState();
}

class _AccessibleFocusIndicatorState extends State<AccessibleFocusIndicator> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusColor = widget.focusColor ?? theme.colorScheme.primary;

    return Focus(
      focusNode: _focusNode,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: _isFocused
              ? Border.all(
                  color: focusColor,
                  width: widget.focusWidth,
                )
              : null,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Semantic label builder for common UI patterns
class SemanticLabels {
  /// Generate label for button
  static String button(String action, {String? context}) {
    return context != null ? '$action $context button' : '$action button';
  }

  /// Generate label for link
  static String link(String destination) {
    return 'Link to $destination';
  }

  /// Generate label for input field
  static String input(String fieldName, {bool required = false}) {
    return required 
        ? '$fieldName, required field' 
        : '$fieldName field';
  }

  /// Generate label for checkbox
  static String checkbox(String label, bool checked) {
    return '$label checkbox, ${checked ? 'checked' : 'unchecked'}';
  }

  /// Generate label for navigation item
  static String navigation(String destination, {bool current = false}) {
    return current 
        ? '$destination, current page' 
        : 'Navigate to $destination';
  }

  /// Generate label for status indicator
  static String status(String status, String context) {
    return '$context status: $status';
  }

  /// Generate label for data table
  static String table(String name, int rows, int columns) {
    return '$name table with $rows rows and $columns columns';
  }

  /// Generate label for pagination
  static String pagination(int current, int total) {
    return 'Page $current of $total';
  }
}

/// WCAG Compliance Report
class WCAGComplianceReport {
  final List<AccessibilityViolation> violations;
  final int passedChecks;
  final WCAGLevel complianceLevel;

  const WCAGComplianceReport({
    required this.violations,
    required this.passedChecks,
    required this.complianceLevel,
  });

  bool get isCompliant => violations.isEmpty;
  
  int get totalChecks => passedChecks + violations.length;
  
  double get compliancePercentage => 
      totalChecks > 0 ? (passedChecks / totalChecks) * 100 : 0;
}

/// Accessibility Violation
class AccessibilityViolation {
  final ViolationType type;
  final Severity severity;
  final String message;
  final String wcagCriterion;

  const AccessibilityViolation({
    required this.type,
    required this.severity,
    required this.message,
    required this.wcagCriterion,
  });
}

/// Violation Type
enum ViolationType {
  colorContrast,
  touchTargetSize,
  textSize,
  focusIndicator,
  missingLabel,
  keyboardNavigation,
}

/// Severity Level
enum Severity {
  critical,
  major,
  minor,
  warning,
}

/// WCAG Compliance Level
enum WCAGLevel {
  none,
  a,
  aa,
  aaa,
}

/// ARIA Validation Result
class ARIAValidationResult {
  final bool isValid;
  final List<String> issues;

  const ARIAValidationResult({
    required this.isValid,
    required this.issues,
  });
}

/// Keyboard Navigation Report
class KeyboardNavigationReport {
  final bool isActive;
  final List<String> supportedKeys;
  final List<String> recommendations;

  const KeyboardNavigationReport({
    required this.isActive,
    required this.supportedKeys,
    required this.recommendations,
  });
}
