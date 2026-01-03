import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Web-specific session management service
/// Handles session persistence, automatic refresh, and multi-device session tracking
class WebSessionService {
  static final WebSessionService _instance = WebSessionService._internal();
  factory WebSessionService() => _instance;
  WebSessionService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  SharedPreferences? _prefs;
  Timer? _refreshTimer;
  Timer? _activityTimer;
  
  bool _isInitialized = false;
  DateTime? _lastActivity;
  String? _currentSessionId;
  
  // Session configuration
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration refreshInterval = Duration(minutes: 50);
  static const Duration activityCheckInterval = Duration(minutes: 5);
  static const Duration inactivityTimeout = Duration(minutes: 30);
  
  // Callbacks
  Function()? onSessionExpired;
  Function()? onSessionRefreshed;
  Function(String)? onSessionError;

  // Getters
  bool get isInitialized => _isInitialized;
  String? get currentSessionId => _currentSessionId;
  DateTime? get lastActivity => _lastActivity;
  bool get isSessionActive => _currentSessionId != null;

  /// Initialize the session service
  static Future<void> initialize() async {
    final instance = WebSessionService();
    try {
      instance._prefs = await SharedPreferences.getInstance();
      await instance._loadSessionData();
      instance._isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Load session data from storage
  Future<void> _loadSessionData() async {
    try {
      _currentSessionId = _prefs?.getString('current_session_id');
      final lastActivityStr = _prefs?.getString('last_activity');
      if (lastActivityStr != null) {
        _lastActivity = DateTime.parse(lastActivityStr);
      }
    } catch (e) {
    }
  }

  /// Save session data to storage
  Future<void> _saveSessionData() async {
    try {
      if (_currentSessionId != null) {
        await _prefs?.setString('current_session_id', _currentSessionId!);
      }
      if (_lastActivity != null) {
        await _prefs?.setString('last_activity', _lastActivity!.toIso8601String());
      }
    } catch (e) {
    }
  }

  /// Start session management
  Future<void> startSession(String userId) async {
    if (!_isInitialized) {
      throw Exception('WebSessionService not initialized. Call initialize() first.');
    }

    try {
      
      // Create session record
      _currentSessionId = await _createSessionRecord(userId);
      _lastActivity = DateTime.now();
      await _saveSessionData();
      
      // Start automatic session refresh
      _startSessionRefresh();
      
      // Start activity monitoring
      _startActivityMonitoring();
      
    } catch (e) {
      onSessionError?.call('Failed to start session: $e');
      rethrow;
    }
  }

  /// Create a session record in the database
  Future<String> _createSessionRecord(String userId) async {
    try {
      final sessionData = {
        'user_id': userId,
        'platform': kIsWeb ? 'web' : 'mobile',
        'browser_info': await _getBrowserInfo(),
        'started_at': DateTime.now().toIso8601String(),
        'last_activity': DateTime.now().toIso8601String(),
        'is_active': true,
      };

      final response = await _supabase
          .from('user_sessions')
          .insert(sessionData)
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      rethrow;
    }
  }

  /// Get browser information for session tracking
  Future<Map<String, dynamic>> _getBrowserInfo() async {
    if (!kIsWeb) {
      return {'platform': 'mobile'};
    }

    try {
      // In a real implementation, you would use dart:html to get browser info
      return {
        'user_agent': 'Web Browser',
        'platform': 'web',
        'screen_width': 0,
        'screen_height': 0,
      };
    } catch (e) {
      return {'platform': 'web'};
    }
  }

  /// Start automatic session refresh timer
  void _startSessionRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(refreshInterval, (timer) async {
      await refreshSession();
    });
  }

  /// Start activity monitoring timer
  void _startActivityMonitoring() {
    _activityTimer?.cancel();
    _activityTimer = Timer.periodic(activityCheckInterval, (timer) async {
      await _checkInactivity();
    });
  }

  /// Refresh the current session
  Future<void> refreshSession() async {
    if (_currentSessionId == null) {
      return;
    }

    try {
      
      // Refresh Supabase auth session
      final response = await _supabase.auth.refreshSession();
      
      if (response.session != null) {
        // Update session record
        await _updateSessionActivity();
        onSessionRefreshed?.call();
      } else {
        await _handleSessionExpired();
      }
    } catch (e) {
      onSessionError?.call('Failed to refresh session: $e');
      
      // If refresh fails, the session might be expired
      if (e.toString().contains('refresh_token_not_found') ||
          e.toString().contains('invalid_grant')) {
        await _handleSessionExpired();
      }
    }
  }

  /// Update session activity timestamp
  Future<void> updateActivity() async {
    _lastActivity = DateTime.now();
    await _saveSessionData();
    
    if (_currentSessionId != null) {
      await _updateSessionActivity();
    }
  }

  /// Update session activity in database
  Future<void> _updateSessionActivity() async {
    if (_currentSessionId == null) return;

    try {
      await _supabase
          .from('user_sessions')
          .update({
            'last_activity': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentSessionId!);
    } catch (e) {
    }
  }

  /// Check for inactivity and handle timeout
  Future<void> _checkInactivity() async {
    if (_lastActivity == null) return;

    final inactiveDuration = DateTime.now().difference(_lastActivity!);
    
    if (inactiveDuration > inactivityTimeout) {
      await _handleSessionExpired();
    }
  }

  /// Handle session expiration
  Future<void> _handleSessionExpired() async {
    
    await endSession();
    onSessionExpired?.call();
  }

  /// End the current session
  Future<void> endSession() async {
    try {
      
      // Mark session as inactive in database
      if (_currentSessionId != null) {
        await _supabase
            .from('user_sessions')
            .update({
              'is_active': false,
              'ended_at': DateTime.now().toIso8601String(),
            })
            .eq('id', _currentSessionId!);
      }
      
      // Stop timers
      _refreshTimer?.cancel();
      _activityTimer?.cancel();
      
      // Clear session data
      _currentSessionId = null;
      _lastActivity = null;
      await _prefs?.remove('current_session_id');
      await _prefs?.remove('last_activity');
      
    } catch (e) {
    }
  }

  /// Get all active sessions for the current user
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('user_sessions')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('last_activity', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Revoke a specific session
  Future<bool> revokeSession(String sessionId) async {
    try {
      await _supabase
          .from('user_sessions')
          .update({
            'is_active': false,
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Revoke all other sessions (keep only current)
  Future<bool> revokeOtherSessions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null || _currentSessionId == null) return false;

      await _supabase
          .from('user_sessions')
          .update({
            'is_active': false,
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .neq('id', _currentSessionId!);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if session is still valid
  Future<bool> isSessionValid() async {
    if (_currentSessionId == null) return false;

    try {
      final response = await _supabase
          .from('user_sessions')
          .select()
          .eq('id', _currentSessionId!)
          .eq('is_active', true)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _refreshTimer?.cancel();
    _activityTimer?.cancel();
    _isInitialized = false;
  }
}
