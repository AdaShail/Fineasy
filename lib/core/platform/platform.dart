/// Platform abstraction layer for cross-platform functionality
/// 
/// This library provides a unified interface for platform-specific operations
/// that differ between web and mobile platforms.
/// 
/// Usage:
/// ```dart
/// import 'package:fineasy/core/platform/platform.dart';
/// 
/// // Get the platform service
/// final platformService = PlatformServiceFactory.instance;
/// 
/// // Use platform-specific features
/// await platformService.shareContent('Hello World');
/// await platformService.downloadFile(data, 'report.pdf');
/// 
/// // Check platform capabilities
/// if (PlatformDetector.isWeb) {
///   // Web-specific code
/// }
/// ```
library;

export 'platform_service.dart';
export 'platform_service_factory.dart';
export 'platform_detector.dart';
export 'web_platform_service.dart' if (dart.library.io) 'mobile_platform_service.dart';
export 'mobile_platform_service.dart' if (dart.library.html) 'web_platform_service.dart';
