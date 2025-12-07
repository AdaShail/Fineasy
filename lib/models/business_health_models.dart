import 'package:json_annotation/json_annotation.dart';

part 'business_health_models.g.dart';

/// Represents a Key Performance Indicator (KPI) metric
@JsonSerializable()
class KPIMetric {
  final String id;
  final String name;
  final KPICategory category;
  final double value;
  final String unit;
  final double target;
  final KPIThreshold threshold;
  final KPITrend trend;
  final DateTime lastUpdated;
  final Map<String, dynamic>? metadata;

  const KPIMetric({
    required this.id,
    required this.name,
    required this.category,
    required this.value,
    required this.unit,
    required this.target,
    required this.threshold,
    required this.trend,
    required this.lastUpdated,
    this.metadata,
  });

  factory KPIMetric.fromJson(Map<String, dynamic> json) =>
      _$KPIMetricFromJson(json);
  Map<String, dynamic> toJson() => _$KPIMetricToJson(this);

  /// Calculate performance percentage against target
  double get performancePercentage => (value / target) * 100;

  /// Check if KPI is meeting target
  bool get isMeetingTarget => value >= target;

  /// Get status based on thresholds
  KPIStatus get status {
    if (value >= threshold.good) return KPIStatus.good;
    if (value >= threshold.warning) return KPIStatus.warning;
    return KPIStatus.critical;
  }
}

/// KPI threshold values for different alert levels
@JsonSerializable()
class KPIThreshold {
  final double critical;
  final double warning;
  final double good;

  const KPIThreshold({
    required this.critical,
    required this.warning,
    required this.good,
  });

  factory KPIThreshold.fromJson(Map<String, dynamic> json) =>
      _$KPIThresholdFromJson(json);
  Map<String, dynamic> toJson() => _$KPIThresholdToJson(this);
}

/// Business health alert for anomalies and threshold violations
@JsonSerializable()
class BusinessHealthAlert {
  final String id;
  final AlertType type;
  final AlertLevel level;
  final String title;
  final String description;
  final String kpiId;
  final double value;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolution;

  const BusinessHealthAlert({
    required this.id,
    required this.type,
    required this.level,
    required this.title,
    required this.description,
    required this.kpiId,
    required this.value,
    required this.metadata,
    required this.createdAt,
    this.isResolved = false,
    this.resolvedAt,
    this.resolution,
  });

  factory BusinessHealthAlert.fromJson(Map<String, dynamic> json) =>
      _$BusinessHealthAlertFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessHealthAlertToJson(this);

  /// Create a resolved copy of this alert
  BusinessHealthAlert resolve(String resolution) {
    return BusinessHealthAlert(
      id: id,
      type: type,
      level: level,
      title: title,
      description: description,
      kpiId: kpiId,
      value: value,
      metadata: metadata,
      createdAt: createdAt,
      isResolved: true,
      resolvedAt: DateTime.now(),
      resolution: resolution,
    );
  }
}

/// Anomaly detection result
@JsonSerializable()
class AnomalyDetection {
  final String businessId;
  final String kpiId;
  final double value;
  final double expectedValue;
  final double deviation;
  final double confidence;
  final AnomalyType type;
  final DateTime detectedAt;
  final Map<String, dynamic> metadata;

  const AnomalyDetection({
    required this.businessId,
    required this.kpiId,
    required this.value,
    required this.expectedValue,
    required this.deviation,
    required this.confidence,
    required this.type,
    required this.detectedAt,
    required this.metadata,
  });

  factory AnomalyDetection.fromJson(Map<String, dynamic> json) =>
      _$AnomalyDetectionFromJson(json);
  Map<String, dynamic> toJson() => _$AnomalyDetectionToJson(this);

  /// Check if anomaly is significant
  bool get isSignificant => confidence > 0.8;
}

/// Competitive threat detection result
@JsonSerializable()
class CompetitiveThreat {
  final String id;
  final String competitorName;
  final ThreatType type;
  final ThreatLevel level;
  final String description;
  final Map<String, dynamic> impactAnalysis;
  final List<String> recommendedActions;
  final DateTime detectedAt;
  final Map<String, dynamic> metadata;

  const CompetitiveThreat({
    required this.id,
    required this.competitorName,
    required this.type,
    required this.level,
    required this.description,
    required this.impactAnalysis,
    required this.recommendedActions,
    required this.detectedAt,
    required this.metadata,
  });

  factory CompetitiveThreat.fromJson(Map<String, dynamic> json) =>
      _$CompetitiveThreatFromJson(json);
  Map<String, dynamic> toJson() => _$CompetitiveThreatToJson(this);
}

/// Compliance monitoring result
@JsonSerializable()
class ComplianceStatus {
  final String id;
  final String regulationType;
  final ComplianceLevel level;
  final String description;
  final List<ComplianceIssue> issues;
  final List<String> requiredActions;
  final DateTime lastChecked;
  final DateTime? nextReview;
  final Map<String, dynamic> metadata;

  const ComplianceStatus({
    required this.id,
    required this.regulationType,
    required this.level,
    required this.description,
    required this.issues,
    required this.requiredActions,
    required this.lastChecked,
    this.nextReview,
    required this.metadata,
  });

  factory ComplianceStatus.fromJson(Map<String, dynamic> json) =>
      _$ComplianceStatusFromJson(json);
  Map<String, dynamic> toJson() => _$ComplianceStatusToJson(this);

  /// Check if compliance is at risk
  bool get isAtRisk =>
      level == ComplianceLevel.nonCompliant || level == ComplianceLevel.atRisk;
}

/// Individual compliance issue
@JsonSerializable()
class ComplianceIssue {
  final String id;
  final String title;
  final String description;
  final IssueSeverity severity;
  final DateTime deadline;
  final String? correctiveAction;
  final bool isResolved;

  const ComplianceIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.deadline,
    this.correctiveAction,
    this.isResolved = false,
  });

  factory ComplianceIssue.fromJson(Map<String, dynamic> json) =>
      _$ComplianceIssueFromJson(json);
  Map<String, dynamic> toJson() => _$ComplianceIssueToJson(this);

  /// Check if issue is overdue
  bool get isOverdue => DateTime.now().isAfter(deadline) && !isResolved;
}

/// Benchmark comparison result
@JsonSerializable()
class BenchmarkResult {
  final String kpiId;
  final double industryAverage;
  final double userValue;
  final double percentile;
  final PerformanceRating performance;
  final Map<String, dynamic>? metadata;

  const BenchmarkResult({
    required this.kpiId,
    required this.industryAverage,
    required this.userValue,
    required this.percentile,
    required this.performance,
    this.metadata,
  });

  factory BenchmarkResult.fromJson(Map<String, dynamic> json) =>
      _$BenchmarkResultFromJson(json);
  Map<String, dynamic> toJson() => _$BenchmarkResultToJson(this);

  /// Calculate performance gap
  double get performanceGap => userValue - industryAverage;

  /// Check if performing above industry average
  bool get isAboveAverage => userValue > industryAverage;
}

/// Business health summary
@JsonSerializable()
class BusinessHealthSummary {
  final String businessId;
  final double overallScore;
  final HealthStatus status;
  final List<KPIMetric> criticalKPIs;
  final List<BusinessHealthAlert> activeAlerts;
  final List<String> recommendations;
  final DateTime generatedAt;
  final Map<String, dynamic> metadata;

  const BusinessHealthSummary({
    required this.businessId,
    required this.overallScore,
    required this.status,
    required this.criticalKPIs,
    required this.activeAlerts,
    required this.recommendations,
    required this.generatedAt,
    required this.metadata,
  });

  factory BusinessHealthSummary.fromJson(Map<String, dynamic> json) =>
      _$BusinessHealthSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessHealthSummaryToJson(this);

  /// Get number of critical alerts
  int get criticalAlertCount =>
      activeAlerts.where((a) => a.level == AlertLevel.critical).length;

  /// Check if business health is good
  bool get isHealthy =>
      status == HealthStatus.excellent || status == HealthStatus.good;
}

// Enums

enum KPICategory {
  financial,
  operational,
  customer,
  market,
  compliance,
  growth,
}

enum KPITrend { improving, stable, declining }

enum KPIStatus { good, warning, critical }

enum AlertType { threshold, anomaly, competitive, compliance, operational }

enum AlertLevel { info, warning, critical, none }

enum AnomalyType { spike, drop, trend, seasonal, pattern }

enum ThreatType { pricing, product, market, customer, technology }

enum ThreatLevel { low, medium, high, critical }

enum ComplianceLevel { compliant, atRisk, nonCompliant, unknown }

enum IssueSeverity { low, medium, high, critical }

enum PerformanceRating { excellent, good, average, poor }

enum HealthStatus { excellent, good, fair, poor, critical }
