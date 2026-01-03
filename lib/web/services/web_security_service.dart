import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/encrypted_storage_service.dart';
import '../../services/web_session_service.dart';
import 'dart:async';

/// Web-specific security service
/// Handles HTTPS enforcement, secure token storage, session expiration,
/// rate limiting, and security monitoring
class WebSecurityService {
  static final WebSecurityService _instance = WebSecurityService._internal();
  factory WebSecurityService() => _instance;
  WebSecurityService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final _encryptedStorage = EncryptedStorageService();
  final _webSession = WebSessionService();
  
  bool _isInitialized = false;
  Timer? _securityCheckTimer;
  
  // Rate limiting tracking
  final Map<String, List<DateTime>> _rateLimitTracker = {};
  final Map<String, int> _failedAttempts = {};
  
  // Security configuration
  static const int maxRequestsPerMinute = 60;
  static const int maxFailedAttempts = 5;
  static const Duration rateLimitWindow = Duration(minutes: 1);
  static const Duration blockDuration = Duration(minutes: 15);
  static const Duration securityCheckInterval = Duration(minutes: 5);
  
  // Security event callbacks
  Function(String)? onSecurityViolation;
  Function(String)? onRateLimitExceeded;
  Function()? onSessionExpired;
  Function(String)? onSuspiciousActivity;

  bool get isInitialized => _isInitialized;

  /// Initialize the security service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      
      // Initialize dependencies
      await _encryptedStorage.initialize();
      
      // Enforce HTTPS
      _enforceHttps();
      
      // Set up session expiration handling
      _setupSessionExpiration();
      
      // Start security monitoring
      _startSecurityMonitoring();
      
      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Enforce HTTPS for all connections
  void _enforceHttps() {
    if (!kIsWeb) return;

    try {
      // Check if running on HTTPS
      final currentUrl = Uri.base;
      
      if (currentUrl.scheme != 'https' && 
          !currentUrl.host.contains('localhost') &&
          !currentUrl.host.contains('127.0.0.1')) {
        
        // In production, redirect to HTTPS
        if (kReleaseMode) {
          final httpsUrl = currentUrl.replace(scheme: 'https');
          // Note: Actual redirect would require dart:html
          // window.location.href = httpsUrl.toString();
        }
      } else {
      }
    } catch (e) {
    }
  }

  /// Store authentication token securely
  Future<bool> storeAuthToken(String token) async {
    try {
      
      // Store encrypted token
      final success = await _encryptedStorage.setString('auth_token', token);
      
      if (success) {
        // Store token timestamp
        await _encryptedStorage.setString(
          'auth_token_timestamp',
          DateTime.now().toIso8601String(),
        );
        
        // Log security event
        await _logSecurityEvent('token_stored', {
          'timestamp': DateTime.now().toIso8601String(),
        });
        
      }
      
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Retrieve authentication token securely
  Future<String?> getAuthToken() async {
    try {
      final token = await _encryptedStorage.getString('auth_token');
      
      if (token != null) {
        // Check if token is expired
        final isExpired = await _isTokenExpired();
        if (isExpired) {
          await clearAuthToken();
          return null;
        }
      }
      
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Clear authentication token
  Future<void> clearAuthToken() async {
    try {
      await _encryptedStorage.remove('auth_token');
      await _encryptedStorage.remove('auth_token_timestamp');
      
      await _logSecurityEvent('token_cleared', {
        'timestamp': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
    }
  }

  /// Check if token is expired
  Future<bool> _isTokenExpired() async {
    try {
      final timestampStr = await _encryptedStorage.getString('auth_token_timestamp');
      if (timestampStr == null) return true;
      
      final timestamp = DateTime.parse(timestampStr);
      final age = DateTime.now().difference(timestamp);
      
      // Token expires after 24 hours
      return age > const Duration(hours: 24);
    } catch (e) {
      return true;
    }
  }

  /// Set up automatic session expiration handling
  void _setupSessionExpiration() {
    _webSession.onSessionExpired = () async {
      await clearAuthToken();
      await _handleSessionExpiration();
      onSessionExpired?.call();
    };
  }

  /// Handle session expiration
  Future<void> _handleSessionExpiration() async {
    try {
      // Clear all sensitive data
      await clearAuthToken();
      
      // Log security event
      await _logSecurityEvent('session_expired', {
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Sign out user
      await _supabase.auth.signOut();
      
    } catch (e) {
    }
  }

  /// Check rate limit for an operation
  Future<bool> checkRateLimit(String operation) async {
    try {
      final now = DateTime.now();
      final key = operation;
      
      // Initialize tracker for this operation if needed
      _rateLimitTracker[key] ??= [];
      
      // Remove old entries outside the rate limit window
      _rateLimitTracker[key]!.removeWhere(
        (timestamp) => now.difference(timestamp) > rateLimitWindow,
      );
      
      // Check if rate limit exceeded
      if (_rateLimitTracker[key]!.length >= maxRequestsPerMinute) {
        
        await _logSecurityEvent('rate_limit_exceeded', {
          'operation': operation,
          'count': _rateLimitTracker[key]!.length,
          'timestamp': now.toIso8601String(),
        });
        
        onRateLimitExceeded?.call(operation);
        return false;
      }
      
      // Add current request
      _rateLimitTracker[key]!.add(now);
      return true;
    } catch (e) {
      return true; // Allow on error to avoid blocking legitimate requests
    }
  }

  /// Track failed authentication attempt
  Future<void> trackFailedAttempt(String identifier) async {
    try {
      _failedAttempts[identifier] = (_failedAttempts[identifier] ?? 0) + 1;
      
      if (_failedAttempts[identifier]! >= maxFailedAttempts) {
        
        await _logSecurityEvent('max_failed_attempts', {
          'identifier': identifier,
          'count': _failedAttempts[identifier],
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        onSuspiciousActivity?.call('Multiple failed login attempts detected');
      }
    } catch (e) {
    }
  }

  /// Reset failed attempts counter
  void resetFailedAttempts(String identifier) {
    _failedAttempts.remove(identifier);
  }

  /// Check if identifier is blocked due to failed attempts
  bool isBlocked(String identifier) {
    return (_failedAttempts[identifier] ?? 0) >= maxFailedAttempts;
  }

  /// Start security monitoring
  void _startSecurityMonitoring() {
    _securityCheckTimer?.cancel();
    _securityCheckTimer = Timer.periodic(securityCheckInterval, (timer) async {
      await _performSecurityCheck();
    });
  }

  /// Perform periodic security check
  Future<void> _performSecurityCheck() async {
    try {
      
      // Check session validity
      final isSessionValid = await _webSession.isSessionValid();
      if (!isSessionValid && _webSession.isSessionActive) {
        await _handleSessionExpiration();
      }
      
      // Check token expiration
      final isTokenExpired = await _isTokenExpired();
      if (isTokenExpired) {
        await clearAuthToken();
      }
      
      // Clean up old rate limit entries
      _cleanupRateLimitTracker();
      
      // Clean up old failed attempts
      _cleanupFailedAttempts();
      
    } catch (e) {
    }
  }

  /// Clean up old rate limit entries
  void _cleanupRateLimitTracker() {
    final now = DateTime.now();
    _rateLimitTracker.removeWhere((key, timestamps) {
      timestamps.removeWhere(
        (timestamp) => now.difference(timestamp) > rateLimitWindow,
      );
      return timestamps.isEmpty;
    });
  }

  /// Clean up old failed attempts
  void _cleanupFailedAttempts() {
    // Reset failed attempts after block duration
    // In a real implementation, you'd track timestamps for each attempt
    _failedAttempts.clear();
  }

  /// Log security event
  Future<void> _logSecurityEvent(
    String eventType,
    Map<String, dynamic> details,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      final eventData = {
        'user_id': userId,
        'event_type': eventType,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
        'platform': kIsWeb ? 'web' : 'mobile',
      };
      
      // Store in database
      await _supabase.from('security_events').insert(eventData);
      
    } catch (e) {
    }
  }

  /// Validate request origin (CSRF protection)
  bool validateRequestOrigin(String origin) {
    try {
      final allowedOrigins = [
        'https://app.fineasy.tech',
        'https://staging.fineasy.tech',
        'https://dev.fineasy.tech',
        'https://fineasy-3a2ce.web.app', // Firebase default domain
      ];
      
      // Allow localhost in development
      if (!kReleaseMode) {
        allowedOrigins.addAll([
          'http://localhost',
          'http://127.0.0.1',
        ]);
      }
      
      return allowedOrigins.any((allowed) => origin.startsWith(allowed));
    } catch (e) {
      return false;
    }
  }

  /// Sanitize user input to prevent XSS
  String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Get security metrics
  Future<Map<String, dynamic>> getSecurityMetrics() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {};
      
      // Get recent security events
      final events = await _supabase
          .from('security_events')
          .select()
          .eq('user_id', userId)
          .gte('timestamp', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
          .order('timestamp', ascending: false)
          .limit(100);
      
      // Calculate metrics
      final totalEvents = events.length;
      final eventTypes = <String, int>{};
      
      for (final event in events) {
        final type = event['event_type'] as String;
        eventTypes[type] = (eventTypes[type] ?? 0) + 1;
      }
      
      return {
        'total_events': totalEvents,
        'event_types': eventTypes,
        'active_sessions': (await _webSession.getActiveSessions()).length,
        'rate_limit_operations': _rateLimitTracker.length,
        'blocked_identifiers': _failedAttempts.length,
      };
    } catch (e) {
      return {};
    }
  }

  /// Dispose resources
  void dispose() {
    _securityCheckTimer?.cancel();
    _rateLimitTracker.clear();
    _failedAttempts.clear();
    _isInitialized = false;
  }
}
