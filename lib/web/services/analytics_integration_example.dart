import 'package:flutter/material.dart';
import 'web_analytics_service.dart';

/// Example integration of WebAnalyticsService in various scenarios
/// This file demonstrates best practices for using analytics throughout the app

// ============================================================================
// Example 1: Screen with Analytics Tracking
// ============================================================================

class AnalyticsExampleScreen extends StatefulWidget {
  const AnalyticsExampleScreen({super.key});

  @override
  State<AnalyticsExampleScreen> createState() => _AnalyticsExampleScreenState();
}

class _AnalyticsExampleScreenState extends State<AnalyticsExampleScreen> {
  final WebAnalyticsService _analytics = WebAnalyticsService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _trackPageView();
    _measurePageLoad();
  }

  Future<void> _trackPageView() async {
    await _analytics.trackPageView('/example-screen');
  }

  Future<void> _measurePageLoad() async {
    _analytics.startPerformanceMeasure('example_screen_load');
    
    // Simulate loading data
    await Future.delayed(const Duration(seconds: 1));
    
    await _analytics.endPerformanceMeasure('example_screen_load');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _handleButtonClick,
              child: const Text('Track Event'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleFeatureUsage,
              child: const Text('Track Feature Usage'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handlePerformanceTest,
              child: const Text('Test Performance Tracking'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleErrorTest,
              child: const Text('Test Error Tracking'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Future<void> _handleButtonClick() async {
    await _analytics.trackUserAction(
      'click',
      'button',
      label: 'Track Event Button',
      value: 1,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event tracked!')),
      );
    }
  }

  Future<void> _handleFeatureUsage() async {
    await _analytics.trackFeatureUsage(
      'example_feature',
      properties: {
        'screen': 'example_screen',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feature usage tracked!')),
      );
    }
  }

  Future<void> _handlePerformanceTest() async {
    setState(() => _isLoading = true);

    _analytics.startPerformanceMeasure('test_operation');

    // Simulate some work
    await Future.delayed(const Duration(seconds: 2));

    await _analytics.endPerformanceMeasure(
      'test_operation',
      properties: {'test': true},
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Performance tracked!')),
      );
    }
  }

  Future<void> _handleErrorTest() async {
    try {
      // Simulate an error
      throw Exception('This is a test error');
    } catch (e, stackTrace) {
      await _analytics.trackError(
        e,
        stackTrace,
        context: 'error_test',
        properties: {'test': true},
        severity: ErrorSeverity.warning,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error tracked!')),
        );
      }
    }
  }
}

// ============================================================================
// Example 2: Provider with Analytics
// ============================================================================

class ExampleProvider extends ChangeNotifier {
  final WebAnalyticsService _analytics = WebAnalyticsService();
  List<String> _items = [];

  List<String> get items => _items;

  Future<void> loadItems() async {
    try {
      _analytics.startPerformanceMeasure('load_items');

      // Simulate loading
      await Future.delayed(const Duration(seconds: 1));
      _items = ['Item 1', 'Item 2', 'Item 3'];

      await _analytics.endPerformanceMeasure('load_items');
      await _analytics.trackEvent(
        'items_loaded',
        properties: {'count': _items.length},
      );

      notifyListeners();
    } catch (e, stackTrace) {
      await _analytics.trackError(
        e,
        stackTrace,
        context: 'load_items',
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  Future<void> addItem(String item) async {
    try {
      _items.add(item);

      await _analytics.trackEvent(
        'item_added',
        properties: {
          'item': item,
          'total_items': _items.length,
        },
      );

      notifyListeners();
    } catch (e, stackTrace) {
      await _analytics.trackError(
        e,
        stackTrace,
        context: 'add_item',
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  Future<void> removeItem(String item) async {
    try {
      _items.remove(item);

      await _analytics.trackEvent(
        'item_removed',
        properties: {
          'item': item,
          'total_items': _items.length,
        },
      );

      notifyListeners();
    } catch (e, stackTrace) {
      await _analytics.trackError(
        e,
        stackTrace,
        context: 'remove_item',
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }
}

// ============================================================================
// Example 3: Service with Analytics
// ============================================================================

class ExampleService {
  final WebAnalyticsService _analytics = WebAnalyticsService();

  Future<Map<String, dynamic>> fetchData(String id) async {
    _analytics.startPerformanceMeasure('fetch_data');

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final data = {'id': id, 'name': 'Example Data'};

      await _analytics.endPerformanceMeasure(
        'fetch_data',
        properties: {'data_id': id},
      );

      await _analytics.trackEvent(
        'data_fetched',
        properties: {'data_id': id},
      );

      return data;
    } catch (e, stackTrace) {
      await _analytics.trackError(
        e,
        stackTrace,
        context: 'fetch_data',
        properties: {'data_id': id},
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  Future<void> saveData(Map<String, dynamic> data) async {
    _analytics.startPerformanceMeasure('save_data');

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));

      await _analytics.endPerformanceMeasure('save_data');

      await _analytics.trackEvent(
        'data_saved',
        properties: {'data_id': data['id']},
      );
    } catch (e, stackTrace) {
      await _analytics.trackError(
        e,
        stackTrace,
        context: 'save_data',
        properties: {'data_id': data['id']},
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }

  Future<void> deleteData(String id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 200));

      await _analytics.trackEvent(
        'data_deleted',
        properties: {'data_id': id},
      );
    } catch (e, stackTrace) {
      await _analytics.trackError(
        e,
        stackTrace,
        context: 'delete_data',
        properties: {'data_id': id},
        severity: ErrorSeverity.error,
      );
      rethrow;
    }
  }
}

// ============================================================================
// Example 4: Network Request Tracking
// ============================================================================

class NetworkAnalyticsExample {
  final WebAnalyticsService _analytics = WebAnalyticsService();

  Future<void> makeApiRequest(String url, String method) async {
    final startTime = DateTime.now();

    try {
      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 500));

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      await _analytics.trackNetworkRequest(
        url,
        method,
        200, // status code
        duration,
        properties: {
          'success': true,
        },
      );
    } catch (e, stackTrace) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      await _analytics.trackNetworkRequest(
        url,
        method,
        500, // error status code
        duration,
        properties: {
          'success': false,
          'error': e.toString(),
        },
      );

      await _analytics.trackError(
        e,
        stackTrace,
        context: 'network_request',
        properties: {
          'url': url,
          'method': method,
        },
        severity: ErrorSeverity.error,
      );
    }
  }
}

// ============================================================================
// Example 5: Real-Time Metrics Widget
// ============================================================================

class RealTimeMetricsWidget extends StatefulWidget {
  const RealTimeMetricsWidget({super.key});

  @override
  State<RealTimeMetricsWidget> createState() => _RealTimeMetricsWidgetState();
}

class _RealTimeMetricsWidgetState extends State<RealTimeMetricsWidget> {
  final WebAnalyticsService _analytics = WebAnalyticsService();
  Map<String, dynamic> _metrics = {};

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _startAutoRefresh();
  }

  void _loadMetrics() {
    setState(() {
      _metrics = _analytics.getRealTimeMetrics();
    });
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _loadMetrics();
        _startAutoRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real-Time Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Active Session: ${_metrics['active_session'] ?? false}'),
            Text('Events (5 min): ${_metrics['events_last_5_min'] ?? 0}'),
            Text('Errors (5 min): ${_metrics['errors_last_5_min'] ?? 0}'),
            Text('Error Rate: ${_metrics['error_rate'] ?? '0.00'}%'),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Example 6: Analytics Initialization in Main App
// ============================================================================

class AnalyticsInitializationExample {
  static Future<void> initializeAnalytics(String userId) async {
    final analytics = WebAnalyticsService();
    await analytics.initialize(userId: userId);

    // Track app launch
    await analytics.trackEvent('app_launched', properties: {
      'platform': 'web',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> endAnalyticsSession() async {
    final analytics = WebAnalyticsService();
    await analytics.endSession();
  }
}
