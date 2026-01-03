/// Caching strategies for web platform
/// 
/// Implements multi-level caching (memory, disk, service worker)
/// to optimize performance and enable offline functionality.

library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache entry with expiration
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration? ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    this.ttl,
  });

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(timestamp) > ttl!;
  }

  Map<String, dynamic> toJson() => {
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'ttl': ttl?.inSeconds,
      };

  factory CacheEntry.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return CacheEntry(
      data: fromJson(json['data'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      ttl: json['ttl'] != null ? Duration(seconds: json['ttl'] as int) : null,
    );
  }
}

/// Memory cache with LRU eviction
class MemoryCache<K, V> {
  final int maxSize;
  final Map<K, CacheEntry<V>> _cache = {};
  final List<K> _accessOrder = [];

  MemoryCache({this.maxSize = 100});

  /// Get value from cache
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      remove(key);
      return null;
    }

    // Update access order (LRU)
    _accessOrder.remove(key);
    _accessOrder.add(key);

    return entry.data;
  }

  /// Put value in cache
  void put(K key, V value, {Duration? ttl}) {
    // Remove if already exists
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
    }

    // Evict oldest if at capacity
    if (_cache.length >= maxSize && !_cache.containsKey(key)) {
      final oldestKey = _accessOrder.first;
      remove(oldestKey);
    }

    _cache[key] = CacheEntry(
      data: value,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
    _accessOrder.add(key);
  }

  /// Remove value from cache
  void remove(K key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  /// Get cache size
  int get size => _cache.length;

  /// Check if key exists
  bool containsKey(K key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      remove(key);
      return false;
    }
    return true;
  }
}

/// Disk cache using SharedPreferences
class DiskCache {
  static final DiskCache _instance = DiskCache._internal();
  factory DiskCache() => _instance;
  DiskCache._internal();

  SharedPreferences? _prefs;
  final String _prefix = 'cache_';

  /// Initialize disk cache
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get value from disk cache
  Future<T?> get<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    await initialize();
    
    final jsonString = _prefs?.getString('$_prefix$key');
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final entry = CacheEntry.fromJson(json, fromJson);

      if (entry.isExpired) {
        await remove(key);
        return null;
      }

      return entry.data;
    } catch (e) {
      return null;
    }
  }

  /// Put value in disk cache
  Future<void> put<T>(
    String key,
    T value,
    Map<String, dynamic> Function(T) toJson, {
    Duration? ttl,
  }) async {
    await initialize();

    final entry = CacheEntry(
      data: value,
      timestamp: DateTime.now(),
      ttl: ttl,
    );

    final json = {
      'data': toJson(value),
      'timestamp': entry.timestamp.toIso8601String(),
      'ttl': ttl?.inSeconds,
    };

    await _prefs?.setString('$_prefix$key', jsonEncode(json));
  }

  /// Remove value from disk cache
  Future<void> remove(String key) async {
    await initialize();
    await _prefs?.remove('$_prefix$key');
  }

  /// Clear all disk cache
  Future<void> clear() async {
    await initialize();
    final keys = _prefs?.getKeys().where((k) => k.startsWith(_prefix)) ?? [];
    for (final key in keys) {
      await _prefs?.remove(key);
    }
  }

  /// Get all cache keys
  Future<Set<String>> getKeys() async {
    await initialize();
    return _prefs?.getKeys()
            .where((k) => k.startsWith(_prefix))
            .map((k) => k.substring(_prefix.length))
            .toSet() ??
        {};
  }
}

/// Multi-level cache manager
class CacheManager<T> {
  final String namespace;
  final MemoryCache<String, T> _memoryCache;
  final DiskCache _diskCache = DiskCache();
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final Duration? defaultTtl;

  CacheManager({
    required this.namespace,
    required this.fromJson,
    required this.toJson,
    this.defaultTtl,
    int memoryCacheSize = 100,
  }) : _memoryCache = MemoryCache(maxSize: memoryCacheSize);

  /// Get value from cache (checks memory first, then disk)
  Future<T?> get(String key) async {
    // Check memory cache first
    final memoryValue = _memoryCache.get(key);
    if (memoryValue != null) {
      return memoryValue;
    }

    // Check disk cache
    final diskValue = await _diskCache.get('${namespace}_$key', fromJson);
    if (diskValue != null) {
      // Populate memory cache
      _memoryCache.put(key, diskValue, ttl: defaultTtl);
      return diskValue;
    }

    return null;
  }

  /// Put value in cache (both memory and disk)
  Future<void> put(String key, T value, {Duration? ttl}) async {
    final effectiveTtl = ttl ?? defaultTtl;
    
    // Store in memory cache
    _memoryCache.put(key, value, ttl: effectiveTtl);

    // Store in disk cache
    await _diskCache.put('${namespace}_$key', value, toJson, ttl: effectiveTtl);
  }

  /// Remove value from cache
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _diskCache.remove('${namespace}_$key');
  }

  /// Clear all cache
  Future<void> clear() async {
    _memoryCache.clear();
    final keys = await _diskCache.getKeys();
    for (final key in keys) {
      if (key.startsWith('${namespace}_')) {
        await _diskCache.remove(key);
      }
    }
  }

  /// Get or fetch value (with automatic caching)
  Future<T> getOrFetch(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await get(key);
      if (cached != null) {
        return cached;
      }
    }

    final value = await fetcher();
    await put(key, value, ttl: ttl);
    return value;
  }
}

/// Cache configuration for different data types
class CacheConfig {
  /// API response cache (5 minutes)
  static const Duration apiResponseTtl = Duration(minutes: 5);

  /// User data cache (30 minutes)
  static const Duration userDataTtl = Duration(minutes: 30);

  /// Static content cache (1 hour)
  static const Duration staticContentTtl = Duration(hours: 1);

  /// Image cache (24 hours)
  static const Duration imageTtl = Duration(hours: 24);

  /// Offline data cache (7 days)
  static const Duration offlineDataTtl = Duration(days: 7);

  /// No expiration
  static const Duration? noExpiration = null;
}

/// Service worker cache strategy (for web)
class ServiceWorkerCacheStrategy {
  /// Cache-first strategy: Check cache first, fallback to network
  static const String cacheFirst = 'cache-first';

  /// Network-first strategy: Try network first, fallback to cache
  static const String networkFirst = 'network-first';

  /// Cache-only strategy: Only use cache
  static const String cacheOnly = 'cache-only';

  /// Network-only strategy: Only use network
  static const String networkOnly = 'network-only';

  /// Stale-while-revalidate: Return cache immediately, update in background
  static const String staleWhileRevalidate = 'stale-while-revalidate';
}

/// Cache statistics
class CacheStats {
  int hits = 0;
  int misses = 0;
  int evictions = 0;

  double get hitRate => hits + misses > 0 ? hits / (hits + misses) : 0.0;

  void recordHit() => hits++;
  void recordMiss() => misses++;
  void recordEviction() => evictions++;

  void reset() {
    hits = 0;
    misses = 0;
    evictions = 0;
  }

  @override
  String toString() {
    return 'CacheStats(hits: $hits, misses: $misses, evictions: $evictions, hitRate: ${(hitRate * 100).toStringAsFixed(2)}%)';
  }
}

/// Global cache manager instances
class AppCaches {
  static final CacheManager<Map<String, dynamic>> apiCache = CacheManager(
    namespace: 'api',
    fromJson: (json) => json,
    toJson: (data) => data,
    defaultTtl: CacheConfig.apiResponseTtl,
  );

  static final CacheManager<Map<String, dynamic>> userData = CacheManager(
    namespace: 'user',
    fromJson: (json) => json,
    toJson: (data) => data,
    defaultTtl: CacheConfig.userDataTtl,
  );

  static final CacheManager<String> staticContent = CacheManager(
    namespace: 'static',
    fromJson: (json) => json['content'] as String,
    toJson: (data) => {'content': data},
    defaultTtl: CacheConfig.staticContentTtl,
  );

  /// Clear all caches
  static Future<void> clearAll() async {
    await Future.wait([
      apiCache.clear(),
      userData.clear(),
      staticContent.clear(),
    ]);
  }
}
