// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bias_detection_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BiasDetectionResult _$BiasDetectionResultFromJson(Map<String, dynamic> json) =>
    BiasDetectionResult(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      modelName: json['modelName'] as String,
      biasType: $enumDecode(_$BiasTypeEnumMap, json['biasType']),
      biasScore: (json['biasScore'] as num).toDouble(),
      thresholdExceeded: json['thresholdExceeded'] as bool,
      metrics: json['metrics'] as Map<String, dynamic>,
      affectedGroups:
          (json['affectedGroups'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$BiasDetectionResultToJson(
  BiasDetectionResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'modelName': instance.modelName,
  'biasType': _$BiasTypeEnumMap[instance.biasType]!,
  'biasScore': instance.biasScore,
  'thresholdExceeded': instance.thresholdExceeded,
  'metrics': instance.metrics,
  'affectedGroups': instance.affectedGroups,
  'detectedAt': instance.detectedAt.toIso8601String(),
  'metadata': instance.metadata,
};

const _$BiasTypeEnumMap = {
  BiasType.demographicParity: 'demographic_parity',
  BiasType.equalizedOdds: 'equalized_odds',
  BiasType.calibration: 'calibration',
  BiasType.individualFairness: 'individual_fairness',
  BiasType.counterfactualFairness: 'counterfactual_fairness',
  BiasType.demographic: 'demographic',
  BiasType.behavioral: 'behavioral',
  BiasType.historical: 'historical',
  BiasType.algorithmic: 'algorithmic',
  BiasType.confirmation: 'confirmation',
};

FairnessMonitoring _$FairnessMonitoringFromJson(Map<String, dynamic> json) =>
    FairnessMonitoring(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      modelName: json['modelName'] as String,
      monitoredMetrics:
          (json['monitoredMetrics'] as List<dynamic>)
              .map((e) => $enumDecode(_$FairnessMetricEnumMap, e))
              .toList(),
      thresholds: (json['thresholds'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      monitoringInterval: Duration(
        microseconds: (json['monitoringInterval'] as num).toInt(),
      ),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      configuration: json['configuration'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$FairnessMonitoringToJson(FairnessMonitoring instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'modelName': instance.modelName,
      'monitoredMetrics':
          instance.monitoredMetrics
              .map((e) => _$FairnessMetricEnumMap[e]!)
              .toList(),
      'thresholds': instance.thresholds,
      'monitoringInterval': instance.monitoringInterval.inMicroseconds,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'configuration': instance.configuration,
    };

const _$FairnessMetricEnumMap = {
  FairnessMetric.demographicParityDifference: 'demographic_parity_difference',
  FairnessMetric.equalizedOddsDifference: 'equalized_odds_difference',
  FairnessMetric.calibrationDifference: 'calibration_difference',
  FairnessMetric.individualFairnessScore: 'individual_fairness_score',
  FairnessMetric.demographicParity: 'demographic_parity',
  FairnessMetric.equalizedOdds: 'equalized_odds',
  FairnessMetric.calibration: 'calibration',
  FairnessMetric.individualFairness: 'individual_fairness',
};

FairnessViolation _$FairnessViolationFromJson(Map<String, dynamic> json) =>
    FairnessViolation(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      modelName: json['modelName'] as String,
      metric: $enumDecode(_$FairnessMetricEnumMap, json['metric']),
      actualValue: (json['actualValue'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      severity: json['severity'] as String,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      context: json['context'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$FairnessViolationToJson(FairnessViolation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'modelName': instance.modelName,
      'metric': _$FairnessMetricEnumMap[instance.metric]!,
      'actualValue': instance.actualValue,
      'threshold': instance.threshold,
      'severity': instance.severity,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'context': instance.context,
    };

AlgorithmicAudit _$AlgorithmicAuditFromJson(Map<String, dynamic> json) =>
    AlgorithmicAudit(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      modelName: json['modelName'] as String,
      modelVersion: json['modelVersion'] as String,
      conductedAt: DateTime.parse(json['conductedAt'] as String),
      conductedBy: json['conductedBy'] as String,
      performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
      biasMetrics: json['biasMetrics'] as Map<String, dynamic>,
      fairnessMetrics: json['fairnessMetrics'] as Map<String, dynamic>,
      issues:
          (json['issues'] as List<dynamic>).map((e) => e as String).toList(),
      recommendations:
          (json['recommendations'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      status: json['status'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AlgorithmicAuditToJson(AlgorithmicAudit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'modelName': instance.modelName,
      'modelVersion': instance.modelVersion,
      'conductedAt': instance.conductedAt.toIso8601String(),
      'conductedBy': instance.conductedBy,
      'performanceMetrics': instance.performanceMetrics,
      'biasMetrics': instance.biasMetrics,
      'fairnessMetrics': instance.fairnessMetrics,
      'issues': instance.issues,
      'recommendations': instance.recommendations,
      'status': instance.status,
      'metadata': instance.metadata,
    };
