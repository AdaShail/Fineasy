import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/web_analytics_service.dart';
import '../../core/responsive/responsive_layout.dart';

/// Web analytics dashboard screen
/// Displays real-time metrics, events, errors, and performance data
class WebAnalyticsDashboardScreen extends StatefulWidget {
  const WebAnalyticsDashboardScreen({super.key});

  @override
  State<WebAnalyticsDashboardScreen> createState() => _WebAnalyticsDashboardScreenState();
}

class _WebAnalyticsDashboardScreenState extends State<WebAnalyticsDashboardScreen> {
  final WebAnalyticsService _analytics = WebAnalyticsService();
  Timer? _refreshTimer;
  
  Map<String, dynamic> _realTimeMetrics = {};
  AnalyticsSummary? _summary;
  List<AnalyticsEvent> _recentEvents = [];
  List<ErrorEvent> _recentErrors = [];
  List<PerformanceMetric> _recentPerformance = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
    _listenToStreams();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _realTimeMetrics = _analytics.getRealTimeMetrics();
      _summary = _analytics.getAnalyticsSummary();
      _recentEvents = _summary?.events.take(10).toList() ?? [];
      _recentErrors = _summary?.errors.take(10).toList() ?? [];
      _recentPerformance = _summary?.performanceMetrics.take(10).toList() ?? [];
    });
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadData();
    });
  }

  void _listenToStreams() {
    _analytics.eventStream.listen((event) {
      if (mounted) _loadData();
    });
    
    _analytics.errorStream.listen((error) {
      if (mounted) _loadData();
    });
    
    _analytics.performanceStream.listen((metric) {
      if (mounted) _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
            tooltip: 'Export Data',
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRealTimeMetricsCard(),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildRecentEventsCard(),
          const SizedBox(height: 16),
          _buildRecentErrorsCard(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRealTimeMetricsCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildSummaryCard()),
            ],
          ),
          const SizedBox(height: 24),
          _buildRecentEventsCard(),
          const SizedBox(height: 24),
          _buildRecentErrorsCard(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildRealTimeMetricsCard()),
              const SizedBox(width: 24),
              Expanded(child: _buildSummaryCard()),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRecentEventsCard()),
              const SizedBox(width: 24),
              Expanded(child: _buildRecentErrorsCard()),
            ],
          ),
          const SizedBox(height: 24),
          _buildPerformanceChartCard(),
        ],
      ),
    );
  }

  Widget _buildRealTimeMetricsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Real-Time Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Live',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Active Session',
              _realTimeMetrics['active_session'] == true ? 'Yes' : 'No',
              Icons.check_circle,
              _realTimeMetrics['active_session'] == true ? Colors.green : Colors.grey,
            ),
            _buildMetricRow(
              'Session Duration',
              '${_realTimeMetrics['session_duration_minutes'] ?? 0} min',
              Icons.timer,
              Colors.blue,
            ),
            _buildMetricRow(
              'Events (Last 5 min)',
              '${_realTimeMetrics['events_last_5_min'] ?? 0}',
              Icons.event,
              Colors.purple,
            ),
            _buildMetricRow(
              'Errors (Last 5 min)',
              '${_realTimeMetrics['errors_last_5_min'] ?? 0}',
              Icons.error,
              Colors.red,
            ),
            _buildMetricRow(
              'Avg Performance',
              '${(_realTimeMetrics['avg_performance_ms'] ?? 0).toStringAsFixed(0)} ms',
              Icons.speed,
              Colors.orange,
            ),
            _buildMetricRow(
              'Error Rate',
              '${_realTimeMetrics['error_rate'] ?? '0.00'}%',
              Icons.warning,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Session Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryItem(
              'Total Events',
              '${_summary?.totalEvents ?? 0}',
              Colors.blue,
            ),
            _buildSummaryItem(
              'Total Errors',
              '${_summary?.totalErrors ?? 0}',
              Colors.red,
            ),
            _buildSummaryItem(
              'Performance Metrics',
              '${_summary?.totalPerformanceMetrics ?? 0}',
              Colors.orange,
            ),
            _buildSummaryItem(
              'Session Duration',
              '${_summary?.sessionDuration.inMinutes ?? 0} min',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEventsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.event_note, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Recent Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recentEvents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No events yet'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentEvents.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final event = _recentEvents[index];
                  return ListTile(
                    leading: const Icon(Icons.circle, size: 12, color: Colors.blue),
                    title: Text(event.name),
                    subtitle: Text(
                      _formatTimestamp(event.timestamp),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline, size: 20),
                      onPressed: () => _showEventDetails(event),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentErrorsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Recent Errors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recentErrors.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No errors'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentErrors.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final error = _recentErrors[index];
                  return ListTile(
                    leading: Icon(
                      Icons.error,
                      size: 20,
                      color: _getSeverityColor(error.severity),
                    ),
                    title: Text(
                      error.error,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _formatTimestamp(error.timestamp),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline, size: 20),
                      onPressed: () => _showErrorDetails(error),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChartCard() {
    if (_recentPerformance.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Performance Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _recentPerformance
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                                e.key.toDouble(),
                                e.value.duration.inMilliseconds.toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.debug:
        return Colors.grey;
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.fatal:
        return Colors.purple;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showEventDetails(AnalyticsEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Timestamp: ${event.timestamp}'),
              const SizedBox(height: 8),
              Text('User ID: ${event.userId ?? "N/A"}'),
              const SizedBox(height: 8),
              Text('Session ID: ${event.sessionId ?? "N/A"}'),
              const SizedBox(height: 16),
              const Text('Properties:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(event.properties.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDetails(ErrorEvent error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: ${error.error}'),
              const SizedBox(height: 8),
              Text('Severity: ${error.severity}'),
              const SizedBox(height: 8),
              Text('Context: ${error.context ?? "N/A"}'),
              const SizedBox(height: 8),
              Text('Timestamp: ${error.timestamp}'),
              const SizedBox(height: 16),
              if (error.stackTrace != null) ...[
                const Text('Stack Trace:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(error.stackTrace!, style: const TextStyle(fontSize: 10)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }
}
