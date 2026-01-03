import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'recurring_payment_service.dart';

class AppLifecycleService extends WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  String? _currentBusinessId;

  void initialize({String? businessId}) {
    _currentBusinessId = businessId;
    WidgetsBinding.instance.addObserver(this);
  }

  void setBusinessId(String businessId) {
    _currentBusinessId = businessId;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _handleAppResumed() async {
    try {
      // Check if session is still valid when app resumes
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.isExpired) {
        await Supabase.instance.client.auth.refreshSession();
      }

      // Process recurring payments when app resumes
      await _processRecurringPayments();
    } catch (e) {
    }
  }

  void _handleAppPaused() {
    // App is going to background - session should be preserved automatically
    // by Supabase's persistent storage
  }

  /// Process recurring payments to generate any due occurrences
  Future<void> _processRecurringPayments() async {
    if (_currentBusinessId == null) {
      return;
    }

    try {
      final count = await RecurringPaymentService.processRecurringPayments(
        businessId: _currentBusinessId!,
      );
      
      if (count > 0) {
      }
    } catch (e) {
    }
  }
}
