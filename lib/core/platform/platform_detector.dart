import 'package:flutter/foundation.dart';

/// Utility class for detecting the current platform and screen characteristics
class PlatformDetector {
  /// Returns true if running on web platform
  static bool get isWeb => kIsWeb;
  
  /// Returns true if running on mobile platform (iOS or Android)
  static bool get isMobile => !kIsWeb;
  
  /// Returns true if running on desktop (web with large screen or desktop OS)
  static bool isDesktop(double screenWidth) {
    if (kIsWeb) {
      return screenWidth >= 1024;
    }
    return false; // Native desktop apps would check Platform.isWindows, etc.
  }
  
  /// Returns true if running on tablet (web with medium screen)
  static bool isTablet(double screenWidth) {
    if (kIsWeb) {
      return screenWidth >= 768 && screenWidth < 1024;
    }
    return false; // Could be enhanced to detect native tablets
  }
  
  /// Returns true if running on mobile-sized screen
  static bool isMobileScreen(double screenWidth) {
    return screenWidth < 768;
  }
  
  /// Get the device type based on screen width
  static DeviceType getDeviceType(double screenWidth) {
    if (screenWidth >= 1024) {
      return DeviceType.desktop;
    } else if (screenWidth >= 768) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
  
  /// Check if the current platform supports a specific feature
  static bool supportsFeature(PlatformCapability capability) {
    switch (capability) {
      case PlatformCapability.touchInput:
        return true; // All platforms support touch or click
      
      case PlatformCapability.keyboardInput:
        return true; // All platforms support keyboard
      
      case PlatformCapability.mouseInput:
        return kIsWeb; // Web typically has mouse, mobile has touch
      
      case PlatformCapability.fileDownload:
        return true; // Both platforms support file operations
      
      case PlatformCapability.nativeShare:
        return !kIsWeb; // Native share is mobile-only
      
      case PlatformCapability.urlRouting:
        return kIsWeb; // URL routing is web-specific
      
      case PlatformCapability.offlineStorage:
        return true; // Both platforms support local storage
    }
  }
}

/// Device types based on screen size
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Platform capabilities that may vary between web and mobile
enum PlatformCapability {
  touchInput,
  keyboardInput,
  mouseInput,
  fileDownload,
  nativeShare,
  urlRouting,
  offlineStorage,
}
