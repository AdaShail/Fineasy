import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Check for existing session on app start
    _checkExistingSession();

    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final event = data.event;

      logger.d('Auth state changed: $event, session: ${session != null}');

      if (session != null && !session.isExpired) {
        _isAuthenticated = true;
        _loadUserProfile();
      } else if (event == AuthChangeEvent.signedOut ||
          event == AuthChangeEvent.tokenRefreshed && session == null) {
        _isAuthenticated = false;
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _checkExistingSession() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      logger.d('Checking existing session: ${session != null}');

      if (session != null && !session.isExpired) {
        logger.i('Valid session found, loading user profile');
        _isAuthenticated = true;
        await _loadUserProfile();
      } else {
        logger.d('No valid session found or session expired');
        // Try to recover session from storage
        try {
          // Try to refresh the session instead of recover
          await Supabase.instance.client.auth.refreshSession();
          final recoveredSession = Supabase.instance.client.auth.currentSession;
          if (recoveredSession != null && !recoveredSession.isExpired) {
            logger.i('Session refreshed successfully');
            _isAuthenticated = true;
            await _loadUserProfile();
          } else {
            logger.w('Session refresh failed');
            _isAuthenticated = false;
            _user = null;
          }
        } catch (recoveryError) {
          logger.e('Session refresh error', error: recoveryError);
          _isAuthenticated = false;
          _user = null;
          _error = 'Failed to refresh session. Please sign in again.';
        }
      }
    } catch (e) {
      logger.e('Session check failed', error: e);
      _isAuthenticated = false;
      _user = null;
      _error = 'Failed to check session. Please sign in again.';
    }
    notifyListeners();
  }

  Future<void> initAuth() async {
    _isAuthenticated = await _authService.retrieveSession();
    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        _user = UserModel.fromJson(userData);
        logger.i('User profile loaded successfully');
      } else {
        logger.w('No user data found');
      }
      notifyListeners();
    } catch (e) {
      logger.e('Failed to load user profile', error: e);
      _error = 'Failed to load user profile: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final success = await _authService.signInWithEmail(email, password);
      if (success) {
        _isAuthenticated = true;
        await _loadUserProfile();
        logger.i('User signed in successfully with email');
      } else {
        _error = 'Sign in failed. Please check your credentials.';
        logger.w('Sign in failed for email: $email');
      }
      _setLoading(false);
      return success;
    } catch (e) {
      logger.e('Sign in error', error: e);
      _error = 'Sign in failed: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      final success = await _authService.signUpWithEmail(email, password, name);
      if (success) {
        logger.i('User signed up successfully with email');
      } else {
        _error = 'Sign up failed. Please try again.';
        logger.w('Sign up failed for email: $email');
      }
      _setLoading(false);
      return success;
    } catch (e) {
      logger.e('Sign up error', error: e);
      _error = 'Sign up failed: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithPhone(String phone) async {
    _setLoading(true);
    _error = null;
    try {
      final success = await _authService.signInWithPhone(phone);
      if (success) {
        logger.i('OTP sent successfully to phone: $phone');
      } else {
        _error = 'Failed to send OTP. Please try again.';
        logger.w('Failed to send OTP to phone: $phone');
      }
      _setLoading(false);
      return success;
    } catch (e) {
      logger.e('Sign in with phone error', error: e);
      _error = 'Failed to send OTP: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOTP(String phone, String otp) async {
    _setLoading(true);
    _error = null;
    try {
      final success = await _authService.verifyOTP(phone, otp);
      if (success) {
        _isAuthenticated = true;
        await _loadUserProfile();
        logger.i('OTP verified successfully for phone: $phone');
      } else {
        _error = 'Invalid OTP. Please try again.';
        logger.w('OTP verification failed for phone: $phone');
      }
      _setLoading(false);
      return success;
    } catch (e) {
      logger.e('OTP verification error', error: e);
      _error = 'OTP verification failed: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _isAuthenticated = false;
      _user = null;
      _error = null;
      logger.i('User signed out successfully');
      _setLoading(false);
    } catch (e) {
      logger.e('Sign out error', error: e);
      _error = 'Sign out failed: ${e.toString()}';
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      final success = await _authService.changePassword(
        currentPassword,
        newPassword,
      );
      if (success) {
        logger.i('Password changed successfully');
      } else {
        _error =
            'Failed to change password. Please check your current password.';
        logger.w('Password change failed');
      }
      _setLoading(false);
      return success;
    } catch (e) {
      logger.e('Change password error', error: e);
      _error = 'Failed to change password: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    _setLoading(true);
    _error = null;
    try {
      final success = await _authService.deleteAccount();
      if (success) {
        _isAuthenticated = false;
        _user = null;
        logger.i('Account deleted successfully');
      } else {
        _error = 'Failed to delete account. Please try again.';
        logger.w('Account deletion failed');
      }
      _setLoading(false);
      return success;
    } catch (e) {
      logger.e('Delete account error', error: e);
      _error = 'Failed to delete account: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
