import 'package:flutter/material.dart';
import '../../services/web_session_service.dart';
import '../widgets/security_monitor_widget.dart';

/// Web security settings screen
/// Allows users to manage security settings, view active sessions, and monitor security events
class WebSecuritySettingsScreen extends StatefulWidget {
  const WebSecuritySettingsScreen({super.key});

  @override
  State<WebSecuritySettingsScreen> createState() => _WebSecuritySettingsScreenState();
}

class _WebSecuritySettingsScreenState extends State<WebSecuritySettingsScreen> {
  final _sessionService = WebSessionService();
  
  List<Map<String, dynamic>> _activeSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveSessions();
  }

  Future<void> _loadActiveSessions() async {
    setState(() => _isLoading = true);
    
    try {
      final sessions = await _sessionService.getActiveSessions();
      setState(() {
        _activeSessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _revokeSession(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Session'),
        content: const Text('Are you sure you want to revoke this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _sessionService.revokeSession(sessionId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session revoked successfully')),
        );
        _loadActiveSessions();
      }
    }
  }

  Future<void> _revokeAllOtherSessions() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke All Other Sessions'),
        content: const Text(
          'This will sign out all other devices. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Revoke All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _sessionService.revokeOtherSessions();
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All other sessions revoked')),
        );
        _loadActiveSessions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Security Monitor
                  const SecurityMonitorWidget(),
                  const SizedBox(height: 24),
                  
                  // Active Sessions
                  Card(
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
                                  icon: const Icon(Icons.logout),
                                  label: const Text('Revoke All Others'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_activeSessions.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No active sessions'),
                              ),
                            )
                          else
                            ..._activeSessions.map((session) {
                              final isCurrent = session['id'] == _sessionService.currentSessionId;
                              return _buildSessionCard(session, isCurrent);
                            }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Security Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'HTTPS Enforcement',
                            'Enabled',
                            Icons.lock,
                            Colors.green,
                          ),
                          _buildInfoRow(
                            'Token Encryption',
                            'AES-256',
                            Icons.vpn_key,
                            Colors.green,
                          ),
                          _buildInfoRow(
                            'Session Timeout',
                            '30 minutes',
                            Icons.timer,
                            Colors.blue,
                          ),
                          _buildInfoRow(
                            'Rate Limiting',
                            '60 req/min',
                            Icons.speed,
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, bool isCurrent) {
    final startedAt = DateTime.parse(session['started_at'] as String);
    final lastActivity = DateTime.parse(session['last_activity'] as String);
    final platform = session['platform'] as String;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isCurrent ? Colors.blue.withOpacity(0.1) : null,
      child: ListTile(
        leading: Icon(
          platform == 'web' ? Icons.web : Icons.phone_android,
          size: 32,
        ),
        title: Row(
          children: [
            Text(
              platform == 'web' ? 'Web Browser' : 'Mobile App',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isCurrent) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Current',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Started: ${_formatDateTime(startedAt)}'),
            Text('Last active: ${_formatDateTime(lastActivity)}'),
          ],
        ),
        trailing: isCurrent
            ? null
            : IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: () => _revokeSession(session['id'] as String),
                tooltip: 'Revoke session',
              ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
