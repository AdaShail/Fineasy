/// API cache service with endpoint-specific configuration
/// 
/// Implements intelligent caching strategies for API responses
/// with automatic invalidation and per-endpoint configuration.
/// 
/// Requirements: 8.5, 20.8

library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'caching_strategy.dart';

/// Cache strategy for API endpoints
enum ApiCacheStrategy {
  /// Always fetch from network, never cache
  noCache,
  
  /// Cache for short duration (5 minutes)
  shortTerm,
  
  /// Cache for medium duration (30 minutes)
  mediumTerm,
  
  /// Cache for long duration (1 hour)
  longTerm,
  
  /// Cache indefinitely until manually invalidated
  persistent,
  
  /// Cache first, update in background
  staleWhileRevalidate,
}

/// API endpoint cache configuration
class ApiEndpointConfig {
  final String endpoint;
  final ApiCacheStrategy strategy;
  final Duration? customTtl;
  final bool invalidateOnMutation;
  final List<String>? invalidatesWith; // Other endpoints that invalidate this cache

  const ApiEndpointConfig({
    required this.endpoint,
    required this.strategy,
    this.customTtl,
    this.invalidateOnMutation = true,
    this.invalidatesWith,
  });

  Duration get ttl {
    if (customTtl != null) return customTtl!;
    
    switch (strategy) {
      case ApiCacheStrategy.noCache:
        return Duration.zero;
      case ApiCacheStrategy.shortTerm:
        return const Duration(minutes: 5);
      case ApiCacheStrategy.mediumTerm:
        return const Duration(minutes: 30);
      case ApiCacheStrategy.longTerm:
        return const Duration(hours: 1);
      case ApiCacheStrategy.persistent:
        return const Duration(days: 365); // Effectively permanent
      case ApiCacheStrategy.staleWhileRevalidate:
        return const Duration(minutes: 5);
    }
  }
}

/// API cache service
class ApiCacheService {
  static final ApiCacheService _instance = ApiCacheService._internal();
  factory ApiCacheService() => _instance;
  ApiCacheService._internal();

  final CacheManager<Map<String, dynamic>> _cache = CacheManager(
    namespace: 'api',
    fromJson: (json) => json,
    toJson: (data) => data,
  );

  final Map<String, ApiEndpointConfig> _endpointConfigs = {};
  final Map<String, DateTime> _lastFetchTimes = {};
  final Map<String, List<String>> _invalidationMap = {};

  /// Register endpoint configuration
  void registerEndpoint(ApiEndpointConfig config) {
    _endpointConfigs[config.endpoint] = config;
    
    // Build invalidation map
    if (config.invalidatesWith != null) {
      for (final relatedEndpoint in config.invalidatesWith!) {
        _invalidationMap[relatedEndpoint] ??= [];
        _invalidationMap[relatedEndpoint]!.add(config.endpoint);
      }
    }
  }

  /// Register multiple endpoints
  void registerEndpoints(List<ApiEndpointConfig> configs) {
    for (final config in configs) {
      registerEndpoint(config);
    }
  }

  /// Get cached response or fetch from network
  Future<Map<String, dynamic>> getOrFetch({
    required String endpoint,
    required Map<String, dynamic>? queryParams,
    required Future<Map<String, dynamic>> Function() fetcher,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _buildCacheKey(endpoint, queryParams);
    final config = _endpointConfigs[endpoint];

    // No cache strategy
    if (config?.strategy == ApiCacheStrategy.noCache || forceRefresh) {
      final data = await fetcher();
      _lastFetchTimes[cacheKey] = DateTime.now();
      return data;
    }

    // Stale-while-revalidate strategy
    if (config?.strategy == ApiCacheStrategy.staleWhileRevalidate) {
      return _staleWhileRevalidate(
        cacheKey: cacheKey,
        fetcher: fetcher,
        ttl: config!.ttl,
      );
    }

    // Standard cache-first strategy
    final cached = await _cache.get(cacheKey);
    if (cached != null && !forceRefresh) {
      return cached;
    }

    // Fetch from network
    final data = await fetcher();
    
    // Store in cache
    final ttl = config?.ttl ?? const Duration(minutes: 5);
    await _cache.put(cacheKey, data, ttl: ttl);
    _lastFetchTimes[cacheKey] = DateTime.now();

    return data;
  }

  /// Stale-while-revalidate strategy
  Future<Map<String, dynamic>> _staleWhileRevalidate({
    required String cacheKey,
    required Future<Map<String, dynamic>> Function() fetcher,
    required Duration ttl,
  }) async {
    final cached = await _cache.get(cacheKey);
    
    if (cached != null) {
      // Return stale data immediately
      
      // Revalidate in background
      _revalidateInBackground(cacheKey, fetcher, ttl);
      
      return cached;
    }

    // No cached data, fetch normally
    final data = await fetcher();
    await _cache.put(cacheKey, data, ttl: ttl);
    _lastFetchTimes[cacheKey] = DateTime.now();
    return data;
  }

  /// Revalidate cache in background
  void _revalidateInBackground(
    String cacheKey,
    Future<Map<String, dynamic>> Function() fetcher,
    Duration ttl,
  ) {
    fetcher().then((data) async {
      await _cache.put(cacheKey, data, ttl: ttl);
      _lastFetchTimes[cacheKey] = DateTime.now();
    }).catchError((error) {
    });
  }

  /// Invalidate cache for specific endpoint
  Future<void> invalidate(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final cacheKey = _buildCacheKey(endpoint, queryParams);
    await _cache.remove(cacheKey);
    _lastFetchTimes.remove(cacheKey);
    
    // Invalidate related endpoints
    final relatedEndpoints = _invalidationMap[endpoint];
    if (relatedEndpoints != null) {
      for (final relatedEndpoint in relatedEndpoints) {
        await invalidate(relatedEndpoint);
      }
    }
    
  }

  /// Invalidate all caches matching pattern
  Future<void> invalidatePattern(String pattern) async {
    // Note: This is a simplified implementation
    // In production, you would iterate through all cache keys
  }

  /// Invalidate all caches
  Future<void> invalidateAll() async {
    await _cache.clear();
    _lastFetchTimes.clear();
  }

  /// Prefetch data for endpoint
  Future<void> prefetch({
    required String endpoint,
    required Map<String, dynamic>? queryParams,
    required Future<Map<String, dynamic>> Function() fetcher,
  }) async {
    final cacheKey = _buildCacheKey(endpoint, queryParams);
    final config = _endpointConfigs[endpoint];
    
    if (config?.strategy == ApiCacheStrategy.noCache) {
      return; // Don't prefetch if no-cache strategy
    }

    try {
      final data = await fetcher();
      final ttl = config?.ttl ?? const Duration(minutes: 5);
      await _cache.put(cacheKey, data, ttl: ttl);
      _lastFetchTimes[cacheKey] = DateTime.now();
    } catch (error) {
    }
  }

  /// Check if endpoint is cached
  Future<bool> isCached(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final cacheKey = _buildCacheKey(endpoint, queryParams);
    final cached = await _cache.get(cacheKey);
    return cached != null;
  }

  /// Get cache age
  Duration? getCacheAge(String endpoint, {Map<String, dynamic>? queryParams}) {
    final cacheKey = _buildCacheKey(endpoint, queryParams);
    final lastFetch = _lastFetchTimes[cacheKey];
    
    if (lastFetch == null) return null;
    
    return DateTime.now().difference(lastFetch);
  }

  /// Build cache key from endpoint and query params
  String _buildCacheKey(String endpoint, Map<String, dynamic>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return endpoint;
    }

    // Sort params for consistent keys
    final sortedParams = Map.fromEntries(
      queryParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    final paramString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return '$endpoint?$paramString';
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'totalCached': _lastFetchTimes.length,
      'registeredEndpoints': _endpointConfigs.length,
      'invalidationRules': _invalidationMap.length,
    };
  }
}

/// Predefined API endpoint configurations
class ApiEndpoints {
  /// Dashboard data (short-term cache)
  static const dashboard = ApiEndpointConfig(
    endpoint: '/api/dashboard',
    strategy: ApiCacheStrategy.shortTerm,
  );

  /// User profile (medium-term cache)
  static const userProfile = ApiEndpointConfig(
    endpoint: '/api/user/profile',
    strategy: ApiCacheStrategy.mediumTerm,
  );

  /// Invoices list (stale-while-revalidate)
  static const invoices = ApiEndpointConfig(
    endpoint: '/api/invoices',
    strategy: ApiCacheStrategy.staleWhileRevalidate,
    invalidatesWith: ['/api/invoices/create', '/api/invoices/update'],
  );

  /// Invoice detail (medium-term cache)
  static const invoiceDetail = ApiEndpointConfig(
    endpoint: '/api/invoices/:id',
    strategy: ApiCacheStrategy.mediumTerm,
    invalidatesWith: ['/api/invoices/update'],
  );

  /// Customers list (stale-while-revalidate)
  static const customers = ApiEndpointConfig(
    endpoint: '/api/customers',
    strategy: ApiCacheStrategy.staleWhileRevalidate,
    invalidatesWith: ['/api/customers/create', '/api/customers/update'],
  );

  /// Transactions list (short-term cache)
  static const transactions = ApiEndpointConfig(
    endpoint: '/api/transactions',
    strategy: ApiCacheStrategy.shortTerm,
    invalidatesWith: ['/api/transactions/create'],
  );

  /// Reports (long-term cache)
  static const reports = ApiEndpointConfig(
    endpoint: '/api/reports',
    strategy: ApiCacheStrategy.longTerm,
  );

  /// Settings (persistent cache)
  static const settings = ApiEndpointConfig(
    endpoint: '/api/settings',
    strategy: ApiCacheStrategy.persistent,
    invalidatesWith: ['/api/settings/update'],
  );

  /// Static content (persistent cache)
  static const staticContent = ApiEndpointConfig(
    endpoint: '/api/static',
    strategy: ApiCacheStrategy.persistent,
  );

  /// Get all predefined configurations
  static List<ApiEndpointConfig> get all => [
        dashboard,
        userProfile,
        invoices,
        invoiceDetail,
        customers,
        transactions,
        reports,
        settings,
        staticContent,
      ];
}

/// Cache invalidation helper
class CacheInvalidation {
  static final ApiCacheService _cache = ApiCacheService();

  /// Invalidate after mutation
  static Future<void> afterCreate(String resourceType) async {
    await _cache.invalidate('/api/$resourceType');
    await _cache.invalidatePattern(resourceType);
  }

  /// Invalidate after update
  static Future<void> afterUpdate(String resourceType, String id) async {
    await _cache.invalidate('/api/$resourceType/$id');
    await _cache.invalidate('/api/$resourceType');
    await _cache.invalidatePattern(resourceType);
  }

  /// Invalidate after delete
  static Future<void> afterDelete(String resourceType, String id) async {
    await _cache.invalidate('/api/$resourceType/$id');
    await _cache.invalidate('/api/$resourceType');
    await _cache.invalidatePattern(resourceType);
  }

  /// Invalidate related resources
  static Future<void> invalidateRelated(List<String> resourceTypes) async {
    for (final resourceType in resourceTypes) {
      await _cache.invalidatePattern(resourceType);
    }
  }
}

/// Cache warming helper
class CacheWarming {
  static final ApiCacheService _cache = ApiCacheService();

  /// Warm critical caches on app start
  static Future<void> warmCriticalCaches({
    required Future<Map<String, dynamic>> Function() fetchDashboard,
    required Future<Map<String, dynamic>> Function() fetchUserProfile,
  }) async {
    await Future.wait([
      _cache.prefetch(
        endpoint: '/api/dashboard',
        queryParams: null,
        fetcher: fetchDashboard,
      ),
      _cache.prefetch(
        endpoint: '/api/user/profile',
        queryParams: null,
        fetcher: fetchUserProfile,
      ),
    ]);
  }

  /// Warm cache for specific route
  static Future<void> warmRouteCache(
    String route,
    Map<String, Future<Map<String, dynamic>> Function()> fetchers,
  ) async {
    final futures = fetchers.entries.map((entry) {
      return _cache.prefetch(
        endpoint: entry.key,
        queryParams: null,
        fetcher: entry.value,
      );
    });

    await Future.wait(futures);
  }
}
