import 'package:flutter/material.dart';
import '../core/responsive/responsive_breakpoints.dart';

/// Helper class for responsive design utilities
class ResponsiveHelper {
  /// Get the current device type based on width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (ResponsiveBreakpoints.isMobile(width)) {
      return DeviceType.mobile;
    } else if (ResponsiveBreakpoints.isTablet(width)) {
      return DeviceType.tablet;
    } else if (ResponsiveBreakpoints.isLargeDesktop(width)) {
      return DeviceType.largeDesktop;
    } else {
      return DeviceType.desktop;
    }
  }
  
  /// Get responsive value based on device type
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop;
    }
  }
  
  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }
  
  /// Get responsive card padding
  static EdgeInsets getResponsiveCardPadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: const EdgeInsets.all(12),
      tablet: const EdgeInsets.all(16),
      desktop: const EdgeInsets.all(20),
    );
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    required double desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 20,
      tablet: 22,
      desktop: 24,
    );
  }
  
  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 8,
      tablet: 12,
      desktop: 16,
    );
  }
  
  /// Get number of columns for grid
  static int getGridColumns(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      largeDesktop: 4,
    );
  }
  
  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return getResponsiveValue(
      context,
      mobile: screenWidth * 0.9,
      tablet: 600,
      desktop: 700,
      largeDesktop: 800,
    );
  }
  
  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }
  
  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;
  }
  
  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 48,
      tablet: 52,
      desktop: 56,
    );
  }
  
  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 56,
      tablet: 64,
      desktop: 72,
    );
  }
  
  /// Get responsive sidebar width
  static double getSidebarWidth(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 280,
      tablet: 300,
      desktop: 320,
    );
  }
  
  /// Get responsive max content width
  static double getMaxContentWidth(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: double.infinity,
      tablet: 900,
      desktop: 1200,
      largeDesktop: 1600,
    );
  }
  
  /// Build responsive widget
  static Widget buildResponsive(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    required Widget desktop,
    Widget? largeDesktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

/// Device type enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Extension on BuildContext for easy access to responsive helpers
extension ResponsiveContext on BuildContext {
  /// Get device type
  DeviceType get deviceType => ResponsiveHelper.getDeviceType(this);
  
  /// Check if mobile
  bool get isMobile => ResponsiveHelper.isMobile(this);
  
  /// Check if tablet
  bool get isTablet => ResponsiveHelper.isTablet(this);
  
  /// Check if desktop
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  
  /// Get responsive padding
  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  
  /// Get responsive card padding
  EdgeInsets get responsiveCardPadding => ResponsiveHelper.getResponsiveCardPadding(this);
  
  /// Get responsive spacing
  double get responsiveSpacing => ResponsiveHelper.getResponsiveSpacing(this);
  
  /// Get grid columns
  int get gridColumns => ResponsiveHelper.getGridColumns(this);
}
