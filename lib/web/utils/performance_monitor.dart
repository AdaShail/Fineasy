/// Performance monitoring utilities for web platform
/// 
/// Tracks and reports performance metrics including load times,
/// frame rates, memory usage, and network performance.

library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Performance metric types
enum MetricType {
  pageLoad,
  routeTransition,
  apiCall,
  imageLoad,
  widgetBuild,
  custom,
}

/// Performance metric
class PerformanceMetric {
  final String name;
  final MetricType type;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.name,
    required this.type,
    required this.startTime,
    required this.endTime,
    Map<String, dynamic>? metadata,
  })  : duration = endTime.difference(startTime),
        metadata = metadata;

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.toString(),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'duration': duration.inMilliseconds,
        'metadata': metadata,
      };

  @override
  String toString() {
    return 'PerformanceMetric(name: $name, type: $type, duration: ${duration.inMilliseconds}ms)';
  }
}

/// Performance monitor
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<PerformanceMetric> _metrics = [];
  final Map<String, DateTime> _activeTimers = {};
  final Map<String, int> _counters = {};
  
  bool _isEnabled = true;
  int _maxMetrics = 1000;

  /// Enable/disable monitoring
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Set maximum number of metrics to store
  void setMaxMetrics(int max) {
    _maxMetrics = max;
  }

  /// Start timing a metric
  void startTimer(String name, {MetricType type = MetricType.custom}) {
    if (!_isEnabled) return;
    _activeTimers[name] = DateTime.now();
  }

  /// Stop timing a metric
  void stopTimer(
    String name, {
    MetricType type = MetricType.custom,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled) return;

    final startTime = _activeTimers.remove(name);
    if (startTime == null) {
      return;
    }

    final metric = PerformanceMetric(
      name: name,
      type: type,
      startTime: startTime,
      endTime: DateTime.now(),
      metadata: metadata,
    );

    _addMetric(metric);
  }

  /// Record a metric with explicit duration
  void recordMetric(
    String name,
    Duration duration, {
    MetricType type = MetricType.custom,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled) return;

    final now = DateTime.now();
    final metric = PerformanceMetric(
      name: name,
      type: type,
      startTime: now.subtract(duration),
      endTime: now,
      metadata: metadata,
    );

    _addMetric(metric);
  }

  /// Increment a counter
  void incrementCounter(String name) {
    if (!_isEnabled) return;
    _counters[name] = (_counters[name] ?? 0) + 1;
  }

  /// Get counter value
  int getCounter(String name) {
    return _counters[name] ?? 0;
  }

  /// Reset counter
  void resetCounter(String name) {
    _counters.remove(name);
  }

  /// Add metric to storage
  void _addMetric(PerformanceMetric metric) {
    _metrics.add(metric);

    // Trim if exceeds max
    if (_metrics.length > _maxMetrics) {
      _metrics.removeRange(0, _metrics.length - _maxMetrics);
    }

    // Log slow operations
    if (metric.duration.inMilliseconds > 1000) {
    }
  }

  /// Get all metrics
  List<PerformanceMetric> getMetrics({MetricType? type}) {
    if (type == null) return List.unmodifiable(_metrics);
    return _metrics.where((m) => m.type == type).toList();
  }

  /// Get metrics by name
  List<PerformanceMetric> getMetricsByName(String name) {
    return _metrics.where((m) => m.name == name).toList();
  }

  /// Get average duration for a metric
  Duration? getAverageDuration(String name) {
    final metrics = getMetricsByName(name);
    if (metrics.isEmpty) return null;

    final totalMs = metrics.fold<int>(
      0,
      (sum, m) => sum + m.duration.inMilliseconds,
    );

    return Duration(milliseconds: totalMs ~/ metrics.length);
  }

  /// Get performance summary
  Map<String, dynamic> getSummary() {
    final summary = <String, dynamic>{};

    for (final type in MetricType.values) {
      final typeMetrics = getMetrics(type: type);
      if (typeMetrics.isEmpty) continue;

      final durations = typeMetrics.map((m) => m.duration.inMilliseconds).toList();
      durations.sort();

      summary[type.toString()] = {
        'count': typeMetrics.length,
        'avgMs': durations.reduce((a, b) => a + b) / durations.length,
        'minMs': durations.first,
        'maxMs': durations.last,
        'p50Ms': durations[durations.length ~/ 2],
        'p95Ms': durations[(durations.length * 0.95).toInt()],
        'p99Ms': durations[(durations.length * 0.99).toInt()],
      };
    }

    summary['counters'] = Map.from(_counters);

    return summary;
  }

  /// Clear all metrics
  void clear() {
    _metrics.clear();
    _activeTimers.clear();
    _counters.clear();
  }

  /// Export metrics as JSON
  List<Map<String, dynamic>> exportMetrics() {
    return _metrics.map((m) => m.toJson()).toList();
  }
}

/// Frame rate monitor
class FrameRateMonitor {
  static final FrameRateMonitor _instance = FrameRateMonitor._internal();
  factory FrameRateMonitor() => _instance;
  FrameRateMonitor._internal();

  final List<Duration> _frameDurations = [];
  int _droppedFrames = 0;
  bool _isMonitoring = false;

  /// Start monitoring frame rate
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _frameDurations.clear();
    _droppedFrames = 0;

    SchedulerBinding.instance.addTimingsCallback(_onFrameTiming);
  }

  /// Stop monitoring frame rate
  void stopMonitoring() {
    _isMonitoring = false;
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTiming);
  }

  void _onFrameTiming(List<FrameTiming> timings) {
    if (!_isMonitoring) return;

    for (final timing in timings) {
      final frameDuration = timing.totalSpan;
      _frameDurations.add(frameDuration);

      // Consider frame dropped if it takes more than 16.67ms (60fps)
      if (frameDuration.inMilliseconds > 16) {
        _droppedFrames++;
      }

      // Keep only last 120 frames (2 seconds at 60fps)
      if (_frameDurations.length > 120) {
        _frameDurations.removeAt(0);
      }
    }
  }

  /// Get current FPS
  double get currentFps {
    if (_frameDurations.isEmpty) return 0.0;

    final avgDuration = _frameDurations.fold<int>(
          0,
          (sum, d) => sum + d.inMicroseconds,
        ) /
        _frameDurations.length;

    return 1000000.0 / avgDuration; // Convert microseconds to FPS
  }

  /// Get dropped frames count
  int get droppedFrames => _droppedFrames;

  /// Get frame rate statistics
  Map<String, dynamic> getStats() {
    if (_frameDurations.isEmpty) {
      return {
        'fps': 0.0,
        'droppedFrames': 0,
        'avgFrameTime': 0.0,
      };
    }

    final durations = _frameDurations.map((d) => d.inMilliseconds).toList();
    final avgFrameTime = durations.reduce((a, b) => a + b) / durations.length;

    return {
      'fps': currentFps,
      'droppedFrames': _droppedFrames,
      'avgFrameTime': avgFrameTime,
      'minFrameTime': durations.reduce((a, b) => a < b ? a : b),
      'maxFrameTime': durations.reduce((a, b) => a > b ? a : b),
    };
  }

  /// Reset statistics
  void reset() {
    _frameDurations.clear();
    _droppedFrames = 0;
  }
}

/// Network performance tracker
class NetworkPerformanceTracker {
  static final NetworkPerformanceTracker _instance =
      NetworkPerformanceTracker._internal();
  factory NetworkPerformanceTracker() => _instance;
  NetworkPerformanceTracker._internal();

  final Map<String, DateTime> _requestStarts = {};
  final List<NetworkMetric> _metrics = [];

  /// Start tracking a network request
  void startRequest(String requestId) {
    _requestStarts[requestId] = DateTime.now();
  }

  /// End tracking a network request
  void endRequest(
    String requestId, {
    required int statusCode,
    required int responseSize,
    String? url,
  }) {
    final startTime = _requestStarts.remove(requestId);
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime);
    final metric = NetworkMetric(
      requestId: requestId,
      url: url,
      duration: duration,
      statusCode: statusCode,
      responseSize: responseSize,
    );

    _metrics.add(metric);

    // Keep only last 100 requests
    if (_metrics.length > 100) {
      _metrics.removeAt(0);
    }
  }

  /// Get network statistics
  Map<String, dynamic> getStats() {
    if (_metrics.isEmpty) {
      return {
        'totalRequests': 0,
        'avgDuration': 0.0,
        'totalDataTransferred': 0,
      };
    }

    final durations = _metrics.map((m) => m.duration.inMilliseconds).toList();
    final totalSize = _metrics.fold<int>(0, (sum, m) => sum + m.responseSize);

    return {
      'totalRequests': _metrics.length,
      'avgDuration': durations.reduce((a, b) => a + b) / durations.length,
      'totalDataTransferred': totalSize,
      'avgResponseSize': totalSize / _metrics.length,
      'successRate': _metrics.where((m) => m.statusCode < 400).length /
          _metrics.length,
    };
  }

  /// Clear metrics
  void clear() {
    _requestStarts.clear();
    _metrics.clear();
  }
}

/// Network metric
class NetworkMetric {
  final String requestId;
  final String? url;
  final Duration duration;
  final int statusCode;
  final int responseSize;

  NetworkMetric({
    required this.requestId,
    this.url,
    required this.duration,
    required this.statusCode,
    required this.responseSize,
  });
}

/// Performance helper functions
class PerformanceHelpers {
  /// Measure async function execution time
  static Future<T> measureAsync<T>(
    String name,
    Future<T> Function() function, {
    MetricType type = MetricType.custom,
  }) async {
    final monitor = PerformanceMonitor();
    monitor.startTimer(name, type: type);

    try {
      return await function();
    } finally {
      monitor.stopTimer(name, type: type);
    }
  }

  /// Measure sync function execution time
  static T measureSync<T>(
    String name,
    T Function() function, {
    MetricType type = MetricType.custom,
  }) {
    final monitor = PerformanceMonitor();
    monitor.startTimer(name, type: type);

    try {
      return function();
    } finally {
      monitor.stopTimer(name, type: type);
    }
  }

  /// Log performance summary
  static void logSummary() {
    final monitor = PerformanceMonitor();
    final summary = monitor.getSummary();
    
    for (final entry in summary.entries) {
    }
  }
}
