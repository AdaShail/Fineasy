import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../widgets/web_card.dart';

/// Web-optimized notification preferences screen
/// Provides comprehensive notification management for desktop users
class WebNotificationPreferencesScreen extends StatefulWidget {
  const WebNotificationPreferencesScreen({super.key});

  @override
  State<WebNotificationPreferencesScreen> createState() =>
      _WebNotificationPreferencesScreenState();
}

class _WebNotificationPreferencesScreenState
    extends State<WebNotificationPreferencesScreen> {
  // Notification channels
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _webNotifications = true;

  // Business notifications
  bool _transactionAlerts = true;
  bool _paymentReminders = true;
  bool _lowBalanceAlerts = true;
  bool _invoiceUpdates = true;
  bool _customerActivity = false;

  // Report notifications
  bool _dailySummary = true;
  bool _weeklyReports = false;
  bool _monthlyReports = true;
  bool _customReports = false;

  // System notifications
  bool _securityAlerts = true;
  bool _systemUpdates = true;
  bool _maintenanceNotices = true;
  bool _featureAnnouncements = false;

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Preferences',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage how you receive notifications',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSettings,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save Settings'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Notification Channels
          WebCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text(
                      'Notification Channels',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose how you want to receive notifications',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
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
                const Divider(),
                _buildSwitchTile(
                  'Web Notifications',
                  'Receive browser notifications',
                  Icons.web,
                  _webNotifications,
                  (value) => setState(() => _webNotifications = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Business Notifications
          WebCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.business, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text(
                      'Business Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get notified about important business events',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
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
                const Divider(),
                _buildSwitchTile(
                  'Invoice Updates',
                  'Notifications for invoice status changes',
                  Icons.description,
                  _invoiceUpdates,
                  (value) => setState(() => _invoiceUpdates = value),
                ),
                const Divider(),
                _buildSwitchTile(
                  'Customer Activity',
                  'Notifications for customer interactions',
                  Icons.people,
                  _customerActivity,
                  (value) => setState(() => _customerActivity = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Report Notifications
          WebCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.assessment, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text(
                      'Report Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Receive automated business reports',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
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
                const Divider(),
                _buildSwitchTile(
                  'Custom Reports',
                  'Notifications for custom report generation',
                  Icons.bar_chart,
                  _customReports,
                  (value) => setState(() => _customReports = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // System Notifications
          WebCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.settings, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text(
                      'System Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Stay informed about system updates and security',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
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
                const Divider(),
                _buildSwitchTile(
                  'Feature Announcements',
                  'New feature announcements and tips',
                  Icons.new_releases,
                  _featureAnnouncements,
                  (value) => setState(() => _featureAnnouncements = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notification Schedule
          WebCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.schedule, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Text(
                      'Notification Schedule',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.bedtime),
                  title: const Text('Quiet Hours'),
                  subtitle: const Text('10:00 PM - 8:00 AM'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement quiet hours
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: const Text('Notification Sound'),
                  subtitle: const Text('Default'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement sound selection
                  },
                ),
              ],
            ),
          ),
        ],
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

  void _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    // Simulate saving
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification settings saved!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}
