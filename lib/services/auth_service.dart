import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'device_session_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage(
    mOptions: MacOsOptions(
      groupId: 'com.example.fineasy',
      accountName: 'fineasy_auth',
      synchronizable: false,
    ),
  );
  final _deviceSessionService = DeviceSessionService();
  Future<bool> signInWithEmail(String email, String password) async {
    debugPrint("Attempting login with $email / $password");
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null && response.user != null) {
        // Check device authorization if single device login is enabled
        if (DeviceSessionService.enableSingleDeviceLogin) {
          final isAuthorized = await _deviceSessionService.isDeviceAuthorized(
            response.user!.id,
          );
          if (!isAuthorized) {
            // Register this device and remove others
            await _deviceSessionService.registerDeviceSession(
              response.user!.id,
            );
          }
        }

        await persistSession(response.session!);

        // Register device session
        await _deviceSessionService.registerDeviceSession(response.user!.id);

        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Sign in failed: $e");
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<void> persistSession(Session session) async {
    final json = jsonEncode(session.toJson());
    await _storage.write(key: 'supabase_session', value: json);
  }

  Future<bool> retrieveSession() async {
    final stored = await _storage.read(key: 'supabase_session');
    if (stored == null) return false;
    try {
      final response = await _supabase.auth.setSession(stored);
      if (response.session != null) {
        await persistSession(response.session!);
        return true;
      }
    } catch (e) {
      await _storage.delete(key: 'supabase_session');
    }
    return false;
  }

  Future<bool> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      debugPrint("Attempting signup with email: $email");

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      debugPrint(
        "Signup response: ${response.user != null ? 'Success' : 'Failed'}",
      );
      return response.user != null;
    } catch (e) {
      debugPrint("Signup error details: $e");
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  Future<void> clearSession() async {
    await _storage.delete(key: 'supabase_session');
    await _supabase.auth.signOut();
  }

  Future<bool> signInWithPhone(String phone) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phone);
      return true;
    } catch (e) {
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  Future<bool> verifyOTP(String phone, String otp) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );
      return response.user != null;
    } catch (e) {
      throw Exception('Failed to verify OTP: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      await _supabase.auth.signOut();
      await clearSession();

      // Remove device session
      if (userId != null) {
        await _deviceSessionService.removeDeviceSession(userId);
      }
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        return {
          'id': user.id,
          'email': user.email,
          'phone': user.phone,
          'name': user.userMetadata?['name'],
          'created_at': user.createdAt,
          'last_login_at': user.lastSignInAt,
          'is_email_verified': user.emailConfirmedAt != null,
          'is_phone_verified': user.phoneConfirmedAt != null,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  Future<bool> deleteAccount() async {
    try {
      await _supabase.auth.signOut();
      return true;
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  String? get currentUserId => _supabase.auth.currentUser?.id;

  bool get isAuthenticated => _supabase.auth.currentUser != null;
}
