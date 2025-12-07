// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competitive_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompetitiveAnalysis _$CompetitiveAnalysisFromJson(
  Map<String, dynamic> json,
) => CompetitiveAnalysis(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  marketPosition: MarketPosition.fromJson(
    json['marketPosition'] as Map<String, dynamic>,
  ),
  competitors:
      (json['competitors'] as List<dynamic>)
          .map((e) => CompetitorProfile.fromJson(e as Map<String, dynamic>))
          .toList(),
  swotAnalysis: SWOTAnalysis.fromJson(
    json['swotAnalysis'] as Map<String, dynamic>,
  ),
  gaps:
      (json['gaps'] as List<dynamic>?)
          ?.map((e) => CompetitiveGap.fromJson(e as Map<String, dynamic>))
          .toList(),
  recommendations:
      (json['recommendations'] as List<dynamic>?)
          ?.map(
            (e) =>
                PositioningRecommendation.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  analyzedAt:
      json['analyzedAt'] == null
          ? null
          : DateTime.parse(json['analyzedAt'] as String),
  positioningRecommendations:
      (json['positioningRecommendations'] as List<dynamic>?)
          ?.map(
            (e) =>
                PositioningRecommendation.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  competitiveAdvantages:
      (json['competitiveAdvantages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  threats:
      (json['threats'] as List<dynamic>?)?.map((e) => e as String).toList(),
  opportunities:
      (json['opportunities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  overallScore: (json['overallScore'] as num?)?.toDouble(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CompetitiveAnalysisToJson(
  CompetitiveAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'marketPosition': instance.marketPosition,
  'competitors': instance.competitors,
  'swotAnalysis': instance.swotAnalysis,
  'gaps': instance.gaps,
  'recommendations': instance.recommendations,
  'analyzedAt': instance.analyzedAt?.toIso8601String(),
  'positioningRecommendations': instance.positioningRecommendations,
  'competitiveAdvantages': instance.competitiveAdvantages,
  'threats': instance.threats,
  'opportunities': instance.opportunities,
  'overallScore': instance.overallScore,
  'createdAt': instance.createdAt?.toIso8601String(),
};

MarketPosition _$MarketPositionFromJson(
  Map<String, dynamic> json,
) => MarketPosition(
  id: json['id'] as String,
  marketShare: (json['marketShare'] as num).toDouble(),
  positioning: json['positioning'] as String,
  strengths:
      (json['strengths'] as List<dynamic>).map((e) => e as String).toList(),
  weaknesses:
      (json['weaknesses'] as List<dynamic>).map((e) => e as String).toList(),
  competitiveScore: (json['competitiveScore'] as num).toDouble(),
  marketSize: (json['marketSize'] as num?)?.toDouble(),
  marketGrowthRate: (json['marketGrowthRate'] as num?)?.toDouble(),
  revenueRank: (json['revenueRank'] as num?)?.toInt(),
  growthRank: (json['growthRank'] as num?)?.toInt(),
  customerSatisfactionRank: (json['customerSatisfactionRank'] as num?)?.toInt(),
  innovationRank: (json['innovationRank'] as num?)?.toInt(),
  overallRank: (json['overallRank'] as num?)?.toInt(),
  positioningQuadrant: json['positioningQuadrant'] as String?,
);

Map<String, dynamic> _$MarketPositionToJson(MarketPosition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'marketShare': instance.marketShare,
      'positioning': instance.positioning,
      'strengths': instance.strengths,
      'weaknesses': instance.weaknesses,
      'competitiveScore': instance.competitiveScore,
      'marketSize': instance.marketSize,
      'marketGrowthRate': instance.marketGrowthRate,
      'revenueRank': instance.revenueRank,
      'growthRank': instance.growthRank,
      'customerSatisfactionRank': instance.customerSatisfactionRank,
      'innovationRank': instance.innovationRank,
      'overallRank': instance.overallRank,
      'positioningQuadrant': instance.positioningQuadrant,
    };

CompetitorProfile _$CompetitorProfileFromJson(Map<String, dynamic> json) =>
    CompetitorProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$CompetitorTypeEnumMap, json['type']),
      marketShare: (json['marketShare'] as num).toDouble(),
      pricingStrategy: $enumDecode(
        _$PricingStrategyEnumMap,
        json['pricingStrategy'],
      ),
      strengths:
          (json['strengths'] as List<dynamic>).map((e) => e as String).toList(),
      weaknesses:
          (json['weaknesses'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      keyDifferentiators:
          (json['keyDifferentiators'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      threatLevel: $enumDecode(_$ThreatLevelEnumMap, json['threatLevel']),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      estimatedRevenue: (json['estimatedRevenue'] as num?)?.toDouble(),
      targetMarket: json['targetMarket'] as String?,
      competitiveAdvantages:
          (json['competitiveAdvantages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$CompetitorProfileToJson(CompetitorProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$CompetitorTypeEnumMap[instance.type]!,
      'marketShare': instance.marketShare,
      'pricingStrategy': _$PricingStrategyEnumMap[instance.pricingStrategy]!,
      'strengths': instance.strengths,
      'weaknesses': instance.weaknesses,
      'keyDifferentiators': instance.keyDifferentiators,
      'threatLevel': _$ThreatLevelEnumMap[instance.threatLevel]!,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'estimatedRevenue': instance.estimatedRevenue,
      'targetMarket': instance.targetMarket,
      'competitiveAdvantages': instance.competitiveAdvantages,
    };

const _$CompetitorTypeEnumMap = {
  CompetitorType.direct: 'direct',
  CompetitorType.indirect: 'indirect',
  CompetitorType.potential: 'potential',
};

const _$PricingStrategyEnumMap = {
  PricingStrategy.premium: 'premium',
  PricingStrategy.competitive: 'competitive',
  PricingStrategy.discount: 'discount',
  PricingStrategy.valueBased: 'valueBased',
  PricingStrategy.lowCost: 'lowCost',
  PricingStrategy.value: 'value',
};

const _$ThreatLevelEnumMap = {
  ThreatLevel.low: 'low',
  ThreatLevel.medium: 'medium',
  ThreatLevel.high: 'high',
  ThreatLevel.critical: 'critical',
};

SWOTAnalysis _$SWOTAnalysisFromJson(Map<String, dynamic> json) => SWOTAnalysis(
  strengths:
      (json['strengths'] as List<dynamic>).map((e) => e as String).toList(),
  weaknesses:
      (json['weaknesses'] as List<dynamic>).map((e) => e as String).toList(),
  opportunities:
      (json['opportunities'] as List<dynamic>).map((e) => e as String).toList(),
  threats: (json['threats'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$SWOTAnalysisToJson(SWOTAnalysis instance) =>
    <String, dynamic>{
      'strengths': instance.strengths,
      'weaknesses': instance.weaknesses,
      'opportunities': instance.opportunities,
      'threats': instance.threats,
    };

CompetitiveGap _$CompetitiveGapFromJson(Map<String, dynamic> json) =>
    CompetitiveGap(
      id: json['id'] as String,
      area: json['area'] as String,
      description: json['description'] as String,
      impactScore: (json['impactScore'] as num).toDouble(),
      recommendation: json['recommendation'] as String,
      rationale: json['rationale'] as String?,
      impact: (json['impact'] as num?)?.toDouble(),
      cost: (json['cost'] as num?)?.toDouble(),
      timeframe: json['timeframe'] as String?,
      riskLevel: json['riskLevel'] as String?,
      priority: (json['priority'] as num?)?.toDouble(),
      actions:
          (json['actions'] as List<dynamic>?)?.map((e) => e as String).toList(),
      title: json['title'] as String?,
      expectedImpact: (json['expectedImpact'] as num?)?.toDouble(),
      implementationCost: (json['implementationCost'] as num?)?.toDouble(),
      requiredActions:
          (json['requiredActions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$CompetitiveGapToJson(CompetitiveGap instance) =>
    <String, dynamic>{
      'id': instance.id,
      'area': instance.area,
      'description': instance.description,
      'impactScore': instance.impactScore,
      'recommendation': instance.recommendation,
      'rationale': instance.rationale,
      'impact': instance.impact,
      'cost': instance.cost,
      'timeframe': instance.timeframe,
      'riskLevel': instance.riskLevel,
      'priority': instance.priority,
      'actions': instance.actions,
      'title': instance.title,
      'expectedImpact': instance.expectedImpact,
      'implementationCost': instance.implementationCost,
      'requiredActions': instance.requiredActions,
    };

PositioningRecommendation _$PositioningRecommendationFromJson(
  Map<String, dynamic> json,
) => PositioningRecommendation(
  id: json['id'] as String,
  type: json['type'] as String,
  description: json['description'] as String,
  priority: (json['priority'] as num).toDouble(),
  actionItems:
      (json['actionItems'] as List<dynamic>).map((e) => e as String).toList(),
  strategicRecommendations:
      (json['strategicRecommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$PositioningRecommendationToJson(
  PositioningRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'description': instance.description,
  'priority': instance.priority,
  'actionItems': instance.actionItems,
  'strategicRecommendations': instance.strategicRecommendations,
};
