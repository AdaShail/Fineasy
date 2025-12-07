import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DebugHelper {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final tagStr = tag != null ? '[$tag] ' : '';
      print('🐛 $timestamp $tagStr$message');
    }
  }

  static void logError(String message, dynamic error, {String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final tagStr = tag != null ? '[$tag] ' : '';
      print('❌ $timestamp ${tagStr}ERROR: $message');
      print('❌ $timestamp ${tagStr}Details: $error');
    }
  }

  static void logSuccess(String message, {String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final tagStr = tag != null ? '[$tag] ' : '';
      print('✅ $timestamp $tagStr$message');
    }
  }

  static void logSupabaseConfig() {
    if (kDebugMode) {
      final supabase = Supabase.instance.client;
      log('Supabase Client: ${supabase.runtimeType}', tag: 'CONFIG');
      log(
        'Auth User: ${supabase.auth.currentUser?.email ?? 'Not logged in'}',
        tag: 'AUTH',
      );
      log(
        'Auth Session: ${supabase.auth.currentSession != null ? 'Active' : 'None'}',
        tag: 'AUTH',
      );
    }
  }

  static Future<void> testSupabaseConnection() async {
    try {
      log('Testing Supabase connection...', tag: 'TEST');

      final supabase = Supabase.instance.client;

      // Test basic connection
      await supabase.from('businesses').select('count').limit(1);
      logSuccess('Supabase connection successful', tag: 'TEST');

      // Test auth
      final user = supabase.auth.currentUser;
      if (user != null) {
        logSuccess('User authenticated: ${user.email}', tag: 'AUTH');
      } else {
        log('No user authenticated', tag: 'AUTH');
      }
    } catch (e) {
      logError('Supabase connection failed', e, tag: 'TEST');
    }
  }

  static Future<void> testBusinessCreation(
    Map<String, dynamic> businessData,
  ) async {
    try {
      log('Testing business creation...', tag: 'BUSINESS');
      log('Business data: $businessData', tag: 'BUSINESS');

      final supabase = Supabase.instance.client;

      // Check if user is authenticated
      final user = supabase.auth.currentUser;
      if (user == null) {
        logError(
          'Business creation failed',
          'User not authenticated',
          tag: 'BUSINESS',
        );
        return;
      }

      logSuccess('User authenticated: ${user.email}', tag: 'BUSINESS');

      // Test insert
      final response =
          await supabase
              .from('businesses')
              .insert(businessData)
              .select()
              .single();

      logSuccess(
        'Business created successfully: ${response['id']}',
        tag: 'BUSINESS',
      );
    } catch (e) {
      logError('Business creation test failed', e, tag: 'BUSINESS');

      // Detailed error analysis
      if (e.toString().contains('row-level security')) {
        logError(
          'RLS Policy Issue',
          'Run fix_rls_policies.sql in Supabase',
          tag: 'BUSINESS',
        );
      } else if (e.toString().contains('duplicate key')) {
        logError(
          'Duplicate Business',
          'User already has a business',
          tag: 'BUSINESS',
        );
      } else if (e.toString().contains('not authenticated')) {
        logError(
          'Auth Issue',
          'User session expired or invalid',
          tag: 'BUSINESS',
        );
      }
    }
  }

  static Future<void> testEmailConfiguration() async {
    try {
      log('Testing email configuration...', tag: 'EMAIL');

      final supabase = Supabase.instance.client;

      // Try to get auth settings (this will fail if not configured properly)
      final user = supabase.auth.currentUser;
      if (user != null) {
        log('Current user email: ${user.email}', tag: 'EMAIL');
        log('Email confirmed: ${user.emailConfirmedAt != null}', tag: 'EMAIL');

        if (user.emailConfirmedAt == null) {
          log(
            'Email not confirmed - check Supabase email settings',
            tag: 'EMAIL',
          );
        }
      }
    } catch (e) {
      logError('Email configuration test failed', e, tag: 'EMAIL');
    }
  }
}
