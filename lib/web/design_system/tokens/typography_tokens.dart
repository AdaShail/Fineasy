/// Design token system for typography
/// Provides font families, sizes, weights, line heights, and letter spacing
library;

import 'package:flutter/material.dart';

/// Font family tokens
class FontFamilyTokens {
  /// Primary UI font (sans-serif)
  static const String sans = 'Inter';

  /// Optional serif font for headings
  static const String serif = 'Merriweather';

  /// Monospace font for code and numbers
  static const String mono = 'JetBrains Mono';

  /// Get font family by name
  static String getFamily(String name) {
    switch (name.toLowerCase()) {
      case 'sans':
        return sans;
      case 'serif':
        return serif;
      case 'mono':
        return mono;
      default:
        return sans;
    }
  }
}

/// Font size tokens
class FontSizeTokens {
  static const double xs = 12.0;
  static const double sm = 14.0;
  static const double base = 16.0;
  static const double lg = 18.0;
  static const double xl = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 30.0;
  static const double xl4 = 36.0;
  static const double xl5 = 48.0;
  static const double xl6 = 60.0;

  /// Get font size by name
  static double getSize(String name) {
    switch (name.toLowerCase()) {
      case 'xs':
        return xs;
      case 'sm':
        return sm;
      case 'base':
        return base;
      case 'lg':
        return lg;
      case 'xl':
        return xl;
      case '2xl':
        return xl2;
      case '3xl':
        return xl3;
      case '4xl':
        return xl4;
      case '5xl':
        return xl5;
      case '6xl':
        return xl6;
      default:
        return base;
    }
  }
}

/// Font weight tokens
class FontWeightTokens {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight normal = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extrabold = FontWeight.w800;

  /// Get font weight by name
  static FontWeight getWeight(String name) {
    switch (name.toLowerCase()) {
      case 'light':
        return light;
      case 'normal':
        return normal;
      case 'medium':
        return medium;
      case 'semibold':
        return semibold;
      case 'bold':
        return bold;
      case 'extrabold':
        return extrabold;
      default:
        return normal;
    }
  }
}

/// Line height tokens
class LineHeightTokens {
  static const double none = 1.0;
  static const double tight = 1.25;
  static const double snug = 1.375;
  static const double normal = 1.5;
  static const double relaxed = 1.625;
  static const double loose = 2.0;

  /// Get line height by name
  static double getHeight(String name) {
    switch (name.toLowerCase()) {
      case 'none':
        return none;
      case 'tight':
        return tight;
      case 'snug':
        return snug;
      case 'normal':
        return normal;
      case 'relaxed':
        return relaxed;
      case 'loose':
        return loose;
      default:
        return normal;
    }
  }
}

/// Letter spacing tokens
class LetterSpacingTokens {
  static const double tighter = -0.05;
  static const double tight = -0.025;
  static const double normal = 0.0;
  static const double wide = 0.025;
  static const double wider = 0.05;
  static const double widest = 0.1;

  /// Get letter spacing by name (returns em units)
  static double getSpacing(String name) {
    switch (name.toLowerCase()) {
      case 'tighter':
        return tighter;
      case 'tight':
        return tight;
      case 'normal':
        return normal;
      case 'wide':
        return wide;
      case 'wider':
        return wider;
      case 'widest':
        return widest;
      default:
        return normal;
    }
  }
}

/// Complete typography token system
class TypographyTokens {
  final String fontFamilySans;
  final String fontFamilySerif;
  final String fontFamilyMono;

  final Map<String, double> fontSize;
  final Map<String, FontWeight> fontWeight;
  final Map<String, double> lineHeight;
  final Map<String, double> letterSpacing;

  const TypographyTokens({
    required this.fontFamilySans,
    required this.fontFamilySerif,
    required this.fontFamilyMono,
    required this.fontSize,
    required this.fontWeight,
    required this.lineHeight,
    required this.letterSpacing,
  });

  /// Default typography tokens
  static const defaultTokens = TypographyTokens(
    fontFamilySans: FontFamilyTokens.sans,
    fontFamilySerif: FontFamilyTokens.serif,
    fontFamilyMono: FontFamilyTokens.mono,
    fontSize: {
      'xs': FontSizeTokens.xs,
      'sm': FontSizeTokens.sm,
      'base': FontSizeTokens.base,
      'lg': FontSizeTokens.lg,
      'xl': FontSizeTokens.xl,
      '2xl': FontSizeTokens.xl2,
      '3xl': FontSizeTokens.xl3,
      '4xl': FontSizeTokens.xl4,
      '5xl': FontSizeTokens.xl5,
      '6xl': FontSizeTokens.xl6,
    },
    fontWeight: {
      'light': FontWeightTokens.light,
      'normal': FontWeightTokens.normal,
      'medium': FontWeightTokens.medium,
      'semibold': FontWeightTokens.semibold,
      'bold': FontWeightTokens.bold,
      'extrabold': FontWeightTokens.extrabold,
    },
    lineHeight: {
      'none': LineHeightTokens.none,
      'tight': LineHeightTokens.tight,
      'snug': LineHeightTokens.snug,
      'normal': LineHeightTokens.normal,
      'relaxed': LineHeightTokens.relaxed,
      'loose': LineHeightTokens.loose,
    },
    letterSpacing: {
      'tighter': LetterSpacingTokens.tighter,
      'tight': LetterSpacingTokens.tight,
      'normal': LetterSpacingTokens.normal,
      'wide': LetterSpacingTokens.wide,
      'wider': LetterSpacingTokens.wider,
      'widest': LetterSpacingTokens.widest,
    },
  );
}

/// Text style presets for common use cases
class TextStylePresets {
  static TextStyle h1({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.sans,
        fontSize: FontSizeTokens.xl6,
        fontWeight: FontWeightTokens.bold,
        height: LineHeightTokens.tight,
        letterSpacing: LetterSpacingTokens.tight,
        color: color,
      );

  static TextStyle h2({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.sans,
        fontSize: FontSizeTokens.xl5,
        fontWeight: FontWeightTokens.bold,
        height: LineHeightTokens.tight,
        letterSpacing: LetterSpacingTokens.tight,
        color: color,
      );

  static TextStyle h3({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.sans,
        fontSize: FontSizeTokens.xl4,
        fontWeight: FontWeightTokens.semibold,
        height: LineHeightTokens.snug,
        letterSpacing: LetterSpacingTokens.normal,
        color: color,
      );

  static TextStyle h4({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.sans,
        fontSize: FontSizeTokens.xl3,
        fontWeight: FontWeightTokens.semibold,
        height: LineHeightTokens.snug,
        letterSpacing: LetterSpacingTokens.normal,
        color: color,
      );

  static TextStyle h5({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.sans,
        fontSize: FontSizeTokens.xl2,
        fontWeight: FontWeightTokens.medium,
        height: LineHeightTokens.normal,
        letterSpacing: LetterSpacingTokens.normal,
        color: color,
      );

  static TextStyle h6({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.sans,
        fontSize: FontSizeTokens.xl,
        fontWeight: FontWeightTokens.medium,
        height: LineHeightTokens.normal,
        letterSpacing: LetterSpacingTokens.normal,
        color: color,
      );

  static TextStyle bodyLarge({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.sans,
        fontSize: FontSizeTokens.lg,
        fontWeight: FontWeightTokens.normal,
        height: LineHeightTokens.relaxed,
        letterSpacing: LetterSpacingTokens.normal,
        color: color,
      );

  static TextStyle body({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.sans,
        fontSize: FontSizeTokens.base,
        fontWeight: FontWeightTokens.normal,
        height: LineHeightTokens.normal,
        letterSpacing: LetterSpacingTokens.normal,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.sans,
        fontSize: FontSizeTokens.sm,
        fontWeight: FontWeightTokens.normal,
        height: LineHeightTokens.normal,
        letterSpacing: LetterSpacingTokens.normal,
        color: color,
      );

  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.sans,
        fontSize: FontSizeTokens.xs,
        fontWeight: FontWeightTokens.normal,
        height: LineHeightTokens.normal,
        letterSpacing: LetterSpacingTokens.wide,
        color: color,
      );

  static TextStyle label({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.sans,
        fontSize: FontSizeTokens.sm,
        fontWeight: FontWeightTokens.medium,
        height: LineHeightTokens.normal,
        letterSpacing: LetterSpacingTokens.wide,
        color: color,
      );

  static TextStyle code({Color? color}) => TextStyle(
        fontFamily: FontFamilyTokens.mono,
        fontSize: FontSizeTokens.sm,
        fontWeight: FontWeightTokens.normal,
        height: LineHeightTokens.normal,
        letterSpacing: LetterSpacingTokens.normal,
        color: color,
      );
}
