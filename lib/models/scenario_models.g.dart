// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScenarioDefinition _$ScenarioDefinitionFromJson(Map<String, dynamic> json) =>
    ScenarioDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ScenarioTypeEnumMap, json['type']),
      parameters: json['parameters'] as Map<String, dynamic>,
      variables: (json['variables'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, VariableRange.fromJson(e as Map<String, dynamic>)),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      businessId: json['businessId'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ScenarioDefinitionToJson(ScenarioDefinition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$ScenarioTypeEnumMap[instance.type]!,
      'parameters': instance.parameters,
      'variables': instance.variables,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'businessId': instance.businessId,
      'isActive': instance.isActive,
    };

const _$ScenarioTypeEnumMap = {
  ScenarioType.cashFlow: 'cashFlow',
  ScenarioType.customerBehavior: 'customerBehavior',
  ScenarioType.marketCondition: 'marketCondition',
  ScenarioType.comprehensive: 'comprehensive',
  ScenarioType.riskAssessment: 'riskAssessment',
  ScenarioType.growthProjection: 'growthProjection',
  ScenarioType.competitiveAnalysis: 'competitiveAnalysis',
  ScenarioType.supplierPerformance: 'supplierPerformance',
  ScenarioType.competitiveResponse: 'competitiveResponse',
  ScenarioType.pricingChange: 'pricingChange',
  ScenarioType.economicDownturn: 'economicDownturn',
  ScenarioType.marketExpansion: 'marketExpansion',
};

VariableRange _$VariableRangeFromJson(Map<String, dynamic> json) =>
    VariableRange(
      name: json['name'] as String,
      minValue: (json['minValue'] as num).toDouble(),
      maxValue: (json['maxValue'] as num).toDouble(),
      defaultValue: (json['defaultValue'] as num).toDouble(),
      unit: json['unit'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$VariableRangeToJson(VariableRange instance) =>
    <String, dynamic>{
      'name': instance.name,
      'minValue': instance.minValue,
      'maxValue': instance.maxValue,
      'defaultValue': instance.defaultValue,
      'unit': instance.unit,
      'description': instance.description,
    };

CashFlowImpactModel _$CashFlowImpactModelFromJson(Map<String, dynamic> json) =>
    CashFlowImpactModel(
      id: json['id'] as String,
      scenarioId: json['scenarioId'] as String,
      monthlyProjections: (json['monthlyProjections'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      totalImpact: (json['totalImpact'] as num).toDouble(),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      keyFactors:
          (json['keyFactors'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      impactMetrics: json['impactMetrics'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CashFlowImpactModelToJson(
  CashFlowImpactModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'scenarioId': instance.scenarioId,
  'monthlyProjections': instance.monthlyProjections,
  'totalImpact': instance.totalImpact,
  'confidenceScore': instance.confidenceScore,
  'keyFactors': instance.keyFactors,
  'generatedAt': instance.generatedAt.toIso8601String(),
  'impactMetrics': instance.impactMetrics,
};

CustomerBehaviorSimulation _$CustomerBehaviorSimulationFromJson(
  Map<String, dynamic> json,
) => CustomerBehaviorSimulation(
  id: json['id'] as String,
  scenarioId: json['scenarioId'] as String,
  behaviorPatterns: json['behaviorPatterns'] as Map<String, dynamic>,
  results:
      (json['results'] as List<dynamic>)
          .map(
            (e) => CustomerSimulationResult.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  overallImpact: (json['overallImpact'] as num).toDouble(),
  simulatedAt: DateTime.parse(json['simulatedAt'] as String),
  aggregatedMetrics:
      json['aggregatedMetrics'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$CustomerBehaviorSimulationToJson(
  CustomerBehaviorSimulation instance,
) => <String, dynamic>{
  'id': instance.id,
  'scenarioId': instance.scenarioId,
  'behaviorPatterns': instance.behaviorPatterns,
  'results': instance.results,
  'overallImpact': instance.overallImpact,
  'simulatedAt': instance.simulatedAt.toIso8601String(),
  'aggregatedMetrics': instance.aggregatedMetrics,
};

CustomerSimulationResult _$CustomerSimulationResultFromJson(
  Map<String, dynamic> json,
) => CustomerSimulationResult(
  customerId: json['customerId'] as String,
  totalOrderValue: (json['totalOrderValue'] as num).toDouble(),
  totalPayments: (json['totalPayments'] as num).toDouble(),
  paymentReliability: (json['paymentReliability'] as num).toDouble(),
  creditUtilization: (json['creditUtilization'] as num).toDouble(),
  behaviorMetrics: json['behaviorMetrics'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CustomerSimulationResultToJson(
  CustomerSimulationResult instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'totalOrderValue': instance.totalOrderValue,
  'totalPayments': instance.totalPayments,
  'paymentReliability': instance.paymentReliability,
  'creditUtilization': instance.creditUtilization,
  'behaviorMetrics': instance.behaviorMetrics,
};

MarketConditionModel _$MarketConditionModelFromJson(
  Map<String, dynamic> json,
) => MarketConditionModel(
  id: json['id'] as String,
  scenarioId: json['scenarioId'] as String,
  marketFactors: (json['marketFactors'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  marketImpactScore: (json['marketImpactScore'] as num).toDouble(),
  riskFactors:
      (json['riskFactors'] as List<dynamic>).map((e) => e as String).toList(),
  opportunities:
      (json['opportunities'] as List<dynamic>).map((e) => e as String).toList(),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
  scenarioConditions:
      json['scenarioConditions'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$MarketConditionModelToJson(
  MarketConditionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'scenarioId': instance.scenarioId,
  'marketFactors': instance.marketFactors,
  'marketImpactScore': instance.marketImpactScore,
  'riskFactors': instance.riskFactors,
  'opportunities': instance.opportunities,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
  'scenarioConditions': instance.scenarioConditions,
};

ComprehensiveScenarioAnalysis _$ComprehensiveScenarioAnalysisFromJson(
  Map<String, dynamic> json,
) => ComprehensiveScenarioAnalysis(
  id: json['id'] as String,
  scenarioId: json['scenarioId'] as String,
  cashFlowImpact: CashFlowImpactModel.fromJson(
    json['cashFlowImpact'] as Map<String, dynamic>,
  ),
  customerBehavior: CustomerBehaviorSimulation.fromJson(
    json['customerBehavior'] as Map<String, dynamic>,
  ),
  marketConditions: MarketConditionModel.fromJson(
    json['marketConditions'] as Map<String, dynamic>,
  ),
  overallRiskScore: (json['overallRiskScore'] as num).toDouble(),
  overallOpportunityScore: (json['overallOpportunityScore'] as num).toDouble(),
  recommendations:
      (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$ComprehensiveScenarioAnalysisToJson(
  ComprehensiveScenarioAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'scenarioId': instance.scenarioId,
  'cashFlowImpact': instance.cashFlowImpact,
  'customerBehavior': instance.customerBehavior,
  'marketConditions': instance.marketConditions,
  'overallRiskScore': instance.overallRiskScore,
  'overallOpportunityScore': instance.overallOpportunityScore,
  'recommendations': instance.recommendations,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};
