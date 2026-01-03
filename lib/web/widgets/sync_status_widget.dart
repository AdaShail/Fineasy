import 'package:flutter/material.dart';
import '../../services/cross_platform_sync_service.dart';
import 'package:intl/intl.dart';

/// Sync status widget for displaying real-time sync information
class SyncStatusWidget extends StatefulWidget {
  final bool showDetails;
  final bool compact;

  const SyncStatusWidget({
    super.key,
    this.showDetails = true,
    this.compact = false,
  });

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  final _syncService = CrossPlatformSyncService();
  SyncStatus _currentStatus = SyncStatus.inactive;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _setupSyncListener();
    _updateStatus();
  }

  void _setupSyncListener() {
    _syncService.onSyncStatusChange = (status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
        });
      }
    };
  }

  void _updateStatus() {
    if (_syncService.isInitialized) {
      setState(() {
        if (_syncService.isSyncing) {
          _currentStatus = SyncStatus.syncing;
        } else if (_syncService.syncErrors.isNotEmpty) {
          _currentStatus = SyncStatus.error;
        } else {
          _currentStatus = SyncStatus.active;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactView();
    }
    
    return _buildFullView();
  }

  Widget _buildCompactView() {
    return InkWell(
      onTap: () {
        setState(() {
          _showDetails = !_showDetails;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor().withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            const SizedBox(width: 8),
            Text(
              _getStatusText(),
              style: TextStyle(
                color: _getStatusColor(),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_showDetails) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: _getStatusColor(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_currentStatus == SyncStatus.error)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Retry sync',
                    onPressed: _retrySync,
                  ),
              ],
            ),
            if (widget.showDetails) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildSyncDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (_currentStatus) {
      case SyncStatus.inactive:
        return Icon(
          Icons.cloud_off,
          color: Colors.grey[400],
          size: widget.compact ? 16 : 24,
        );
      case SyncStatus.active:
        return Icon(
          Icons.cloud_done,
          color: Colors.green[600],
          size: widget.compact ? 16 : 24,
        );
      case SyncStatus.syncing:
        return SizedBox(
          width: widget.compact ? 16 : 24,
          height: widget.compact ? 16 : 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
        );
      case SyncStatus.error:
        return Icon(
          Icons.cloud_off,
          color: Colors.red[600],
          size: widget.compact ? 16 : 24,
        );
    }
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case SyncStatus.inactive:
        return Colors.grey[600]!;
      case SyncStatus.active:
        return Colors.green[600]!;
      case SyncStatus.syncing:
        return Colors.blue[600]!;
      case SyncStatus.error:
        return Colors.red[600]!;
    }
  }

  String _getStatusText() {
    switch (_currentStatus) {
      case SyncStatus.inactive:
        return 'Sync Inactive';
      case SyncStatus.active:
        return 'Synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.error:
        return 'Sync Error';
    }
  }

  Widget _buildSyncDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(
          'Last Sync',
          _syncService.lastSyncTime != null
              ? _formatDateTime(_syncService.lastSyncTime!)
              : 'Never',
          Icons.access_time,
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          'Pending Changes',
          _syncService.hasPendingChanges ? 'Yes' : 'No',
          Icons.pending_actions,
        ),
        if (_syncService.syncErrors.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildErrorSection(),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, size: 20, color: Colors.red[700]),
              const SizedBox(width: 8),
              Text(
                'Sync Errors',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...(_syncService.syncErrors.take(3).map((error) => Padding(
                padding: const EdgeInsets.only(left: 28, top: 4),
                child: Text(
                  '• $error',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                  ),
                ),
              ))),
          if (_syncService.syncErrors.length > 3)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 4),
              child: Text(
                '... and ${_syncService.syncErrors.length - 3} more',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
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
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y h:mm a').format(dateTime);
    }
  }

  Future<void> _retrySync() async {
    try {
      final userId = _syncService.supabase.auth.currentUser?.id;
      if (userId != null) {
        await _syncService.performFullSync(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sync completed successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _syncService.onSyncStatusChange = null;
    super.dispose();
  }
}
