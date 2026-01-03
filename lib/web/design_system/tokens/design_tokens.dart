/// Design Token System
/// Central export file for all design tokens
/// 
/// This file provides a unified interface to access all design tokens
/// including colors, typography, spacing, shadows, border radius, and animations.
library;

export 'color_tokens.dart';
export 'typography_tokens.dart';
export 'spacing_tokens.dart';
export 'shadow_tokens.dart';
export 'border_radius_tokens.dart';
export 'animation_tokens.dart';

import 'package:flutter/material.dart';
import 'color_tokens.dart';
import 'typography_tokens.dart';
import 'spacing_tokens.dart';
import 'shadow_tokens.dart';
import 'border_radius_tokens.dart';
import 'animation_tokens.dart';

/// Complete design token system
class DesignTokens {
  final ColorTokens colors;
  final TypographyTokens typography;
  final Map<String, double> spacing;
  final Map<String, List<BoxShadow>> shadows;
  final Map<String, double> borderRadius;
  final Map<String, Duration> animationDuration;
  final Map<String, Curve> animationEasing;

  const DesignTokens({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.shadows,
    required this.borderRadius,
    required this.animationDuration,
    required this.animationEasing,
  });

  /// Light theme tokens
  static final light = DesignTokens(
    colors: LightColorTokens.tokens,
    typography: TypographyTokens.defaultTokens,
    spacing: SpacingTokens.all,
    shadows: ShadowTokens.all,
    borderRadius: BorderRadiusTokens.all,
    animationDuration: AnimationDurationTokens.all,
    animationEasing: AnimationEasingTokens.all,
  );

  /// Dark theme tokens
  static final dark = DesignTokens(
    colors: DarkColorTokens.tokens,
    typography: TypographyTokens.defaultTokens,
    spacing: SpacingTokens.all,
    shadows: ShadowTokens.all,
    borderRadius: BorderRadiusTokens.all,
    animationDuration: AnimationDurationTokens.all,
    animationEasing: AnimationEasingTokens.all,
  );
}

/// Theme configuration with light and dark variants
class ThemeTokens {
  final DesignTokens light;
  final DesignTokens dark;
  final ThemeMode currentMode;

  const ThemeTokens({
    required this.light,
    required this.dark,
    this.currentMode = ThemeMode.system,
  });

  /// Get current theme tokens based on mode
  DesignTokens getCurrent(Brightness brightness) {
    if (currentMode == ThemeMode.light) {
      return light;
    } else if (currentMode == ThemeMode.dark) {
      return dark;
    } else {
      // System mode - use brightness
      return brightness == Brightness.dark ? dark : light;
    }
  }

  /// Default theme configuration
  static final defaultTheme = ThemeTokens(
    light: DesignTokens.light,
    dark: DesignTokens.dark,
  );
}

/// Token utility functions
class TokenUtils {
  /// Convert spacing token to EdgeInsets
  static EdgeInsets spacingToInsets(double spacing) {
    return EdgeInsets.all(spacing);
  }

  /// Convert spacing tokens to EdgeInsets with different values
  static EdgeInsets spacingToInsetsSymmetric({
    required double horizontal,
    required double vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  /// Convert spacing tokens to EdgeInsets with individual values
  static EdgeInsets spacingToInsetsOnly({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left ?? 0,
      top: top ?? 0,
      right: right ?? 0,
      bottom: bottom ?? 0,
    );
  }

  /// Create SizedBox with spacing
  static SizedBox spacingBox(double spacing) {
    return SizedBox(
      width: spacing,
      height: spacing,
    );
  }

  /// Create horizontal spacing
  static SizedBox horizontalSpacing(double spacing) {
    return SizedBox(width: spacing);
  }

  /// Create vertical spacing
  static SizedBox verticalSpacing(double spacing) {
    return SizedBox(height: spacing);
  }

  /// Apply shadow to BoxDecoration
  static BoxDecoration decorationWithShadow({
    Color? color,
    BorderRadius? borderRadius,
    required List<BoxShadow> shadow,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      boxShadow: shadow,
    );
  }

  /// Create rounded container decoration
  static BoxDecoration roundedDecoration({
    required Color color,
    required double borderRadius,
    List<BoxShadow>? shadow,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadow,
      border: border,
    );
  }
}

/// Extension methods for easy token access
extension BuildContextTokens on BuildContext {
  /// Get design tokens for current theme
  DesignTokens get tokens {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? DesignTokens.dark
        : DesignTokens.light;
  }

  /// Get color tokens
  ColorTokens get colors => tokens.colors;

  /// Get typography tokens
  TypographyTokens get typography => tokens.typography;

  /// Get spacing value by name
  double spacing(String name) {
    return SpacingTokens.getSpaceByName(name);
  }

  /// Get shadow by name
  List<BoxShadow> shadow(String name) {
    return ShadowTokens.getShadow(name);
  }

  /// Get border radius by name
  double borderRadius(String name) {
    return BorderRadiusTokens.getRadius(name);
  }

  /// Get animation duration by name
  Duration animationDuration(String name) {
    return AnimationDurationTokens.getDuration(name);
  }

  /// Get animation curve by name
  Curve animationCurve(String name) {
    return AnimationEasingTokens.getCurve(name);
  }
}
