import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';
import '../fraud/fraud_settings_screen.dart';
import '../fraud/fraud_alerts_screen.dart';
import 'business_settings_screen.dart';
import 'account_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'backup_settings_screen.dart';
//import 'ai_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Business Settings Section
          _buildSectionHeader('Business'),
          _buildSettingsTile(
            context,
            icon: Icons.business,
            title: 'Business Information',
            subtitle: 'Update business details and preferences',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BusinessSettingsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // AI & Security Section
          // _buildSectionHeader('AI & Security'),
          // _buildSettingsTile(
          //   context,
          //   icon: Icons.smart_toy,
          //   title: 'AI Settings',
          //   subtitle: 'Configure AI features and privacy settings',
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(builder: (_) => const AISettingsScreen()),
          //     );
          //   },
          // ),
          _buildSettingsTile(
            context,
            icon: Icons.security,
            title: 'Fraud Detection',
            subtitle: 'AI-powered fraud and error detection settings',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FraudSettingsScreen()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.warning,
            title: 'Fraud Alerts',
            subtitle: 'View and manage fraud detection alerts',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FraudAlertsScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Account Settings Section
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            context,
            icon: Icons.person,
            title: 'Account Settings',
            subtitle: 'Manage your account and security',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AccountSettingsScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Configure notification preferences',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Data & Backup Section
          _buildSectionHeader('Data & Backup'),
          _buildSettingsTile(
            context,
            icon: Icons.backup,
            title: 'Backup & Sync',
            subtitle: 'Manage data backup and synchronization',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BackupSettingsScreen()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Export your business data',
            onTap: () => _showExportDialog(context),
          ),

          const SizedBox(height: 24),

          // Support Section
          _buildSectionHeader('Support'),
          _buildSettingsTile(
            context,
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () => _showHelpDialog(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () => _showAboutDialog(context),
          ),

          const SizedBox(height: 32),

          // Logout Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
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

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Data'),
            content: const Text('Choose the data you want to export:'),
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
                      content: Text('Export feature coming soon!'),
                    ),
                  );
                },
                child: const Text('Export All'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Help & Support'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Need help? Contact us:'),
                  SizedBox(height: 16),
                  Text('Email: support@fineasy.com'),
                  Text('Phone: +91 9876543210'),
                  Text('Website: www.fineasy.com'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Fineasy',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.account_balance_wallet,
        size: 48,
        color: AppTheme.primaryColor,
      ),
      children: const [
        Text(
          'Complete Business Management & Cashbook Application for small to medium businesses.',
        ),
      ],
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.signOut();

                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
