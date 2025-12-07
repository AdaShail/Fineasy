/// Models for feature flags and A/B testing
library;

class FeatureCheckResult {
  final String featureName;
  final bool enabled;
  final String? variant;
  final Map<String, dynamic> metadata;

  FeatureCheckResult({
    required this.featureName,
    required this.enabled,
    this.variant,
    this.metadata = const {},
  });

  factory FeatureCheckResult.fromJson(Map<String, dynamic> json) {
    return FeatureCheckResult(
      featureName: json['feature_name'] ?? '',
      enabled: json['enabled'] ?? false,
      variant: json['variant'],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feature_name': featureName,
      'enabled': enabled,
      'variant': variant,
      'metadata': metadata,
    };
  }
}

class FeatureFlag {
  final String name;
  final String status;
  final String description;
  final double rolloutPercentage;
  final bool abTestEnabled;
  final Map<String, double> abTestVariants;
  final List<String> targetUsers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  FeatureFlag({
    required this.name,
    required this.status,
    required this.description,
    required this.rolloutPercentage,
    required this.abTestEnabled,
    required this.abTestVariants,
    required this.targetUsers,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory FeatureFlag.fromJson(Map<String, dynamic> json) {
    return FeatureFlag(
      name: json['name'] ?? '',
      status: json['status'] ?? 'disabled',
      description: json['description'] ?? '',
      rolloutPercentage: (json['rollout_percentage'] ?? 0.0).toDouble(),
      abTestEnabled: json['ab_test_enabled'] ?? false,
      abTestVariants: Map<String, double>.from(json['ab_test_variants'] ?? {}),
      targetUsers: List<String>.from(json['target_users'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'description': description,
      'rollout_percentage': rolloutPercentage,
      'ab_test_enabled': abTestEnabled,
      'ab_test_variants': abTestVariants,
      'target_users': targetUsers,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class FeatureAnalytics {
  final String featureName;
  final int periodDays;
  final int totalInteractions;
  final int totalConversions;
  final double conversionRate;
  final List<ABTestResult> abTestResults;
  final DateTime generatedAt;

  FeatureAnalytics({
    required this.featureName,
    required this.periodDays,
    required this.totalInteractions,
    required this.totalConversions,
    required this.conversionRate,
    required this.abTestResults,
    required this.generatedAt,
  });

  factory FeatureAnalytics.fromJson(Map<String, dynamic> json) {
    return FeatureAnalytics(
      featureName: json['feature_name'] ?? '',
      periodDays: json['period_days'] ?? 0,
      totalInteractions: json['total_interactions'] ?? 0,
      totalConversions: json['total_conversions'] ?? 0,
      conversionRate: (json['conversion_rate'] ?? 0.0).toDouble(),
      abTestResults:
          (json['ab_test_results'] as List<dynamic>? ?? [])
              .map((item) => ABTestResult.fromJson(item))
              .toList(),
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feature_name': featureName,
      'period_days': periodDays,
      'total_interactions': totalInteractions,
      'total_conversions': totalConversions,
      'conversion_rate': conversionRate,
      'ab_test_results':
          abTestResults.map((result) => result.toJson()).toList(),
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}

class ABTestResult {
  final String userId;
  final String featureName;
  final String variant;
  final DateTime assignedAt;
  final int interactions;
  final int conversions;
  final DateTime? lastInteraction;

  ABTestResult({
    required this.userId,
    required this.featureName,
    required this.variant,
    required this.assignedAt,
    required this.interactions,
    required this.conversions,
    this.lastInteraction,
  });

  factory ABTestResult.fromJson(Map<String, dynamic> json) {
    return ABTestResult(
      userId: json['user_id'] ?? '',
      featureName: json['feature_name'] ?? '',
      variant: json['variant'] ?? '',
      assignedAt: DateTime.parse(json['assigned_at']),
      interactions: json['interactions'] ?? 0,
      conversions: json['conversions'] ?? 0,
      lastInteraction:
          json['last_interaction'] != null
              ? DateTime.parse(json['last_interaction'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'feature_name': featureName,
      'variant': variant,
      'assigned_at': assignedAt.toIso8601String(),
      'interactions': interactions,
      'conversions': conversions,
      'last_interaction': lastInteraction?.toIso8601String(),
    };
  }
}

class PerformanceMetrics {
  final String featureName;
  final int periodHours;
  final Map<String, MetricSummary> metrics;
  final int alertsCount;
  final DateTime generatedAt;

  PerformanceMetrics({
    required this.featureName,
    required this.periodHours,
    required this.metrics,
    required this.alertsCount,
    required this.generatedAt,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    final metricsData = json['metrics'] as Map<String, dynamic>? ?? {};
    final metrics = <String, MetricSummary>{};

    metricsData.forEach((key, value) {
      metrics[key] = MetricSummary.fromJson(value);
    });

    return PerformanceMetrics(
      featureName: json['feature_name'] ?? '',
      periodHours: json['period_hours'] ?? 0,
      metrics: metrics,
      alertsCount: json['alerts_count'] ?? 0,
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final metricsJson = <String, dynamic>{};
    metrics.forEach((key, value) {
      metricsJson[key] = value.toJson();
    });

    return {
      'feature_name': featureName,
      'period_hours': periodHours,
      'metrics': metricsJson,
      'alerts_count': alertsCount,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}

class MetricSummary {
  final int count;
  final double average;
  final double median;
  final double min;
  final double max;
  final double? latest;

  MetricSummary({
    required this.count,
    required this.average,
    required this.median,
    required this.min,
    required this.max,
    this.latest,
  });

  factory MetricSummary.fromJson(Map<String, dynamic> json) {
    return MetricSummary(
      count: json['count'] ?? 0,
      average: (json['average'] ?? 0.0).toDouble(),
      median: (json['median'] ?? 0.0).toDouble(),
      min: (json['min'] ?? 0.0).toDouble(),
      max: (json['max'] ?? 0.0).toDouble(),
      latest: json['latest']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'average': average,
      'median': median,
      'min': min,
      'max': max,
      'latest': latest,
    };
  }
}

enum FeatureFlagStatus { disabled, enabled, testing, rollout }

enum ABTestVariant { control, variantA, variantB }

extension FeatureFlagStatusExtension on FeatureFlagStatus {
  String get value {
    switch (this) {
      case FeatureFlagStatus.disabled:
        return 'disabled';
      case FeatureFlagStatus.enabled:
        return 'enabled';
      case FeatureFlagStatus.testing:
        return 'testing';
      case FeatureFlagStatus.rollout:
        return 'rollout';
    }
  }

  static FeatureFlagStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'enabled':
        return FeatureFlagStatus.enabled;
      case 'testing':
        return FeatureFlagStatus.testing;
      case 'rollout':
        return FeatureFlagStatus.rollout;
      default:
        return FeatureFlagStatus.disabled;
    }
  }
}

extension ABTestVariantExtension on ABTestVariant {
  String get value {
    switch (this) {
      case ABTestVariant.control:
        return 'control';
      case ABTestVariant.variantA:
        return 'variant_a';
      case ABTestVariant.variantB:
        return 'variant_b';
    }
  }

  static ABTestVariant fromString(String value) {
    switch (value.toLowerCase()) {
      case 'variant_a':
        return ABTestVariant.variantA;
      case 'variant_b':
        return ABTestVariant.variantB;
      default:
        return ABTestVariant.control;
    }
  }
}
