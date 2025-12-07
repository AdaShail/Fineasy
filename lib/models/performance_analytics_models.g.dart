// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DecisionOutcome _$DecisionOutcomeFromJson(Map<String, dynamic> json) =>
    DecisionOutcome(
      id: json['id'] as String,
      decisionId: json['decisionId'] as String,
      businessId: json['businessId'] as String,
      type: $enumDecode(_$DecisionOutcomeTypeEnumMap, json['type']),
      predictedValue: (json['predictedValue'] as num).toDouble(),
      actualValue: (json['actualValue'] as num).toDouble(),
      accuracyScore: (json['accuracyScore'] as num).toDouble(),
      metrics: json['metrics'] as Map<String, dynamic>,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DecisionOutcomeToJson(DecisionOutcome instance) =>
    <String, dynamic>{
      'id': instance.id,
      'decisionId': instance.decisionId,
      'businessId': instance.businessId,
      'type': _$DecisionOutcomeTypeEnumMap[instance.type]!,
      'predictedValue': instance.predictedValue,
      'actualValue': instance.actualValue,
      'accuracyScore': instance.accuracyScore,
      'metrics': instance.metrics,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'notes': instance.notes,
    };

const _$DecisionOutcomeTypeEnumMap = {
  DecisionOutcomeType.cashFlowPrediction: 'cashFlowPrediction',
  DecisionOutcomeType.customerBehavior: 'customerBehavior',
  DecisionOutcomeType.paymentRecovery: 'paymentRecovery',
  DecisionOutcomeType.expenseOptimization: 'expenseOptimization',
  DecisionOutcomeType.riskAssessment: 'riskAssessment',
  DecisionOutcomeType.opportunityIdentification: 'opportunityIdentification',
  DecisionOutcomeType.supplierPerformance: 'supplierPerformance',
  DecisionOutcomeType.complianceAction: 'complianceAction',
};

AIPerformanceMetrics _$AIPerformanceMetricsFromJson(
  Map<String, dynamic> json,
) => AIPerformanceMetrics(
  businessId: json['businessId'] as String,
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  totalDecisions: (json['totalDecisions'] as num).toInt(),
  successfulDecisions: (json['successfulDecisions'] as num).toInt(),
  overallAccuracy: (json['overallAccuracy'] as num).toDouble(),
  averageConfidence: (json['averageConfidence'] as num).toDouble(),
  accuracyByType: (json['accuracyByType'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      $enumDecode(_$DecisionOutcomeTypeEnumMap, k),
      (e as num).toDouble(),
    ),
  ),
  keyMetrics: (json['keyMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  calculatedAt: DateTime.parse(json['calculatedAt'] as String),
);

Map<String, dynamic> _$AIPerformanceMetricsToJson(
  AIPerformanceMetrics instance,
) => <String, dynamic>{
  'businessId': instance.businessId,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'totalDecisions': instance.totalDecisions,
  'successfulDecisions': instance.successfulDecisions,
  'overallAccuracy': instance.overallAccuracy,
  'averageConfidence': instance.averageConfidence,
  'accuracyByType': instance.accuracyByType.map(
    (k, e) => MapEntry(_$DecisionOutcomeTypeEnumMap[k]!, e),
  ),
  'keyMetrics': instance.keyMetrics,
  'calculatedAt': instance.calculatedAt.toIso8601String(),
};

AutomationROI _$AutomationROIFromJson(Map<String, dynamic> json) =>
    AutomationROI(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      actionId: json['actionId'] as String,
      category: $enumDecode(_$ROICategoryEnumMap, json['category']),
      costSavings: (json['costSavings'] as num).toDouble(),
      timeSavings: (json['timeSavings'] as num).toDouble(),
      revenueImpact: (json['revenueImpact'] as num).toDouble(),
      implementationCost: (json['implementationCost'] as num).toDouble(),
      netROI: (json['netROI'] as num).toDouble(),
      roiPercentage: (json['roiPercentage'] as num).toDouble(),
      breakdown: json['breakdown'] as Map<String, dynamic>,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );

Map<String, dynamic> _$AutomationROIToJson(AutomationROI instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'actionId': instance.actionId,
      'category': _$ROICategoryEnumMap[instance.category]!,
      'costSavings': instance.costSavings,
      'timeSavings': instance.timeSavings,
      'revenueImpact': instance.revenueImpact,
      'implementationCost': instance.implementationCost,
      'netROI': instance.netROI,
      'roiPercentage': instance.roiPercentage,
      'breakdown': instance.breakdown,
      'calculatedAt': instance.calculatedAt.toIso8601String(),
    };

const _$ROICategoryEnumMap = {
  ROICategory.paymentReminders: 'paymentReminders',
  ROICategory.expenseControl: 'expenseControl',
  ROICategory.customerManagement: 'customerManagement',
  ROICategory.supplierNegotiation: 'supplierNegotiation',
  ROICategory.complianceAutomation: 'complianceAutomation',
  ROICategory.riskMitigation: 'riskMitigation',
  ROICategory.processOptimization: 'processOptimization',
};

BusinessImpactMetrics _$BusinessImpactMetricsFromJson(
  Map<String, dynamic> json,
) => BusinessImpactMetrics(
  businessId: json['businessId'] as String,
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  cashFlowImprovement: (json['cashFlowImprovement'] as num).toDouble(),
  customerSatisfactionDelta:
      (json['customerSatisfactionDelta'] as num).toDouble(),
  operationalEfficiencyGain:
      (json['operationalEfficiencyGain'] as num).toDouble(),
  complianceScoreImprovement:
      (json['complianceScoreImprovement'] as num).toDouble(),
  automatedTasksCount: (json['automatedTasksCount'] as num).toInt(),
  totalTimeSaved: (json['totalTimeSaved'] as num).toDouble(),
  totalCostSavings: (json['totalCostSavings'] as num).toDouble(),
  categoryImpacts: (json['categoryImpacts'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  calculatedAt: DateTime.parse(json['calculatedAt'] as String),
);

Map<String, dynamic> _$BusinessImpactMetricsToJson(
  BusinessImpactMetrics instance,
) => <String, dynamic>{
  'businessId': instance.businessId,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'cashFlowImprovement': instance.cashFlowImprovement,
  'customerSatisfactionDelta': instance.customerSatisfactionDelta,
  'operationalEfficiencyGain': instance.operationalEfficiencyGain,
  'complianceScoreImprovement': instance.complianceScoreImprovement,
  'automatedTasksCount': instance.automatedTasksCount,
  'totalTimeSaved': instance.totalTimeSaved,
  'totalCostSavings': instance.totalCostSavings,
  'categoryImpacts': instance.categoryImpacts,
  'calculatedAt': instance.calculatedAt.toIso8601String(),
};

PerformanceDashboardData _$PerformanceDashboardDataFromJson(
  Map<String, dynamic> json,
) => PerformanceDashboardData(
  businessId: json['businessId'] as String,
  aiMetrics: AIPerformanceMetrics.fromJson(
    json['aiMetrics'] as Map<String, dynamic>,
  ),
  businessImpact: BusinessImpactMetrics.fromJson(
    json['businessImpact'] as Map<String, dynamic>,
  ),
  topROIActions:
      (json['topROIActions'] as List<dynamic>)
          .map((e) => AutomationROI.fromJson(e as Map<String, dynamic>))
          .toList(),
  recentOutcomes:
      (json['recentOutcomes'] as List<dynamic>)
          .map((e) => DecisionOutcome.fromJson(e as Map<String, dynamic>))
          .toList(),
  trends: json['trends'] as Map<String, dynamic>,
  alerts:
      (json['alerts'] as List<dynamic>)
          .map((e) => PerformanceAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
  generatedAt: DateTime.parse(json['generatedAt'] as String),
);

Map<String, dynamic> _$PerformanceDashboardDataToJson(
  PerformanceDashboardData instance,
) => <String, dynamic>{
  'businessId': instance.businessId,
  'aiMetrics': instance.aiMetrics,
  'businessImpact': instance.businessImpact,
  'topROIActions': instance.topROIActions,
  'recentOutcomes': instance.recentOutcomes,
  'trends': instance.trends,
  'alerts': instance.alerts,
  'generatedAt': instance.generatedAt.toIso8601String(),
};

PerformanceAlert _$PerformanceAlertFromJson(Map<String, dynamic> json) =>
    PerformanceAlert(
      id: json['id'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      title: json['title'] as String,
      description: json['description'] as String,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isResolved: json['isResolved'] as bool,
    );

Map<String, dynamic> _$PerformanceAlertToJson(PerformanceAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'title': instance.title,
      'description': instance.description,
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
      'isResolved': instance.isResolved,
    };

const _$AlertTypeEnumMap = {
  AlertType.accuracyDrop: 'accuracyDrop',
  AlertType.performanceDegradation: 'performanceDegradation',
  AlertType.roiDecline: 'roiDecline',
  AlertType.systemError: 'systemError',
  AlertType.dataQualityIssue: 'dataQualityIssue',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};

PerformanceReportConfig _$PerformanceReportConfigFromJson(
  Map<String, dynamic> json,
) => PerformanceReportConfig(
  businessId: json['businessId'] as String,
  type: $enumDecode(_$ReportTypeEnumMap, json['type']),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  includedMetrics:
      (json['includedMetrics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  filters: json['filters'] as Map<String, dynamic>,
  format: $enumDecode(_$ReportFormatEnumMap, json['format']),
);

Map<String, dynamic> _$PerformanceReportConfigToJson(
  PerformanceReportConfig instance,
) => <String, dynamic>{
  'businessId': instance.businessId,
  'type': _$ReportTypeEnumMap[instance.type]!,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'includedMetrics': instance.includedMetrics,
  'filters': instance.filters,
  'format': _$ReportFormatEnumMap[instance.format]!,
};

const _$ReportTypeEnumMap = {
  ReportType.weekly: 'weekly',
  ReportType.monthly: 'monthly',
  ReportType.quarterly: 'quarterly',
  ReportType.annual: 'annual',
  ReportType.custom: 'custom',
};

const _$ReportFormatEnumMap = {
  ReportFormat.json: 'json',
  ReportFormat.pdf: 'pdf',
  ReportFormat.excel: 'excel',
  ReportFormat.dashboard: 'dashboard',
};
