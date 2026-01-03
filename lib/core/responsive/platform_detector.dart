import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'responsive_breakpoints.dart';

/// Platform detection utilities for web and mobile
class PlatformDetector {
  /// Check if running on web platform
  static bool get isWeb => kIsWeb;
  
  /// Check if running on mobile platform (iOS or Android)
  static bool get isMobile => !kIsWeb;
  
  /// Get current screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  /// Get current screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  /// Check if current screen is mobile size
  static bool isMobileScreen(BuildContext context) {
    return ResponsiveBreakpoints.isMobile(getScreenWidth(context));
  }
  
  /// Check if current screen is tablet size
  static bool isTabletScreen(BuildContext context) {
    return ResponsiveBreakpoints.isTablet(getScreenWidth(context));
  }
  
  /// Check if current screen is desktop size
  static bool isDesktopScreen(BuildContext context) {
    return ResponsiveBreakpoints.isDesktop(getScreenWidth(context));
  }
  
  /// Check if current screen is large desktop size
  static bool isLargeDesktopScreen(BuildContext context) {
    return ResponsiveBreakpoints.isLargeDesktop(getScreenWidth(context));
  }
  
  /// Get device type based on screen size
  static DeviceType getDeviceType(BuildContext context) {
    final width = getScreenWidth(context);
    
    if (ResponsiveBreakpoints.isMobile(width)) {
      return DeviceType.mobile;
    } else if (ResponsiveBreakpoints.isTablet(width)) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
}

/// Enum representing device types
enum DeviceType {
  mobile,
  tablet,
  desktop,
}
