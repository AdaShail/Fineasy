import 'package:flutter/material.dart';
import 'web_security_service.dart';
import '../../services/web_session_service.dart';
import '../../services/auth_service.dart';

/// Example integration of WebSecurityService in the application
/// This demonstrates best practices for using security features

class SecurityIntegrationExample {
  final _securityService = WebSecurityService();
  final _sessionService = WebSessionService();
  final _authService = AuthService();

  /// Initialize security on app startup
  Future<void> initializeSecurity() async {
    try {
      // Initialize security service
      await _securityService.initialize();
      
      // Set up security event callbacks
      _setupSecurityCallbacks();
      
    } catch (e) {
      rethrow;
    }
  }

  /// Set up callbacks for security events
  void _setupSecurityCallbacks() {
    // Handle session expiration
    _securityService.onSessionExpired = () {
      // In a real app, navigate to login screen
      // Navigator.pushReplacementNamed(context, '/login');
    };

    // Handle rate limit exceeded
    _securityService.onRateLimitExceeded = (operation) {
      // Show user-friendly message
      // showSnackBar('Too many requests. Please try again later.');
    };

    // Handle suspicious activity
    _securityService.onSuspiciousActivity = (message) {
      // Log to monitoring service
      // Send alert to security team
    };

    // Handle security violations
    _securityService.onSecurityViolation = (message) {
      // Take appropriate action
    };
  }

  /// Example: Secure login flow
  Future<bool> secureLogin(String email, String password) async {
    try {
      // Check if user is blocked due to failed attempts
      if (_securityService.isBlocked(email)) {
        throw Exception('Account temporarily blocked. Please try again later.');
      }

      // Check rate limit
      if (!await _securityService.checkRateLimit('login')) {
        throw Exception('Too many login attempts. Please try again later.');
      }

      // Attempt login
      final success = await _authService.signInWithEmail(email, password);

      if (success) {
        // Reset failed attempts on successful login
        _securityService.resetFailedAttempts(email);

        // Get auth token
        final user = await _authService.getCurrentUser();
        if (user != null) {
          // Store token securely
          // In a real implementation, you'd get the actual token
          // await _securityService.storeAuthToken(token);

          // Start session
          await _sessionService.startSession(user['id'] as String);
        }

        return true;
      } else {
        // Track failed attempt
        await _securityService.trackFailedAttempt(email);
        return false;
      }
    } catch (e) {
      // Track failed attempt
      await _securityService.trackFailedAttempt(email);
      rethrow;
    }
  }

  /// Example: Secure logout flow
  Future<void> secureLogout() async {
    try {
      // Clear auth token
      await _securityService.clearAuthToken();

      // End session
      await _sessionService.endSession();

      // Sign out from auth service
      await _authService.signOut();

    } catch (e) {
      rethrow;
    }
  }

  /// Example: Protected API call with rate limiting
  Future<Map<String, dynamic>> makeProtectedApiCall(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      // Check rate limit
      if (!await _securityService.checkRateLimit('api_$endpoint')) {
        throw Exception('Rate limit exceeded for this operation');
      }

      // Sanitize input data
      final sanitizedData = <String, dynamic>{};
      data.forEach((key, value) {
        if (value is String) {
          sanitizedData[key] = _securityService.sanitizeInput(value);
        } else {
          sanitizedData[key] = value;
        }
      });

      // Get auth token
      final token = await _securityService.getAuthToken();
      if (token == null) {
        throw Exception('No valid authentication token');
      }

      // Make API call (pseudo-code)
      // final response = await http.post(
      //   endpoint,
      //   headers: {'Authorization': 'Bearer $token'},
      //   body: sanitizedData,
      // );

      // Update session activity
      await _sessionService.updateActivity();

      // Return response
      return {'success': true};
    } catch (e) {
      rethrow;
    }
  }

  /// Example: Validate and sanitize user input
  String validateAndSanitizeInput(String input, {int? maxLength}) {
    // Sanitize to prevent XSS
    String sanitized = _securityService.sanitizeInput(input);

    // Trim whitespace
    sanitized = sanitized.trim();

    // Enforce max length
    if (maxLength != null && sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    return sanitized;
  }

  /// Example: Check security status
  Future<Map<String, dynamic>> getSecurityStatus() async {
    try {
      // Get security metrics
      final metrics = await _securityService.getSecurityMetrics();

      // Get session info
      final isSessionValid = await _sessionService.isSessionValid();
      final activeSessions = await _sessionService.getActiveSessions();

      return {
        'metrics': metrics,
        'session_valid': isSessionValid,
        'active_sessions': activeSessions.length,
        'last_activity': _sessionService.lastActivity?.toIso8601String(),
      };
    } catch (e) {
      return {};
    }
  }

  /// Example: Handle session refresh
  Future<void> refreshSessionIfNeeded() async {
    try {
      // Check if session is still valid
      final isValid = await _sessionService.isSessionValid();

      if (!isValid) {
        await _sessionService.refreshSession();
      }

      // Update activity
      await _sessionService.updateActivity();
    } catch (e) {
      // Session refresh failed - might need to re-authenticate
      await secureLogout();
    }
  }

  /// Example: Revoke all other sessions (for security)
  Future<bool> revokeOtherDevices() async {
    try {
      final success = await _sessionService.revokeOtherSessions();

      if (success) {
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Example: Monitor for suspicious activity
  Future<void> monitorActivity(String action, Map<String, dynamic> context) async {
    try {
      // Check for unusual patterns
      final metrics = await _securityService.getSecurityMetrics();
      final recentEvents = metrics['event_types'] as Map<String, dynamic>? ?? {};

      // Check for excessive failed attempts
      final failedAttempts = recentEvents['max_failed_attempts'] as int? ?? 0;
      if (failedAttempts > 3) {
        _securityService.onSuspiciousActivity?.call(
          'Multiple failed login attempts detected',
        );
      }

      // Check for rate limit violations
      final rateLimitViolations = recentEvents['rate_limit_exceeded'] as int? ?? 0;
      if (rateLimitViolations > 5) {
        _securityService.onSuspiciousActivity?.call(
          'Excessive rate limit violations detected',
        );
      }
    } catch (e) {
    }
  }

  /// Dispose resources
  void dispose() {
    _securityService.dispose();
    _sessionService.dispose();
  }
}

/// Widget example showing security integration in UI
class SecureScreenExample extends StatefulWidget {
  const SecureScreenExample({super.key});

  @override
  State<SecureScreenExample> createState() => _SecureScreenExampleState();
}

class _SecureScreenExampleState extends State<SecureScreenExample> {
  final _integration = SecurityIntegrationExample();
  Map<String, dynamic> _securityStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSecurity();
  }

  Future<void> _initializeSecurity() async {
    try {
      await _integration.initializeSecurity();
      await _loadSecurityStatus();
    } catch (e) {
    }
  }

  Future<void> _loadSecurityStatus() async {
    setState(() => _isLoading = true);

    try {
      final status = await _integration.getSecurityStatus();
      setState(() {
        _securityStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _integration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Integration Example'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Status',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusRow(
                            'Session Valid',
                            _securityStatus['session_valid'] == true ? 'Yes' : 'No',
                          ),
                          _buildStatusRow(
                            'Active Sessions',
                            '${_securityStatus['active_sessions'] ?? 0}',
                          ),
                          _buildStatusRow(
                            'Last Activity',
                            _securityStatus['last_activity'] ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSecurityStatus,
                    child: const Text('Refresh Status'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await _integration.revokeOtherDevices();
                      await _loadSecurityStatus();
                    },
                    child: const Text('Revoke Other Devices'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
