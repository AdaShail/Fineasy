import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/sync_service.dart';

class SyncProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();

  bool _isOnline = true;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _pendingSyncItems = 0;
  String? _syncError;

  // Getters
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingSyncItems => _pendingSyncItems;
  String? get syncError => _syncError;

  SyncProvider() {
    _initializeConnectivity();
    _loadSyncStatus();
  }

  void _initializeConnectivity() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOnline = _isOnline;
      _isOnline =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);

      if (!wasOnline && _isOnline) {
        // Just came online, trigger sync
        syncAll();
      }

      notifyListeners();
    });

    // Check initial connectivity
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _isOnline =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);
    notifyListeners();
  }

  Future<void> _loadSyncStatus() async {
    try {
      _pendingSyncItems = await _syncService.getPendingSyncItemsCount();
      _lastSyncTime = await _syncService.getLastSyncTime();
      notifyListeners();
    } catch (e) {
      _syncError = e.toString();
      notifyListeners();
    }
  }

  Future<void> syncAll() async {
    if (!_isOnline || _isSyncing) return;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      await _syncService.syncAllData();
      _lastSyncTime = DateTime.now();
      _pendingSyncItems = 0;
    } catch (e) {
      _syncError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncNow() async {
    await syncAll();
  }

  Future<void> syncTransactions() async {
    if (!_isOnline || _isSyncing) return;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      await _syncService.syncTransactions();
      await _loadSyncStatus();
    } catch (e) {
      _syncError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncCustomers() async {
    if (!_isOnline || _isSyncing) return;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      await _syncService.syncCustomers();
      await _loadSyncStatus();
    } catch (e) {
      _syncError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncSuppliers() async {
    if (!_isOnline || _isSyncing) return;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      await _syncService.syncSuppliers();
      await _loadSyncStatus();
    } catch (e) {
      _syncError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void addPendingSyncItem() {
    _pendingSyncItems++;
    notifyListeners();
  }

  void clearSyncError() {
    _syncError = null;
    notifyListeners();
  }

  String getConnectionStatusText() {
    if (_isSyncing) return 'Syncing...';
    if (!_isOnline) return 'Offline';
    if (_pendingSyncItems > 0) return '$_pendingSyncItems pending';
    return 'Online';
  }

  Color getConnectionStatusColor() {
    if (_isSyncing) return Colors.orange;
    if (!_isOnline) return Colors.red;
    if (_pendingSyncItems > 0) return Colors.orange;
    return Colors.green;
  }
}
