import 'package:json_annotation/json_annotation.dart';

part 'scenario_models.g.dart';

enum ScenarioType {
  cashFlow,
  customerBehavior,
  marketCondition,
  comprehensive,
  riskAssessment,
  growthProjection,
  competitiveAnalysis,
  supplierPerformance,
  competitiveResponse,
  pricingChange,
  economicDownturn,
  marketExpansion,
}

@JsonSerializable()
class ScenarioDefinition {
  final String id;
  final String name;
  final String description;
  final ScenarioType type;
  final Map<String, dynamic> parameters;
  final Map<String, VariableRange> variables;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String businessId;
  final bool isActive;

  const ScenarioDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.parameters,
    required this.variables,
    required this.createdAt,
    this.updatedAt,
    required this.businessId,
    this.isActive = true,
  });

  factory ScenarioDefinition.fromJson(Map<String, dynamic> json) =>
      _$ScenarioDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$ScenarioDefinitionToJson(this);
}

@JsonSerializable()
class VariableRange {
  final String name;
  final double minValue;
  final double maxValue;
  final double defaultValue;
  final String unit;
  final String description;

  const VariableRange({
    required this.name,
    required this.minValue,
    required this.maxValue,
    required this.defaultValue,
    required this.unit,
    required this.description,
  });

  factory VariableRange.fromJson(Map<String, dynamic> json) =>
      _$VariableRangeFromJson(json);

  Map<String, dynamic> toJson() => _$VariableRangeToJson(this);
}

@JsonSerializable()
class CashFlowImpactModel {
  final String id;
  final String scenarioId;
  final Map<String, double> monthlyProjections;
  final double totalImpact;
  final double confidenceScore;
  final List<String> keyFactors;
  final DateTime generatedAt;
  final Map<String, dynamic> impactMetrics;

  const CashFlowImpactModel({
    required this.id,
    required this.scenarioId,
    required this.monthlyProjections,
    required this.totalImpact,
    required this.confidenceScore,
    required this.keyFactors,
    required this.generatedAt,
    this.impactMetrics = const {},
  });

  factory CashFlowImpactModel.fromJson(Map<String, dynamic> json) =>
      _$CashFlowImpactModelFromJson(json);

  Map<String, dynamic> toJson() => _$CashFlowImpactModelToJson(this);
}

@JsonSerializable()
class CustomerBehaviorSimulation {
  final String id;
  final String scenarioId;
  final Map<String, dynamic> behaviorPatterns;
  final List<CustomerSimulationResult> results;
  final double overallImpact;
  final DateTime simulatedAt;
  final Map<String, dynamic> aggregatedMetrics;

  const CustomerBehaviorSimulation({
    required this.id,
    required this.scenarioId,
    required this.behaviorPatterns,
    required this.results,
    required this.overallImpact,
    required this.simulatedAt,
    this.aggregatedMetrics = const {},
  });

  factory CustomerBehaviorSimulation.fromJson(Map<String, dynamic> json) =>
      _$CustomerBehaviorSimulationFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerBehaviorSimulationToJson(this);
}

@JsonSerializable()
class CustomerSimulationResult {
  final String customerId;
  final double totalOrderValue;
  final double totalPayments;
  final double paymentReliability;
  final double creditUtilization;
  final Map<String, dynamic> behaviorMetrics;

  const CustomerSimulationResult({
    required this.customerId,
    required this.totalOrderValue,
    required this.totalPayments,
    required this.paymentReliability,
    required this.creditUtilization,
    required this.behaviorMetrics,
  });

  factory CustomerSimulationResult.fromJson(Map<String, dynamic> json) =>
      _$CustomerSimulationResultFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerSimulationResultToJson(this);
}

@JsonSerializable()
class MarketConditionModel {
  final String id;
  final String scenarioId;
  final Map<String, double> marketFactors;
  final double marketImpactScore;
  final List<String> riskFactors;
  final List<String> opportunities;
  final DateTime analyzedAt;
  final Map<String, dynamic> scenarioConditions;

  const MarketConditionModel({
    required this.id,
    required this.scenarioId,
    required this.marketFactors,
    required this.marketImpactScore,
    required this.riskFactors,
    required this.opportunities,
    required this.analyzedAt,
    this.scenarioConditions = const {},
  });

  factory MarketConditionModel.fromJson(Map<String, dynamic> json) =>
      _$MarketConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$MarketConditionModelToJson(this);
}

@JsonSerializable()
class ComprehensiveScenarioAnalysis {
  final String id;
  final String scenarioId;
  final CashFlowImpactModel cashFlowImpact;
  final CustomerBehaviorSimulation customerBehavior;
  final MarketConditionModel marketConditions;
  final double overallRiskScore;
  final double overallOpportunityScore;
  final List<String> recommendations;
  final DateTime analyzedAt;

  const ComprehensiveScenarioAnalysis({
    required this.id,
    required this.scenarioId,
    required this.cashFlowImpact,
    required this.customerBehavior,
    required this.marketConditions,
    required this.overallRiskScore,
    required this.overallOpportunityScore,
    required this.recommendations,
    required this.analyzedAt,
  });

  factory ComprehensiveScenarioAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ComprehensiveScenarioAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$ComprehensiveScenarioAnalysisToJson(this);
}
