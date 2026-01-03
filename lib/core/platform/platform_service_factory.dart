import 'package:flutter/foundation.dart';
import 'platform_service.dart';
import 'web_platform_service.dart' if (dart.library.io) 'mobile_platform_service.dart';
import 'mobile_platform_service.dart' if (dart.library.html) 'web_platform_service.dart';

/// Factory for creating the appropriate PlatformService implementation
/// based on the current platform.
/// 
/// This uses conditional imports to ensure only the relevant platform
/// code is included in the final bundle.
class PlatformServiceFactory {
  static PlatformService? _instance;
  
  /// Get the singleton instance of the appropriate PlatformService
  static PlatformService get instance {
    _instance ??= _createPlatformService();
    return _instance!;
  }
  
  /// Create the appropriate platform service based on the current platform
  static PlatformService _createPlatformService() {
    if (kIsWeb) {
      return WebPlatformService();
    } else {
      return MobilePlatformService();
    }
  }
  
  /// Reset the instance (useful for testing)
  @visibleForTesting
  static void reset() {
    _instance = null;
  }
  
  /// Set a custom instance (useful for testing)
  @visibleForTesting
  static void setInstance(PlatformService service) {
    _instance = service;
  }
}
