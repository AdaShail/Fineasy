import 'package:flutter/material.dart';
import '../responsive/responsive_breakpoints.dart';

/// Responsive color schemes that adapt based on screen size and theme mode
class ResponsiveColorScheme {
  /// Get responsive color scheme for light mode
  static ColorScheme getLightColorScheme(Color seedColor, double width) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    
    // Adjust colors based on screen size if needed
    if (ResponsiveBreakpoints.isMobile(width)) {
      // Mobile might use slightly different surface colors for better contrast
      return scheme.copyWith(
        surface: Colors.white,
        surfaceContainerHighest: Colors.grey.shade100,
      );
    }
    
    return scheme;
  }
  
  /// Get responsive color scheme for dark mode
  static ColorScheme getDarkColorScheme(Color seedColor, double width) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    
    // Adjust colors based on screen size if needed
    if (ResponsiveBreakpoints.isMobile(width)) {
      // Mobile dark mode might use deeper blacks
      return scheme.copyWith(
        surface: const Color(0xFF121212),
        surfaceContainerHighest: const Color(0xFF1E1E1E),
      );
    }
    
    return scheme;
  }
  
  /// Get semantic colors for financial data
  static FinancialColors getFinancialColors(bool isDark) {
    return FinancialColors(
      profit: isDark ? Colors.green.shade400 : Colors.green.shade700,
      loss: isDark ? Colors.red.shade400 : Colors.red.shade700,
      pending: isDark ? Colors.orange.shade400 : Colors.orange.shade700,
      paid: isDark ? Colors.blue.shade400 : Colors.blue.shade700,
      overdue: isDark ? Colors.deepOrange.shade400 : Colors.deepOrange.shade700,
      neutral: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
    );
  }
  
  /// Get status colors
  static StatusColors getStatusColors(bool isDark) {
    return StatusColors(
      success: isDark ? Colors.green.shade400 : Colors.green.shade600,
      warning: isDark ? Colors.orange.shade400 : Colors.orange.shade600,
      error: isDark ? Colors.red.shade400 : Colors.red.shade600,
      info: isDark ? Colors.blue.shade400 : Colors.blue.shade600,
    );
  }
  
  /// Get chart colors for data visualization
  static List<Color> getChartColors(bool isDark) {
    if (isDark) {
      return [
        Colors.blue.shade400,
        Colors.green.shade400,
        Colors.orange.shade400,
        Colors.purple.shade400,
        Colors.teal.shade400,
        Colors.pink.shade400,
        Colors.amber.shade400,
        Colors.cyan.shade400,
      ];
    } else {
      return [
        Colors.blue.shade600,
        Colors.green.shade600,
        Colors.orange.shade600,
        Colors.purple.shade600,
        Colors.teal.shade600,
        Colors.pink.shade600,
        Colors.amber.shade600,
        Colors.cyan.shade600,
      ];
    }
  }
  
  /// Get surface colors with different elevations
  static SurfaceColors getSurfaceColors(bool isDark) {
    if (isDark) {
      return SurfaceColors(
        level0: const Color(0xFF121212),
        level1: const Color(0xFF1E1E1E),
        level2: const Color(0xFF232323),
        level3: const Color(0xFF282828),
        level4: const Color(0xFF2C2C2C),
        level5: const Color(0xFF303030),
      );
    } else {
      return SurfaceColors(
        level0: Colors.white,
        level1: Colors.grey.shade50,
        level2: Colors.grey.shade100,
        level3: Colors.grey.shade200,
        level4: Colors.grey.shade300,
        level5: Colors.grey.shade400,
      );
    }
  }
}

/// Financial-specific colors
class FinancialColors {
  final Color profit;
  final Color loss;
  final Color pending;
  final Color paid;
  final Color overdue;
  final Color neutral;
  
  const FinancialColors({
    required this.profit,
    required this.loss,
    required this.pending,
    required this.paid,
    required this.overdue,
    required this.neutral,
  });
}

/// Status colors for UI feedback
class StatusColors {
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  
  const StatusColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });
}

/// Surface colors at different elevation levels
class SurfaceColors {
  final Color level0;
  final Color level1;
  final Color level2;
  final Color level3;
  final Color level4;
  final Color level5;
  
  const SurfaceColors({
    required this.level0,
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
    required this.level5,
  });
}
