import '../responsive/responsive_breakpoints.dart';

/// Adaptive spacing system that adjusts based on screen size
class AdaptiveSpacing {
  /// Get responsive padding value
  static double getPadding(double width, {SpacingSize size = SpacingSize.medium}) {
    final scale = _getSpacingScale(width);
    
    switch (size) {
      case SpacingSize.tiny:
        return 4 * scale;
      case SpacingSize.small:
        return 8 * scale;
      case SpacingSize.medium:
        return 16 * scale;
      case SpacingSize.large:
        return 24 * scale;
      case SpacingSize.extraLarge:
        return 32 * scale;
      case SpacingSize.huge:
        return 48 * scale;
    }
  }
  
  /// Get responsive margin value
  static double getMargin(double width, {SpacingSize size = SpacingSize.medium}) {
    return getPadding(width, size: size);
  }
  
  /// Get responsive gap value for flex layouts
  static double getGap(double width, {SpacingSize size = SpacingSize.medium}) {
    return getPadding(width, size: size);
  }
  
  /// Get responsive border radius
  static double getBorderRadius(double width, {RadiusSize size = RadiusSize.medium}) {
    final scale = _getSpacingScale(width);
    
    switch (size) {
      case RadiusSize.small:
        return 4 * scale;
      case RadiusSize.medium:
        return 8 * scale;
      case RadiusSize.large:
        return 12 * scale;
      case RadiusSize.extraLarge:
        return 16 * scale;
      case RadiusSize.circular:
        return 999; // Fully circular
    }
  }
  
  /// Get responsive icon size
  static double getIconSize(double width, {IconSize size = IconSize.medium}) {
    final scale = _getSpacingScale(width);
    
    switch (size) {
      case IconSize.small:
        return 16 * scale;
      case IconSize.medium:
        return 24 * scale;
      case IconSize.large:
        return 32 * scale;
      case IconSize.extraLarge:
        return 48 * scale;
    }
  }
  
  /// Get responsive elevation
  static double getElevation(double width, {ElevationLevel level = ElevationLevel.medium}) {
    // Elevation doesn't scale as much with screen size
    final scale = ResponsiveBreakpoints.isMobile(width) ? 0.8 : 1.0;
    
    switch (level) {
      case ElevationLevel.none:
        return 0;
      case ElevationLevel.low:
        return 2 * scale;
      case ElevationLevel.medium:
        return 4 * scale;
      case ElevationLevel.high:
        return 8 * scale;
      case ElevationLevel.veryHigh:
        return 16 * scale;
    }
  }
  
  /// Get responsive container width
  static double getContainerWidth(double screenWidth) {
    if (ResponsiveBreakpoints.isMobile(screenWidth)) {
      return screenWidth; // Full width on mobile
    } else if (ResponsiveBreakpoints.isTablet(screenWidth)) {
      return screenWidth * 0.9; // 90% on tablet
    } else if (ResponsiveBreakpoints.isLargeDesktop(screenWidth)) {
      return 1400; // Max width on large desktop
    } else {
      return 1200; // Max width on desktop
    }
  }
  
  /// Get responsive grid columns
  static int getGridColumns(double width) {
    if (ResponsiveBreakpoints.isMobile(width)) {
      return 1;
    } else if (ResponsiveBreakpoints.isTablet(width)) {
      return 2;
    } else if (ResponsiveBreakpoints.isLargeDesktop(width)) {
      return 4;
    } else {
      return 3;
    }
  }
  
  /// Get spacing scale factor based on screen width
  static double _getSpacingScale(double width) {
    if (ResponsiveBreakpoints.isMobile(width)) {
      return 0.85; // Tighter spacing on mobile
    } else if (ResponsiveBreakpoints.isTablet(width)) {
      return 1.0; // Base spacing on tablet
    } else if (ResponsiveBreakpoints.isLargeDesktop(width)) {
      return 1.2; // More generous spacing on large desktop
    } else {
      return 1.1; // Slightly more spacing on desktop
    }
  }
}

/// Spacing size options
enum SpacingSize {
  tiny,
  small,
  medium,
  large,
  extraLarge,
  huge,
}

/// Border radius size options
enum RadiusSize {
  small,
  medium,
  large,
  extraLarge,
  circular,
}

/// Icon size options
enum IconSize {
  small,
  medium,
  large,
  extraLarge,
}

/// Elevation level options
enum ElevationLevel {
  none,
  low,
  medium,
  high,
  veryHigh,
}
