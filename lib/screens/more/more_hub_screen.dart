import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';

class MoreHubScreen extends StatelessWidget {
  const MoreHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileCard(context),
                const SizedBox(height: 16),
                _buildFeaturesSection(context),
                const SizedBox(height: 16),
                _buildReportsSection(context),
                const SizedBox(height: 16),
                _buildSettingsSection(context),
                const SizedBox(height: 16),
                _buildSupportSection(context),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'More',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, Color(0xFF1976D2)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Consumer2<AuthProvider, BusinessProvider>(
      builder: (context, authProvider, businessProvider, child) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    businessProvider.business?.name.isNotEmpty == true
                        ? businessProvider.business!.name[0].toUpperCase()
                        : 'B',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessProvider.business?.name ?? 'Business Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.user?.email ?? 'user@example.com',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return _buildSection('Features', [
      _buildMenuItem(
        context,
        icon: Icons.receipt_long,
        title: 'Transaction Invoices',
        subtitle: 'View and generate invoices for transactions',
        color: Colors.blue,
        onTap: () => Navigator.pushNamed(context, '/transaction-invoices'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.account_balance_wallet,
        title: 'Receivables Management',
        subtitle: 'Track invoices and pending payments',
        color: Colors.green,
        onTap: () => Navigator.pushNamed(context, '/receivables'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.repeat,
        title: 'Recurring Payments',
        subtitle: 'Manage automatic recurring payments',
        color: Colors.deepOrange,
        onTap: () => Navigator.pushNamed(context, '/recurring-payments'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.insights,
        title: 'AI Insights',
        subtitle: 'Smart business analytics',
        color: Colors.purple,
        onTap: () => Navigator.pushNamed(context, '/insights'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.security,
        title: 'Fraud Detection',
        subtitle: 'Security alerts and monitoring',
        color: Colors.red,
        onTap: () => Navigator.pushNamed(context, '/fraud-alerts'),
      ),
      // Commented out - Social features disabled
      // _buildMenuItem(
      //   context,
      //   icon: Icons.people,
      //   title: 'Social Features',
      //   subtitle: 'Connect with other businesses',
      //   color: Colors.blue,
      //   onTap: () => Navigator.pushNamed(context, '/social'),
      // ),
      _buildMenuItem(
        context,
        icon: Icons.chat,
        title: 'WhatsApp Templates',
        subtitle: 'Manage WhatsApp message templates',
        color: Colors.teal,
        onTap: () => Navigator.pushNamed(context, '/whatsapp-templates'),
      ),
    ]);
  }

  Widget _buildReportsSection(BuildContext context) {
    return _buildSection('Reports & Analytics', [
      _buildMenuItem(
        context,
        icon: Icons.assessment,
        title: 'Financial Reports',
        subtitle: 'Income, expenses, and profit analysis',
        color: Colors.indigo,
        onTap: () => Navigator.pushNamed(context, '/reports'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.analytics,
        title: 'Business Analytics',
        subtitle: 'Performance metrics and trends',
        color: Colors.teal,
        onTap: () => Navigator.pushNamed(context, '/analytics'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.file_download,
        title: 'Export Data',
        subtitle: 'Download reports in PDF/Excel',
        color: Colors.orange,
        onTap: () => _showExportOptions(context),
      ),
    ]);
  }

  Widget _buildSettingsSection(BuildContext context) {
    return _buildSection('Settings', [
      _buildMenuItem(
        context,
        icon: Icons.business_center,
        title: 'Business Settings',
        subtitle: 'Company info and preferences',
        color: Colors.brown,
        onTap: () => Navigator.pushNamed(context, '/business-settings'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.account_circle,
        title: 'Account Settings',
        subtitle: 'Profile and security settings',
        color: Colors.grey,
        onTap: () => Navigator.pushNamed(context, '/account-settings'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.notifications,
        title: 'Notifications',
        subtitle: 'Manage notification preferences',
        color: Colors.amber,
        onTap: () => Navigator.pushNamed(context, '/notification-settings'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.palette,
        title: 'Theme Settings',
        subtitle: 'Customize app appearance',
        color: Colors.pink,
        onTap: () => Navigator.pushNamed(context, '/theme-settings'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.backup,
        title: 'Backup & Sync',
        subtitle: 'Data backup and synchronization',
        color: Colors.cyan,
        onTap: () => Navigator.pushNamed(context, '/backup-settings'),
      ),
    ]);
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSection('Support & Info', [
      _buildMenuItem(
        context,
        icon: Icons.help_outline,
        title: 'Help & FAQ',
        subtitle: 'Get help and find answers',
        color: Colors.blue,
        onTap: () => Navigator.pushNamed(context, '/help'),
      ),
      _buildMenuItem(
        context,
        icon: Icons.feedback,
        title: 'Send Feedback',
        subtitle: 'Share your thoughts with us',
        color: Colors.green,
        onTap: () => _showFeedbackDialog(context),
      ),
      _buildMenuItem(
        context,
        icon: Icons.info_outline,
        title: 'About',
        subtitle: 'App version and information',
        color: Colors.grey,
        onTap: () => _showAboutDialog(context),
      ),
      _buildMenuItem(
        context,
        icon: Icons.logout,
        title: 'Logout',
        subtitle: 'Sign out of your account',
        color: Colors.red,
        onTap: () => _showLogoutDialog(context),
      ),
    ]);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Export Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('Export as PDF'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement PDF export
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart, color: Colors.green),
                  title: const Text('Export as Excel'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement Excel export
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.code, color: Colors.blue),
                  title: const Text('Export as CSV'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implement CSV export
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Send Feedback'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Your feedback',
                    hintText: 'Tell us what you think...',
                  ),
                  maxLines: 4,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement feedback submission
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your feedback!'),
                    ),
                  );
                },
                child: const Text('Send'),
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
      applicationIcon: const Icon(Icons.business, size: 48),
      children: [
        const Text(
          'A comprehensive business management solution for small and medium enterprises.',
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
