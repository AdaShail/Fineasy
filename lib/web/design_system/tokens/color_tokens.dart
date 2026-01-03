/// Design token system for colors
/// Provides a comprehensive color palette with light and dark theme variants
library;

import 'package:flutter/material.dart';

/// Color shade structure for a single color family
class ColorShades {
  final Color shade50;
  final Color shade100;
  final Color shade200;
  final Color shade300;
  final Color shade400;
  final Color shade500; // Base color
  final Color shade600;
  final Color shade700;
  final Color shade800;
  final Color shade900;

  const ColorShades({
    required this.shade50,
    required this.shade100,
    required this.shade200,
    required this.shade300,
    required this.shade400,
    required this.shade500,
    required this.shade600,
    required this.shade700,
    required this.shade800,
    required this.shade900,
  });

  /// Get shade by index (50-900)
  Color getShade(int shade) {
    switch (shade) {
      case 50:
        return shade50;
      case 100:
        return shade100;
      case 200:
        return shade200;
      case 300:
        return shade300;
      case 400:
        return shade400;
      case 500:
        return shade500;
      case 600:
        return shade600;
      case 700:
        return shade700;
      case 800:
        return shade800;
      case 900:
        return shade900;
      default:
        return shade500; // Default to base color
    }
  }
}

/// Semantic color tokens for success, warning, error, and info states
class SemanticColors {
  final ColorShades success;
  final ColorShades warning;
  final ColorShades error;
  final ColorShades info;

  const SemanticColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });
}

/// Surface colors for backgrounds, cards, and overlays
class SurfaceColors {
  final Color background;
  final Color foreground;
  final Color card;
  final Color overlay;
  final Color elevated;

  const SurfaceColors({
    required this.background,
    required this.foreground,
    required this.card,
    required this.overlay,
    required this.elevated,
  });
}

/// Neutral color scale from white to black
class NeutralColors {
  final Color shade0; // Pure white
  final Color shade50;
  final Color shade100;
  final Color shade200;
  final Color shade300;
  final Color shade400;
  final Color shade500;
  final Color shade600;
  final Color shade700;
  final Color shade800;
  final Color shade900;
  final Color shade1000; // Pure black

  const NeutralColors({
    required this.shade0,
    required this.shade50,
    required this.shade100,
    required this.shade200,
    required this.shade300,
    required this.shade400,
    required this.shade500,
    required this.shade600,
    required this.shade700,
    required this.shade800,
    required this.shade900,
    required this.shade1000,
  });

  /// Get shade by index (0-1000)
  Color getShade(int shade) {
    switch (shade) {
      case 0:
        return shade0;
      case 50:
        return shade50;
      case 100:
        return shade100;
      case 200:
        return shade200;
      case 300:
        return shade300;
      case 400:
        return shade400;
      case 500:
        return shade500;
      case 600:
        return shade600;
      case 700:
        return shade700;
      case 800:
        return shade800;
      case 900:
        return shade900;
      case 1000:
        return shade1000;
      default:
        return shade500; // Default to middle gray
    }
  }
}

/// Complete color token system for a theme
class ColorTokens {
  final ColorShades primary;
  final ColorShades secondary;
  final ColorShades accent;
  final NeutralColors neutral;
  final SemanticColors semantic;
  final SurfaceColors surface;

  const ColorTokens({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.neutral,
    required this.semantic,
    required this.surface,
  });
}

/// Light theme color tokens
class LightColorTokens {
  static const primary = ColorShades(
    shade50: Color(0xFFE3F2FD),
    shade100: Color(0xFFBBDEFB),
    shade200: Color(0xFF90CAF9),
    shade300: Color(0xFF64B5F6),
    shade400: Color(0xFF42A5F5),
    shade500: Color(0xFF2196F3), // Base
    shade600: Color(0xFF1E88E5),
    shade700: Color(0xFF1976D2),
    shade800: Color(0xFF1565C0),
    shade900: Color(0xFF0D47A1),
  );

  static const secondary = ColorShades(
    shade50: Color(0xFFF3E5F5),
    shade100: Color(0xFFE1BEE7),
    shade200: Color(0xFFCE93D8),
    shade300: Color(0xFFBA68C8),
    shade400: Color(0xFFAB47BC),
    shade500: Color(0xFF9C27B0), // Base
    shade600: Color(0xFF8E24AA),
    shade700: Color(0xFF7B1FA2),
    shade800: Color(0xFF6A1B9A),
    shade900: Color(0xFF4A148C),
  );

  static const accent = ColorShades(
    shade50: Color(0xFFE8F5E9),
    shade100: Color(0xFFC8E6C9),
    shade200: Color(0xFFA5D6A7),
    shade300: Color(0xFF81C784),
    shade400: Color(0xFF66BB6A),
    shade500: Color(0xFF4CAF50), // Base
    shade600: Color(0xFF43A047),
    shade700: Color(0xFF388E3C),
    shade800: Color(0xFF2E7D32),
    shade900: Color(0xFF1B5E20),
  );

  static const neutral = NeutralColors(
    shade0: Color(0xFFFFFFFF),
    shade50: Color(0xFFFAFAFA),
    shade100: Color(0xFFF5F5F5),
    shade200: Color(0xFFEEEEEE),
    shade300: Color(0xFFE0E0E0),
    shade400: Color(0xFFBDBDBD),
    shade500: Color(0xFF9E9E9E),
    shade600: Color(0xFF757575),
    shade700: Color(0xFF616161),
    shade800: Color(0xFF424242),
    shade900: Color(0xFF212121),
    shade1000: Color(0xFF000000),
  );

  static const success = ColorShades(
    shade50: Color(0xFFE8F5E9),
    shade100: Color(0xFFC8E6C9),
    shade200: Color(0xFFA5D6A7),
    shade300: Color(0xFF81C784),
    shade400: Color(0xFF66BB6A),
    shade500: Color(0xFF4CAF50), // Base
    shade600: Color(0xFF43A047),
    shade700: Color(0xFF388E3C),
    shade800: Color(0xFF2E7D32),
    shade900: Color(0xFF1B5E20),
  );

  static const warning = ColorShades(
    shade50: Color(0xFFFFF3E0),
    shade100: Color(0xFFFFE0B2),
    shade200: Color(0xFFFFCC80),
    shade300: Color(0xFFFFB74D),
    shade400: Color(0xFFFFA726),
    shade500: Color(0xFFFF9800), // Base
    shade600: Color(0xFFFB8C00),
    shade700: Color(0xFFF57C00),
    shade800: Color(0xFFEF6C00),
    shade900: Color(0xFFE65100),
  );

  static const error = ColorShades(
    shade50: Color(0xFFFFEBEE),
    shade100: Color(0xFFFFCDD2),
    shade200: Color(0xFFEF9A9A),
    shade300: Color(0xFFE57373),
    shade400: Color(0xFFEF5350),
    shade500: Color(0xFFF44336), // Base
    shade600: Color(0xFFE53935),
    shade700: Color(0xFFD32F2F),
    shade800: Color(0xFFC62828),
    shade900: Color(0xFFB71C1C),
  );

  static const info = ColorShades(
    shade50: Color(0xFFE1F5FE),
    shade100: Color(0xFFB3E5FC),
    shade200: Color(0xFF81D4FA),
    shade300: Color(0xFF4FC3F7),
    shade400: Color(0xFF29B6F6),
    shade500: Color(0xFF03A9F4), // Base
    shade600: Color(0xFF039BE5),
    shade700: Color(0xFF0288D1),
    shade800: Color(0xFF0277BD),
    shade900: Color(0xFF01579B),
  );

  static const semantic = SemanticColors(
    success: success,
    warning: warning,
    error: error,
    info: info,
  );

  static const surface = SurfaceColors(
    background: Color(0xFFFAFAFA),
    foreground: Color(0xFF212121),
    card: Color(0xFFFFFFFF),
    overlay: Color(0x80000000), // 50% black
    elevated: Color(0xFFFFFFFF),
  );

  static const tokens = ColorTokens(
    primary: primary,
    secondary: secondary,
    accent: accent,
    neutral: neutral,
    semantic: semantic,
    surface: surface,
  );
}

/// Dark theme color tokens
class DarkColorTokens {
  static const primary = ColorShades(
    shade50: Color(0xFF0D47A1),
    shade100: Color(0xFF1565C0),
    shade200: Color(0xFF1976D2),
    shade300: Color(0xFF1E88E5),
    shade400: Color(0xFF2196F3),
    shade500: Color(0xFF42A5F5), // Base (lighter for dark theme)
    shade600: Color(0xFF64B5F6),
    shade700: Color(0xFF90CAF9),
    shade800: Color(0xFFBBDEFB),
    shade900: Color(0xFFE3F2FD),
  );

  static const secondary = ColorShades(
    shade50: Color(0xFF4A148C),
    shade100: Color(0xFF6A1B9A),
    shade200: Color(0xFF7B1FA2),
    shade300: Color(0xFF8E24AA),
    shade400: Color(0xFF9C27B0),
    shade500: Color(0xFFAB47BC), // Base (lighter for dark theme)
    shade600: Color(0xFFBA68C8),
    shade700: Color(0xFFCE93D8),
    shade800: Color(0xFFE1BEE7),
    shade900: Color(0xFFF3E5F5),
  );

  static const accent = ColorShades(
    shade50: Color(0xFF1B5E20),
    shade100: Color(0xFF2E7D32),
    shade200: Color(0xFF388E3C),
    shade300: Color(0xFF43A047),
    shade400: Color(0xFF4CAF50),
    shade500: Color(0xFF66BB6A), // Base (lighter for dark theme)
    shade600: Color(0xFF81C784),
    shade700: Color(0xFFA5D6A7),
    shade800: Color(0xFFC8E6C9),
    shade900: Color(0xFFE8F5E9),
  );

  static const neutral = NeutralColors(
    shade0: Color(0xFF000000),
    shade50: Color(0xFF0A0A0A),
    shade100: Color(0xFF1A1A1A),
    shade200: Color(0xFF2A2A2A),
    shade300: Color(0xFF3A3A3A),
    shade400: Color(0xFF4A4A4A),
    shade500: Color(0xFF6A6A6A),
    shade600: Color(0xFF8A8A8A),
    shade700: Color(0xFFAAAAAA),
    shade800: Color(0xFFCACACA),
    shade900: Color(0xFFEAEAEA),
    shade1000: Color(0xFFFFFFFF),
  );

  static const success = ColorShades(
    shade50: Color(0xFF1B5E20),
    shade100: Color(0xFF2E7D32),
    shade200: Color(0xFF388E3C),
    shade300: Color(0xFF43A047),
    shade400: Color(0xFF4CAF50),
    shade500: Color(0xFF66BB6A), // Base
    shade600: Color(0xFF81C784),
    shade700: Color(0xFFA5D6A7),
    shade800: Color(0xFFC8E6C9),
    shade900: Color(0xFFE8F5E9),
  );

  static const warning = ColorShades(
    shade50: Color(0xFFE65100),
    shade100: Color(0xFFEF6C00),
    shade200: Color(0xFFF57C00),
    shade300: Color(0xFFFB8C00),
    shade400: Color(0xFFFF9800),
    shade500: Color(0xFFFFA726), // Base
    shade600: Color(0xFFFFB74D),
    shade700: Color(0xFFFFCC80),
    shade800: Color(0xFFFFE0B2),
    shade900: Color(0xFFFFF3E0),
  );

  static const error = ColorShades(
    shade50: Color(0xFFB71C1C),
    shade100: Color(0xFFC62828),
    shade200: Color(0xFFD32F2F),
    shade300: Color(0xFFE53935),
    shade400: Color(0xFFF44336),
    shade500: Color(0xFFEF5350), // Base
    shade600: Color(0xFFE57373),
    shade700: Color(0xFFEF9A9A),
    shade800: Color(0xFFFFCDD2),
    shade900: Color(0xFFFFEBEE),
  );

  static const info = ColorShades(
    shade50: Color(0xFF01579B),
    shade100: Color(0xFF0277BD),
    shade200: Color(0xFF0288D1),
    shade300: Color(0xFF039BE5),
    shade400: Color(0xFF03A9F4),
    shade500: Color(0xFF29B6F6), // Base
    shade600: Color(0xFF4FC3F7),
    shade700: Color(0xFF81D4FA),
    shade800: Color(0xFFB3E5FC),
    shade900: Color(0xFFE1F5FE),
  );

  static const semantic = SemanticColors(
    success: success,
    warning: warning,
    error: error,
    info: info,
  );

  static const surface = SurfaceColors(
    background: Color(0xFF121212),
    foreground: Color(0xFFE0E0E0),
    card: Color(0xFF1E1E1E),
    overlay: Color(0x80000000), // 50% black
    elevated: Color(0xFF2A2A2A),
  );

  static const tokens = ColorTokens(
    primary: primary,
    secondary: secondary,
    accent: accent,
    neutral: neutral,
    semantic: semantic,
    surface: surface,
  );
}
