import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/ai_config.dart';
import '../models/feature_flag_models.dart';
import 'auth_service.dart';

/// Service for managing feature flags and A/B testing
class FeatureFlagService {
  static const String _cachePrefix = 'feature_flag_';
  static const Duration _cacheExpiry = Duration(minutes: 5);

  final AuthService _authService = AuthService();
  final Map<String, FeatureFlagCache> _memoryCache = {};

  /// Check if a feature is enabled for the current user
  Future<bool> isFeatureEnabled(String featureName) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return false;

      // Check memory cache first
      if (_isMemoryCacheValid(featureName)) {
        return _memoryCache[featureName]!.enabled;
      }

      // Check persistent cache
      final cachedResult = await _getCachedResult(featureName);
      if (cachedResult != null) {
        _memoryCache[featureName] = cachedResult;
        return cachedResult.enabled;
      }

      // Fetch from API
      final result = await _checkFeatureFromAPI(
        featureName,
        user['id'] as String,
      );
      if (result != null) {
        await _cacheResult(featureName, result);
        _memoryCache[featureName] = FeatureFlagCache(
          enabled: result.enabled,
          variant: result.variant,
          cachedAt: DateTime.now(),
        );
        return result.enabled;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking feature flag $featureName: $e');
      return false;
    }
  }

  /// Get A/B test variant for a feature
  Future<String?> getFeatureVariant(String featureName) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return null;

      // Check memory cache first
      if (_isMemoryCacheValid(featureName)) {
        return _memoryCache[featureName]!.variant;
      }

      // Check persistent cache
      final cachedResult = await _getCachedResult(featureName);
      if (cachedResult != null) {
        _memoryCache[featureName] = cachedResult;
        return cachedResult.variant;
      }

      // Fetch from API
      final result = await _checkFeatureFromAPI(
        featureName,
        user['id'] as String,
      );
      if (result != null) {
        await _cacheResult(featureName, result);
        _memoryCache[featureName] = FeatureFlagCache(
          enabled: result.enabled,
          variant: result.variant,
          cachedAt: DateTime.now(),
        );
        return result.variant;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting feature variant $featureName: $e');
      return null;
    }
  }

  /// Track user interaction with a feature
  Future<void> trackInteraction(
    String featureName, {
    String interactionType = 'view',
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      final token = await _getAccessToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${AIConfig.baseUrl}/api/v1/feature-flags/track/interaction'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'feature_name': featureName,
          'user_id': user['id'],
          'interaction_type': interactionType,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to track interaction: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error tracking interaction: $e');
    }
  }

  /// Track conversion event for A/B testing
  Future<void> trackConversion(
    String featureName, {
    double conversionValue = 1.0,
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      final token = await _getAccessToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${AIConfig.baseUrl}/api/v1/feature-flags/track/conversion'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'feature_name': featureName,
          'user_id': user['id'],
          'conversion_value': conversionValue,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to track conversion: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error tracking conversion: $e');
    }
  }

  /// Preload feature flags for better performance
  Future<void> preloadFeatureFlags() async {
    final features = [
      'fraud_detection',
      'predictive_insights',
      'compliance_checking',
      'nlp_invoice_generation',
      'smart_notifications',
      'ml_analytics_engine',
    ];

    for (final feature in features) {
      await isFeatureEnabled(feature);
    }
  }

  /// Clear all cached feature flags
  Future<void> clearCache() async {
    _memoryCache.clear();
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  /// Check feature from API
  Future<FeatureCheckResult?> _checkFeatureFromAPI(
    String featureName,
    String userId,
  ) async {
    try {
      final token = await _getAccessToken();
      if (token == null) return null;

      final response = await http
          .post(
            Uri.parse('${AIConfig.baseUrl}/api/v1/feature-flags/check'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'feature_name': featureName, 'user_id': userId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FeatureCheckResult.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error checking feature from API: $e');
    }
    return null;
  }

  /// Check if memory cache is valid
  bool _isMemoryCacheValid(String featureName) {
    final cached = _memoryCache[featureName];
    if (cached == null) return false;

    return DateTime.now().difference(cached.cachedAt) < _cacheExpiry;
  }

  /// Get cached result from persistent storage
  Future<FeatureFlagCache?> _getCachedResult(String featureName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$featureName';
      final cachedData = prefs.getString(cacheKey);

      if (cachedData != null) {
        final data = jsonDecode(cachedData);
        final cache = FeatureFlagCache.fromJson(data);

        // Check if cache is still valid
        if (DateTime.now().difference(cache.cachedAt) < _cacheExpiry) {
          return cache;
        } else {
          // Remove expired cache
          await prefs.remove(cacheKey);
        }
      }
    } catch (e) {
      debugPrint('Error getting cached result: $e');
    }
    return null;
  }

  /// Cache result to persistent storage
  Future<void> _cacheResult(
    String featureName,
    FeatureCheckResult result,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$featureName';
      final cache = FeatureFlagCache(
        enabled: result.enabled,
        variant: result.variant,
        cachedAt: DateTime.now(),
      );

      await prefs.setString(cacheKey, jsonEncode(cache.toJson()));
    } catch (e) {
      debugPrint('Error caching result: $e');
    }
  }

  /// Get access token from Supabase
  Future<String?> _getAccessToken() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      return session?.accessToken;
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }
}

/// Feature flag cache entry
class FeatureFlagCache {
  final bool enabled;
  final String? variant;
  final DateTime cachedAt;

  FeatureFlagCache({
    required this.enabled,
    this.variant,
    required this.cachedAt,
  });

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'variant': variant,
    'cached_at': cachedAt.toIso8601String(),
  };

  factory FeatureFlagCache.fromJson(Map<String, dynamic> json) =>
      FeatureFlagCache(
        enabled: json['enabled'] ?? false,
        variant: json['variant'],
        cachedAt: DateTime.parse(json['cached_at']),
      );
}
