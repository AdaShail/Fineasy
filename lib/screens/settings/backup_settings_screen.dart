import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/sync_provider.dart';
import '../../utils/app_theme.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  bool _autoBackup = true;
  bool _wifiOnly = true;
  String _backupFrequency = 'daily';
  bool _includeImages = true;
  bool _includeReports = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Sync')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sync Status
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sync Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            syncProvider.isOnline
                                ? Icons.cloud_done
                                : Icons.cloud_off,
                            color:
                                syncProvider.isOnline
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            syncProvider.isOnline ? 'Connected' : 'Offline',
                            style: TextStyle(
                              color:
                                  syncProvider.isOnline
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Last sync: ${_formatLastSync(syncProvider.lastSyncTime)}',
                        style: const TextStyle(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              syncProvider.isSyncing
                                  ? null
                                  : () => _manualSync(syncProvider),
                          icon:
                              syncProvider.isSyncing
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.sync),
                          label: Text(
                            syncProvider.isSyncing ? 'Syncing...' : 'Sync Now',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Auto Backup Settings
          _buildSectionHeader('Auto Backup'),
          Card(
            child: Column(
              children: [
                _buildSwitchTile(
                  'Enable Auto Backup',
                  'Automatically backup your data',
                  Icons.backup,
                  _autoBackup,
                  (value) => setState(() => _autoBackup = value),
                ),
                if (_autoBackup) ...[
                  const Divider(),
                  _buildSwitchTile(
                    'WiFi Only',
                    'Only backup when connected to WiFi',
                    Icons.wifi,
                    _wifiOnly,
                    (value) => setState(() => _wifiOnly = value),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.schedule,
                      color: AppTheme.primaryColor,
                    ),
                    title: const Text('Backup Frequency'),
                    subtitle: Text(_getFrequencyText(_backupFrequency)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showFrequencyDialog,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Backup Content
          _buildSectionHeader('Backup Content'),
          Card(
            child: Column(
              children: [
                _buildSwitchTile(
                  'Include Images',
                  'Backup profile and business images',
                  Icons.image,
                  _includeImages,
                  (value) => setState(() => _includeImages = value),
                ),
                const Divider(),
                _buildSwitchTile(
                  'Include Reports',
                  'Backup generated PDF reports',
                  Icons.description,
                  _includeReports,
                  (value) => setState(() => _includeReports = value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Storage Info
          _buildSectionHeader('Storage Information'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStorageRow('Local Storage', '45.2 MB'),
                  const SizedBox(height: 8),
                  _buildStorageRow('Cloud Storage', '38.7 MB'),
                  const SizedBox(height: 8),
                  _buildStorageRow('Available Space', '4.2 GB'),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 0.02, // 2% used
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2% of available storage used',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Backup Actions
          _buildSectionHeader('Backup Actions'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.download,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Create Manual Backup'),
                  subtitle: const Text('Create a backup file to download'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _createManualBackup,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.upload,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Restore from Backup'),
                  subtitle: const Text('Restore data from a backup file'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _restoreFromBackup,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.errorColor),
                  title: const Text(
                    'Clear Local Data',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                  subtitle: const Text('Remove all local cached data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showClearDataDialog,
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

  Widget _buildStorageRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.secondaryTextColor)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryTextColor,
          ),
        ),
      ],
    );
  }

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  String _getFrequencyText(String frequency) {
    switch (frequency) {
      case 'hourly':
        return 'Every hour';
      case 'daily':
        return 'Once a day';
      case 'weekly':
        return 'Once a week';
      case 'manual':
        return 'Manual only';
      default:
        return 'Once a day';
    }
  }

  void _manualSync(SyncProvider syncProvider) {
    syncProvider.syncNow();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sync started...')));
  }

  void _showFrequencyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Backup Frequency'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Every hour'),
                  value: 'hourly',
                  groupValue: _backupFrequency,
                  onChanged: (value) {
                    setState(() => _backupFrequency = value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Once a day'),
                  value: 'daily',
                  groupValue: _backupFrequency,
                  onChanged: (value) {
                    setState(() => _backupFrequency = value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Once a week'),
                  value: 'weekly',
                  groupValue: _backupFrequency,
                  onChanged: (value) {
                    setState(() => _backupFrequency = value!);
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Manual only'),
                  value: 'manual',
                  groupValue: _backupFrequency,
                  onChanged: (value) {
                    setState(() => _backupFrequency = value!);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _createManualBackup() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Simulate backup creation
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manual backup created successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create backup: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _restoreFromBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Restore from Backup'),
            content: const Text(
              'This will replace all current data with backup data. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Restore'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        // Simulate restore process
        await Future.delayed(const Duration(seconds: 3));

        if (mounted) {
          Navigator.of(context).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data restored successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to restore backup: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Clear Local Data',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            content: const Text(
              'This will remove all locally cached data. Your data will be re-downloaded from the cloud on next sync. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _clearLocalData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Clear Data'),
              ),
            ],
          ),
    );
  }

  Future<void> _clearLocalData() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Simulate clearing local data
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local data cleared successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _saveSettings() async {
    try {
      // Save backup settings to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_backup', _autoBackup);
      await prefs.setBool('wifi_only', _wifiOnly);
      await prefs.setString('backup_frequency', _backupFrequency);
      await prefs.setBool('include_images', _includeImages);
      await prefs.setBool('include_reports', _includeReports);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup settings saved!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
