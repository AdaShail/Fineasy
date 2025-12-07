import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppLifecycleService extends WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print('App resumed - checking session');
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        print('App paused - preserving session');
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        print('App detached');
        break;
      case AppLifecycleState.inactive:
        print('App inactive');
        break;
      case AppLifecycleState.hidden:
        print('App hidden');
        break;
    }
  }

  void _handleAppResumed() async {
    try {
      // Check if session is still valid when app resumes
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.isExpired) {
        print('Session expired, attempting refresh');
        await Supabase.instance.client.auth.refreshSession();
      }
    } catch (e) {
      print('Error handling app resume: $e');
    }
  }

  void _handleAppPaused() {
    // App is going to background - session should be preserved automatically
    // by Supabase's persistent storage
    print('App going to background, session will be preserved');
  }
}
