import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Service for screen reader announcements and support
class ScreenReaderService {
  static final ScreenReaderService _instance = ScreenReaderService._internal();
  factory ScreenReaderService() => _instance;
  ScreenReaderService._internal();

  final List<String> _announcementQueue = [];
  bool _isAnnouncing = false;

  /// Announce a message to screen readers
  void announce(
    BuildContext context,
    String message, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) {
    _announcementQueue.add(message);
    _processQueue(context, assertiveness);
  }

  void _processQueue(BuildContext context, Assertiveness assertiveness) {
    if (_isAnnouncing || _announcementQueue.isEmpty) return;

    _isAnnouncing = true;
    final message = _announcementQueue.removeAt(0);

    // Use SemanticsService to announce
    SemanticsService.announce(
      message,
      assertiveness == Assertiveness.assertive
          ? TextDirection.rtl // Use RTL for assertive (interrupts)
          : TextDirection.ltr, // Use LTR for polite (waits)
    );

    // Process next announcement after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _isAnnouncing = false;
      if (_announcementQueue.isNotEmpty) {
        _processQueue(context, assertiveness);
      }
    });
  }

  /// Announce a navigation change
  void announceNavigation(BuildContext context, String destination) {
    announce(context, 'Navigated to $destination', assertiveness: Assertiveness.polite);
  }

  /// Announce a form error
  void announceError(BuildContext context, String error) {
    announce(context, 'Error: $error', assertiveness: Assertiveness.assertive);
  }

  /// Announce a success message
  void announceSuccess(BuildContext context, String message) {
    announce(context, 'Success: $message', assertiveness: Assertiveness.polite);
  }

  /// Announce loading state
  void announceLoading(BuildContext context, String what) {
    announce(context, 'Loading $what', assertiveness: Assertiveness.polite);
  }

  /// Announce completion
  void announceComplete(BuildContext context, String what) {
    announce(context, '$what complete', assertiveness: Assertiveness.polite);
  }

  /// Clear announcement queue
  void clearQueue() {
    _announcementQueue.clear();
  }
}

/// Assertiveness level for announcements
enum Assertiveness {
  polite,
  assertive,
}

/// ARIA live region widget for dynamic content
class ARIALiveRegion extends StatefulWidget {
  final Widget child;
  final LiveRegionMode mode;
  final String? label;

  const ARIALiveRegion({
    super.key,
    required this.child,
    this.mode = LiveRegionMode.polite,
    this.label,
  });

  @override
  State<ARIALiveRegion> createState() => _ARIALiveRegionState();
}

class _ARIALiveRegionState extends State<ARIALiveRegion> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: widget.mode == LiveRegionMode.assertive,
      label: widget.label,
      child: widget.child,
    );
  }
}

/// Live region mode
enum LiveRegionMode {
  polite,
  assertive,
  off,
}

/// Semantic HTML structure helpers
class SemanticStructure {
  /// Create a semantic heading
  static Widget heading({
    required String text,
    required int level,
    TextStyle? style,
  }) {
    return Semantics(
      header: true,
      label: text,
      child: Text(
        text,
        style: style,
      ),
    );
  }

  /// Create a semantic list
  static Widget list({
    required List<Widget> children,
    String? label,
  }) {
    return Semantics(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// Create a semantic list item
  static Widget listItem({
    required Widget child,
    String? label,
  }) {
    return Semantics(
      label: label,
      child: child,
    );
  }

  /// Create a semantic navigation
  static Widget navigation({
    required List<Widget> children,
    String? label,
  }) {
    return Semantics(
      label: label ?? 'Navigation',
      child: Column(
        children: children,
      ),
    );
  }

  /// Create a semantic main content area
  static Widget main({
    required Widget child,
    String? label,
  }) {
    return Semantics(
      label: label ?? 'Main content',
      child: child,
    );
  }

  /// Create a semantic article
  static Widget article({
    required Widget child,
    String? label,
  }) {
    return Semantics(
      label: label,
      child: child,
    );
  }

  /// Create a semantic section
  static Widget section({
    required Widget child,
    String? label,
  }) {
    return Semantics(
      label: label,
      child: child,
    );
  }

  /// Create a semantic form
  static Widget form({
    required Widget child,
    String? label,
  }) {
    return Semantics(
      label: label ?? 'Form',
      child: child,
    );
  }
}

/// Widget that provides text alternatives for non-text content
class AccessibleImage extends StatelessWidget {
  final ImageProvider image;
  final String altText;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isDecorative;

  const AccessibleImage({
    super.key,
    required this.image,
    required this.altText,
    this.width,
    this.height,
    this.fit,
    this.isDecorative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: isDecorative ? '' : altText,
      excludeSemantics: isDecorative,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: isDecorative ? '' : altText,
      ),
    );
  }
}

/// Widget that provides text alternatives for icons
class AccessibleIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final double? size;
  final Color? color;
  final bool isDecorative;

  const AccessibleIcon({
    super.key,
    required this.icon,
    required this.label,
    this.size,
    this.color,
    this.isDecorative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isDecorative ? '' : label,
      excludeSemantics: isDecorative,
      child: Icon(
        icon,
        size: size,
        color: color,
        semanticLabel: isDecorative ? '' : label,
      ),
    );
  }
}

/// Widget for accessible buttons with proper semantics
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final bool enabled;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      hint: tooltip,
      child: Tooltip(
        message: tooltip ?? '',
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          child: child,
        ),
      ),
    );
  }
}

/// Widget for accessible links
class AccessibleLink extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String? semanticLabel;
  final String? tooltip;

  const AccessibleLink({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: semanticLabel,
      hint: tooltip,
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}

/// Widget for accessible text fields
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? errorText;
  final bool required;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  const AccessibleTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.required = false,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: required ? '$label (required)' : label,
      hint: hint,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          suffixIcon: required
              ? const Icon(Icons.star, size: 8, color: Colors.red)
              : null,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
      ),
    );
  }
}

/// Widget for accessible checkboxes
class AccessibleCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String label;
  final bool enabled;

  const AccessibleCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      enabled: enabled,
      label: label,
      child: CheckboxListTile(
        value: value,
        onChanged: enabled ? onChanged : null,
        title: Text(label),
      ),
    );
  }
}

/// Widget for accessible radio buttons
class AccessibleRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final String label;
  final bool enabled;

  const AccessibleRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: value == groupValue,
      enabled: enabled,
      label: label,
      child: RadioListTile<T>(
        value: value,
        groupValue: groupValue,
        onChanged: enabled ? onChanged : null,
        title: Text(label),
      ),
    );
  }
}

/// Widget for accessible progress indicators
class AccessibleProgressIndicator extends StatelessWidget {
  final double? value;
  final String label;
  final String? valueLabel;

  const AccessibleProgressIndicator({
    super.key,
    this.value,
    required this.label,
    this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    final percentLabel = value != null
        ? '${(value! * 100).toInt()}%'
        : 'Loading';

    return Semantics(
      label: '$label: ${valueLabel ?? percentLabel}',
      child: LinearProgressIndicator(
        value: value,
      ),
    );
  }
}

/// Mixin for screen reader announcements
mixin ScreenReaderAnnouncementMixin<T extends StatefulWidget> on State<T> {
  final ScreenReaderService _screenReaderService = ScreenReaderService();

  /// Announce a message
  void announce(String message, {Assertiveness assertiveness = Assertiveness.polite}) {
    _screenReaderService.announce(context, message, assertiveness: assertiveness);
  }

  /// Announce navigation
  void announceNavigation(String destination) {
    _screenReaderService.announceNavigation(context, destination);
  }

  /// Announce error
  void announceError(String error) {
    _screenReaderService.announceError(context, error);
  }

  /// Announce success
  void announceSuccess(String message) {
    _screenReaderService.announceSuccess(context, message);
  }

  /// Announce loading
  void announceLoading(String what) {
    _screenReaderService.announceLoading(context, what);
  }

  /// Announce completion
  void announceComplete(String what) {
    _screenReaderService.announceComplete(context, what);
  }
}
