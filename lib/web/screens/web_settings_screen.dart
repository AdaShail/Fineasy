import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../widgets/web_card.dart';
import 'web_theme_customization_screen.dart';
import 'web_whatsapp_templates_screen.dart';
import 'web_business_configuration_screen.dart';
import 'web_user_profile_screen.dart';
import 'web_notification_preferences_screen.dart';

/// Web-optimized settings and configuration screen
/// Provides a comprehensive settings interface with sidebar navigation
/// Requirements: 3.10, 7.4
class WebSettingsScreen extends StatefulWidget {
  const WebSettingsScreen({super.key});

  @override
  State<WebSettingsScreen> createState() => _WebSettingsScreenState();
}

class _WebSettingsScreenState extends State<WebSettingsScreen> {
  String _selectedSection = 'profile';

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: _buildSettingsList(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar navigation
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your preferences',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Navigation items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildNavItem(
                        'profile',
                        'User Profile',
                        Icons.person,
                        'Manage your account information',
                      ),
                      _buildNavItem(
                        'theme',
                        'Theme Customization',
                        Icons.palette,
                        'Customize app appearance',
                      ),
                      _buildNavItem(
                        'whatsapp',
                        'WhatsApp Templates',
                        Icons.message,
                        'Manage message templates',
                      ),
                      _buildNavItem(
                        'business',
                        'Business Configuration',
                        Icons.business,
                        'Configure business settings',
                      ),
                      _buildNavItem(
                        'notifications',
                        'Notification Preferences',
                        Icons.notifications,
                        'Manage notifications',
                      ),
                      const Divider(height: 32),
                      _buildNavItem(
                        'security',
                        'Security & Privacy',
                        Icons.security,
                        'Security settings',
                      ),
                      _buildNavItem(
                        'data',
                        'Data & Backup',
                        Icons.backup,
                        'Manage your data',
                      ),
                    ],
                  ),
                ),
                // Logout button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: _buildContentArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String id,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = _selectedSection == id;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.primaryColor : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        selected: isSelected,
        onTap: () {
          setState(() {
            _selectedSection = id;
          });
        },
      ),
    );
  }

  Widget _buildContentArea() {
    switch (_selectedSection) {
      case 'profile':
        return const WebUserProfileScreen();
      case 'theme':
        return const WebThemeCustomizationScreen();
      case 'whatsapp':
        return const WebWhatsAppTemplatesScreen();
      case 'business':
        return const WebBusinessConfigurationScreen();
      case 'notifications':
        return const WebNotificationPreferencesScreen();
      case 'security':
        return _buildSecuritySettings();
      case 'data':
        return _buildDataSettings();
      default:
        return const Center(child: Text('Select a section'));
    }
  }

  Widget _buildSettingsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMobileSettingsTile(
          icon: Icons.person,
          title: 'User Profile',
          subtitle: 'Manage your account information',
          onTap: () => _navigateToScreen(const WebUserProfileScreen()),
        ),
        _buildMobileSettingsTile(
          icon: Icons.palette,
          title: 'Theme Customization',
          subtitle: 'Customize app appearance',
          onTap: () => _navigateToScreen(const WebThemeCustomizationScreen()),
        ),
        _buildMobileSettingsTile(
          icon: Icons.message,
          title: 'WhatsApp Templates',
          subtitle: 'Manage message templates',
          onTap: () => _navigateToScreen(const WebWhatsAppTemplatesScreen()),
        ),
        _buildMobileSettingsTile(
          icon: Icons.business,
          title: 'Business Configuration',
          subtitle: 'Configure business settings',
          onTap: () => _navigateToScreen(const WebBusinessConfigurationScreen()),
        ),
        _buildMobileSettingsTile(
          icon: Icons.notifications,
          title: 'Notification Preferences',
          subtitle: 'Manage notifications',
          onTap: () => _navigateToScreen(const WebNotificationPreferencesScreen()),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.errorColor,
            side: const BorderSide(color: AppTheme.errorColor),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSettingsTile({
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

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _buildSecuritySettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security & Privacy',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your security settings and privacy preferences',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          WebCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password & Authentication',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your account password'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement password change
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Two-Factor Authentication'),
                  subtitle: const Text('Add extra security to your account'),
                  trailing: Switch(value: false, onChanged: (value) {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data & Backup',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your data and backup settings',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          WebCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Export Data'),
                  subtitle: const Text('Download your business data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement data export
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Backup Settings'),
                  subtitle: const Text('Configure automatic backups'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement backup settings
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
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
