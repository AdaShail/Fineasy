// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'platform_service.dart';

/// Web-specific implementation of PlatformService
/// 
/// Uses browser APIs for file downloads, clipboard operations,
/// and URL handling.
class WebPlatformService implements PlatformService {
  @override
  bool get isWeb => true;
  
  @override
  bool get isMobile => false;
  
  @override
  bool get isDesktop => true;
  
  @override
  Future<void> shareContent(String content, {String? subject}) async {
    try {
      // Try to use Web Share API if available
      if (js.context.hasProperty('navigator') && 
          js.context['navigator'].hasProperty('share')) {
        final shareData = {
          'text': content,
          if (subject != null) 'title': subject,
        };
        
        await js.context['navigator'].callMethod('share', [js.JsObject.jsify(shareData)]);
      } else {
        // Fallback: Copy to clipboard
        await copyToClipboard(content);
        if (kDebugMode) {
        }
      }
    } catch (e) {
      if (kDebugMode) {
      }
      // Fallback to clipboard
      await copyToClipboard(content);
    }
  }
  
  @override
  Future<void> downloadFile(Uint8List data, String filename, {String? mimeType}) async {
    try {
      // Create a blob from the data
      final blob = html.Blob([data], mimeType ?? 'application/octet-stream');
      
      // Create a temporary URL for the blob
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Create an anchor element and trigger download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..style.display = 'none';
      
      html.document.body?.append(anchor);
      anchor.click();
      
      // Clean up
      anchor.remove();
      html.Url.revokeObjectUrl(url);
      
      if (kDebugMode) {
      }
    } catch (e) {
      if (kDebugMode) {
      }
      rethrow;
    }
  }
  
  @override
  Future<void> openUrl(String url, {bool inApp = false}) async {
    try {
      // On web, inApp parameter is ignored - always opens in new tab
      html.window.open(url, '_blank');
      
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
      // Try modern Clipboard API first
      if (js.context.hasProperty('navigator') && 
          js.context['navigator'].hasProperty('clipboard')) {
        await js.context['navigator']['clipboard'].callMethod('writeText', [text]);
      } else {
        // Fallback: Use textarea method
        final textarea = html.TextAreaElement()
          ..value = text
          ..style.position = 'fixed'
          ..style.opacity = '0';
        
        html.document.body?.append(textarea);
        textarea.select();
        html.document.execCommand('copy');
        textarea.remove();
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
  Future<String?> getFromClipboard() async {
    try {
      // Try modern Clipboard API
      if (js.context.hasProperty('navigator') && 
          js.context['navigator'].hasProperty('clipboard')) {
        final text = await js.context['navigator']['clipboard'].callMethod('readText', []);
        return text?.toString();
      }
      
      if (kDebugMode) {
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
      }
      return null;
    }
  }
  
  @override
  bool isFeatureAvailable(PlatformFeature feature) {
    switch (feature) {
      case PlatformFeature.clipboard:
        return js.context.hasProperty('navigator') && 
               js.context['navigator'].hasProperty('clipboard');
      
      case PlatformFeature.nativeShare:
        return js.context.hasProperty('navigator') && 
               js.context['navigator'].hasProperty('share');
      
      case PlatformFeature.serviceWorker:
        return js.context.hasProperty('navigator') && 
               js.context['navigator'].hasProperty('serviceWorker');
      
      case PlatformFeature.pwaInstall:
        // Check if beforeinstallprompt event is supported
        return true; // Will be determined at runtime
      
      case PlatformFeature.localStorage:
        return js.context.hasProperty('localStorage');
      
      case PlatformFeature.pushNotifications:
        return js.context.hasProperty('Notification');
      
      case PlatformFeature.location:
        return js.context.hasProperty('navigator') && 
               js.context['navigator'].hasProperty('geolocation');
      
      case PlatformFeature.camera:
        return js.context.hasProperty('navigator') && 
               js.context['navigator'].hasProperty('mediaDevices');
      
      // Features not typically available on web
      case PlatformFeature.fileSystem:
      case PlatformFeature.biometrics:
      case PlatformFeature.backgroundProcessing:
        return false;
    }
  }
  
  @override
  Future<String?> getStoragePath() async {
    // Web doesn't have a traditional file system path
    return null;
  }
  
  @override
  Future<bool> hasInternetConnection() async {
    try {
      // Check navigator.onLine property
      if (js.context.hasProperty('navigator')) {
        final onLine = js.context['navigator']['onLine'];
        return onLine == true;
      }
      
      // Assume online if we can't check
      return true;
    } catch (e) {
      if (kDebugMode) {
      }
      return true;
    }
  }
}
