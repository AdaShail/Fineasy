import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Service for detecting and monitoring network connectivity on web
class NetworkConnectivityService {
  static final NetworkConnectivityService _instance = NetworkConnectivityService._internal();
  factory NetworkConnectivityService() => _instance;
  NetworkConnectivityService._internal() {
    _initialize();
  }

  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Timer? _pingTimer;
  static const Duration _pingInterval = Duration(seconds: 30);

  /// Initialize connectivity monitoring
  void _initialize() {
    if (!kIsWeb) return;

    // Initial state
    _isOnline = html.window.navigator.onLine ?? true;
    _connectivityController.add(_isOnline);

    // Listen to browser online/offline events
    html.window.addEventListener('online', _handleOnline);
    html.window.addEventListener('offline', _handleOffline);

    // Start periodic connectivity check
    _startPeriodicCheck();
  }

  /// Handle online event
  void _handleOnline(html.Event event) {
    if (!_isOnline) {
      _isOnline = true;
      _connectivityController.add(true);
      if (kDebugMode) {
      }
    }
  }

  /// Handle offline event
  void _handleOffline(html.Event event) {
    if (_isOnline) {
      _isOnline = false;
      _connectivityController.add(false);
      if (kDebugMode) {
      }
    }
  }

  /// Start periodic connectivity check
  void _startPeriodicCheck() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) async {
      await checkConnectivity();
    });
  }

  /// Check connectivity by attempting to reach a reliable endpoint
  Future<bool> checkConnectivity() async {
    if (!kIsWeb) return true;

    try {
      // Check browser's navigator.onLine first
      final browserOnline = html.window.navigator.onLine ?? true;
      
      if (!browserOnline) {
        _updateConnectivity(false);
        return false;
      }

      // Attempt to fetch a small resource to verify actual connectivity
      await html.window.fetch(
        'https://www.google.com/favicon.ico',
        {
          'method': 'HEAD',
          'mode': 'no-cors',
          'cache': 'no-cache',
        },
      );

      _updateConnectivity(true);
      return true;
    } catch (e) {
      _updateConnectivity(false);
      return false;
    }
  }

  /// Update connectivity state
  void _updateConnectivity(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _connectivityController.add(isOnline);
    }
  }

  /// Wait for connection to be restored
  Future<void> waitForConnection({Duration? timeout}) async {
    if (_isOnline) return;

    final completer = Completer<void>();
    late StreamSubscription<bool> subscription;

    subscription = connectivityStream.listen((isOnline) {
      if (isOnline) {
        subscription.cancel();
        completer.complete();
      }
    });

    if (timeout != null) {
      return completer.future.timeout(
        timeout,
        onTimeout: () {
          subscription.cancel();
          throw TimeoutException('Connection not restored within timeout');
        },
      );
    }

    return completer.future;
  }

  /// Dispose resources
  void dispose() {
    if (kIsWeb) {
      html.window.removeEventListener('online', _handleOnline);
      html.window.removeEventListener('offline', _handleOffline);
    }
    _pingTimer?.cancel();
    _connectivityController.close();
  }
}
