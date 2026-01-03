import 'dart:typed_data';

/// Abstract interface for platform-specific operations
/// 
/// This service provides a unified API for operations that differ
/// between web and mobile platforms, such as file handling, sharing,
/// clipboard operations, and URL management.
abstract class PlatformService {
  /// Returns true if running on web platform
  bool get isWeb;
  
  /// Returns true if running on mobile platform (iOS or Android)
  bool get isMobile;
  
  /// Returns true if running on desktop platform
  bool get isDesktop;
  
  /// Share content using platform-specific sharing mechanism
  /// 
  /// On mobile: Uses native share sheet
  /// On web: Uses Web Share API or fallback to clipboard
  Future<void> shareContent(String content, {String? subject});
  
  /// Download or save a file
  /// 
  /// On mobile: Saves to device storage
  /// On web: Triggers browser download
  Future<void> downloadFile(Uint8List data, String filename, {String? mimeType});
  
  /// Open a URL in the appropriate way for the platform
  /// 
  /// On mobile: Opens in external browser or in-app browser
  /// On web: Opens in new tab
  Future<void> openUrl(String url, {bool inApp = false});
  
  /// Copy text to clipboard
  Future<void> copyToClipboard(String text);
  
  /// Get text from clipboard
  Future<String?> getFromClipboard();
  
  /// Check if a specific feature is available on this platform
  bool isFeatureAvailable(PlatformFeature feature);
  
  /// Get platform-specific storage path (mobile only)
  /// Returns null on web
  Future<String?> getStoragePath();
  
  /// Check if the device has internet connectivity
  Future<bool> hasInternetConnection();
}

/// Platform-specific features that may or may not be available
enum PlatformFeature {
  /// Native share sheet
  nativeShare,
  
  /// File system access
  fileSystem,
  
  /// Clipboard access
  clipboard,
  
  /// Camera access
  camera,
  
  /// Location services
  location,
  
  /// Push notifications
  pushNotifications,
  
  /// Biometric authentication
  biometrics,
  
  /// Background processing
  backgroundProcessing,
  
  /// Local storage/database
  localStorage,
  
  /// Web-specific features
  serviceWorker,
  
  /// PWA installation
  pwaInstall,
}
