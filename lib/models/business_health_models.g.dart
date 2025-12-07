// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_health_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KPIMetric _$KPIMetricFromJson(Map<String, dynamic> json) => KPIMetric(
  id: json['id'] as String,
  name: json['name'] as String,
  category: $enumDecode(_$KPICategoryEnumMap, json['category']),
  value: (json['value'] as num).toDouble(),
  unit: json['unit'] as String,
  target: (json['target'] as num).toDouble(),
  threshold: KPIThreshold.fromJson(json['threshold'] as Map<String, dynamic>),
  trend: $enumDecode(_$KPITrendEnumMap, json['trend']),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$KPIMetricToJson(KPIMetric instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': _$KPICategoryEnumMap[instance.category]!,
  'value': instance.value,
  'unit': instance.unit,
  'target': instance.target,
  'threshold': instance.threshold,
  'trend': _$KPITrendEnumMap[instance.trend]!,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'metadata': instance.metadata,
};

const _$KPICategoryEnumMap = {
  KPICategory.financial: 'financial',
  KPICategory.operational: 'operational',
  KPICategory.customer: 'customer',
  KPICategory.market: 'market',
  KPICategory.compliance: 'compliance',
  KPICategory.growth: 'growth',
};

const _$KPITrendEnumMap = {
  KPITrend.improving: 'improving',
  KPITrend.stable: 'stable',
  KPITrend.declining: 'declining',
};

KPIThreshold _$KPIThresholdFromJson(Map<String, dynamic> json) => KPIThreshold(
  critical: (json['critical'] as num).toDouble(),
  warning: (json['warning'] as num).toDouble(),
  good: (json['good'] as num).toDouble(),
);

Map<String, dynamic> _$KPIThresholdToJson(KPIThreshold instance) =>
    <String, dynamic>{
      'critical': instance.critical,
      'warning': instance.warning,
      'good': instance.good,
    };

BusinessHealthAlert _$BusinessHealthAlertFromJson(Map<String, dynamic> json) =>
    BusinessHealthAlert(
      id: json['id'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      level: $enumDecode(_$AlertLevelEnumMap, json['level']),
      title: json['title'] as String,
      description: json['description'] as String,
      kpiId: json['kpiId'] as String,
      value: (json['value'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedAt:
          json['resolvedAt'] == null
              ? null
              : DateTime.parse(json['resolvedAt'] as String),
      resolution: json['resolution'] as String?,
    );

Map<String, dynamic> _$BusinessHealthAlertToJson(
  BusinessHealthAlert instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$AlertTypeEnumMap[instance.type]!,
  'level': _$AlertLevelEnumMap[instance.level]!,
  'title': instance.title,
  'description': instance.description,
  'kpiId': instance.kpiId,
  'value': instance.value,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
  'isResolved': instance.isResolved,
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'resolution': instance.resolution,
};

const _$AlertTypeEnumMap = {
  AlertType.threshold: 'threshold',
  AlertType.anomaly: 'anomaly',
  AlertType.competitive: 'competitive',
  AlertType.compliance: 'compliance',
  AlertType.operational: 'operational',
};

const _$AlertLevelEnumMap = {
  AlertLevel.info: 'info',
  AlertLevel.warning: 'warning',
  AlertLevel.critical: 'critical',
  AlertLevel.none: 'none',
};

AnomalyDetection _$AnomalyDetectionFromJson(Map<String, dynamic> json) =>
    AnomalyDetection(
      businessId: json['businessId'] as String,
      kpiId: json['kpiId'] as String,
      value: (json['value'] as num).toDouble(),
      expectedValue: (json['expectedValue'] as num).toDouble(),
      deviation: (json['deviation'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      type: $enumDecode(_$AnomalyTypeEnumMap, json['type']),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AnomalyDetectionToJson(AnomalyDetection instance) =>
    <String, dynamic>{
      'businessId': instance.businessId,
      'kpiId': instance.kpiId,
      'value': instance.value,
      'expectedValue': instance.expectedValue,
      'deviation': instance.deviation,
      'confidence': instance.confidence,
      'type': _$AnomalyTypeEnumMap[instance.type]!,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$AnomalyTypeEnumMap = {
  AnomalyType.spike: 'spike',
  AnomalyType.drop: 'drop',
  AnomalyType.trend: 'trend',
  AnomalyType.seasonal: 'seasonal',
  AnomalyType.pattern: 'pattern',
};

CompetitiveThreat _$CompetitiveThreatFromJson(Map<String, dynamic> json) =>
    CompetitiveThreat(
      id: json['id'] as String,
      competitorName: json['competitorName'] as String,
      type: $enumDecode(_$ThreatTypeEnumMap, json['type']),
      level: $enumDecode(_$ThreatLevelEnumMap, json['level']),
      description: json['description'] as String,
      impactAnalysis: json['impactAnalysis'] as Map<String, dynamic>,
      recommendedActions:
          (json['recommendedActions'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CompetitiveThreatToJson(CompetitiveThreat instance) =>
    <String, dynamic>{
      'id': instance.id,
      'competitorName': instance.competitorName,
      'type': _$ThreatTypeEnumMap[instance.type]!,
      'level': _$ThreatLevelEnumMap[instance.level]!,
      'description': instance.description,
      'impactAnalysis': instance.impactAnalysis,
      'recommendedActions': instance.recommendedActions,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$ThreatTypeEnumMap = {
  ThreatType.pricing: 'pricing',
  ThreatType.product: 'product',
  ThreatType.market: 'market',
  ThreatType.customer: 'customer',
  ThreatType.technology: 'technology',
};

const _$ThreatLevelEnumMap = {
  ThreatLevel.low: 'low',
  ThreatLevel.medium: 'medium',
  ThreatLevel.high: 'high',
  ThreatLevel.critical: 'critical',
};

ComplianceStatus _$ComplianceStatusFromJson(Map<String, dynamic> json) =>
    ComplianceStatus(
      id: json['id'] as String,
      regulationType: json['regulationType'] as String,
      level: $enumDecode(_$ComplianceLevelEnumMap, json['level']),
      description: json['description'] as String,
      issues:
          (json['issues'] as List<dynamic>)
              .map((e) => ComplianceIssue.fromJson(e as Map<String, dynamic>))
              .toList(),
      requiredActions:
          (json['requiredActions'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      lastChecked: DateTime.parse(json['lastChecked'] as String),
      nextReview:
          json['nextReview'] == null
              ? null
              : DateTime.parse(json['nextReview'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ComplianceStatusToJson(ComplianceStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'regulationType': instance.regulationType,
      'level': _$ComplianceLevelEnumMap[instance.level]!,
      'description': instance.description,
      'issues': instance.issues,
      'requiredActions': instance.requiredActions,
      'lastChecked': instance.lastChecked.toIso8601String(),
      'nextReview': instance.nextReview?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$ComplianceLevelEnumMap = {
  ComplianceLevel.compliant: 'compliant',
  ComplianceLevel.atRisk: 'atRisk',
  ComplianceLevel.nonCompliant: 'nonCompliant',
  ComplianceLevel.unknown: 'unknown',
};

ComplianceIssue _$ComplianceIssueFromJson(Map<String, dynamic> json) =>
    ComplianceIssue(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: $enumDecode(_$IssueSeverityEnumMap, json['severity']),
      deadline: DateTime.parse(json['deadline'] as String),
      correctiveAction: json['correctiveAction'] as String?,
      isResolved: json['isResolved'] as bool? ?? false,
    );

Map<String, dynamic> _$ComplianceIssueToJson(ComplianceIssue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'severity': _$IssueSeverityEnumMap[instance.severity]!,
      'deadline': instance.deadline.toIso8601String(),
      'correctiveAction': instance.correctiveAction,
      'isResolved': instance.isResolved,
    };

const _$IssueSeverityEnumMap = {
  IssueSeverity.low: 'low',
  IssueSeverity.medium: 'medium',
  IssueSeverity.high: 'high',
  IssueSeverity.critical: 'critical',
};

BenchmarkResult _$BenchmarkResultFromJson(Map<String, dynamic> json) =>
    BenchmarkResult(
      kpiId: json['kpiId'] as String,
      industryAverage: (json['industryAverage'] as num).toDouble(),
      userValue: (json['userValue'] as num).toDouble(),
      percentile: (json['percentile'] as num).toDouble(),
      performance: $enumDecode(_$PerformanceRatingEnumMap, json['performance']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$BenchmarkResultToJson(BenchmarkResult instance) =>
    <String, dynamic>{
      'kpiId': instance.kpiId,
      'industryAverage': instance.industryAverage,
      'userValue': instance.userValue,
      'percentile': instance.percentile,
      'performance': _$PerformanceRatingEnumMap[instance.performance]!,
      'metadata': instance.metadata,
    };

const _$PerformanceRatingEnumMap = {
  PerformanceRating.excellent: 'excellent',
  PerformanceRating.good: 'good',
  PerformanceRating.average: 'average',
  PerformanceRating.poor: 'poor',
};

BusinessHealthSummary _$BusinessHealthSummaryFromJson(
  Map<String, dynamic> json,
) => BusinessHealthSummary(
  businessId: json['businessId'] as String,
  overallScore: (json['overallScore'] as num).toDouble(),
  status: $enumDecode(_$HealthStatusEnumMap, json['status']),
  criticalKPIs:
      (json['criticalKPIs'] as List<dynamic>)
          .map((e) => KPIMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
  activeAlerts:
      (json['activeAlerts'] as List<dynamic>)
          .map((e) => BusinessHealthAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
  recommendations:
      (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  generatedAt: DateTime.parse(json['generatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$BusinessHealthSummaryToJson(
  BusinessHealthSummary instance,
) => <String, dynamic>{
  'businessId': instance.businessId,
  'overallScore': instance.overallScore,
  'status': _$HealthStatusEnumMap[instance.status]!,
  'criticalKPIs': instance.criticalKPIs,
  'activeAlerts': instance.activeAlerts,
  'recommendations': instance.recommendations,
  'generatedAt': instance.generatedAt.toIso8601String(),
  'metadata': instance.metadata,
};

const _$HealthStatusEnumMap = {
  HealthStatus.excellent: 'excellent',
  HealthStatus.good: 'good',
  HealthStatus.fair: 'fair',
  HealthStatus.poor: 'poor',
  HealthStatus.critical: 'critical',
};
