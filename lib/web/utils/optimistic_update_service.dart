/// Optimistic UI update service for web platform
/// 
/// Implements optimistic updates with automatic rollback on failure
/// and user notifications for better perceived performance.
/// 
/// Requirements: 8.4

library;

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Optimistic update result
enum OptimisticUpdateResult {
  success,
  failure,
  rollback,
}

/// Optimistic update state
class OptimisticUpdateState<T> {
  final String id;
  final T originalValue;
  final T optimisticValue;
  final DateTime timestamp;
  OptimisticUpdateResult? result;
  Object? error;

  OptimisticUpdateState({
    required this.id,
    required this.originalValue,
    required this.optimisticValue,
    required this.timestamp,
    this.result,
    this.error,
  });

  bool get isPending => result == null;
  bool get isSuccess => result == OptimisticUpdateResult.success;
  bool get isFailure => result == OptimisticUpdateResult.failure;
  bool get isRolledBack => result == OptimisticUpdateResult.rollback;
}

/// Optimistic update callback
typedef OptimisticUpdateCallback<T> = void Function(OptimisticUpdateState<T> state);

/// Optimistic update service
class OptimisticUpdateService {
  static final OptimisticUpdateService _instance = OptimisticUpdateService._internal();
  factory OptimisticUpdateService() => _instance;
  OptimisticUpdateService._internal();

  final Map<String, OptimisticUpdateState> _pendingUpdates = {};
  final List<OptimisticUpdateCallback> _listeners = [];
  int _updateCounter = 0;

  /// Add listener for update state changes
  void addListener(OptimisticUpdateCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(OptimisticUpdateCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify listeners
  void _notifyListeners<T>(OptimisticUpdateState<T> state) {
    for (final listener in _listeners) {
      try {
        listener(state);
      } catch (e) {
      }
    }
  }

  /// Execute optimistic update
  Future<T> execute<T>({
    required T currentValue,
    required T optimisticValue,
    required Future<T> Function() operation,
    void Function(T value)? onSuccess,
    void Function(Object error)? onError,
    void Function()? onRollback,
    String? updateId,
  }) async {
    final id = updateId ?? 'update_${_updateCounter++}';
    
    // Create update state
    final state = OptimisticUpdateState<T>(
      id: id,
      originalValue: currentValue,
      optimisticValue: optimisticValue,
      timestamp: DateTime.now(),
    );

    _pendingUpdates[id] = state;

    // Immediately apply optimistic value
    _notifyListeners(state);

    try {
      // Execute actual operation
      final result = await operation();

      // Mark as success
      state.result = OptimisticUpdateResult.success;
      _pendingUpdates.remove(id);
      _notifyListeners(state);

      // Call success callback
      onSuccess?.call(result);

      return result;
    } catch (error) {
      // Mark as failure
      state.result = OptimisticUpdateResult.failure;
      state.error = error;

      // Rollback to original value
      state.result = OptimisticUpdateResult.rollback;
      _pendingUpdates.remove(id);
      _notifyListeners(state);

      // Call error and rollback callbacks
      onError?.call(error);
      onRollback?.call();

      rethrow;
    }
  }

  /// Get pending updates
  List<OptimisticUpdateState> getPendingUpdates() {
    return _pendingUpdates.values.toList();
  }

  /// Check if update is pending
  bool isPending(String updateId) {
    return _pendingUpdates.containsKey(updateId);
  }

  /// Get update state
  OptimisticUpdateState? getUpdateState(String updateId) {
    return _pendingUpdates[updateId];
  }

  /// Clear all pending updates
  void clear() {
    _pendingUpdates.clear();
  }
}

/// Optimistic update wrapper for state management
class OptimisticUpdateWrapper<T> {
  final OptimisticUpdateService _service = OptimisticUpdateService();
  T _currentValue;
  final List<void Function(T value)> _listeners = [];

  OptimisticUpdateWrapper(this._currentValue);

  /// Get current value
  T get value => _currentValue;

  /// Add listener
  void addListener(void Function(T value) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(void Function(T value) listener) {
    _listeners.remove(listener);
  }

  /// Notify listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener(_currentValue);
      } catch (e) {
      }
    }
  }

  /// Update with optimistic UI
  Future<T> update({
    required T optimisticValue,
    required Future<T> Function() operation,
    void Function(T value)? onSuccess,
    void Function(Object error)? onError,
  }) async {
    final originalValue = _currentValue;

    // Apply optimistic value immediately
    _currentValue = optimisticValue;
    _notifyListeners();

    try {
      await _service.execute<T>(
        currentValue: originalValue,
        optimisticValue: optimisticValue,
        operation: operation,
        onSuccess: (value) {
          _currentValue = value;
          _notifyListeners();
          onSuccess?.call(value);
        },
        onError: onError,
        onRollback: () {
          // Rollback to original value
          _currentValue = originalValue;
          _notifyListeners();
        },
      );

      return _currentValue;
    } catch (error) {
      // Value already rolled back in service
      rethrow;
    }
  }

  /// Dispose wrapper
  void dispose() {
    _listeners.clear();
  }
}

/// Optimistic list operations
class OptimisticList<T> {
  final OptimisticUpdateService _service = OptimisticUpdateService();
  List<T> _items;
  final List<void Function(List<T> items)> _listeners = [];

  OptimisticList(this._items);

  /// Get current items
  List<T> get items => List.unmodifiable(_items);

  /// Add listener
  void addListener(void Function(List<T> items) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(void Function(List<T> items) listener) {
    _listeners.remove(listener);
  }

  /// Notify listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener(_items);
      } catch (e) {
      }
    }
  }

  /// Add item optimistically
  Future<void> add({
    required T item,
    required Future<T> Function() operation,
    void Function(T item)? onSuccess,
    void Function(Object error)? onError,
  }) async {
    final originalItems = List<T>.from(_items);

    // Add optimistically
    _items.add(item);
    _notifyListeners();

    try {
      await _service.execute<T>(
        currentValue: item,
        optimisticValue: item,
        operation: operation,
        onSuccess: (value) {
          // Update with actual value from server
          final index = _items.indexOf(item);
          if (index != -1) {
            _items[index] = value;
            _notifyListeners();
          }
          onSuccess?.call(value);
        },
        onError: onError,
        onRollback: () {
          // Rollback: remove item
          _items = originalItems;
          _notifyListeners();
        },
      );
    } catch (error) {
      // Already rolled back
      rethrow;
    }
  }

  /// Remove item optimistically
  Future<void> remove({
    required T item,
    required Future<void> Function() operation,
    void Function()? onSuccess,
    void Function(Object error)? onError,
  }) async {
    final originalItems = List<T>.from(_items);
    final index = _items.indexOf(item);

    if (index == -1) {
      throw ArgumentError('Item not found in list');
    }

    // Remove optimistically
    _items.removeAt(index);
    _notifyListeners();

    try {
      await _service.execute<void>(
        currentValue: null,
        optimisticValue: null,
        operation: operation,
        onSuccess: (_) {
          onSuccess?.call();
        },
        onError: onError,
        onRollback: () {
          // Rollback: restore item
          _items = originalItems;
          _notifyListeners();
        },
      );
    } catch (error) {
      // Already rolled back
      rethrow;
    }
  }

  /// Update item optimistically
  Future<void> update({
    required T oldItem,
    required T newItem,
    required Future<T> Function() operation,
    void Function(T item)? onSuccess,
    void Function(Object error)? onError,
  }) async {
    final originalItems = List<T>.from(_items);
    final index = _items.indexOf(oldItem);

    if (index == -1) {
      throw ArgumentError('Item not found in list');
    }

    // Update optimistically
    _items[index] = newItem;
    _notifyListeners();

    try {
      await _service.execute<T>(
        currentValue: oldItem,
        optimisticValue: newItem,
        operation: operation,
        onSuccess: (value) {
          // Update with actual value from server
          final currentIndex = _items.indexOf(newItem);
          if (currentIndex != -1) {
            _items[currentIndex] = value;
            _notifyListeners();
          }
          onSuccess?.call(value);
        },
        onError: onError,
        onRollback: () {
          // Rollback: restore original item
          _items = originalItems;
          _notifyListeners();
        },
      );
    } catch (error) {
      // Already rolled back
      rethrow;
    }
  }

  /// Dispose list
  void dispose() {
    _listeners.clear();
  }
}

/// Optimistic map operations
class OptimisticMap<K, V> {
  final OptimisticUpdateService _service = OptimisticUpdateService();
  Map<K, V> _data;
  final List<void Function(Map<K, V> data)> _listeners = [];

  OptimisticMap(this._data);

  /// Get current data
  Map<K, V> get data => Map.unmodifiable(_data);

  /// Add listener
  void addListener(void Function(Map<K, V> data) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(void Function(Map<K, V> data) listener) {
    _listeners.remove(listener);
  }

  /// Notify listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener(_data);
      } catch (e) {
      }
    }
  }

  /// Set value optimistically
  Future<void> set({
    required K key,
    required V value,
    required Future<V> Function() operation,
    void Function(V value)? onSuccess,
    void Function(Object error)? onError,
  }) async {
    final originalData = Map<K, V>.from(_data);
    final originalValue = _data[key];

    // Set optimistically
    _data[key] = value;
    _notifyListeners();

    try {
      await _service.execute<V>(
        currentValue: originalValue as V,
        optimisticValue: value,
        operation: operation,
        onSuccess: (resultValue) {
          // Update with actual value from server
          _data[key] = resultValue;
          _notifyListeners();
          onSuccess?.call(resultValue);
        },
        onError: onError,
        onRollback: () {
          // Rollback
          _data = originalData;
          _notifyListeners();
        },
      );
    } catch (error) {
      // Already rolled back
      rethrow;
    }
  }

  /// Remove value optimistically
  Future<void> remove({
    required K key,
    required Future<void> Function() operation,
    void Function()? onSuccess,
    void Function(Object error)? onError,
  }) async {
    final originalData = Map<K, V>.from(_data);

    if (!_data.containsKey(key)) {
      throw ArgumentError('Key not found in map');
    }

    // Remove optimistically
    _data.remove(key);
    _notifyListeners();

    try {
      await _service.execute<void>(
        currentValue: null,
        optimisticValue: null,
        operation: operation,
        onSuccess: (_) {
          onSuccess?.call();
        },
        onError: onError,
        onRollback: () {
          // Rollback
          _data = originalData;
          _notifyListeners();
        },
      );
    } catch (error) {
      // Already rolled back
      rethrow;
    }
  }

  /// Dispose map
  void dispose() {
    _listeners.clear();
  }
}

/// Error notification handler for optimistic updates
class OptimisticUpdateErrorHandler {
  static void handleError(Object error, {
    String? message,
    void Function()? onRetry,
  }) {
    
    // In a real app, this would show a toast or snackbar
    // For now, just log the error
    final errorMessage = message ?? 'Operation failed. Changes have been reverted.';
  }
}
