import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Notification preferences
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  // Business notifications
  bool _transactionAlerts = true;
  bool _paymentReminders = true;
  bool _lowBalanceAlerts = true;
  bool _dailySummary = true;
  bool _weeklyReports = false;
  bool _monthlyReports = true;

  // System notifications
  bool _securityAlerts = true;
  bool _systemUpdates = true;
  bool _maintenanceNotices = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Notifications
          _buildSectionHeader('General Notifications'),
          Card(
            child: Column(
              children: [
                _buildSwitchTile(
                  'Push Notifications',
                  'Receive notifications on your device',
                  Icons.notifications,
                  _pushNotifications,
                  (value) => setState(() => _pushNotifications = value),
                ),
                const Divider(),
                _buildSwitchTile(
                  'Email Notifications',
                  'Receive notifications via email',
                  Icons.email,
                  _emailNotifications,
                  (value) => setState(() => _emailNotifications = value),
                ),
                const Divider(),
                _buildSwitchTile(
                  'SMS Notifications',
                  'Receive notifications via SMS',
                  Icons.sms,
                  _smsNotifications,
                  (value) => setState(() => _smsNotifications = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Business Notifications
          _buildSectionHeader('Business Notifications'),
          Card(
            child: Column(
              children: [
                _buildSwitchTile(
                  'Transaction Alerts',
                  'Get notified for new transactions',
                  Icons.receipt,
                  _transactionAlerts,
                  (value) => setState(() => _transactionAlerts = value),
                ),
                const Divider(),
                _buildSwitchTile(
                  'Payment Reminders',
                  'Reminders for due payments',
                  Icons.payment,
                  _paymentReminders,
                  (value) => setState(() => _paymentReminders = value),
                ),
                const Divider(),
                _buildSwitchTile(
                  'Low Balance Alerts',
                  'Alert when balance is low',
                  Icons.warning,
                  _lowBalanceAlerts,
                  (value) => setState(() => _lowBalanceAlerts = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Report Notifications
          _buildSectionHeader('Report Notifications'),
          Card(
            child: Column(
              children: [
                _buildSwitchTile(
                  'Daily Summary',
                  'Daily business summary at end of day',
                  Icons.today,
                  _dailySummary,
                  (value) => setState(() => _dailySummary = value),
                ),
                const Divider(),
                _buildSwitchTile(
                  'Weekly Reports',
                  'Weekly business performance reports',
                  Icons.calendar_view_week,
                  _weeklyReports,
                  (value) => setState(() => _weeklyReports = value),
                ),
                const Divider(),
                _buildSwitchTile(
                  'Monthly Reports',
                  'Monthly business analysis reports',
                  Icons.calendar_month,
                  _monthlyReports,
                  (value) => setState(() => _monthlyReports = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // System Notifications
          _buildSectionHeader('System Notifications'),
          Card(
            child: Column(
              children: [
                _buildSwitchTile(
                  'Security Alerts',
                  'Important security notifications',
                  Icons.security,
                  _securityAlerts,
                  (value) => setState(() => _securityAlerts = value),
                ),
                const Divider(),
                _buildSwitchTile(
                  'System Updates',
                  'App updates and new features',
                  Icons.system_update,
                  _systemUpdates,
                  (value) => setState(() => _systemUpdates = value),
                ),
                const Divider(),
                _buildSwitchTile(
                  'Maintenance Notices',
                  'Scheduled maintenance notifications',
                  Icons.build,
                  _maintenanceNotices,
                  (value) => setState(() => _maintenanceNotices = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notification Schedule
          _buildSectionHeader('Notification Schedule'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Quiet Hours'),
                  subtitle: const Text('10:00 PM - 8:00 AM'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showQuietHoursDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: const Text('Notification Sound'),
                  subtitle: const Text('Default'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showSoundDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  void _showQuietHoursDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quiet Hours'),
            content: const Text(
              'Set the hours when you don\'t want to receive notifications.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quiet hours feature coming soon!'),
                    ),
                  );
                },
                child: const Text('Set Hours'),
              ),
            ],
          ),
    );
  }

  void _showSoundDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Notification Sound'),
            content: const Text('Choose your notification sound.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sound selection feature coming soon!'),
                    ),
                  );
                },
                child: const Text('Choose Sound'),
              ),
            ],
          ),
    );
  }

  void _saveSettings() {
    // TODO: Save notification settings to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
