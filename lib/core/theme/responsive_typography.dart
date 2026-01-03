import 'package:flutter/material.dart';
import '../responsive/responsive_breakpoints.dart';

/// Responsive typography scales that adapt based on screen size
class ResponsiveTypography {
  /// Get responsive text theme based on screen width
  static TextTheme getTextTheme(double width, {bool isDark = false}) {
    final scale = _getScale(width);
    final baseColor = isDark ? Colors.white : Colors.black87;
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontSize: 45 * scale,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontSize: 36 * scale,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 32 * scale,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28 * scale,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24 * scale,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22 * scale,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: baseColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12 * scale,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: baseColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: baseColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11 * scale,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: baseColor,
      ),
    );
  }
  
  /// Get typography scale factor based on screen width
  static double _getScale(double width) {
    if (ResponsiveBreakpoints.isMobile(width)) {
      return 0.9; // Slightly smaller for mobile
    } else if (ResponsiveBreakpoints.isTablet(width)) {
      return 1.0; // Base scale for tablet
    } else if (ResponsiveBreakpoints.isLargeDesktop(width)) {
      return 1.15; // Larger for large desktop
    } else {
      return 1.05; // Slightly larger for desktop
    }
  }
  
  /// Get responsive heading style
  static TextStyle getHeadingStyle(double width, {bool isDark = false}) {
    final scale = _getScale(width);
    return TextStyle(
      fontSize: 24 * scale,
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : Colors.black87,
    );
  }
  
  /// Get responsive body style
  static TextStyle getBodyStyle(double width, {bool isDark = false}) {
    final scale = _getScale(width);
    return TextStyle(
      fontSize: 14 * scale,
      fontWeight: FontWeight.normal,
      color: isDark ? Colors.white70 : Colors.black87,
    );
  }
  
  /// Get responsive caption style
  static TextStyle getCaptionStyle(double width, {bool isDark = false}) {
    final scale = _getScale(width);
    return TextStyle(
      fontSize: 12 * scale,
      fontWeight: FontWeight.normal,
      color: isDark ? Colors.white60 : Colors.black54,
    );
  }
}
