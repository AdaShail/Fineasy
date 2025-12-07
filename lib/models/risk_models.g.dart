// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RiskAssessment _$RiskAssessmentFromJson(Map<String, dynamic> json) =>
    RiskAssessment(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      type: $enumDecode(_$RiskTypeEnumMap, json['type']),
      overallRisk: $enumDecode(_$RiskLevelEnumMap, json['overallRisk']),
      factors:
          (json['factors'] as List<dynamic>)
              .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
              .toList(),
      recommendations:
          (json['recommendations'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      assessedAt: DateTime.parse(json['assessedAt'] as String),
      decisionId: json['decisionId'] as String?,
      overallRiskScore: (json['overallRiskScore'] as num?)?.toDouble(),
      riskLevel: $enumDecodeNullable(_$RiskLevelEnumMap, json['riskLevel']),
      riskFactors:
          (json['riskFactors'] as List<dynamic>?)
              ?.map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
              .toList(),
      aiAnalysis: json['aiAnalysis'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RiskAssessmentToJson(RiskAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'type': _$RiskTypeEnumMap[instance.type]!,
      'overallRisk': _$RiskLevelEnumMap[instance.overallRisk]!,
      'factors': instance.factors,
      'recommendations': instance.recommendations,
      'confidenceScore': instance.confidenceScore,
      'assessedAt': instance.assessedAt.toIso8601String(),
      'decisionId': instance.decisionId,
      'overallRiskScore': instance.overallRiskScore,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel],
      'riskFactors': instance.riskFactors,
      'aiAnalysis': instance.aiAnalysis,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$RiskTypeEnumMap = {
  RiskType.financial: 'financial',
  RiskType.operational: 'operational',
  RiskType.market: 'market',
  RiskType.compliance: 'compliance',
  RiskType.overall: 'overall',
};

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.medium: 'medium',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
};

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) => RiskFactor(
  id: json['id'] as String,
  description: json['description'] as String,
  level: $enumDecode(_$RiskLevelEnumMap, json['level']),
  probability: (json['probability'] as num).toDouble(),
  impact: (json['impact'] as num).toDouble(),
  mitigation: json['mitigation'] as String,
  riskLevel: $enumDecodeNullable(_$RiskLevelEnumMap, json['riskLevel']),
  impactScore: (json['impactScore'] as num?)?.toDouble(),
  mitigationStrategies:
      (json['mitigationStrategies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  type: json['type'] as String?,
  score: (json['score'] as num?)?.toDouble(),
  factors:
      (json['factors'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$RiskFactorToJson(RiskFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'level': _$RiskLevelEnumMap[instance.level]!,
      'probability': instance.probability,
      'impact': instance.impact,
      'mitigation': instance.mitigation,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel],
      'impactScore': instance.impactScore,
      'mitigationStrategies': instance.mitigationStrategies,
      'type': instance.type,
      'score': instance.score,
      'factors': instance.factors,
    };

AIRiskAnalysis _$AIRiskAnalysisFromJson(Map<String, dynamic> json) =>
    AIRiskAnalysis(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      identifiedRisks:
          (json['identifiedRisks'] as List<dynamic>)
              .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
              .toList(),
      overallRiskScore: (json['overallRiskScore'] as num).toDouble(),
      aiRecommendations:
          (json['aiRecommendations'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      keyRisks:
          (json['keyRisks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      successProbability: (json['successProbability'] as num?)?.toDouble(),
      potentialImpact: json['potentialImpact'] as String?,
      mitigationStrategies:
          (json['mitigationStrategies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      recommendation: json['recommendation'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AIRiskAnalysisToJson(AIRiskAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'identifiedRisks': instance.identifiedRisks,
      'overallRiskScore': instance.overallRiskScore,
      'aiRecommendations': instance.aiRecommendations,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
      'keyRisks': instance.keyRisks,
      'successProbability': instance.successProbability,
      'potentialImpact': instance.potentialImpact,
      'mitigationStrategies': instance.mitigationStrategies,
      'recommendation': instance.recommendation,
      'confidence': instance.confidence,
    };
