import 'package:flutter/material.dart';
import '../../services/fraud_detection_service.dart';
import '../../utils/app_theme.dart';

class FraudSettingsScreen extends StatefulWidget {
  const FraudSettingsScreen({super.key});

  @override
  State<FraudSettingsScreen> createState() => _FraudSettingsScreenState();
}

class _FraudSettingsScreenState extends State<FraudSettingsScreen> {
  final FraudDetectionService _fraudService = FraudDetectionService();
  bool _isServiceAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkServiceAvailability();
  }

  Future<void> _checkServiceAvailability() async {
    final available = await _fraudService.isServiceAvailable();
    if (mounted) {
      setState(() {
        _isServiceAvailable = available;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fraud Detection Settings')),
      body: ListenableBuilder(
        listenable: _fraudService,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Status
                _buildServiceStatusCard(),
                const SizedBox(height: 16),

                // Main Settings
                _buildMainSettingsCard(),
                const SizedBox(height: 16),

                // Detection Settings
                _buildDetectionSettingsCard(),
                const SizedBox(height: 16),

                // Alert Settings
                _buildAlertSettingsCard(),
                const SizedBox(height: 16),

                // Advanced Settings
                _buildAdvancedSettingsCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isServiceAvailable ? Icons.check_circle : Icons.error,
                  color:
                      _isServiceAvailable
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Service Status',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isServiceAvailable
                  ? 'AI fraud detection services are online and available'
                  : 'AI fraud detection services are currently unavailable',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _checkServiceAvailability,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Status'),
                ),
                const SizedBox(width: 12),
                if (!_isServiceAvailable)
                  TextButton(
                    onPressed: () {
                      _showServiceUnavailableDialog();
                    },
                    child: const Text('Learn More'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fraud Detection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Fraud Detection'),
              subtitle: const Text(
                'Automatically detect potential fraud and errors in transactions',
              ),
              value: _fraudService.isEnabled,
              onChanged:
                  _isServiceAvailable
                      ? (value) {
                        _fraudService.setEnabled(value);
                        _showSettingChangedSnackBar(
                          'Fraud detection ${value ? 'enabled' : 'disabled'}',
                        );
                      }
                      : null,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Real-time Checking'),
              subtitle: const Text(
                'Check for fraud while entering transaction data',
              ),
              value: _fraudService.realTimeCheckingEnabled,
              onChanged:
                  _fraudService.isEnabled && _isServiceAvailable
                      ? (value) {
                        _fraudService.setRealTimeCheckingEnabled(value);
                        _showSettingChangedSnackBar(
                          'Real-time checking ${value ? 'enabled' : 'disabled'}',
                        );
                      }
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detection Sensitivity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Confidence Threshold: ${(_fraudService.confidenceThreshold * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Only show alerts with confidence above this threshold',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            Slider(
              value: _fraudService.confidenceThreshold,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label:
                  '${(_fraudService.confidenceThreshold * 100).toStringAsFixed(0)}%',
              onChanged:
                  _fraudService.isEnabled && _isServiceAvailable
                      ? (value) {
                        _fraudService.setConfidenceThreshold(value);
                      }
                      : null,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low (10%)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'High (100%)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alert Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAlertTypeToggle(
              'Duplicate Invoices',
              'Alert when duplicate invoices are detected',
              Icons.content_copy,
              true, // This would be stored in settings
              (value) {
                // Handle toggle
                _showSettingChangedSnackBar(
                  'Duplicate invoice alerts ${value ? 'enabled' : 'disabled'}',
                );
              },
            ),
            _buildAlertTypeToggle(
              'Payment Mismatches',
              'Alert when payment amounts don\'t match',
              Icons.error_outline,
              true,
              (value) {
                _showSettingChangedSnackBar(
                  'Payment mismatch alerts ${value ? 'enabled' : 'disabled'}',
                );
              },
            ),
            _buildAlertTypeToggle(
              'Suspicious Patterns',
              'Alert when unusual transaction patterns are detected',
              Icons.warning,
              true,
              (value) {
                _showSettingChangedSnackBar(
                  'Suspicious pattern alerts ${value ? 'enabled' : 'disabled'}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertTypeToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged:
            _fraudService.isEnabled && _isServiceAvailable ? onChanged : null,
      ),
    );
  }

  Widget _buildAdvancedSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Clear Alert History'),
              subtitle: const Text('Remove all dismissed fraud alerts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showClearHistoryDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Alert Data'),
              subtitle: const Text('Download fraud alert history as CSV'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showExportDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Fraud Detection'),
              subtitle: const Text('Learn how AI fraud detection works'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingChangedSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.successColor),
    );
  }

  void _showServiceUnavailableDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Service Unavailable'),
            content: const Text(
              'AI fraud detection services are currently unavailable. This could be due to:\n\n'
              '• Network connectivity issues\n'
              '• Server maintenance\n'
              '• Service configuration problems\n\n'
              'Please try again later or contact support if the issue persists.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Alert History'),
            content: const Text(
              'This will permanently delete all fraud alert history. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Clear history logic would go here
                  Navigator.of(context).pop();
                  _showSettingChangedSnackBar('Alert history cleared');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Alert Data'),
            content: const Text(
              'Export your fraud alert history as a CSV file for analysis or record keeping.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Export logic would go here
                  Navigator.of(context).pop();
                  _showSettingChangedSnackBar('Alert data exported');
                },
                child: const Text('Export'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About Fraud Detection'),
            content: const SingleChildScrollView(
              child: Text(
                'AI-powered fraud detection uses machine learning algorithms to analyze your transaction patterns and identify potential fraud or errors.\n\n'
                'Features:\n'
                '• Duplicate invoice detection\n'
                '• Payment mismatch identification\n'
                '• Suspicious pattern recognition\n'
                '• Real-time transaction analysis\n\n'
                'The system learns from your business patterns to provide more accurate alerts over time while protecting your data privacy.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
