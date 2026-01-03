import 'package:flutter/foundation.dart';
import '../services/cross_platform_sync_service.dart';
import '../services/web_session_service.dart';

/// Provider for managing cross-platform sync and session state
class SyncStatusProvider extends ChangeNotifier {
  final CrossPlatformSyncService _syncService = CrossPlatformSyncService();
  final WebSessionService _sessionService = WebSessionService();

  SyncStatus _syncStatus = SyncStatus.inactive;
  bool _isSessionActive = false;
  DateTime? _lastSyncTime;
  List<String> _syncErrors = [];
  bool _hasPendingChanges = false;

  // Getters
  SyncStatus get syncStatus => _syncStatus;
  bool get isSessionActive => _isSessionActive;
  DateTime? get lastSyncTime => _lastSyncTime;
  List<String> get syncErrors => _syncErrors;
  bool get hasPendingChanges => _hasPendingChanges;
  bool get isSyncing => _syncStatus == SyncStatus.syncing;

  SyncStatusProvider() {
    _initialize();
  }

  void _initialize() {
    // Set up sync service callbacks
    _syncService.onSyncStatusChange = (status) {
      _syncStatus = status;
      _updateState();
      notifyListeners();
    };

    _syncService.onSyncComplete = () {
      _updateState();
      notifyListeners();
    };

    _syncService.onSyncError = (error) {
      _syncErrors = _syncService.syncErrors;
      notifyListeners();
    };

    // Set up session service callbacks
    _sessionService.onSessionExpired = () {
      _isSessionActive = false;
      notifyListeners();
    };

    _sessionService.onSessionRefreshed = () {
      _isSessionActive = true;
      notifyListeners();
    };

    // Initial state update
    _updateState();
  }

  void _updateState() {
    _lastSyncTime = _syncService.lastSyncTime;
    _syncErrors = _syncService.syncErrors;
    _hasPendingChanges = _syncService.hasPendingChanges;
    _isSessionActive = _sessionService.isSessionActive;
  }

  /// Start sync for a user
  Future<void> startSync(String userId) async {
    try {
      await _syncService.startRealtimeSync(userId);
      _updateState();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Stop sync
  Future<void> stopSync() async {
    try {
      await _syncService.stopRealtimeSync();
      _updateState();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Perform full sync
  Future<void> performFullSync(String userId) async {
    try {
      await _syncService.performFullSync(userId);
      _updateState();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Sync pending changes
  Future<void> syncPendingChanges() async {
    try {
      await _syncService.syncPendingChanges();
      _updateState();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Clear sync errors
  void clearErrors() {
    _syncService.clearErrors();
    _updateState();
    notifyListeners();
  }

  /// Start session
  Future<void> startSession(String userId) async {
    try {
      await _sessionService.startSession(userId);
      _isSessionActive = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// End session
  Future<void> endSession() async {
    try {
      await _sessionService.endSession();
      _isSessionActive = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Update activity
  Future<void> updateActivity() async {
    try {
      await _sessionService.updateActivity();
    } catch (e) {
    }
  }

  /// Refresh session
  Future<void> refreshSession() async {
    try {
      await _sessionService.refreshSession();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _syncService.onSyncStatusChange = null;
    _syncService.onSyncComplete = null;
    _syncService.onSyncError = null;
    _sessionService.onSessionExpired = null;
    _sessionService.onSessionRefreshed = null;
    super.dispose();
  }
}
