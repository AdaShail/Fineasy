/// Design token system for border radius
/// Provides consistent border radius values for component variants
library;

import 'package:flutter/material.dart';

/// Border radius tokens
class BorderRadiusTokens {
  /// No radius (0px)
  static const double none = 0.0;

  /// Small radius (4px)
  /// Used for: Small buttons, chips
  static const double sm = 4.0;

  /// Base radius (8px)
  /// Used for: Default buttons, inputs, cards
  static const double base = 8.0;

  /// Medium radius (12px)
  /// Used for: Medium cards, modals
  static const double md = 12.0;

  /// Large radius (16px)
  /// Used for: Large cards, containers
  static const double lg = 16.0;

  /// Extra large radius (24px)
  /// Used for: Hero sections, large containers
  static const double xl = 24.0;

  /// 2X large radius (32px)
  /// Used for: Special containers
  static const double xl2 = 32.0;

  /// Full radius (9999px)
  /// Used for: Pills, circular buttons, avatars
  static const double full = 9999.0;

  /// Get radius value by name
  static double getRadius(String name) {
    switch (name.toLowerCase()) {
      case 'none':
        return none;
      case 'sm':
        return sm;
      case 'base':
        return base;
      case 'md':
        return md;
      case 'lg':
        return lg;
      case 'xl':
        return xl;
      case '2xl':
        return xl2;
      case 'full':
        return full;
      default:
        return base;
    }
  }

  /// Get BorderRadius object by name
  static BorderRadius getBorderRadius(String name) {
    return BorderRadius.circular(getRadius(name));
  }

  /// All radius values as a map
  static const Map<String, double> all = {
    'none': none,
    'sm': sm,
    'base': base,
    'md': md,
    'lg': lg,
    'xl': xl,
    '2xl': xl2,
    'full': full,
  };
}

/// Semantic border radius tokens for common use cases
class SemanticBorderRadius {
  /// Button border radius (8px)
  static const double button = BorderRadiusTokens.base;

  /// Input field border radius (8px)
  static const double input = BorderRadiusTokens.base;

  /// Card border radius (12px)
  static const double card = BorderRadiusTokens.md;

  /// Modal border radius (16px)
  static const double modal = BorderRadiusTokens.lg;

  /// Chip/Tag border radius (full)
  static const double chip = BorderRadiusTokens.full;

  /// Avatar border radius (full)
  static const double avatar = BorderRadiusTokens.full;

  /// Badge border radius (full)
  static const double badge = BorderRadiusTokens.full;

  /// Dropdown border radius (8px)
  static const double dropdown = BorderRadiusTokens.base;

  /// Tooltip border radius (4px)
  static const double tooltip = BorderRadiusTokens.sm;

  /// Toast notification border radius (8px)
  static const double toast = BorderRadiusTokens.base;

  /// Get BorderRadius object for semantic use case
  static BorderRadius get(String name) {
    double radius;
    switch (name.toLowerCase()) {
      case 'button':
        radius = button;
        break;
      case 'input':
        radius = input;
        break;
      case 'card':
        radius = card;
        break;
      case 'modal':
        radius = modal;
        break;
      case 'chip':
        radius = chip;
        break;
      case 'avatar':
        radius = avatar;
        break;
      case 'badge':
        radius = badge;
        break;
      case 'dropdown':
        radius = dropdown;
        break;
      case 'tooltip':
        radius = tooltip;
        break;
      case 'toast':
        radius = toast;
        break;
      default:
        radius = BorderRadiusTokens.base;
    }
    return BorderRadius.circular(radius);
  }
}

/// Border width tokens
class BorderWidthTokens {
  /// No border (0px)
  static const double none = 0.0;

  /// Thin border (1px)
  static const double thin = 1.0;

  /// Default border (2px)
  static const double base = 2.0;

  /// Thick border (4px)
  static const double thick = 4.0;

  /// Get border width by name
  static double getWidth(String name) {
    switch (name.toLowerCase()) {
      case 'none':
        return none;
      case 'thin':
        return thin;
      case 'base':
        return base;
      case 'thick':
        return thick;
      default:
        return thin;
    }
  }
}
