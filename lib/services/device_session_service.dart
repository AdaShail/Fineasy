import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceSessionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _deviceSessionTable = 'user_device_sessions';

  /// Enable single device login restriction
  static bool enableSingleDeviceLogin = false; // Set to true to enable

  /// Get unique device identifier
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.model}_${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.model}_${iosInfo.identifierForVendor}';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return '${macInfo.model}_${macInfo.systemGUID}';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return '${windowsInfo.computerName}_${windowsInfo.deviceId}';
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
    }

    // Fallback to a timestamp-based ID
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Register device session after successful login
  Future<bool> registerDeviceSession(String userId) async {
    if (!enableSingleDeviceLogin) return true;

    try {
      final deviceId = await getDeviceId();
      final deviceInfo = await _getDeviceInfo();

      // If single device login is enabled, remove other sessions
      if (enableSingleDeviceLogin) {
        await _removeOtherDeviceSessions(userId, deviceId);
      }

      // Register current device session
      await _supabase.from(_deviceSessionTable).upsert({
        'user_id': userId,
        'device_id': deviceId,
        'device_info': deviceInfo,
        'last_active': DateTime.now().toIso8601String(),
        'is_active': true,
      });

      return true;
    } catch (e) {
      debugPrint('Error registering device session: $e');
      return false;
    }
  }

  /// Check if current device is authorized
  Future<bool> isDeviceAuthorized(String userId) async {
    if (!enableSingleDeviceLogin) return true;

    try {
      final deviceId = await getDeviceId();

      final response =
          await _supabase
              .from(_deviceSessionTable)
              .select()
              .eq('user_id', userId)
              .eq('device_id', deviceId)
              .eq('is_active', true)
              .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking device authorization: $e');
      return false;
    }
  }

  /// Remove device session on logout
  Future<void> removeDeviceSession(String userId) async {
    if (!enableSingleDeviceLogin) return;

    try {
      final deviceId = await getDeviceId();

      await _supabase
          .from(_deviceSessionTable)
          .update({'is_active': false})
          .eq('user_id', userId)
          .eq('device_id', deviceId);
    } catch (e) {
      debugPrint('Error removing device session: $e');
    }
  }

  /// Remove all other device sessions (for single device login)
  Future<void> _removeOtherDeviceSessions(
    String userId,
    String currentDeviceId,
  ) async {
    try {
      await _supabase
          .from(_deviceSessionTable)
          .update({'is_active': false})
          .eq('user_id', userId)
          .neq('device_id', currentDeviceId);
    } catch (e) {
      debugPrint('Error removing other device sessions: $e');
    }
  }

  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'version': iosInfo.systemVersion,
        };
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return {
          'platform': 'macOS',
          'model': macInfo.model,
          'name': macInfo.computerName,
          'version': macInfo.osRelease,
        };
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }

    return {
      'platform': Platform.operatingSystem,
      'model': 'Unknown',
      'version': 'Unknown',
    };
  }

  /// Get all active sessions for user (for admin/settings view)
  Future<List<Map<String, dynamic>>> getUserActiveSessions(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from(_deviceSessionTable)
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('last_active', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting user sessions: $e');
      return [];
    }
  }

  /// Revoke specific device session
  Future<bool> revokeDeviceSession(String userId, String deviceId) async {
    try {
      await _supabase
          .from(_deviceSessionTable)
          .update({'is_active': false})
          .eq('user_id', userId)
          .eq('device_id', deviceId);

      return true;
    } catch (e) {
      debugPrint('Error revoking device session: $e');
      return false;
    }
  }

  /// Update last active timestamp
  Future<void> updateLastActive(String userId) async {
    if (!enableSingleDeviceLogin) return;

    try {
      final deviceId = await getDeviceId();

      await _supabase
          .from(_deviceSessionTable)
          .update({'last_active': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .eq('device_id', deviceId);
    } catch (e) {
      debugPrint('Error updating last active: $e');
    }
  }
}

/*
To enable single device login, you need to create this table in Supabase:

CREATE TABLE user_device_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  device_info JSONB,
  last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, device_id)
);

-- Enable RLS
ALTER TABLE user_device_sessions ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to manage their own sessions
CREATE POLICY "Users can manage their own device sessions" ON user_device_sessions
  FOR ALL USING (auth.uid() = user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
CREATE TRIGGER update_user_device_sessions_updated_at
  BEFORE UPDATE ON user_device_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
*/
