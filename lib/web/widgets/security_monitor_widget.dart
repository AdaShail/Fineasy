import 'package:flutter/material.dart';
import '../services/web_security_service.dart';

/// Widget for displaying security status and metrics
class SecurityMonitorWidget extends StatefulWidget {
  const SecurityMonitorWidget({super.key});

  @override
  State<SecurityMonitorWidget> createState() => _SecurityMonitorWidgetState();
}

class _SecurityMonitorWidgetState extends State<SecurityMonitorWidget> {
  final _securityService = WebSecurityService();
  
  Map<String, dynamic> _metrics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    
    try {
      final metrics = await _securityService.getSecurityMetrics();
      setState(() {
        _metrics = metrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Security Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadMetrics,
                  tooltip: 'Refresh metrics',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Active Sessions',
              '${_metrics['active_sessions'] ?? 0}',
              Icons.devices,
            ),
            _buildMetricRow(
              'Security Events (7 days)',
              '${_metrics['total_events'] ?? 0}',
              Icons.security,
            ),
            _buildMetricRow(
              'Rate Limited Operations',
              '${_metrics['rate_limit_operations'] ?? 0}',
              Icons.speed,
            ),
            _buildMetricRow(
              'Blocked Attempts',
              '${_metrics['blocked_identifiers'] ?? 0}',
              Icons.block,
            ),
            const SizedBox(height: 16),
            if (_metrics['event_types'] != null) ...[
              Text(
                'Recent Events',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._buildEventTypesList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEventTypesList() {
    final eventTypes = _metrics['event_types'] as Map<String, dynamic>? ?? {};
    
    return eventTypes.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            const SizedBox(width: 32),
            Expanded(
              child: Text(
                _formatEventType(entry.key),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Text(
              '${entry.value}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatEventType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
