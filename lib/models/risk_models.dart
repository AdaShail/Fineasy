import 'package:json_annotation/json_annotation.dart';
import 'autopilot_models.dart';

part 'risk_models.g.dart';

// Risk Assessment Models
@JsonSerializable()
class RiskAssessment {
  final String id;
  final String businessId;
  final RiskType type;
  final RiskLevel overallRisk;
  final List<RiskFactor> factors;
  final List<String> recommendations;
  final double confidenceScore;
  final DateTime assessedAt;
  final String? decisionId;
  final double? overallRiskScore;
  final RiskLevel? riskLevel;
  final List<RiskFactor>? riskFactors;
  final String? aiAnalysis;
  final DateTime? createdAt;

  RiskAssessment({
    required this.id,
    required this.businessId,
    required this.type,
    required this.overallRisk,
    required this.factors,
    required this.recommendations,
    required this.confidenceScore,
    required this.assessedAt,
    this.decisionId,
    this.overallRiskScore,
    this.riskLevel,
    this.riskFactors,
    this.aiAnalysis,
    this.createdAt,
  });

  factory RiskAssessment.fromJson(Map<String, dynamic> json) =>
      _$RiskAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$RiskAssessmentToJson(this);
}

@JsonSerializable()
class RiskFactor {
  final String id;
  final String description;
  final RiskLevel level;
  final double probability;
  final double impact;
  final String mitigation;
  final RiskLevel? riskLevel;
  final double? impactScore;
  final List<String>? mitigationStrategies;
  final String? type;
  final double? score;
  final List<String>? factors;

  RiskFactor({
    required this.id,
    required this.description,
    required this.level,
    required this.probability,
    required this.impact,
    required this.mitigation,
    this.riskLevel,
    this.impactScore,
    this.mitigationStrategies,
    this.type,
    this.score,
    this.factors,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorFromJson(json);
  Map<String, dynamic> toJson() => _$RiskFactorToJson(this);
}

@JsonSerializable()
class AIRiskAnalysis {
  final String id;
  final String businessId;
  final List<RiskFactor> identifiedRisks;
  final double overallRiskScore;
  final List<String> aiRecommendations;
  final DateTime analyzedAt;
  final List<String>? keyRisks;
  final double? successProbability;
  final String? potentialImpact;
  final List<String>? mitigationStrategies;
  final String? recommendation;
  final double? confidence;

  AIRiskAnalysis({
    required this.id,
    required this.businessId,
    required this.identifiedRisks,
    required this.overallRiskScore,
    required this.aiRecommendations,
    required this.analyzedAt,
    this.keyRisks,
    this.successProbability,
    this.potentialImpact,
    this.mitigationStrategies,
    this.recommendation,
    this.confidence,
  });

  factory AIRiskAnalysis.fromJson(Map<String, dynamic> json) =>
      _$AIRiskAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$AIRiskAnalysisToJson(this);
}
