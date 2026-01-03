import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Enhanced cross-platform sync service with real-time listeners
/// Handles data synchronization between web and mobile platforms
class CrossPlatformSyncService {
  static final CrossPlatformSyncService _instance =
      CrossPlatformSyncService._internal();
  factory CrossPlatformSyncService() => _instance;
  CrossPlatformSyncService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  SharedPreferences? _prefs;
  
  // Real-time subscriptions
  RealtimeChannel? _transactionsChannel;
  RealtimeChannel? _customersChannel;
  RealtimeChannel? _suppliersChannel;
  RealtimeChannel? _invoicesChannel;
  RealtimeChannel? _paymentsChannel;
  RealtimeChannel? _businessChannel;
  
  // Sync state
  bool _isSyncing = false;
  bool _isInitialized = false;
  DateTime? _lastSyncTime;
  final List<String> _syncErrors = [];
  final Map<String, dynamic> _pendingChanges = {};
  
  // Callbacks for real-time updates
  Function(Map<String, dynamic>)? onTransactionUpdate;
  Function(Map<String, dynamic>)? onCustomerUpdate;
  Function(Map<String, dynamic>)? onSupplierUpdate;
  Function(Map<String, dynamic>)? onInvoiceUpdate;
  Function(Map<String, dynamic>)? onPaymentUpdate;
  Function(Map<String, dynamic>)? onBusinessUpdate;
  Function()? onSyncComplete;
  Function(String)? onSyncError;
  Function(SyncStatus)? onSyncStatusChange;

  // Getters
  bool get isSyncing => _isSyncing;
  bool get isInitialized => _isInitialized;
  DateTime? get lastSyncTime => _lastSyncTime;
  List<String> get syncErrors => List.unmodifiable(_syncErrors);
  bool get hasPendingChanges => _pendingChanges.isNotEmpty;
  SupabaseClient get supabase => _supabase;

  /// Initialize the sync service
  static Future<void> initialize() async {
    final instance = CrossPlatformSyncService();
    try {
      instance._prefs = await SharedPreferences.getInstance();
      await instance._loadLastSyncTime();
      instance._isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Load last sync time from storage
  Future<void> _loadLastSyncTime() async {
    try {
      final timestamp = _prefs?.getString('last_sync_time');
      if (timestamp != null) {
        _lastSyncTime = DateTime.parse(timestamp);
      }
    } catch (e) {
    }
  }

  /// Save last sync time to storage
  Future<void> _saveLastSyncTime() async {
    try {
      _lastSyncTime = DateTime.now();
      await _prefs?.setString('last_sync_time', _lastSyncTime!.toIso8601String());
    } catch (e) {
    }
  }

  /// Initialize real-time listeners for all tables
  Future<void> startRealtimeSync(String userId) async {
    if (!_isInitialized) {
      throw Exception('CrossPlatformSyncService not initialized. Call initialize() first.');
    }

    try {
      
      // Set up real-time listeners for each table
      await _setupTransactionsListener(userId);
      await _setupCustomersListener(userId);
      await _setupSuppliersListener(userId);
      await _setupInvoicesListener(userId);
      await _setupPaymentsListener(userId);
      await _setupBusinessListener(userId);
      
      _notifySyncStatus(SyncStatus.active);
    } catch (e) {
      _syncErrors.add('Failed to start real-time sync: $e');
      onSyncError?.call('Failed to start real-time sync: $e');
      _notifySyncStatus(SyncStatus.error);
      rethrow;
    }
  }

  /// Set up transactions real-time listener
  Future<void> _setupTransactionsListener(String userId) async {
    try {
      _transactionsChannel = _supabase
          .channel('transactions_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'transactions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _handleRealtimeUpdate('transactions', payload);
              onTransactionUpdate?.call(payload.newRecord);
            },
          )
          .subscribe();
      
    } catch (e) {
      rethrow;
    }
  }

  /// Set up customers real-time listener
  Future<void> _setupCustomersListener(String userId) async {
    try {
      _customersChannel = _supabase
          .channel('customers_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'customers',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _handleRealtimeUpdate('customers', payload);
              onCustomerUpdate?.call(payload.newRecord);
            },
          )
          .subscribe();
      
    } catch (e) {
      rethrow;
    }
  }

  /// Set up suppliers real-time listener
  Future<void> _setupSuppliersListener(String userId) async {
    try {
      _suppliersChannel = _supabase
          .channel('suppliers_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'suppliers',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _handleRealtimeUpdate('suppliers', payload);
              onSupplierUpdate?.call(payload.newRecord);
            },
          )
          .subscribe();
      
    } catch (e) {
      rethrow;
    }
  }

  /// Set up invoices real-time listener
  Future<void> _setupInvoicesListener(String userId) async {
    try {
      _invoicesChannel = _supabase
          .channel('invoices_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'invoices',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _handleRealtimeUpdate('invoices', payload);
              onInvoiceUpdate?.call(payload.newRecord);
            },
          )
          .subscribe();
      
    } catch (e) {
      rethrow;
    }
  }

  /// Set up payments real-time listener
  Future<void> _setupPaymentsListener(String userId) async {
    try {
      _paymentsChannel = _supabase
          .channel('payments_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'payments',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _handleRealtimeUpdate('payments', payload);
              onPaymentUpdate?.call(payload.newRecord);
            },
          )
          .subscribe();
      
    } catch (e) {
      rethrow;
    }
  }

  /// Set up business real-time listener
  Future<void> _setupBusinessListener(String userId) async {
    try {
      _businessChannel = _supabase
          .channel('business_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'businesses',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _handleRealtimeUpdate('businesses', payload);
              onBusinessUpdate?.call(payload.newRecord);
            },
          )
          .subscribe();
      
    } catch (e) {
      rethrow;
    }
  }

  /// Handle real-time update with conflict resolution
  void _handleRealtimeUpdate(String table, PostgresChangePayload payload) {
    try {
      final recordId = payload.newRecord['id'] as String?;
      if (recordId == null) return;

      // Check for pending local changes
      final pendingKey = '${table}_$recordId';
      if (_pendingChanges.containsKey(pendingKey)) {
        // Conflict detected - resolve using last-write-wins strategy
        final localTimestamp = _pendingChanges[pendingKey]['updated_at'] as String?;
        final remoteTimestamp = payload.newRecord['updated_at'] as String?;
        
        if (localTimestamp != null && remoteTimestamp != null) {
          final local = DateTime.parse(localTimestamp);
          final remote = DateTime.parse(remoteTimestamp);
          
          if (local.isAfter(remote)) {
            // Local change is newer, keep it and re-sync
            _syncPendingChange(table, recordId);
            return;
          }
        }
        
        // Remote change is newer or equal, remove pending change
        _pendingChanges.remove(pendingKey);
      }
      
      // Update last sync time
      _saveLastSyncTime();
    } catch (e) {
      _syncErrors.add('Error handling update for $table: $e');
    }
  }

  /// Sync a pending change to the server
  Future<void> _syncPendingChange(String table, String recordId) async {
    final pendingKey = '${table}_$recordId';
    final change = _pendingChanges[pendingKey];
    
    if (change == null) return;
    
    try {
      await _supabase.from(table).upsert(change);
      _pendingChanges.remove(pendingKey);
    } catch (e) {
      _syncErrors.add('Failed to sync $pendingKey: $e');
    }
  }

  /// Queue a change for sync (used when offline or for conflict resolution)
  void queueChange(String table, String recordId, Map<String, dynamic> data) {
    final pendingKey = '${table}_$recordId';
    _pendingChanges[pendingKey] = {
      ...data,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Sync all pending changes
  Future<void> syncPendingChanges() async {
    if (_pendingChanges.isEmpty) {
      return;
    }

    _isSyncing = true;
    _notifySyncStatus(SyncStatus.syncing);
    
    try {
      
      final entries = _pendingChanges.entries.toList();
      for (final entry in entries) {
        final parts = entry.key.split('_');
        if (parts.length >= 2) {
          final table = parts[0];
          final recordId = parts.sublist(1).join('_');
          await _syncPendingChange(table, recordId);
        }
      }
      
      await _saveLastSyncTime();
      onSyncComplete?.call();
      _notifySyncStatus(SyncStatus.active);
    } catch (e) {
      _syncErrors.add('Failed to sync pending changes: $e');
      onSyncError?.call('Failed to sync pending changes: $e');
      _notifySyncStatus(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  /// Perform a full sync of all data
  Future<void> performFullSync(String userId) async {
    if (_isSyncing) {
      return;
    }

    _isSyncing = true;
    _syncErrors.clear();
    _notifySyncStatus(SyncStatus.syncing);
    
    try {
      
      // Sync pending changes first
      await syncPendingChanges();
      
      // Update last sync time
      await _saveLastSyncTime();
      
      onSyncComplete?.call();
      _notifySyncStatus(SyncStatus.active);
    } catch (e) {
      _syncErrors.add('Full sync failed: $e');
      onSyncError?.call('Full sync failed: $e');
      _notifySyncStatus(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  /// Stop all real-time listeners
  Future<void> stopRealtimeSync() async {
    try {
      
      await _transactionsChannel?.unsubscribe();
      await _customersChannel?.unsubscribe();
      await _suppliersChannel?.unsubscribe();
      await _invoicesChannel?.unsubscribe();
      await _paymentsChannel?.unsubscribe();
      await _businessChannel?.unsubscribe();
      
      _transactionsChannel = null;
      _customersChannel = null;
      _suppliersChannel = null;
      _invoicesChannel = null;
      _paymentsChannel = null;
      _businessChannel = null;
      
      _notifySyncStatus(SyncStatus.inactive);
    } catch (e) {
    }
  }

  /// Clear all sync errors
  void clearErrors() {
    _syncErrors.clear();
  }

  /// Clear all pending changes (use with caution)
  void clearPendingChanges() {
    _pendingChanges.clear();
  }

  /// Notify sync status change
  void _notifySyncStatus(SyncStatus status) {
    onSyncStatusChange?.call(status);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopRealtimeSync();
    _isInitialized = false;
  }
}

/// Sync status enum
enum SyncStatus {
  inactive,
  active,
  syncing,
  error,
}