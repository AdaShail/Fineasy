import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing accessibility preferences
class AccessibilityPreferencesService {
  static final AccessibilityPreferencesService _instance =
      AccessibilityPreferencesService._internal();
  factory AccessibilityPreferencesService() => _instance;
  AccessibilityPreferencesService._internal();

  static const String _keyReducedMotion = 'accessibility_reduced_motion';
  static const String _keyHighContrast = 'accessibility_high_contrast';
  static const String _keyFontSize = 'accessibility_font_size';
  static const String _keyTextScale = 'accessibility_text_scale';

  AccessibilityPreferences _preferences = const AccessibilityPreferences();
  final List<VoidCallback> _listeners = [];

  /// Get current preferences
  AccessibilityPreferences get preferences => _preferences;

  /// Add a listener for preference changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Load preferences from storage
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    _preferences = AccessibilityPreferences(
      reducedMotion: prefs.getBool(_keyReducedMotion) ?? false,
      highContrast: prefs.getBool(_keyHighContrast) ?? false,
      fontSize: FontSize.values[prefs.getInt(_keyFontSize) ?? 1],
      textScale: prefs.getDouble(_keyTextScale) ?? 1.0,
    );

    _notifyListeners();
  }

  /// Save preferences to storage
  Future<void> savePreferences(AccessibilityPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyReducedMotion, preferences.reducedMotion);
    await prefs.setBool(_keyHighContrast, preferences.highContrast);
    await prefs.setInt(_keyFontSize, preferences.fontSize.index);
    await prefs.setDouble(_keyTextScale, preferences.textScale);

    _preferences = preferences;
    _notifyListeners();
  }

  /// Update reduced motion preference
  Future<void> setReducedMotion(bool enabled) async {
    await savePreferences(_preferences.copyWith(reducedMotion: enabled));
  }

  /// Update high contrast preference
  Future<void> setHighContrast(bool enabled) async {
    await savePreferences(_preferences.copyWith(highContrast: enabled));
  }

  /// Update font size preference
  Future<void> setFontSize(FontSize size) async {
    await savePreferences(_preferences.copyWith(fontSize: size));
  }

  /// Update text scale preference
  Future<void> setTextScale(double scale) async {
    await savePreferences(_preferences.copyWith(textScale: scale));
  }

  /// Detect system preferences
  AccessibilityPreferences detectSystemPreferences(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AccessibilityPreferences(
      reducedMotion: mediaQuery.disableAnimations,
      highContrast: mediaQuery.highContrast,
      fontSize: _preferences.fontSize,
      textScale: mediaQuery.textScaler.scale(1.0),
    );
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    await savePreferences(const AccessibilityPreferences());
  }
}

/// Accessibility preferences data class
class AccessibilityPreferences {
  final bool reducedMotion;
  final bool highContrast;
  final FontSize fontSize;
  final double textScale;

  const AccessibilityPreferences({
    this.reducedMotion = false,
    this.highContrast = false,
    this.fontSize = FontSize.medium,
    this.textScale = 1.0,
  });

  AccessibilityPreferences copyWith({
    bool? reducedMotion,
    bool? highContrast,
    FontSize? fontSize,
    double? textScale,
  }) {
    return AccessibilityPreferences(
      reducedMotion: reducedMotion ?? this.reducedMotion,
      highContrast: highContrast ?? this.highContrast,
      fontSize: fontSize ?? this.fontSize,
      textScale: textScale ?? this.textScale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccessibilityPreferences &&
        other.reducedMotion == reducedMotion &&
        other.highContrast == highContrast &&
        other.fontSize == fontSize &&
        other.textScale == textScale;
  }

  @override
  int get hashCode {
    return reducedMotion.hashCode ^
        highContrast.hashCode ^
        fontSize.hashCode ^
        textScale.hashCode;
  }
}

/// Font size options
enum FontSize {
  small,
  medium,
  large,
  extraLarge,
}

extension FontSizeExtension on FontSize {
  String get label {
    switch (this) {
      case FontSize.small:
        return 'Small';
      case FontSize.medium:
        return 'Medium';
      case FontSize.large:
        return 'Large';
      case FontSize.extraLarge:
        return 'Extra Large';
    }
  }

  double get scale {
    switch (this) {
      case FontSize.small:
        return 0.875;
      case FontSize.medium:
        return 1.0;
      case FontSize.large:
        return 1.125;
      case FontSize.extraLarge:
        return 1.25;
    }
  }
}

/// Provider for accessibility preferences
class AccessibilityPreferencesProvider extends InheritedWidget {
  final AccessibilityPreferences preferences;
  final AccessibilityPreferencesService service;

  const AccessibilityPreferencesProvider({
    super.key,
    required this.preferences,
    required this.service,
    required super.child,
  });

  static AccessibilityPreferencesProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AccessibilityPreferencesProvider>();
  }

  @override
  bool updateShouldNotify(AccessibilityPreferencesProvider oldWidget) {
    return preferences != oldWidget.preferences;
  }
}

/// Widget that respects reduced motion preference
class ReducedMotionWidget extends StatelessWidget {
  final Widget child;
  final Widget reducedChild;
  final bool? forceReduced;

  const ReducedMotionWidget({
    super.key,
    required this.child,
    required this.reducedChild,
    this.forceReduced,
  });

  @override
  Widget build(BuildContext context) {
    final provider = AccessibilityPreferencesProvider.of(context);
    final shouldReduce = forceReduced ??
        provider?.preferences.reducedMotion ??
        MediaQuery.of(context).disableAnimations;

    return shouldReduce ? reducedChild : child;
  }
}

/// Widget that applies high contrast mode
class HighContrastWidget extends StatelessWidget {
  final Widget child;
  final ColorScheme? highContrastColorScheme;

  const HighContrastWidget({
    super.key,
    required this.child,
    this.highContrastColorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final provider = AccessibilityPreferencesProvider.of(context);
    final shouldUseHighContrast = provider?.preferences.highContrast ??
        MediaQuery.of(context).highContrast;

    if (!shouldUseHighContrast) {
      return child;
    }

    final theme = Theme.of(context);
    final highContrastTheme = theme.copyWith(
      colorScheme: highContrastColorScheme ?? _createHighContrastColorScheme(theme),
    );

    return Theme(
      data: highContrastTheme,
      child: child,
    );
  }

  ColorScheme _createHighContrastColorScheme(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return ColorScheme(
      brightness: theme.brightness,
      primary: isDark ? Colors.white : Colors.black,
      onPrimary: isDark ? Colors.black : Colors.white,
      secondary: isDark ? Colors.yellow : Colors.blue.shade900,
      onSecondary: isDark ? Colors.black : Colors.white,
      error: isDark ? Colors.red.shade300 : Colors.red.shade900,
      onError: Colors.white,
      surface: isDark ? Colors.black : Colors.white,
      onSurface: isDark ? Colors.white : Colors.black,
    );
  }
}

/// Widget that applies font size adjustments
class FontSizeAdjustmentWidget extends StatelessWidget {
  final Widget child;

  const FontSizeAdjustmentWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final provider = AccessibilityPreferencesProvider.of(context);
    final textScale = provider?.preferences.textScale ?? 1.0;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
      ),
      child: child,
    );
  }
}

/// Accessibility settings panel widget
class AccessibilitySettingsPanel extends StatefulWidget {
  const AccessibilitySettingsPanel({super.key});

  @override
  State<AccessibilitySettingsPanel> createState() => _AccessibilitySettingsPanelState();
}

class _AccessibilitySettingsPanelState extends State<AccessibilitySettingsPanel> {
  final _service = AccessibilityPreferencesService();
  late AccessibilityPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = _service.preferences;
    _service.addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    setState(() {
      _preferences = _service.preferences;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accessibility Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Reduced Motion'),
              subtitle: const Text('Minimize animations and transitions'),
              value: _preferences.reducedMotion,
              onChanged: (value) {
                _service.setReducedMotion(value);
              },
            ),
            SwitchListTile(
              title: const Text('High Contrast Mode'),
              subtitle: const Text('Increase contrast for better visibility'),
              value: _preferences.highContrast,
              onChanged: (value) {
                _service.setHighContrast(value);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Font Size'),
              subtitle: Text(_preferences.fontSize.label),
            ),
            Slider(
              value: _preferences.fontSize.index.toDouble(),
              min: 0,
              max: FontSize.values.length - 1.0,
              divisions: FontSize.values.length - 1,
              label: _preferences.fontSize.label,
              onChanged: (value) {
                _service.setFontSize(FontSize.values[value.toInt()]);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Text Scale'),
              subtitle: Text('${(_preferences.textScale * 100).toInt()}%'),
            ),
            Slider(
              value: _preferences.textScale,
              min: 0.75,
              max: 2.0,
              divisions: 25,
              label: '${(_preferences.textScale * 100).toInt()}%',
              onChanged: (value) {
                _service.setTextScale(value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _service.resetToDefaults();
                  },
                  child: const Text('Reset to Defaults'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final systemPrefs = _service.detectSystemPreferences(context);
                    _service.savePreferences(systemPrefs);
                  },
                  child: const Text('Use System Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mixin for accessibility preferences
mixin AccessibilityPreferencesMixin<T extends StatefulWidget> on State<T> {
  final AccessibilityPreferencesService _service = AccessibilityPreferencesService();

  AccessibilityPreferences get preferences => _service.preferences;

  bool get reducedMotion => preferences.reducedMotion;
  bool get highContrast => preferences.highContrast;
  FontSize get fontSize => preferences.fontSize;
  double get textScale => preferences.textScale;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Get animation duration based on reduced motion preference
  Duration getAnimationDuration(Duration normal) {
    return reducedMotion ? Duration.zero : normal;
  }

  /// Get curve based on reduced motion preference
  Curve getAnimationCurve(Curve normal) {
    return reducedMotion ? Curves.linear : normal;
  }
}

/// Helper to create accessible animations
class AccessibleAnimation {
  /// Create an animation controller that respects reduced motion
  static AnimationController createController({
    required TickerProvider vsync,
    required Duration duration,
    bool respectReducedMotion = true,
  }) {
    final service = AccessibilityPreferencesService();
    final effectiveDuration = respectReducedMotion && service.preferences.reducedMotion
        ? Duration.zero
        : duration;

    return AnimationController(
      vsync: vsync,
      duration: effectiveDuration,
    );
  }

  /// Create a tween animation that respects reduced motion
  static Animation<T> createTween<T>({
    required AnimationController controller,
    required Tween<T> tween,
    Curve curve = Curves.easeInOut,
    bool respectReducedMotion = true,
  }) {
    final service = AccessibilityPreferencesService();
    final effectiveCurve = respectReducedMotion && service.preferences.reducedMotion
        ? Curves.linear
        : curve;

    return tween.animate(
      CurvedAnimation(
        parent: controller,
        curve: effectiveCurve,
      ),
    );
  }
}
