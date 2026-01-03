/// Design token system for shadows and elevation
/// Provides shadow definitions for different elevation levels
library;

import 'package:flutter/material.dart';

/// Shadow tokens for elevation levels
class ShadowTokens {
  /// No shadow
  static const List<BoxShadow> none = [];

  /// Subtle elevation (level 1)
  /// Used for: Slightly raised elements
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Default elevation (level 2)
  /// Used for: Cards, buttons
  static const List<BoxShadow> base = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Medium elevation (level 3)
  /// Used for: Dropdowns, popovers
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];

  /// Large elevation (level 4)
  /// Used for: Modals, dialogs
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
  ];

  /// Extra large elevation (level 5)
  /// Used for: High elevation modals
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x19000000), // 10% black
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x24000000), // 14% black
      offset: Offset(0, 10),
      blurRadius: 10,
      spreadRadius: -5,
    ),
  ];

  /// Maximum elevation (level 6)
  /// Used for: Overlays, full-screen modals
  static const List<BoxShadow> xl2 = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      offset: Offset(0, 25),
      blurRadius: 50,
      spreadRadius: -12,
    ),
  ];

  /// Inset shadow
  /// Used for: Input fields, pressed states
  static const List<BoxShadow> inner = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Get shadow by name
  static List<BoxShadow> getShadow(String name) {
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
      case 'inner':
        return inner;
      default:
        return base;
    }
  }

  /// All shadow values as a map
  static const Map<String, List<BoxShadow>> all = {
    'none': none,
    'sm': sm,
    'base': base,
    'md': md,
    'lg': lg,
    'xl': xl,
    '2xl': xl2,
    'inner': inner,
  };
}

/// Z-index tokens for layering
class ZIndexTokens {
  /// Base layer (0)
  static const int base = 0;

  /// Dropdown layer (10)
  static const int dropdown = 10;

  /// Sticky elements (20)
  static const int sticky = 20;

  /// Fixed elements (30)
  static const int fixed = 30;

  /// Modal backdrop (40)
  static const int modalBackdrop = 40;

  /// Modal content (50)
  static const int modal = 50;

  /// Popover layer (60)
  static const int popover = 60;

  /// Tooltip layer (70)
  static const int tooltip = 70;

  /// Toast notification layer (80)
  static const int toast = 80;

  /// Maximum layer (100)
  static const int max = 100;

  /// Get z-index by name
  static int getZIndex(String name) {
    switch (name.toLowerCase()) {
      case 'base':
        return base;
      case 'dropdown':
        return dropdown;
      case 'sticky':
        return sticky;
      case 'fixed':
        return fixed;
      case 'modalbackdrop':
        return modalBackdrop;
      case 'modal':
        return modal;
      case 'popover':
        return popover;
      case 'tooltip':
        return tooltip;
      case 'toast':
        return toast;
      case 'max':
        return max;
      default:
        return base;
    }
  }
}

/// Elevation helper for Material Design elevation
class ElevationTokens {
  /// Level 0 - No elevation
  static const double level0 = 0.0;

  /// Level 1 - Subtle elevation (1dp)
  static const double level1 = 1.0;

  /// Level 2 - Default elevation (2dp)
  static const double level2 = 2.0;

  /// Level 3 - Medium elevation (4dp)
  static const double level3 = 4.0;

  /// Level 4 - High elevation (8dp)
  static const double level4 = 8.0;

  /// Level 5 - Maximum elevation (16dp)
  static const double level5 = 16.0;

  /// Get elevation by level
  static double getElevation(int level) {
    switch (level) {
      case 0:
        return level0;
      case 1:
        return level1;
      case 2:
        return level2;
      case 3:
        return level3;
      case 4:
        return level4;
      case 5:
        return level5;
      default:
        return level2;
    }
  }
}
