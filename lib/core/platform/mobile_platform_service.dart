import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'platform_service.dart';

/// Mobile-specific implementation of PlatformService
/// 
/// Uses native mobile APIs for file handling, sharing,
/// clipboard operations, and URL launching.
class MobilePlatformService implements PlatformService {
  @override
  bool get isWeb => false;
  
  @override
  bool get isMobile => true;
  
  @override
  bool get isDesktop => false;
  
  @override
  Future<void> shareContent(String content, {String? subject}) async {
    try {
      await Share.share(
        content,
        subject: subject,
      );
      
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
      rethrow;
    }
  }
  
  @override
  Future<void> downloadFile(Uint8List data, String filename, {String? mimeType}) async {
    try {
      // Get the appropriate directory for saving files
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      
      // Write the file
      final file = File(filePath);
      await file.writeAsBytes(data);
      
      if (kDebugMode) {
      }
      
      // Optionally share the file so user can save it elsewhere
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Download: $filename',
      );
    } catch (e) {
      if (kDebugMode) {
      }
      rethrow;
    }
  }
  
  @override
  Future<void> openUrl(String url, {bool inApp = false}) async {
    try {
      final uri = Uri.parse(url);
      
      if (inApp) {
        // Open in in-app browser
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );
      } else {
        // Open in external browser
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
      rethrow;
    }
  }
  
  @override
  Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
      rethrow;
    }
  }
  
  @override
  Future<String?> getFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } catch (e) {
      if (kDebugMode) {
      }
      return null;
    }
  }
  
  @override
  bool isFeatureAvailable(PlatformFeature feature) {
    switch (feature) {
      case PlatformFeature.nativeShare:
      case PlatformFeature.fileSystem:
      case PlatformFeature.clipboard:
      case PlatformFeature.camera:
      case PlatformFeature.location:
      case PlatformFeature.pushNotifications:
      case PlatformFeature.localStorage:
        return true;
      
      case PlatformFeature.biometrics:
        // Available on most modern devices
        return Platform.isIOS || Platform.isAndroid;
      
      case PlatformFeature.backgroundProcessing:
        // Available but with limitations
        return true;
      
      // Web-specific features not available on mobile
      case PlatformFeature.serviceWorker:
      case PlatformFeature.pwaInstall:
        return false;
    }
  }
  
  @override
  Future<String?> getStoragePath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      if (kDebugMode) {
      }
      return null;
    }
  }
  
  @override
  Future<bool> hasInternetConnection() async {
    try {
      // Simple connectivity check by attempting to lookup a host
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
      }
      return false;
    }
  }
}
