import 'package:json_annotation/json_annotation.dart';

part 'bias_detection_models.g.dart';

/// Types of bias that can be detected
enum BiasType {
  @JsonValue('demographic_parity')
  demographicParity,
  @JsonValue('equalized_odds')
  equalizedOdds,
  @JsonValue('calibration')
  calibration,
  @JsonValue('individual_fairness')
  individualFairness,
  @JsonValue('counterfactual_fairness')
  counterfactualFairness,
  @JsonValue('demographic')
  demographic,
  @JsonValue('behavioral')
  behavioral,
  @JsonValue('historical')
  historical,
  @JsonValue('algorithmic')
  algorithmic,
  @JsonValue('confirmation')
  confirmation,
}

/// Fairness metrics for evaluation
enum FairnessMetric {
  @JsonValue('demographic_parity_difference')
  demographicParityDifference,
  @JsonValue('equalized_odds_difference')
  equalizedOddsDifference,
  @JsonValue('calibration_difference')
  calibrationDifference,
  @JsonValue('individual_fairness_score')
  individualFairnessScore,
  @JsonValue('demographic_parity')
  demographicParity,
  @JsonValue('equalized_odds')
  equalizedOdds,
  @JsonValue('calibration')
  calibration,
  @JsonValue('individual_fairness')
  individualFairness,
}

/// Result of bias detection analysis
@JsonSerializable()
class BiasDetectionResult {
  final String id;
  final String businessId;
  final String modelName;
  final BiasType biasType;
  final double biasScore;
  final bool thresholdExceeded;
  final Map<String, dynamic> metrics;
  final List<String> affectedGroups;
  final DateTime detectedAt;
  final Map<String, dynamic> metadata;

  const BiasDetectionResult({
    required this.id,
    required this.businessId,
    required this.modelName,
    required this.biasType,
    required this.biasScore,
    required this.thresholdExceeded,
    required this.metrics,
    required this.affectedGroups,
    required this.detectedAt,
    this.metadata = const {},
  });

  factory BiasDetectionResult.fromJson(Map<String, dynamic> json) =>
      _$BiasDetectionResultFromJson(json);

  Map<String, dynamic> toJson() => _$BiasDetectionResultToJson(this);
}

/// Fairness monitoring configuration
@JsonSerializable()
class FairnessMonitoring {
  final String id;
  final String businessId;
  final String modelName;
  final List<FairnessMetric> monitoredMetrics;
  final Map<String, double> thresholds;
  final Duration monitoringInterval;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, dynamic> configuration;

  const FairnessMonitoring({
    required this.id,
    required this.businessId,
    required this.modelName,
    required this.monitoredMetrics,
    required this.thresholds,
    required this.monitoringInterval,
    this.isActive = true,
    required this.createdAt,
    this.configuration = const {},
  });

  factory FairnessMonitoring.fromJson(Map<String, dynamic> json) =>
      _$FairnessMonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$FairnessMonitoringToJson(this);
}

/// Fairness violation detected
@JsonSerializable()
class FairnessViolation {
  final String id;
  final String businessId;
  final String modelName;
  final FairnessMetric metric;
  final double actualValue;
  final double threshold;
  final String severity;
  final DateTime detectedAt;
  final Map<String, dynamic> context;

  const FairnessViolation({
    required this.id,
    required this.businessId,
    required this.modelName,
    required this.metric,
    required this.actualValue,
    required this.threshold,
    required this.severity,
    required this.detectedAt,
    this.context = const {},
  });

  factory FairnessViolation.fromJson(Map<String, dynamic> json) =>
      _$FairnessViolationFromJson(json);

  Map<String, dynamic> toJson() => _$FairnessViolationToJson(this);
}

/// Algorithmic audit result
@JsonSerializable()
class AlgorithmicAudit {
  final String id;
  final String businessId;
  final String modelName;
  final String modelVersion;
  final DateTime conductedAt;
  final String conductedBy;
  final Map<String, dynamic> performanceMetrics;
  final Map<String, dynamic> biasMetrics;
  final Map<String, dynamic> fairnessMetrics;
  final List<String> issues;
  final List<String> recommendations;
  final String status;
  final Map<String, dynamic> metadata;

  const AlgorithmicAudit({
    required this.id,
    required this.businessId,
    required this.modelName,
    required this.modelVersion,
    required this.conductedAt,
    required this.conductedBy,
    required this.performanceMetrics,
    required this.biasMetrics,
    required this.fairnessMetrics,
    required this.issues,
    required this.recommendations,
    required this.status,
    this.metadata = const {},
  });

  factory AlgorithmicAudit.fromJson(Map<String, dynamic> json) =>
      _$AlgorithmicAuditFromJson(json);

  Map<String, dynamic> toJson() => _$AlgorithmicAuditToJson(this);
}
