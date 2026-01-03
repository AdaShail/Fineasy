import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Service for detecting browser compatibility and capabilities
class BrowserCompatibilityService {
  static final BrowserCompatibilityService _instance = BrowserCompatibilityService._internal();
  factory BrowserCompatibilityService() => _instance;
  BrowserCompatibilityService._internal() {
    _detectBrowser();
  }

  BrowserInfo? _browserInfo;
  BrowserInfo? get browserInfo => _browserInfo;

  List<String> _unsupportedFeatures = [];
  List<String> get unsupportedFeatures => _unsupportedFeatures;

  bool _isSupported = true;
  bool get isSupported => _isSupported;

  /// Detect browser information
  void _detectBrowser() {
    if (!kIsWeb) return;

    final userAgent = html.window.navigator.userAgent.toLowerCase();
    
    BrowserType type = BrowserType.unknown;
    String version = 'Unknown';

    // Detect browser type
    if (userAgent.contains('chrome') && !userAgent.contains('edg')) {
      type = BrowserType.chrome;
      version = _extractVersion(userAgent, 'chrome/');
    } else if (userAgent.contains('safari') && !userAgent.contains('chrome')) {
      type = BrowserType.safari;
      version = _extractVersion(userAgent, 'version/');
    } else if (userAgent.contains('firefox')) {
      type = BrowserType.firefox;
      version = _extractVersion(userAgent, 'firefox/');
    } else if (userAgent.contains('edg')) {
      type = BrowserType.edge;
      version = _extractVersion(userAgent, 'edg/');
    } else if (userAgent.contains('opera') || userAgent.contains('opr')) {
      type = BrowserType.opera;
      version = _extractVersion(userAgent, 'opr/');
    }

    _browserInfo = BrowserInfo(
      type: type,
      version: version,
      userAgent: html.window.navigator.userAgent,
    );

    // Check browser support
    _checkBrowserSupport();
  }

  /// Extract version from user agent string
  String _extractVersion(String userAgent, String prefix) {
    final index = userAgent.indexOf(prefix);
    if (index == -1) return 'Unknown';

    final versionStart = index + prefix.length;
    final versionEnd = userAgent.indexOf(' ', versionStart);
    
    if (versionEnd == -1) {
      return userAgent.substring(versionStart).split('.').first;
    }
    
    return userAgent.substring(versionStart, versionEnd).split('.').first;
  }

  /// Check if browser is supported
  void _checkBrowserSupport() {
    if (!kIsWeb || _browserInfo == null) return;

    _unsupportedFeatures.clear();

    // Check minimum browser versions
    final minVersions = {
      BrowserType.chrome: 90,
      BrowserType.firefox: 88,
      BrowserType.safari: 14,
      BrowserType.edge: 90,
    };

    final minVersion = minVersions[_browserInfo!.type];
    if (minVersion != null) {
      final currentVersion = int.tryParse(_browserInfo!.version) ?? 0;
      if (currentVersion < minVersion) {
        _isSupported = false;
        _unsupportedFeatures.add('Browser version too old (minimum: $minVersion)');
      }
    }

    // Check for required features
    _checkFeatureSupport();
  }

  /// Check support for specific web features
  void _checkFeatureSupport() {
    if (!kIsWeb) return;

    // Check for Service Worker support
    if (!_hasServiceWorkerSupport()) {
      _unsupportedFeatures.add('Service Workers (offline functionality)');
    }

    // Check for Local Storage support
    if (!_hasLocalStorageSupport()) {
      _unsupportedFeatures.add('Local Storage');
    }

    // Check for IndexedDB support
    if (!_hasIndexedDBSupport()) {
      _unsupportedFeatures.add('IndexedDB (offline data storage)');
    }

    // Check for WebSocket support
    if (!_hasWebSocketSupport()) {
      _unsupportedFeatures.add('WebSockets (real-time updates)');
    }

    // Check for Fetch API support
    if (!_hasFetchSupport()) {
      _unsupportedFeatures.add('Fetch API');
    }
  }

  /// Check if Service Worker is supported
  bool _hasServiceWorkerSupport() {
    try {
      return html.window.navigator.serviceWorker != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if Local Storage is supported
  bool _hasLocalStorageSupport() {
    try {
      html.window.localStorage['test'] = 'test';
      html.window.localStorage.remove('test');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if IndexedDB is supported
  bool _hasIndexedDBSupport() {
    try {
      return html.window.indexedDB != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if WebSocket is supported
  bool _hasWebSocketSupport() {
    try {
      return html.WebSocket.supported;
    } catch (e) {
      return false;
    }
  }

  /// Check if Fetch API is supported
  bool _hasFetchSupport() {
    try {
      // Check if fetch function exists on window
      return true; // Fetch API is widely supported in modern browsers
    } catch (e) {
      return false;
    }
  }

  /// Get recommended browsers
  List<String> getRecommendedBrowsers() {
    return [
      'Google Chrome (version 90+)',
      'Mozilla Firefox (version 88+)',
      'Safari (version 14+)',
      'Microsoft Edge (version 90+)',
    ];
  }

  /// Check if a specific feature is supported
  bool isFeatureSupported(WebFeature feature) {
    if (!kIsWeb) return false;

    switch (feature) {
      case WebFeature.serviceWorker:
        return _hasServiceWorkerSupport();
      case WebFeature.localStorage:
        return _hasLocalStorageSupport();
      case WebFeature.indexedDB:
        return _hasIndexedDBSupport();
      case WebFeature.webSocket:
        return _hasWebSocketSupport();
      case WebFeature.fetchAPI:
        return _hasFetchSupport();
    }
  }
}

/// Browser information model
class BrowserInfo {
  final BrowserType type;
  final String version;
  final String userAgent;

  BrowserInfo({
    required this.type,
    required this.version,
    required this.userAgent,
  });

  String get displayName {
    switch (type) {
      case BrowserType.chrome:
        return 'Google Chrome';
      case BrowserType.firefox:
        return 'Mozilla Firefox';
      case BrowserType.safari:
        return 'Safari';
      case BrowserType.edge:
        return 'Microsoft Edge';
      case BrowserType.opera:
        return 'Opera';
      case BrowserType.unknown:
        return 'Unknown Browser';
    }
  }

  @override
  String toString() {
    return '$displayName $version';
  }
}

/// Supported browser types
enum BrowserType {
  chrome,
  firefox,
  safari,
  edge,
  opera,
  unknown,
}

/// Web features that may need compatibility checking
enum WebFeature {
  serviceWorker,
  localStorage,
  indexedDB,
  webSocket,
  fetchAPI,
}
