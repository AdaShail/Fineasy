import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for managing Progressive Web App (PWA) functionality
/// Handles installation prompts, offline queue, and service worker communication
class PWAService {
  static final PWAService _instance = PWAService._internal();
  factory PWAService() => _instance;
  PWAService._internal();

  // Stream controllers for PWA events
  final _installPromptController = StreamController<bool>.broadcast();
  final _onlineStatusController = StreamController<bool>.broadcast();
  final _syncStatusController = StreamController<SyncStatus>.broadcast();

  // Streams
  Stream<bool> get installPromptAvailable => _installPromptController.stream;
  Stream<bool> get onlineStatus => _onlineStatusController.stream;
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  // State
  bool _isInstallPromptAvailable = false;
  bool _isOnline = true;
  final List<QueuedOperation> _offlineQueue = [];

  /// Initialize PWA service
  Future<void> initialize() async {
    if (!kIsWeb) {
      return;
    }


    // Check initial online status
    _checkOnlineStatus();

    // Set up periodic online status check
    Timer.periodic(const Duration(seconds: 5), (_) {
      _checkOnlineStatus();
    });

  }

  /// Check if PWA install prompt is available
  bool get isInstallPromptAvailable => _isInstallPromptAvailable;

  /// Check if device is online
  bool get isOnline => _isOnline;

  /// Get queued operations count
  int get queuedOperationsCount => _offlineQueue.length;

  /// Show PWA install prompt
  Future<bool> showInstallPrompt() async {
    if (!kIsWeb) {
      return false;
    }

    if (!_isInstallPromptAvailable) {
      return false;
    }

    try {
      // This would trigger the browser's install prompt
      // In a real implementation, this would use dart:js to call the prompt
      
      // Simulate prompt result
      await Future.delayed(const Duration(milliseconds: 500));
      
      _isInstallPromptAvailable = false;
      _installPromptController.add(false);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Queue an operation for offline sync
  Future<void> queueOperation(QueuedOperation operation) async {
    if (!kIsWeb) return;

    
    _offlineQueue.add(operation);
    
    // Notify listeners
    _syncStatusController.add(SyncStatus(
      isPending: true,
      queuedCount: _offlineQueue.length,
      lastSyncTime: DateTime.now(),
    ));

    // Try to sync immediately if online
    if (_isOnline) {
      await syncQueuedOperations();
    }
  }

  /// Sync all queued operations
  Future<void> syncQueuedOperations() async {
    if (!kIsWeb || _offlineQueue.isEmpty) return;


    final operationsToSync = List<QueuedOperation>.from(_offlineQueue);
    final successfulSyncs = <QueuedOperation>[];

    for (final operation in operationsToSync) {
      try {
        // In a real implementation, this would execute the actual operation
        
        // Simulate sync
        await Future.delayed(const Duration(milliseconds: 100));
        
        successfulSyncs.add(operation);
      } catch (e) {
      }
    }

    // Remove successfully synced operations
    _offlineQueue.removeWhere((op) => successfulSyncs.contains(op));

    // Notify listeners
    _syncStatusController.add(SyncStatus(
      isPending: _offlineQueue.isNotEmpty,
      queuedCount: _offlineQueue.length,
      lastSyncTime: DateTime.now(),
      syncedCount: successfulSyncs.length,
    ));

  }

  /// Clear all queued operations
  void clearQueue() {
    _offlineQueue.clear();
    _syncStatusController.add(SyncStatus(
      isPending: false,
      queuedCount: 0,
      lastSyncTime: DateTime.now(),
    ));
  }

  /// Check online status
  void _checkOnlineStatus() {
    // In a real implementation, this would check navigator.onLine
    // For now, assume always online
    final wasOnline = _isOnline;
    _isOnline = true; // Would check actual status in real implementation

    if (wasOnline != _isOnline) {
      _onlineStatusController.add(_isOnline);
      
      if (_isOnline && _offlineQueue.isNotEmpty) {
        // Connection restored, sync queued operations
        syncQueuedOperations();
      }
    }
  }

  /// Request persistent storage
  Future<bool> requestPersistentStorage() async {
    if (!kIsWeb) return false;

    try {
      // In a real implementation, this would use dart:js to call
      // navigator.storage.persist()
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if storage is persisted
  Future<bool> isStoragePersisted() async {
    if (!kIsWeb) return false;

    try {
      // In a real implementation, this would use dart:js to call
      // navigator.storage.persisted()
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clear service worker cache
  Future<void> clearCache() async {
    if (!kIsWeb) return;

    try {
      // In a real implementation, this would send a message to the service worker
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
    }
  }

  /// Dispose resources
  void dispose() {
    _installPromptController.close();
    _onlineStatusController.close();
    _syncStatusController.close();
  }
}

/// Represents an operation queued for offline sync
class QueuedOperation {
  final String id;
  final String type;
  final String url;
  final String method;
  final Map<String, String>? headers;
  final String? body;
  final DateTime queuedAt;

  QueuedOperation({
    required this.id,
    required this.type,
    required this.url,
    required this.method,
    this.headers,
    this.body,
    DateTime? queuedAt,
  }) : queuedAt = queuedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'url': url,
        'method': method,
        'headers': headers,
        'body': body,
        'queuedAt': queuedAt.toIso8601String(),
      };

  factory QueuedOperation.fromJson(Map<String, dynamic> json) {
    return QueuedOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      method: json['method'] as String,
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      body: json['body'] as String?,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
    );
  }
}

/// Represents the sync status
class SyncStatus {
  final bool isPending;
  final int queuedCount;
  final DateTime lastSyncTime;
  final int? syncedCount;

  SyncStatus({
    required this.isPending,
    required this.queuedCount,
    required this.lastSyncTime,
    this.syncedCount,
  });
}
