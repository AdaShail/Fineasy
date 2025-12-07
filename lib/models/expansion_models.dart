import 'package:json_annotation/json_annotation.dart';
import 'autopilot_models.dart';

part 'expansion_models.g.dart';

// Enums
enum OpportunitySize { small, medium, large, massive }

enum FeasibilityLevel { low, medium, high }

// Expansion Analysis Models
@JsonSerializable()
class ExpansionAnalysis {
  final String id;
  final String businessId;
  final ExpansionType type;
  final MarketOpportunity marketOpportunity;
  final FinancialFeasibility financialFeasibility;
  final ResourceRequirements resourceRequirements;
  final ExpansionTimeline timeline;
  final List<RiskFactor> risks;
  final ExpansionRecommendation recommendation;
  final double confidenceScore;
  final DateTime analyzedAt;

  ExpansionAnalysis({
    required this.id,
    required this.businessId,
    required this.type,
    required this.marketOpportunity,
    required this.financialFeasibility,
    required this.resourceRequirements,
    required this.timeline,
    required this.risks,
    required this.recommendation,
    required this.confidenceScore,
    required this.analyzedAt,
  });

  factory ExpansionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ExpansionAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$ExpansionAnalysisToJson(this);
}

@JsonSerializable()
class MarketOpportunity {
  final String id;
  final String description;
  final double marketSize;
  final double growthRate;
  final double competitionLevel;
  final List<String> targetSegments;
  final double? totalMarketSize;
  final double? addressableMarket;
  final String? opportunitySize;
  final List<String>? marketTrends;
  final double? opportunityScore;
  final double? growthPotential;
  final List<String>? entryBarriers;
  final double? feasibilityRating;

  MarketOpportunity({
    required this.id,
    required this.description,
    required this.marketSize,
    required this.growthRate,
    required this.competitionLevel,
    required this.targetSegments,
    this.totalMarketSize,
    this.addressableMarket,
    this.opportunitySize,
    this.marketTrends,
    this.opportunityScore,
    this.growthPotential,
    this.entryBarriers,
    this.feasibilityRating,
  });

  factory MarketOpportunity.fromJson(Map<String, dynamic> json) =>
      _$MarketOpportunityFromJson(json);
  Map<String, dynamic> toJson() => _$MarketOpportunityToJson(this);
}

@JsonSerializable()
class FinancialFeasibility {
  final String id;
  final double estimatedCost;
  final double projectedRevenue;
  final double breakEvenMonths;
  final double roi;
  final bool isFeasible;
  final double? investmentRequired;
  final double? availableFunds;
  final double? fundingGap;
  final double? revenueImpact;
  final String? feasibilityLevel;
  final double? capitalRatio;
  final double? cashFlowBuffer;
  final double? debtToEquityRatio;
  final double? feasibilityRating;

  FinancialFeasibility({
    required this.id,
    required this.estimatedCost,
    required this.projectedRevenue,
    required this.breakEvenMonths,
    required this.roi,
    required this.isFeasible,
    this.investmentRequired,
    this.availableFunds,
    this.fundingGap,
    this.revenueImpact,
    this.feasibilityLevel,
    this.capitalRatio,
    this.cashFlowBuffer,
    this.debtToEquityRatio,
    this.feasibilityRating,
  });

  factory FinancialFeasibility.fromJson(Map<String, dynamic> json) =>
      _$FinancialFeasibilityFromJson(json);
  Map<String, dynamic> toJson() => _$FinancialFeasibilityToJson(this);
}

@JsonSerializable()
class ResourceRequirements {
  final String id;
  final int staffRequired;
  final double capitalRequired;
  final List<String> skillsNeeded;
  final List<String> infrastructureNeeded;
  final int? additionalStaff;
  final double? infrastructureCost;
  final double? operationalCost;
  final List<String>? technologyRequirements;
  final List<String>? skillRequirements;
  final double? capacityGap;
  final bool? timelineFeasible;
  final List<String>? skillGaps;
  final double? resourceAvailability;
  final double? feasibilityRating;

  ResourceRequirements({
    required this.id,
    required this.staffRequired,
    required this.capitalRequired,
    required this.skillsNeeded,
    required this.infrastructureNeeded,
    this.additionalStaff,
    this.infrastructureCost,
    this.operationalCost,
    this.technologyRequirements,
    this.skillRequirements,
    this.capacityGap,
    this.timelineFeasible,
    this.skillGaps,
    this.resourceAvailability,
    this.feasibilityRating,
  });

  factory ResourceRequirements.fromJson(Map<String, dynamic> json) =>
      _$ResourceRequirementsFromJson(json);
  Map<String, dynamic> toJson() => _$ResourceRequirementsToJson(this);
}

@JsonSerializable()
class ExpansionTimeline {
  final String id;
  final int preparationWeeks;
  final int implementationWeeks;
  final int stabilizationWeeks;
  final List<String> milestones;
  final int? planningPhase;
  final int? implementationPhase;
  final int? rampUpPhase;
  final int? totalTimelineWeeks;
  final List<String>? keyMilestones;

  ExpansionTimeline({
    required this.id,
    required this.preparationWeeks,
    required this.implementationWeeks,
    required this.stabilizationWeeks,
    required this.milestones,
    this.planningPhase,
    this.implementationPhase,
    this.rampUpPhase,
    this.totalTimelineWeeks,
    this.keyMilestones,
  });

  factory ExpansionTimeline.fromJson(Map<String, dynamic> json) =>
      _$ExpansionTimelineFromJson(json);
  Map<String, dynamic> toJson() => _$ExpansionTimelineToJson(this);
}

@JsonSerializable()
class RiskFactor {
  final String id;
  final String description;
  final RiskLevel level;
  final double probability;
  final String mitigation;
  final RiskLevel? riskLevel;
  final double? impactScore;
  final List<String>? mitigationStrategies;
  final String? type;

  RiskFactor({
    required this.id,
    required this.description,
    required this.level,
    required this.probability,
    required this.mitigation,
    this.riskLevel,
    this.impactScore,
    this.mitigationStrategies,
    this.type,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorFromJson(json);
  Map<String, dynamic> toJson() => _$RiskFactorToJson(this);
}

// Investment Decision Models
@JsonSerializable()
class ExpansionPlan {
  final String id;
  final String businessId;
  final ExpansionType type;
  final String description;
  final double estimatedCost;
  final DateTime targetDate;
  final double? requiredCapital;
  final double? estimatedMonthlyCosts;
  final double? requiredCapacityIncrease;
  final int? estimatedTimelineMonths;
  final List<String>? requiredSkills;

  ExpansionPlan({
    required this.id,
    required this.businessId,
    required this.type,
    required this.description,
    required this.estimatedCost,
    required this.targetDate,
    this.requiredCapital,
    this.estimatedMonthlyCosts,
    this.requiredCapacityIncrease,
    this.estimatedTimelineMonths,
    this.requiredSkills,
  });

  factory ExpansionPlan.fromJson(Map<String, dynamic> json) =>
      _$ExpansionPlanFromJson(json);
  Map<String, dynamic> toJson() => _$ExpansionPlanToJson(this);
}

@JsonSerializable()
class BusinessFinancialState {
  final double currentRevenue;
  final double currentExpenses;
  final double cashReserves;
  final double debtLevel;
  final double profitMargin;
  final double? cashBalance;
  final double? creditLimit;
  final double? monthlyRevenue;
  final double? monthlyExpenses;
  final double? totalDebt;
  final double? equity;
  final double? operationalCapacity;
  final List<String>? availableSkills;

  BusinessFinancialState({
    required this.currentRevenue,
    required this.currentExpenses,
    required this.cashReserves,
    required this.debtLevel,
    required this.profitMargin,
    this.cashBalance,
    this.creditLimit,
    this.monthlyRevenue,
    this.monthlyExpenses,
    this.totalDebt,
    this.equity,
    this.operationalCapacity,
    this.availableSkills,
  });

  factory BusinessFinancialState.fromJson(Map<String, dynamic> json) =>
      _$BusinessFinancialStateFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessFinancialStateToJson(this);
}

@JsonSerializable()
class MarketConditions {
  final double growthRate;
  final double competitionIntensity;
  final double marketSaturation;
  final List<String> trends;
  final double? targetMarketSize;
  final double? marketGrowthRate;
  final double? regulatoryComplexity;

  MarketConditions({
    required this.growthRate,
    required this.competitionIntensity,
    required this.marketSaturation,
    required this.trends,
    this.targetMarketSize,
    this.marketGrowthRate,
    this.regulatoryComplexity,
  });

  factory MarketConditions.fromJson(Map<String, dynamic> json) =>
      _$MarketConditionsFromJson(json);
  Map<String, dynamic> toJson() => _$MarketConditionsToJson(this);
}

@JsonSerializable()
class ExpansionFeasibilityAnalysis {
  final String id;
  final ExpansionPlan plan;
  final MarketOpportunity marketFeasibility;
  final FinancialFeasibility financialFeasibility;
  final ResourceRequirements operationalFeasibility;
  final List<RiskFactor> risks;
  final ExpansionRecommendation recommendation;
  final double confidenceScore;

  ExpansionFeasibilityAnalysis({
    required this.id,
    required this.plan,
    required this.marketFeasibility,
    required this.financialFeasibility,
    required this.operationalFeasibility,
    required this.risks,
    required this.recommendation,
    required this.confidenceScore,
  });

  factory ExpansionFeasibilityAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ExpansionFeasibilityAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$ExpansionFeasibilityAnalysisToJson(this);
}

// Hiring Models
@JsonSerializable()
class HiringRequest {
  final String id;
  final String position;
  final String department;
  final double salary;
  final String justification;
  final double? expectedSalary;

  HiringRequest({
    required this.id,
    required this.position,
    required this.department,
    required this.salary,
    required this.justification,
    this.expectedSalary,
  });

  factory HiringRequest.fromJson(Map<String, dynamic> json) =>
      _$HiringRequestFromJson(json);
  Map<String, dynamic> toJson() => _$HiringRequestToJson(this);
}

@JsonSerializable()
class FinancialImpact {
  final double totalCost;
  final double ongoingCosts;
  final double oneTimeCosts;
  final double? annualSalaryCost;
  final double? hiringCosts;
  final double? totalFirstYearCost;
  final double? projectedRevenueImpact;
  final double? netImpact;
  final int? paybackMonths;

  FinancialImpact({
    required this.totalCost,
    required this.ongoingCosts,
    required this.oneTimeCosts,
    this.annualSalaryCost,
    this.hiringCosts,
    this.totalFirstYearCost,
    this.projectedRevenueImpact,
    this.netImpact,
    this.paybackMonths,
  });

  factory FinancialImpact.fromJson(Map<String, dynamic> json) =>
      _$FinancialImpactFromJson(json);
  Map<String, dynamic> toJson() => _$FinancialImpactToJson(this);
}

@JsonSerializable()
class ProductivityAnalysis {
  final double expectedProductivityGain;
  final double timeToProductivity;
  final double impactOnTeam;
  final double? currentWorkloadLevel;
  final double? workloadReduction;
  final double? qualityImprovement;
  final double? efficiencyGain;

  ProductivityAnalysis({
    required this.expectedProductivityGain,
    required this.timeToProductivity,
    required this.impactOnTeam,
    this.currentWorkloadLevel,
    this.workloadReduction,
    this.qualityImprovement,
    this.efficiencyGain,
  });

  factory ProductivityAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ProductivityAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$ProductivityAnalysisToJson(this);
}

@JsonSerializable()
class HiringROI {
  final double roi;
  final double paybackPeriod;
  final double netBenefit;
  final double? firstYearROI;
  final double? threeYearROI;
  final int? breakEvenMonths;
  final double? confidenceLevel;

  HiringROI({
    required this.roi,
    required this.paybackPeriod,
    required this.netBenefit,
    this.firstYearROI,
    this.threeYearROI,
    this.breakEvenMonths,
    this.confidenceLevel,
  });

  factory HiringROI.fromJson(Map<String, dynamic> json) =>
      _$HiringROIFromJson(json);
  Map<String, dynamic> toJson() => _$HiringROIToJson(this);
}

@JsonSerializable()
class HiringTiming {
  final TimingRecommendation recommendation;
  final String reasoning;
  final DateTime suggestedDate;
  final int? optimalMonth;

  HiringTiming({
    required this.recommendation,
    required this.reasoning,
    required this.suggestedDate,
    this.optimalMonth,
  });

  factory HiringTiming.fromJson(Map<String, dynamic> json) =>
      _$HiringTimingFromJson(json);
  Map<String, dynamic> toJson() => _$HiringTimingToJson(this);
}

// Marketing Models
@JsonSerializable()
class MarketingOptimization {
  final String id;
  final CustomerAcquisitionAnalysis acquisitionAnalysis;
  final BudgetAllocation budgetAllocation;
  final List<MarketingRecommendation> recommendations;
  final double expectedROI;

  MarketingOptimization({
    required this.id,
    required this.acquisitionAnalysis,
    required this.budgetAllocation,
    required this.recommendations,
    required this.expectedROI,
  });

  factory MarketingOptimization.fromJson(Map<String, dynamic> json) =>
      _$MarketingOptimizationFromJson(json);
  Map<String, dynamic> toJson() => _$MarketingOptimizationToJson(this);
}

@JsonSerializable()
class CustomerAcquisitionAnalysis {
  final double currentCAC;
  final double targetCAC;
  final double customerLifetimeValue;
  final Map<String, double> channelPerformance;
  final int? totalCustomersAcquired;
  final double? averageCAC;
  final double? cacToLtvRatio;
  final String? acquisitionTrend;

  CustomerAcquisitionAnalysis({
    required this.currentCAC,
    required this.targetCAC,
    required this.customerLifetimeValue,
    required this.channelPerformance,
    this.totalCustomersAcquired,
    this.averageCAC,
    this.cacToLtvRatio,
    this.acquisitionTrend,
  });

  factory CustomerAcquisitionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$CustomerAcquisitionAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerAcquisitionAnalysisToJson(this);
}

@JsonSerializable()
class BudgetAllocation {
  final Map<String, double> channelBudgets;
  final double totalBudget;
  final AllocationStrategy strategy;
  final Map<String, double>? channelAllocations;
  final String? allocationStrategy;
  final double? expectedImprovement;

  BudgetAllocation({
    required this.channelBudgets,
    required this.totalBudget,
    required this.strategy,
    this.channelAllocations,
    this.allocationStrategy,
    this.expectedImprovement,
  });

  factory BudgetAllocation.fromJson(Map<String, dynamic> json) =>
      _$BudgetAllocationFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetAllocationToJson(this);
}

@JsonSerializable()
class MarketingRecommendation {
  final String id;
  final RecommendationType type;
  final String description;
  final double priority;
  final double expectedImpact;

  MarketingRecommendation({
    required this.id,
    required this.type,
    required this.description,
    required this.priority,
    required this.expectedImpact,
  });

  factory MarketingRecommendation.fromJson(Map<String, dynamic> json) =>
      _$MarketingRecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$MarketingRecommendationToJson(this);
}

@JsonSerializable()
class BusinessProjections {
  final double projectedRevenue;
  final double projectedExpenses;
  final double projectedProfit;
  final int timeHorizonMonths;
  final double? annualRevenue;

  BusinessProjections({
    required this.projectedRevenue,
    required this.projectedExpenses,
    required this.projectedProfit,
    required this.timeHorizonMonths,
    this.annualRevenue,
  });

  factory BusinessProjections.fromJson(Map<String, dynamic> json) =>
      _$BusinessProjectionsFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessProjectionsToJson(this);
}

@JsonSerializable()
class CashFlowImpact {
  final double immediateImpact;
  final double monthlyImpact;
  final double cumulativeImpact;
  final double? monthlyCostIncrease;
  final double? monthlyRevenueIncrease;
  final double? netMonthlyCashFlow;
  final List<double>? projectedCashFlow;
  final String? cashFlowRisk;

  CashFlowImpact({
    required this.immediateImpact,
    required this.monthlyImpact,
    required this.cumulativeImpact,
    this.monthlyCostIncrease,
    this.monthlyRevenueIncrease,
    this.netMonthlyCashFlow,
    this.projectedCashFlow,
    this.cashFlowRisk,
  });

  factory CashFlowImpact.fromJson(Map<String, dynamic> json) =>
      _$CashFlowImpactFromJson(json);
  Map<String, dynamic> toJson() => _$CashFlowImpactToJson(this);
}

@JsonSerializable()
class BusinessGoals {
  final double revenueTarget;
  final double profitTarget;
  final double marketShareTarget;
  final int timeframeMonths;
  final String? primaryGoal;

  BusinessGoals({
    required this.revenueTarget,
    required this.profitTarget,
    required this.marketShareTarget,
    required this.timeframeMonths,
    this.primaryGoal,
  });

  factory BusinessGoals.fromJson(Map<String, dynamic> json) =>
      _$BusinessGoalsFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessGoalsToJson(this);
}

@JsonSerializable()
class HistoricalMarketingData {
  final Map<String, double> channelROI;
  final Map<String, double> channelConversions;
  final Map<String, double> channelCosts;
  final int dataPointsCount;
  final Map<String, dynamic>? channelData;

  HistoricalMarketingData({
    required this.channelROI,
    required this.channelConversions,
    required this.channelCosts,
    required this.dataPointsCount,
    this.channelData,
  });

  factory HistoricalMarketingData.fromJson(Map<String, dynamic> json) =>
      _$HistoricalMarketingDataFromJson(json);
  Map<String, dynamic> toJson() => _$HistoricalMarketingDataToJson(this);
}

@JsonSerializable()
class MarketingProjections {
  final double projectedCustomers;
  final double projectedRevenue;
  final double projectedROI;
  final Map<String, double> channelProjections;
  final double? expectedRevenue;
  final int? expectedLeads;
  final int? expectedConversions;
  final int? expectedReach;
  final DateTime? projectedAt;

  MarketingProjections({
    required this.projectedCustomers,
    required this.projectedRevenue,
    required this.projectedROI,
    required this.channelProjections,
    this.expectedRevenue,
    this.expectedLeads,
    this.expectedConversions,
    this.expectedReach,
    this.projectedAt,
  });

  factory MarketingProjections.fromJson(Map<String, dynamic> json) =>
      _$MarketingProjectionsFromJson(json);
  Map<String, dynamic> toJson() => _$MarketingProjectionsToJson(this);
}

@JsonSerializable()
class OptimizationOpportunity {
  final String id;
  final String description;
  final double potentialSavings;
  final double implementationCost;
  final double priority;
  final String? type;
  final double? impact;
  final String? recommendation;
  final Map<String, double>? potentialGains;

  OptimizationOpportunity({
    required this.id,
    required this.description,
    required this.potentialSavings,
    required this.implementationCost,
    required this.priority,
    this.type,
    this.impact,
    this.recommendation,
    this.potentialGains,
  });

  factory OptimizationOpportunity.fromJson(Map<String, dynamic> json) =>
      _$OptimizationOpportunityFromJson(json);
  Map<String, dynamic> toJson() => _$OptimizationOpportunityToJson(this);
}

@JsonSerializable()
class ExpansionRisk {
  final String id;
  final String description;
  final RiskLevel level;
  final double probability;
  final String mitigation;
  final double? impact;

  ExpansionRisk({
    required this.id,
    required this.description,
    required this.level,
    required this.probability,
    required this.mitigation,
    this.impact,
  });

  factory ExpansionRisk.fromJson(Map<String, dynamic> json) =>
      _$ExpansionRiskFromJson(json);
  Map<String, dynamic> toJson() => _$ExpansionRiskToJson(this);
}

@JsonSerializable()
class MarketFeasibility {
  final double marketSize;
  final double growthPotential;
  final double competitionLevel;
  final bool isFeasible;

  MarketFeasibility({
    required this.marketSize,
    required this.growthPotential,
    required this.competitionLevel,
    required this.isFeasible,
  });

  factory MarketFeasibility.fromJson(Map<String, dynamic> json) =>
      _$MarketFeasibilityFromJson(json);
  Map<String, dynamic> toJson() => _$MarketFeasibilityToJson(this);
}

@JsonSerializable()
class OperationalFeasibility {
  final bool hasRequiredSkills;
  final bool hasInfrastructure;
  final double implementationComplexity;
  final bool isFeasible;

  OperationalFeasibility({
    required this.hasRequiredSkills,
    required this.hasInfrastructure,
    required this.implementationComplexity,
    required this.isFeasible,
  });

  factory OperationalFeasibility.fromJson(Map<String, dynamic> json) =>
      _$OperationalFeasibilityFromJson(json);
  Map<String, dynamic> toJson() => _$OperationalFeasibilityToJson(this);
}

// Additional Models for Investment Decision Service
@JsonSerializable()
class HiringPlan {
  final String id;
  final List<HiringPosition> positions;
  final double totalCost;
  final int timelineMonths;

  HiringPlan({
    required this.id,
    required this.positions,
    required this.totalCost,
    required this.timelineMonths,
  });

  factory HiringPlan.fromJson(Map<String, dynamic> json) =>
      _$HiringPlanFromJson(json);
  Map<String, dynamic> toJson() => _$HiringPlanToJson(this);
}

@JsonSerializable()
class HiringPosition {
  final String role;
  final double salary;
  final int count;
  final String department;

  HiringPosition({
    required this.role,
    required this.salary,
    required this.count,
    required this.department,
  });

  factory HiringPosition.fromJson(Map<String, dynamic> json) =>
      _$HiringPositionFromJson(json);
  Map<String, dynamic> toJson() => _$HiringPositionToJson(this);
}

@JsonSerializable()
class HiringRisk {
  final HiringRiskType type;
  final String description;
  final RiskSeverity severity;
  final String? impact;
  final String? mitigation;

  HiringRisk({
    required this.type,
    required this.description,
    required this.severity,
    this.impact,
    this.mitigation,
  });

  factory HiringRisk.fromJson(Map<String, dynamic> json) =>
      _$HiringRiskFromJson(json);
  Map<String, dynamic> toJson() => _$HiringRiskToJson(this);
}

@JsonSerializable()
class MarketingChannel {
  final String name;
  final double budget;
  final double roi;
  final double? spend;
  final double? revenue;
  final int? conversions;
  final int? impressions;
  final double? recentPerformanceChange;

  MarketingChannel({
    required this.name,
    required this.budget,
    required this.roi,
    this.spend,
    this.revenue,
    this.conversions,
    this.impressions,
    this.recentPerformanceChange,
  });

  factory MarketingChannel.fromJson(Map<String, dynamic> json) =>
      _$MarketingChannelFromJson(json);
  Map<String, dynamic> toJson() => _$MarketingChannelToJson(this);
}

@JsonSerializable()
class ChannelPerformance {
  final String channel;
  final double roi;
  final double cac;
  final double conversionRate;
  final double? costPerAcquisition;
  final double? reachPotential;

  ChannelPerformance({
    required this.channel,
    required this.roi,
    required this.cac,
    required this.conversionRate,
    this.costPerAcquisition,
    this.reachPotential,
  });

  factory ChannelPerformance.fromJson(Map<String, dynamic> json) =>
      _$ChannelPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelPerformanceToJson(this);
}

// Enums
enum AllocationStrategy {
  @JsonValue('balanced')
  balanced,
  @JsonValue('aggressive')
  aggressive,
  @JsonValue('conservative')
  conservative,
  @JsonValue('performance_based')
  performanceBased,
}

enum RecommendationPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

enum TrendDirection {
  @JsonValue('up')
  up,
  @JsonValue('down')
  down,
  @JsonValue('stable')
  stable,
  @JsonValue('improving')
  improving,
}
