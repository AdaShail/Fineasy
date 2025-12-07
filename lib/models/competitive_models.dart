import 'package:json_annotation/json_annotation.dart';

part 'competitive_models.g.dart';

// Enums
enum CompetitorType { direct, indirect, potential }

enum PricingStrategy {
  premium,
  competitive,
  discount,
  valueBased,
  lowCost,
  value,
}

enum ThreatLevel { low, medium, high, critical }

enum OpportunitySize { small, medium, large, massive }

enum FeasibilityLevel { low, medium, high }

// Competitive Analysis Models
@JsonSerializable()
class CompetitiveAnalysis {
  final String id;
  final String businessId;
  final MarketPosition marketPosition;
  final List<CompetitorProfile> competitors;
  final SWOTAnalysis swotAnalysis;
  final List<CompetitiveGap>? gaps;
  final List<PositioningRecommendation>? recommendations;
  final DateTime? analyzedAt;
  final List<PositioningRecommendation>? positioningRecommendations;
  final List<String>? competitiveAdvantages;
  final List<String>? threats;
  final List<String>? opportunities;
  final double? overallScore;
  final DateTime? createdAt;

  CompetitiveAnalysis({
    required this.id,
    required this.businessId,
    required this.marketPosition,
    required this.competitors,
    required this.swotAnalysis,
    this.gaps,
    this.recommendations,
    this.analyzedAt,
    this.positioningRecommendations,
    this.competitiveAdvantages,
    this.threats,
    this.opportunities,
    this.overallScore,
    this.createdAt,
  });

  factory CompetitiveAnalysis.fromJson(Map<String, dynamic> json) =>
      _$CompetitiveAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$CompetitiveAnalysisToJson(this);
}

@JsonSerializable()
class MarketPosition {
  final String id;
  final double marketShare;
  final String positioning;
  final List<String> strengths;
  final List<String> weaknesses;
  final double competitiveScore;
  final double? marketSize;
  final double? marketGrowthRate;
  final int? revenueRank;
  final int? growthRank;
  final int? customerSatisfactionRank;
  final int? innovationRank;
  final int? overallRank;
  final String? positioningQuadrant;

  MarketPosition({
    required this.id,
    required this.marketShare,
    required this.positioning,
    required this.strengths,
    required this.weaknesses,
    required this.competitiveScore,
    this.marketSize,
    this.marketGrowthRate,
    this.revenueRank,
    this.growthRank,
    this.customerSatisfactionRank,
    this.innovationRank,
    this.overallRank,
    this.positioningQuadrant,
  });

  factory MarketPosition.fromJson(Map<String, dynamic> json) =>
      _$MarketPositionFromJson(json);
  Map<String, dynamic> toJson() => _$MarketPositionToJson(this);
}

@JsonSerializable()
class CompetitorProfile {
  final String id;
  final String name;
  final CompetitorType type;
  final double marketShare;
  final PricingStrategy pricingStrategy;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> keyDifferentiators;
  final ThreatLevel threatLevel;
  final DateTime lastUpdated;
  final double? estimatedRevenue;
  final String? targetMarket;
  final List<String>? competitiveAdvantages;

  CompetitorProfile({
    required this.id,
    required this.name,
    required this.type,
    required this.marketShare,
    required this.pricingStrategy,
    required this.strengths,
    required this.weaknesses,
    required this.keyDifferentiators,
    required this.threatLevel,
    required this.lastUpdated,
    this.estimatedRevenue,
    this.targetMarket,
    this.competitiveAdvantages,
  });

  factory CompetitorProfile.fromJson(Map<String, dynamic> json) =>
      _$CompetitorProfileFromJson(json);
  Map<String, dynamic> toJson() => _$CompetitorProfileToJson(this);
}

@JsonSerializable()
class SWOTAnalysis {
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> opportunities;
  final List<String> threats;

  SWOTAnalysis({
    required this.strengths,
    required this.weaknesses,
    required this.opportunities,
    required this.threats,
  });

  factory SWOTAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SWOTAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$SWOTAnalysisToJson(this);
}

@JsonSerializable()
class CompetitiveGap {
  final String id;
  final String area;
  final String description;
  final double impactScore;
  final String recommendation;
  final String? rationale;
  final double? impact;
  final double? cost;
  final String? timeframe;
  final String? riskLevel;
  final double? priority;
  final List<String>? actions;
  final String? title;
  final double? expectedImpact;
  final double? implementationCost;
  final List<String>? requiredActions;

  CompetitiveGap({
    required this.id,
    required this.area,
    required this.description,
    required this.impactScore,
    required this.recommendation,
    this.rationale,
    this.impact,
    this.cost,
    this.timeframe,
    this.riskLevel,
    this.priority,
    this.actions,
    this.title,
    this.expectedImpact,
    this.implementationCost,
    this.requiredActions,
  });

  factory CompetitiveGap.fromJson(Map<String, dynamic> json) =>
      _$CompetitiveGapFromJson(json);
  Map<String, dynamic> toJson() => _$CompetitiveGapToJson(this);
}

@JsonSerializable()
class PositioningRecommendation {
  final String id;
  final String type;
  final String description;
  final double priority;
  final List<String> actionItems;
  final List<String>? strategicRecommendations;

  PositioningRecommendation({
    required this.id,
    required this.type,
    required this.description,
    required this.priority,
    required this.actionItems,
    this.strategicRecommendations,
  });

  factory PositioningRecommendation.fromJson(Map<String, dynamic> json) =>
      _$PositioningRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$PositioningRecommendationToJson(this);
}
