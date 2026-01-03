import 'package:flutter/foundation.dart';
import '../services/feature_flag_service.dart';

/// Provider for managing feature flags and A/B testing
class FeatureFlagProvider extends ChangeNotifier {
  final FeatureFlagService _featureFlagService = FeatureFlagService();

  // Cache of feature flag states
  final Map<String, bool> _featureStates = {};
  final Map<String, String?> _featureVariants = {};

  // Loading states
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Check if a feature is enabled
  bool isFeatureEnabled(String featureName) {
    return _featureStates[featureName] ?? false;
  }

  /// Get A/B test variant for a feature
  String? getFeatureVariant(String featureName) {
    return _featureVariants[featureName];
  }

  /// Initialize feature flags
  Future<void> initialize() async {
    _setLoading(true);
    _setError(null);

    try {
      await _featureFlagService.preloadFeatureFlags();
      await _loadAllFeatureStates();
    } catch (e) {
      _setError('Failed to initialize feature flags: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh feature flag states
  Future<void> refresh() async {
    await _featureFlagService.clearCache();
    await initialize();
  }

  /// Load all feature states
  Future<void> _loadAllFeatureStates() async {
    final features = [
      'fraud_detection',
      'predictive_insights',
      'compliance_checking',
      'nlp_invoice_generation',
      'smart_notifications',
      'ml_analytics_engine',
    ];

    for (final feature in features) {
      try {
        final enabled = await _featureFlagService.isFeatureEnabled(feature);
        final variant = await _featureFlagService.getFeatureVariant(feature);

        _featureStates[feature] = enabled;
        _featureVariants[feature] = variant;
      } catch (e) {
        _featureStates[feature] = false;
        _featureVariants[feature] = null;
      }
    }

    notifyListeners();
  }

  /// Track interaction with a feature
  Future<void> trackInteraction(
    String featureName, {
    String interactionType = 'view',
  }) async {
    try {
      await _featureFlagService.trackInteraction(
        featureName,
        interactionType: interactionType,
      );
    } catch (e) {
    }
  }

  /// Track conversion for a feature
  Future<void> trackConversion(
    String featureName, {
    double conversionValue = 1.0,
  }) async {
    try {
      await _featureFlagService.trackConversion(
        featureName,
        conversionValue: conversionValue,
      );
    } catch (e) {
    }
  }

  /// Check and update a specific feature state
  Future<bool> checkFeature(String featureName) async {
    try {
      final enabled = await _featureFlagService.isFeatureEnabled(featureName);
      final variant = await _featureFlagService.getFeatureVariant(featureName);

      _featureStates[featureName] = enabled;
      _featureVariants[featureName] = variant;

      notifyListeners();
      return enabled;
    } catch (e) {
      return false;
    }
  }

  /// Get feature state with automatic tracking
  bool getFeatureWithTracking(
    String featureName, {
    String interactionType = 'view',
  }) {
    final enabled = isFeatureEnabled(featureName);

    if (enabled) {
      // Track interaction asynchronously
      trackInteraction(featureName, interactionType: interactionType);
    }

    return enabled;
  }

  /// Get feature variant with automatic tracking
  String? getVariantWithTracking(
    String featureName, {
    String interactionType = 'view',
  }) {
    final variant = getFeatureVariant(featureName);

    if (variant != null) {
      // Track interaction asynchronously
      trackInteraction(featureName, interactionType: interactionType);
    }

    return variant;
  }

  /// Feature-specific helper methods

  /// Check if fraud detection is enabled
  bool get isFraudDetectionEnabled => getFeatureWithTracking('fraud_detection');

  /// Check if predictive insights are enabled
  bool get isPredictiveInsightsEnabled =>
      getFeatureWithTracking('predictive_insights');

  /// Check if compliance checking is enabled
  bool get isComplianceCheckingEnabled =>
      getFeatureWithTracking('compliance_checking');

  /// Check if NLP invoice generation is enabled
  bool get isNLPInvoiceGenerationEnabled =>
      getFeatureWithTracking('nlp_invoice_generation');

  /// Check if smart notifications are enabled
  bool get isSmartNotificationsEnabled =>
      getFeatureWithTracking('smart_notifications');

  /// Check if ML analytics engine is enabled
  bool get isMLAnalyticsEngineEnabled =>
      getFeatureWithTracking('ml_analytics_engine');

  /// Get smart notifications variant
  String? get smartNotificationsVariant =>
      getVariantWithTracking('smart_notifications');

  /// Get compliance checking variant
  String? get complianceCheckingVariant =>
      getVariantWithTracking('compliance_checking');

  /// Helper methods for A/B testing

  /// Check if user is in control group for a feature
  bool isControlGroup(String featureName) {
    final variant = getFeatureVariant(featureName);
    return variant == null || variant == 'control';
  }

  /// Check if user is in variant A for a feature
  bool isVariantA(String featureName) {
    final variant = getFeatureVariant(featureName);
    return variant == 'variant_a';
  }

  /// Check if user is in variant B for a feature
  bool isVariantB(String featureName) {
    final variant = getFeatureVariant(featureName);
    return variant == 'variant_b';
  }

  /// Get all enabled features
  List<String> get enabledFeatures {
    return _featureStates.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get all features with variants
  Map<String, String> get featuresWithVariants {
    final result = <String, String>{};
    _featureVariants.forEach((key, value) {
      if (value != null && _featureStates[key] == true) {
        result[key] = value;
      }
    });
    return result;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    _featureStates.clear();
    _featureVariants.clear();
    await _featureFlagService.clearCache();
    notifyListeners();
  }

  /// Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Debug information
  Map<String, dynamic> get debugInfo {
    return {
      'feature_states': _featureStates,
      'feature_variants': _featureVariants,
      'is_loading': _isLoading,
      'error': _error,
      'enabled_features_count': enabledFeatures.length,
      'features_with_variants_count': featuresWithVariants.length,
    };
  }
}
