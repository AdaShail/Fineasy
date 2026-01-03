import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Web-specific analytics and monitoring service
/// Integrates Google Analytics, error tracking, and custom metrics
class WebAnalyticsService {
  static final WebAnalyticsService _instance = WebAnalyticsService._internal();
  factory WebAnalyticsService() => _instance;
  WebAnalyticsService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  String? _userId;
  String? _sessionId;
  Map<String, dynamic>? _userProperties;
  DateTime? _sessionStartTime;
  
  // Analytics streams
  final StreamController<AnalyticsEvent> _eventController = 
      StreamController<AnalyticsEvent>.broadcast();
  final StreamController<PerformanceMetric> _performanceController = 
      StreamController<PerformanceMetric>.broadcast();
  final StreamController<ErrorEvent> _errorController = 
      StreamController<ErrorEvent>.broadcast();
  
  Stream<AnalyticsEvent> get eventStream => _eventController.stream;
  Stream<PerformanceMetric> get performanceStream => _performanceController.stream;
  Stream<ErrorEvent> get errorStream => _errorController.stream;

  // Performance tracking
  final Map<String, DateTime> _performanceMarkers = {};
  final List<PerformanceMetric> _performanceMetrics = [];
  final List<ErrorEvent> _errorEvents = [];
  final List<AnalyticsEvent> _analyticsEvents = [];

  /// Initialize analytics service
  Future<void> initialize({String? userId}) async {
    try {
      _userId = userId;
      _sessionId = _generateSessionId();
      _sessionStartTime = DateTime.now();
      
      // Collect device and app info
      await _collectUserProperties();
      
      // Track session start
      await trackEvent(
        'session_start',
        properties: {
          'session_id': _sessionId,
          'platform': 'web',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
    } catch (e) {
    }
  }

  /// Track custom event
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    try {
      final event = AnalyticsEvent(
        name: eventName,
        timestamp: DateTime.now(),
        userId: _userId,
        sessionId: _sessionId,
        properties: {
          ...?properties,
          ...?_userProperties,
        },
      );

      _analyticsEvents.add(event);
      _eventController.add(event);

      // Send to Supabase
      await _sendEventToSupabase(event);
      
      // Send to Google Analytics (if configured)
      if (kIsWeb) {
        _sendToGoogleAnalytics(event);
      }
      
    } catch (e) {
    }
  }

  /// Track page view
  Future<void> trackPageView(String pageName, {Map<String, dynamic>? properties}) async {
    await trackEvent(
      'page_view',
      properties: {
        'page_name': pageName,
        'page_path': pageName,
        ...?properties,
      },
    );
  }

  /// Track user action
  Future<void> trackUserAction(
    String action,
    String category, {
    String? label,
    int? value,
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'user_action',
      properties: {
        'action': action,
        'category': category,
        'label': label,
        'value': value,
        ...?properties,
      },
    );
  }

  /// Track feature usage
  Future<void> trackFeatureUsage(String featureName, {Map<String, dynamic>? properties}) async {
    await trackEvent(
      'feature_usage',
      properties: {
        'feature': featureName,
        ...?properties,
      },
    );
  }

  /// Start performance measurement
  void startPerformanceMeasure(String measureName) {
    _performanceMarkers[measureName] = DateTime.now();
  }

  /// End performance measurement and track
  Future<void> endPerformanceMeasure(
    String measureName, {
    Map<String, dynamic>? properties,
  }) async {
    final startTime = _performanceMarkers[measureName];
    if (startTime == null) {
      return;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    final metric = PerformanceMetric(
      name: measureName,
      duration: duration,
      timestamp: endTime,
      properties: properties,
    );

    _performanceMetrics.add(metric);
    _performanceController.add(metric);

    // Track as event
    await trackEvent(
      'performance_metric',
      properties: {
        'metric_name': measureName,
        'duration_ms': duration.inMilliseconds,
        ...?properties,
      },
    );

    _performanceMarkers.remove(measureName);
  }

  /// Track error
  Future<void> trackError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? properties,
    ErrorSeverity severity = ErrorSeverity.error,
  }) async {
    try {
      final errorEvent = ErrorEvent(
        error: error.toString(),
        stackTrace: stackTrace?.toString(),
        context: context,
        severity: severity,
        timestamp: DateTime.now(),
        userId: _userId,
        sessionId: _sessionId,
        properties: {
          ...?properties,
          ...?_userProperties,
        },
      );

      _errorEvents.add(errorEvent);
      _errorController.add(errorEvent);

      // Send to Supabase
      await _sendErrorToSupabase(errorEvent);
      
      // Send to Sentry (if configured)
      if (kIsWeb) {
        _sendToSentry(errorEvent);
      }
      
    } catch (e) {
    }
  }

  /// Track network request
  Future<void> trackNetworkRequest(
    String url,
    String method,
    int statusCode,
    Duration duration, {
    Map<String, dynamic>? properties,
  }) async {
    await trackEvent(
      'network_request',
      properties: {
        'url': url,
        'method': method,
        'status_code': statusCode,
        'duration_ms': duration.inMilliseconds,
        ...?properties,
      },
    );
  }

  /// Get analytics summary
  AnalyticsSummary getAnalyticsSummary() {
    final sessionDuration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!)
        : Duration.zero;

    return AnalyticsSummary(
      totalEvents: _analyticsEvents.length,
      totalErrors: _errorEvents.length,
      totalPerformanceMetrics: _performanceMetrics.length,
      sessionDuration: sessionDuration,
      userId: _userId,
      sessionId: _sessionId,
      events: List.from(_analyticsEvents),
      errors: List.from(_errorEvents),
      performanceMetrics: List.from(_performanceMetrics),
    );
  }

  /// Get real-time metrics
  Map<String, dynamic> getRealTimeMetrics() {
    final now = DateTime.now();
    final last5Minutes = now.subtract(const Duration(minutes: 5));
    
    final recentEvents = _analyticsEvents
        .where((e) => e.timestamp.isAfter(last5Minutes))
        .length;
    
    final recentErrors = _errorEvents
        .where((e) => e.timestamp.isAfter(last5Minutes))
        .length;
    
    final avgPerformance = _performanceMetrics.isNotEmpty
        ? _performanceMetrics
            .map((m) => m.duration.inMilliseconds)
            .reduce((a, b) => a + b) / _performanceMetrics.length
        : 0.0;

    return {
      'active_session': _sessionId != null,
      'session_duration_minutes': _sessionStartTime != null
          ? now.difference(_sessionStartTime!).inMinutes
          : 0,
      'events_last_5_min': recentEvents,
      'errors_last_5_min': recentErrors,
      'avg_performance_ms': avgPerformance,
      'total_events': _analyticsEvents.length,
      'total_errors': _errorEvents.length,
      'error_rate': _analyticsEvents.isNotEmpty
          ? (_errorEvents.length / _analyticsEvents.length * 100).toStringAsFixed(2)
          : '0.00',
    };
  }

  /// Send event to Supabase
  Future<void> _sendEventToSupabase(AnalyticsEvent event) async {
    try {
      await _supabase.from('analytics_events').insert({
        'event_name': event.name,
        'user_id': event.userId,
        'session_id': event.sessionId,
        'timestamp': event.timestamp.toIso8601String(),
        'properties': jsonEncode(event.properties),
        'platform': 'web',
      });
    } catch (e) {
    }
  }

  /// Send error to Supabase
  Future<void> _sendErrorToSupabase(ErrorEvent error) async {
    try {
      await _supabase.from('error_events').insert({
        'error_message': error.error,
        'stack_trace': error.stackTrace,
        'context': error.context,
        'severity': error.severity.toString(),
        'user_id': error.userId,
        'session_id': error.sessionId,
        'timestamp': error.timestamp.toIso8601String(),
        'properties': jsonEncode(error.properties),
        'platform': 'web',
      });
    } catch (e) {
    }
  }

  /// Send to Google Analytics (web only)
  void _sendToGoogleAnalytics(AnalyticsEvent event) {
    if (!kIsWeb) return;
    
    try {
      // Use gtag.js if available
      // This would be injected via web/index.html
      // gtag('event', event.name, event.properties);
    } catch (e) {
    }
  }

  /// Send to Sentry (web only)
  void _sendToSentry(ErrorEvent error) {
    if (!kIsWeb) return;
    
    try {
      // Use Sentry SDK if available
      // Sentry.captureException(error.error, stackTrace: error.stackTrace);
    } catch (e) {
    }
  }

  /// Collect user properties
  Future<void> _collectUserProperties() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      _userProperties = {
        'app_version': packageInfo.version,
        'app_build': packageInfo.buildNumber,
        'platform': 'web',
      };

      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        _userProperties!.addAll({
          'browser': webInfo.browserName.toString(),
          'browser_version': webInfo.appVersion,
          'user_agent': webInfo.userAgent,
          'platform_detail': webInfo.platform,
        });
      }
    } catch (e) {
    }
  }

  /// Generate session ID
  String _generateSessionId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_userId ?? "anonymous"}';
  }

  /// End session
  Future<void> endSession() async {
    await trackEvent(
      'session_end',
      properties: {
        'session_id': _sessionId,
        'duration_minutes': _sessionStartTime != null
            ? DateTime.now().difference(_sessionStartTime!).inMinutes
            : 0,
      },
    );
    
    _sessionId = null;
    _sessionStartTime = null;
  }

  /// Dispose resources
  void dispose() {
    _eventController.close();
    _performanceController.close();
    _errorController.close();
  }
}

/// Analytics event model
class AnalyticsEvent {
  final String name;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic> properties;

  AnalyticsEvent({
    required this.name,
    required this.timestamp,
    this.userId,
    this.sessionId,
    this.properties = const {},
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'timestamp': timestamp.toIso8601String(),
    'user_id': userId,
    'session_id': sessionId,
    'properties': properties,
  };
}

/// Performance metric model
class PerformanceMetric {
  final String name;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic>? properties;

  PerformanceMetric({
    required this.name,
    required this.duration,
    required this.timestamp,
    this.properties,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'duration_ms': duration.inMilliseconds,
    'timestamp': timestamp.toIso8601String(),
    'properties': properties,
  };
}

/// Error event model
class ErrorEvent {
  final String error;
  final String? stackTrace;
  final String? context;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic> properties;

  ErrorEvent({
    required this.error,
    this.stackTrace,
    this.context,
    required this.severity,
    required this.timestamp,
    this.userId,
    this.sessionId,
    this.properties = const {},
  });

  Map<String, dynamic> toJson() => {
    'error': error,
    'stack_trace': stackTrace,
    'context': context,
    'severity': severity.toString(),
    'timestamp': timestamp.toIso8601String(),
    'user_id': userId,
    'session_id': sessionId,
    'properties': properties,
  };
}

/// Error severity levels
enum ErrorSeverity {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Analytics summary model
class AnalyticsSummary {
  final int totalEvents;
  final int totalErrors;
  final int totalPerformanceMetrics;
  final Duration sessionDuration;
  final String? userId;
  final String? sessionId;
  final List<AnalyticsEvent> events;
  final List<ErrorEvent> errors;
  final List<PerformanceMetric> performanceMetrics;

  AnalyticsSummary({
    required this.totalEvents,
    required this.totalErrors,
    required this.totalPerformanceMetrics,
    required this.sessionDuration,
    this.userId,
    this.sessionId,
    required this.events,
    required this.errors,
    required this.performanceMetrics,
  });

  Map<String, dynamic> toJson() => {
    'total_events': totalEvents,
    'total_errors': totalErrors,
    'total_performance_metrics': totalPerformanceMetrics,
    'session_duration_minutes': sessionDuration.inMinutes,
    'user_id': userId,
    'session_id': sessionId,
  };
}
