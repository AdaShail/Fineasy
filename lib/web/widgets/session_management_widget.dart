import 'package:flutter/material.dart';
import '../../services/web_session_service.dart';
import 'package:intl/intl.dart';

/// Session management widget for web platform
/// Displays active sessions and allows users to manage them
class SessionManagementWidget extends StatefulWidget {
  const SessionManagementWidget({super.key});

  @override
  State<SessionManagementWidget> createState() => _SessionManagementWidgetState();
}

class _SessionManagementWidgetState extends State<SessionManagementWidget> {
  final _webSessionService = WebSessionService();
  
  List<Map<String, dynamic>> _activeSessions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActiveSessions();
  }

  Future<void> _loadActiveSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessions = await _webSessionService.getActiveSessions();
      setState(() {
        _activeSessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load sessions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _revokeSession(String sessionId, bool isCurrent) async {
    if (isCurrent) {
      final confirm = await _showConfirmDialog(
        'End Current Session',
        'Are you sure you want to end your current session? You will be signed out.',
      );
      if (!confirm) return;
    }

    try {
      final success = await _webSessionService.revokeSession(sessionId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session ended successfully')),
          );
        }
        await _loadActiveSessions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end session: $e')),
        );
      }
    }
  }

  Future<void> _revokeAllOtherSessions() async {
    final confirm = await _showConfirmDialog(
      'End All Other Sessions',
      'Are you sure you want to end all other active sessions? This will sign out all other devices.',
    );
    if (!confirm) return;

    try {
      final success = await _webSessionService.revokeOtherSessions();
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All other sessions ended successfully')),
          );
        }
        await _loadActiveSessions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end sessions: $e')),
        );
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
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
                  'Active Sessions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_activeSessions.length > 1)
                  TextButton.icon(
                    onPressed: _revokeAllOtherSessions,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('End All Others'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your active sessions across all devices',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadActiveSessions,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_activeSessions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No active sessions found'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _activeSessions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final session = _activeSessions[index];
                  final isCurrent = session['id'] == _webSessionService.currentSessionId;
                  return _buildSessionTile(session, isCurrent);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(Map<String, dynamic> session, bool isCurrent) {
    final platform = session['platform'] as String? ?? 'Unknown';
    final browserInfo = session['browser_info'] as Map<String, dynamic>?;
    final lastActivity = session['last_activity'] as String?;
    final startedAt = session['started_at'] as String?;

    DateTime? lastActivityDate;
    DateTime? startedAtDate;
    
    if (lastActivity != null) {
      try {
        lastActivityDate = DateTime.parse(lastActivity);
      } catch (e) {
        // Ignore parse errors
      }
    }
    
    if (startedAt != null) {
      try {
        startedAtDate = DateTime.parse(startedAt);
      } catch (e) {
        // Ignore parse errors
      }
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCurrent ? Colors.green[100] : Colors.grey[200],
        child: Icon(
          _getPlatformIcon(platform),
          color: isCurrent ? Colors.green[700] : Colors.grey[600],
        ),
      ),
      title: Row(
        children: [
          Text(
            _getPlatformName(platform, browserInfo),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Current',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lastActivityDate != null)
            Text('Last active: ${_formatDateTime(lastActivityDate)}'),
          if (startedAtDate != null)
            Text('Started: ${_formatDateTime(startedAtDate)}'),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.logout),
        tooltip: isCurrent ? 'End current session' : 'End session',
        onPressed: () => _revokeSession(session['id'] as String, isCurrent),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'web':
        return Icons.language;
      case 'mobile':
        return Icons.phone_android;
      case 'ios':
        return Icons.phone_iphone;
      case 'android':
        return Icons.phone_android;
      default:
        return Icons.devices;
    }
  }

  String _getPlatformName(String platform, Map<String, dynamic>? browserInfo) {
    if (browserInfo != null && browserInfo['user_agent'] != null) {
      return browserInfo['user_agent'] as String;
    }
    
    switch (platform.toLowerCase()) {
      case 'web':
        return 'Web Browser';
      case 'mobile':
        return 'Mobile Device';
      case 'ios':
        return 'iOS Device';
      case 'android':
        return 'Android Device';
      default:
        return 'Unknown Device';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }
}
