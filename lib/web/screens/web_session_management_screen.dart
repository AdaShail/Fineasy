import 'package:flutter/material.dart';
import '../widgets/session_management_widget.dart';
import '../widgets/sync_status_widget.dart';
import '../../services/web_session_service.dart';
import '../../services/cross_platform_sync_service.dart';

/// Web session management screen
/// Displays session information, sync status, and management controls
class WebSessionManagementScreen extends StatefulWidget {
  const WebSessionManagementScreen({super.key});

  @override
  State<WebSessionManagementScreen> createState() => _WebSessionManagementScreenState();
}

class _WebSessionManagementScreenState extends State<WebSessionManagementScreen> {
  final _sessionService = WebSessionService();
  final _syncService = CrossPlatformSyncService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session & Sync Management'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Manage Your Sessions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage your active sessions across all devices and platforms',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Sync Status
            const SyncStatusWidget(showDetails: true),
            const SizedBox(height: 16),

            // Session Management
            const SessionManagementWidget(),
            const SizedBox(height: 16),

            // Session Information Card
            _buildSessionInfoCard(),
            const SizedBox(height: 16),

            // Sync Controls Card
            _buildSyncControlsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Session ID',
              _sessionService.currentSessionId ?? 'Not available',
              Icons.fingerprint,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Last Activity',
              _sessionService.lastActivity != null
                  ? _formatDateTime(_sessionService.lastActivity!)
                  : 'Not available',
              Icons.access_time,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Session Status',
              _sessionService.isSessionActive ? 'Active' : 'Inactive',
              Icons.circle,
              statusColor: _sessionService.isSessionActive ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _refreshSession,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Session'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _checkSessionValidity,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Check Validity'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Controls',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Sync Status',
              _syncService.isSyncing ? 'Syncing...' : 'Ready',
              Icons.sync,
              statusColor: _syncService.isSyncing ? Colors.blue : Colors.green,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Pending Changes',
              _syncService.hasPendingChanges ? 'Yes' : 'No',
              Icons.pending_actions,
              statusColor: _syncService.hasPendingChanges ? Colors.orange : Colors.green,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Sync Errors',
              _syncService.syncErrors.isEmpty ? 'None' : '${_syncService.syncErrors.length}',
              Icons.error_outline,
              statusColor: _syncService.syncErrors.isEmpty ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _syncService.hasPendingChanges ? _syncPendingChanges : null,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Sync Pending'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _performFullSync,
                    icon: const Icon(Icons.sync),
                    label: const Text('Full Sync'),
                  ),
                ),
              ],
            ),
            if (_syncService.syncErrors.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _clearSyncErrors,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Errors'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? statusColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: statusColor ?? Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 10) {
      return 'Just now';
    } else if (difference.inMinutes < 1) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Future<void> _refreshSession() async {
    try {
      await _sessionService.refreshSession();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session refreshed successfully')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh session: $e')),
        );
      }
    }
  }

  Future<void> _checkSessionValidity() async {
    try {
      final isValid = await _sessionService.isSessionValid();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isValid ? 'Session is valid' : 'Session is invalid'),
            backgroundColor: isValid ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to check session: $e')),
        );
      }
    }
  }

  Future<void> _syncPendingChanges() async {
    try {
      await _syncService.syncPendingChanges();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pending changes synced successfully')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sync: $e')),
        );
      }
    }
  }

  Future<void> _performFullSync() async {
    try {
      final userId = _syncService.supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No user logged in');
      }
      
      await _syncService.performFullSync(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Full sync completed successfully')),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sync: $e')),
        );
      }
    }
  }

  void _clearSyncErrors() {
    _syncService.clearErrors();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync errors cleared')),
    );
  }
}
