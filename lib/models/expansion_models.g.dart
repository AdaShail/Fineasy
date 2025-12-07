// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expansion_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpansionAnalysis _$ExpansionAnalysisFromJson(Map<String, dynamic> json) =>
    ExpansionAnalysis(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      type: $enumDecode(_$ExpansionTypeEnumMap, json['type']),
      marketOpportunity: MarketOpportunity.fromJson(
        json['marketOpportunity'] as Map<String, dynamic>,
      ),
      financialFeasibility: FinancialFeasibility.fromJson(
        json['financialFeasibility'] as Map<String, dynamic>,
      ),
      resourceRequirements: ResourceRequirements.fromJson(
        json['resourceRequirements'] as Map<String, dynamic>,
      ),
      timeline: ExpansionTimeline.fromJson(
        json['timeline'] as Map<String, dynamic>,
      ),
      risks:
          (json['risks'] as List<dynamic>)
              .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
              .toList(),
      recommendation: $enumDecode(
        _$ExpansionRecommendationEnumMap,
        json['recommendation'],
      ),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
    );

Map<String, dynamic> _$ExpansionAnalysisToJson(
  ExpansionAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'type': _$ExpansionTypeEnumMap[instance.type]!,
  'marketOpportunity': instance.marketOpportunity,
  'financialFeasibility': instance.financialFeasibility,
  'resourceRequirements': instance.resourceRequirements,
  'timeline': instance.timeline,
  'risks': instance.risks,
  'recommendation': _$ExpansionRecommendationEnumMap[instance.recommendation]!,
  'confidenceScore': instance.confidenceScore,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

const _$ExpansionTypeEnumMap = {
  ExpansionType.geographic: 'geographic',
  ExpansionType.productLine: 'product_line',
  ExpansionType.marketSegment: 'market_segment',
  ExpansionType.verticalIntegration: 'vertical_integration',
  ExpansionType.newMarket: 'new_market',
  ExpansionType.newProduct: 'new_product',
  ExpansionType.scaleUp: 'scale_up',
  ExpansionType.acquisition: 'acquisition',
};

const _$ExpansionRecommendationEnumMap = {
  ExpansionRecommendation.proceed: 'proceed',
  ExpansionRecommendation.proceedWithCaution: 'proceed_with_caution',
  ExpansionRecommendation.delay: 'delay',
  ExpansionRecommendation.notRecommended: 'not_recommended',
  ExpansionRecommendation.requiresMoreAnalysis: 'requires_more_analysis',
};

MarketOpportunity _$MarketOpportunityFromJson(Map<String, dynamic> json) =>
    MarketOpportunity(
      id: json['id'] as String,
      description: json['description'] as String,
      marketSize: (json['marketSize'] as num).toDouble(),
      growthRate: (json['growthRate'] as num).toDouble(),
      competitionLevel: (json['competitionLevel'] as num).toDouble(),
      targetSegments:
          (json['targetSegments'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      totalMarketSize: (json['totalMarketSize'] as num?)?.toDouble(),
      addressableMarket: (json['addressableMarket'] as num?)?.toDouble(),
      opportunitySize: json['opportunitySize'] as String?,
      marketTrends:
          (json['marketTrends'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      opportunityScore: (json['opportunityScore'] as num?)?.toDouble(),
      growthPotential: (json['growthPotential'] as num?)?.toDouble(),
      entryBarriers:
          (json['entryBarriers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      feasibilityRating: (json['feasibilityRating'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MarketOpportunityToJson(MarketOpportunity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'marketSize': instance.marketSize,
      'growthRate': instance.growthRate,
      'competitionLevel': instance.competitionLevel,
      'targetSegments': instance.targetSegments,
      'totalMarketSize': instance.totalMarketSize,
      'addressableMarket': instance.addressableMarket,
      'opportunitySize': instance.opportunitySize,
      'marketTrends': instance.marketTrends,
      'opportunityScore': instance.opportunityScore,
      'growthPotential': instance.growthPotential,
      'entryBarriers': instance.entryBarriers,
      'feasibilityRating': instance.feasibilityRating,
    };

FinancialFeasibility _$FinancialFeasibilityFromJson(
  Map<String, dynamic> json,
) => FinancialFeasibility(
  id: json['id'] as String,
  estimatedCost: (json['estimatedCost'] as num).toDouble(),
  projectedRevenue: (json['projectedRevenue'] as num).toDouble(),
  breakEvenMonths: (json['breakEvenMonths'] as num).toDouble(),
  roi: (json['roi'] as num).toDouble(),
  isFeasible: json['isFeasible'] as bool,
  investmentRequired: (json['investmentRequired'] as num?)?.toDouble(),
  availableFunds: (json['availableFunds'] as num?)?.toDouble(),
  fundingGap: (json['fundingGap'] as num?)?.toDouble(),
  revenueImpact: (json['revenueImpact'] as num?)?.toDouble(),
  feasibilityLevel: json['feasibilityLevel'] as String?,
  capitalRatio: (json['capitalRatio'] as num?)?.toDouble(),
  cashFlowBuffer: (json['cashFlowBuffer'] as num?)?.toDouble(),
  debtToEquityRatio: (json['debtToEquityRatio'] as num?)?.toDouble(),
  feasibilityRating: (json['feasibilityRating'] as num?)?.toDouble(),
);

Map<String, dynamic> _$FinancialFeasibilityToJson(
  FinancialFeasibility instance,
) => <String, dynamic>{
  'id': instance.id,
  'estimatedCost': instance.estimatedCost,
  'projectedRevenue': instance.projectedRevenue,
  'breakEvenMonths': instance.breakEvenMonths,
  'roi': instance.roi,
  'isFeasible': instance.isFeasible,
  'investmentRequired': instance.investmentRequired,
  'availableFunds': instance.availableFunds,
  'fundingGap': instance.fundingGap,
  'revenueImpact': instance.revenueImpact,
  'feasibilityLevel': instance.feasibilityLevel,
  'capitalRatio': instance.capitalRatio,
  'cashFlowBuffer': instance.cashFlowBuffer,
  'debtToEquityRatio': instance.debtToEquityRatio,
  'feasibilityRating': instance.feasibilityRating,
};

ResourceRequirements _$ResourceRequirementsFromJson(
  Map<String, dynamic> json,
) => ResourceRequirements(
  id: json['id'] as String,
  staffRequired: (json['staffRequired'] as num).toInt(),
  capitalRequired: (json['capitalRequired'] as num).toDouble(),
  skillsNeeded:
      (json['skillsNeeded'] as List<dynamic>).map((e) => e as String).toList(),
  infrastructureNeeded:
      (json['infrastructureNeeded'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  additionalStaff: (json['additionalStaff'] as num?)?.toInt(),
  infrastructureCost: (json['infrastructureCost'] as num?)?.toDouble(),
  operationalCost: (json['operationalCost'] as num?)?.toDouble(),
  technologyRequirements:
      (json['technologyRequirements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  skillRequirements:
      (json['skillRequirements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  capacityGap: (json['capacityGap'] as num?)?.toDouble(),
  timelineFeasible: json['timelineFeasible'] as bool?,
  skillGaps:
      (json['skillGaps'] as List<dynamic>?)?.map((e) => e as String).toList(),
  resourceAvailability: (json['resourceAvailability'] as num?)?.toDouble(),
  feasibilityRating: (json['feasibilityRating'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ResourceRequirementsToJson(
  ResourceRequirements instance,
) => <String, dynamic>{
  'id': instance.id,
  'staffRequired': instance.staffRequired,
  'capitalRequired': instance.capitalRequired,
  'skillsNeeded': instance.skillsNeeded,
  'infrastructureNeeded': instance.infrastructureNeeded,
  'additionalStaff': instance.additionalStaff,
  'infrastructureCost': instance.infrastructureCost,
  'operationalCost': instance.operationalCost,
  'technologyRequirements': instance.technologyRequirements,
  'skillRequirements': instance.skillRequirements,
  'capacityGap': instance.capacityGap,
  'timelineFeasible': instance.timelineFeasible,
  'skillGaps': instance.skillGaps,
  'resourceAvailability': instance.resourceAvailability,
  'feasibilityRating': instance.feasibilityRating,
};

ExpansionTimeline _$ExpansionTimelineFromJson(Map<String, dynamic> json) =>
    ExpansionTimeline(
      id: json['id'] as String,
      preparationWeeks: (json['preparationWeeks'] as num).toInt(),
      implementationWeeks: (json['implementationWeeks'] as num).toInt(),
      stabilizationWeeks: (json['stabilizationWeeks'] as num).toInt(),
      milestones:
          (json['milestones'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      planningPhase: (json['planningPhase'] as num?)?.toInt(),
      implementationPhase: (json['implementationPhase'] as num?)?.toInt(),
      rampUpPhase: (json['rampUpPhase'] as num?)?.toInt(),
      totalTimelineWeeks: (json['totalTimelineWeeks'] as num?)?.toInt(),
      keyMilestones:
          (json['keyMilestones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$ExpansionTimelineToJson(ExpansionTimeline instance) =>
    <String, dynamic>{
      'id': instance.id,
      'preparationWeeks': instance.preparationWeeks,
      'implementationWeeks': instance.implementationWeeks,
      'stabilizationWeeks': instance.stabilizationWeeks,
      'milestones': instance.milestones,
      'planningPhase': instance.planningPhase,
      'implementationPhase': instance.implementationPhase,
      'rampUpPhase': instance.rampUpPhase,
      'totalTimelineWeeks': instance.totalTimelineWeeks,
      'keyMilestones': instance.keyMilestones,
    };

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) => RiskFactor(
  id: json['id'] as String,
  description: json['description'] as String,
  level: $enumDecode(_$RiskLevelEnumMap, json['level']),
  probability: (json['probability'] as num).toDouble(),
  mitigation: json['mitigation'] as String,
  riskLevel: $enumDecodeNullable(_$RiskLevelEnumMap, json['riskLevel']),
  impactScore: (json['impactScore'] as num?)?.toDouble(),
  mitigationStrategies:
      (json['mitigationStrategies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  type: json['type'] as String?,
);

Map<String, dynamic> _$RiskFactorToJson(RiskFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'level': _$RiskLevelEnumMap[instance.level]!,
      'probability': instance.probability,
      'mitigation': instance.mitigation,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel],
      'impactScore': instance.impactScore,
      'mitigationStrategies': instance.mitigationStrategies,
      'type': instance.type,
    };

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.medium: 'medium',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
};

ExpansionPlan _$ExpansionPlanFromJson(
  Map<String, dynamic> json,
) => ExpansionPlan(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  type: $enumDecode(_$ExpansionTypeEnumMap, json['type']),
  description: json['description'] as String,
  estimatedCost: (json['estimatedCost'] as num).toDouble(),
  targetDate: DateTime.parse(json['targetDate'] as String),
  requiredCapital: (json['requiredCapital'] as num?)?.toDouble(),
  estimatedMonthlyCosts: (json['estimatedMonthlyCosts'] as num?)?.toDouble(),
  requiredCapacityIncrease:
      (json['requiredCapacityIncrease'] as num?)?.toDouble(),
  estimatedTimelineMonths: (json['estimatedTimelineMonths'] as num?)?.toInt(),
  requiredSkills:
      (json['requiredSkills'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$ExpansionPlanToJson(ExpansionPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'type': _$ExpansionTypeEnumMap[instance.type]!,
      'description': instance.description,
      'estimatedCost': instance.estimatedCost,
      'targetDate': instance.targetDate.toIso8601String(),
      'requiredCapital': instance.requiredCapital,
      'estimatedMonthlyCosts': instance.estimatedMonthlyCosts,
      'requiredCapacityIncrease': instance.requiredCapacityIncrease,
      'estimatedTimelineMonths': instance.estimatedTimelineMonths,
      'requiredSkills': instance.requiredSkills,
    };

BusinessFinancialState _$BusinessFinancialStateFromJson(
  Map<String, dynamic> json,
) => BusinessFinancialState(
  currentRevenue: (json['currentRevenue'] as num).toDouble(),
  currentExpenses: (json['currentExpenses'] as num).toDouble(),
  cashReserves: (json['cashReserves'] as num).toDouble(),
  debtLevel: (json['debtLevel'] as num).toDouble(),
  profitMargin: (json['profitMargin'] as num).toDouble(),
  cashBalance: (json['cashBalance'] as num?)?.toDouble(),
  creditLimit: (json['creditLimit'] as num?)?.toDouble(),
  monthlyRevenue: (json['monthlyRevenue'] as num?)?.toDouble(),
  monthlyExpenses: (json['monthlyExpenses'] as num?)?.toDouble(),
  totalDebt: (json['totalDebt'] as num?)?.toDouble(),
  equity: (json['equity'] as num?)?.toDouble(),
  operationalCapacity: (json['operationalCapacity'] as num?)?.toDouble(),
  availableSkills:
      (json['availableSkills'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$BusinessFinancialStateToJson(
  BusinessFinancialState instance,
) => <String, dynamic>{
  'currentRevenue': instance.currentRevenue,
  'currentExpenses': instance.currentExpenses,
  'cashReserves': instance.cashReserves,
  'debtLevel': instance.debtLevel,
  'profitMargin': instance.profitMargin,
  'cashBalance': instance.cashBalance,
  'creditLimit': instance.creditLimit,
  'monthlyRevenue': instance.monthlyRevenue,
  'monthlyExpenses': instance.monthlyExpenses,
  'totalDebt': instance.totalDebt,
  'equity': instance.equity,
  'operationalCapacity': instance.operationalCapacity,
  'availableSkills': instance.availableSkills,
};

MarketConditions _$MarketConditionsFromJson(Map<String, dynamic> json) =>
    MarketConditions(
      growthRate: (json['growthRate'] as num).toDouble(),
      competitionIntensity: (json['competitionIntensity'] as num).toDouble(),
      marketSaturation: (json['marketSaturation'] as num).toDouble(),
      trends:
          (json['trends'] as List<dynamic>).map((e) => e as String).toList(),
      targetMarketSize: (json['targetMarketSize'] as num?)?.toDouble(),
      marketGrowthRate: (json['marketGrowthRate'] as num?)?.toDouble(),
      regulatoryComplexity: (json['regulatoryComplexity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MarketConditionsToJson(MarketConditions instance) =>
    <String, dynamic>{
      'growthRate': instance.growthRate,
      'competitionIntensity': instance.competitionIntensity,
      'marketSaturation': instance.marketSaturation,
      'trends': instance.trends,
      'targetMarketSize': instance.targetMarketSize,
      'marketGrowthRate': instance.marketGrowthRate,
      'regulatoryComplexity': instance.regulatoryComplexity,
    };

ExpansionFeasibilityAnalysis _$ExpansionFeasibilityAnalysisFromJson(
  Map<String, dynamic> json,
) => ExpansionFeasibilityAnalysis(
  id: json['id'] as String,
  plan: ExpansionPlan.fromJson(json['plan'] as Map<String, dynamic>),
  marketFeasibility: MarketOpportunity.fromJson(
    json['marketFeasibility'] as Map<String, dynamic>,
  ),
  financialFeasibility: FinancialFeasibility.fromJson(
    json['financialFeasibility'] as Map<String, dynamic>,
  ),
  operationalFeasibility: ResourceRequirements.fromJson(
    json['operationalFeasibility'] as Map<String, dynamic>,
  ),
  risks:
      (json['risks'] as List<dynamic>)
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
  recommendation: $enumDecode(
    _$ExpansionRecommendationEnumMap,
    json['recommendation'],
  ),
  confidenceScore: (json['confidenceScore'] as num).toDouble(),
);

Map<String, dynamic> _$ExpansionFeasibilityAnalysisToJson(
  ExpansionFeasibilityAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'plan': instance.plan,
  'marketFeasibility': instance.marketFeasibility,
  'financialFeasibility': instance.financialFeasibility,
  'operationalFeasibility': instance.operationalFeasibility,
  'risks': instance.risks,
  'recommendation': _$ExpansionRecommendationEnumMap[instance.recommendation]!,
  'confidenceScore': instance.confidenceScore,
};

HiringRequest _$HiringRequestFromJson(Map<String, dynamic> json) =>
    HiringRequest(
      id: json['id'] as String,
      position: json['position'] as String,
      department: json['department'] as String,
      salary: (json['salary'] as num).toDouble(),
      justification: json['justification'] as String,
      expectedSalary: (json['expectedSalary'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$HiringRequestToJson(HiringRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'position': instance.position,
      'department': instance.department,
      'salary': instance.salary,
      'justification': instance.justification,
      'expectedSalary': instance.expectedSalary,
    };

FinancialImpact _$FinancialImpactFromJson(Map<String, dynamic> json) =>
    FinancialImpact(
      totalCost: (json['totalCost'] as num).toDouble(),
      ongoingCosts: (json['ongoingCosts'] as num).toDouble(),
      oneTimeCosts: (json['oneTimeCosts'] as num).toDouble(),
      annualSalaryCost: (json['annualSalaryCost'] as num?)?.toDouble(),
      hiringCosts: (json['hiringCosts'] as num?)?.toDouble(),
      totalFirstYearCost: (json['totalFirstYearCost'] as num?)?.toDouble(),
      projectedRevenueImpact:
          (json['projectedRevenueImpact'] as num?)?.toDouble(),
      netImpact: (json['netImpact'] as num?)?.toDouble(),
      paybackMonths: (json['paybackMonths'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FinancialImpactToJson(FinancialImpact instance) =>
    <String, dynamic>{
      'totalCost': instance.totalCost,
      'ongoingCosts': instance.ongoingCosts,
      'oneTimeCosts': instance.oneTimeCosts,
      'annualSalaryCost': instance.annualSalaryCost,
      'hiringCosts': instance.hiringCosts,
      'totalFirstYearCost': instance.totalFirstYearCost,
      'projectedRevenueImpact': instance.projectedRevenueImpact,
      'netImpact': instance.netImpact,
      'paybackMonths': instance.paybackMonths,
    };

ProductivityAnalysis _$ProductivityAnalysisFromJson(
  Map<String, dynamic> json,
) => ProductivityAnalysis(
  expectedProductivityGain:
      (json['expectedProductivityGain'] as num).toDouble(),
  timeToProductivity: (json['timeToProductivity'] as num).toDouble(),
  impactOnTeam: (json['impactOnTeam'] as num).toDouble(),
  currentWorkloadLevel: (json['currentWorkloadLevel'] as num?)?.toDouble(),
  workloadReduction: (json['workloadReduction'] as num?)?.toDouble(),
  qualityImprovement: (json['qualityImprovement'] as num?)?.toDouble(),
  efficiencyGain: (json['efficiencyGain'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ProductivityAnalysisToJson(
  ProductivityAnalysis instance,
) => <String, dynamic>{
  'expectedProductivityGain': instance.expectedProductivityGain,
  'timeToProductivity': instance.timeToProductivity,
  'impactOnTeam': instance.impactOnTeam,
  'currentWorkloadLevel': instance.currentWorkloadLevel,
  'workloadReduction': instance.workloadReduction,
  'qualityImprovement': instance.qualityImprovement,
  'efficiencyGain': instance.efficiencyGain,
};

HiringROI _$HiringROIFromJson(Map<String, dynamic> json) => HiringROI(
  roi: (json['roi'] as num).toDouble(),
  paybackPeriod: (json['paybackPeriod'] as num).toDouble(),
  netBenefit: (json['netBenefit'] as num).toDouble(),
  firstYearROI: (json['firstYearROI'] as num?)?.toDouble(),
  threeYearROI: (json['threeYearROI'] as num?)?.toDouble(),
  breakEvenMonths: (json['breakEvenMonths'] as num?)?.toInt(),
  confidenceLevel: (json['confidenceLevel'] as num?)?.toDouble(),
);

Map<String, dynamic> _$HiringROIToJson(HiringROI instance) => <String, dynamic>{
  'roi': instance.roi,
  'paybackPeriod': instance.paybackPeriod,
  'netBenefit': instance.netBenefit,
  'firstYearROI': instance.firstYearROI,
  'threeYearROI': instance.threeYearROI,
  'breakEvenMonths': instance.breakEvenMonths,
  'confidenceLevel': instance.confidenceLevel,
};

HiringTiming _$HiringTimingFromJson(Map<String, dynamic> json) => HiringTiming(
  recommendation: $enumDecode(
    _$TimingRecommendationEnumMap,
    json['recommendation'],
  ),
  reasoning: json['reasoning'] as String,
  suggestedDate: DateTime.parse(json['suggestedDate'] as String),
  optimalMonth: (json['optimalMonth'] as num?)?.toInt(),
);

Map<String, dynamic> _$HiringTimingToJson(HiringTiming instance) =>
    <String, dynamic>{
      'recommendation': _$TimingRecommendationEnumMap[instance.recommendation]!,
      'reasoning': instance.reasoning,
      'suggestedDate': instance.suggestedDate.toIso8601String(),
      'optimalMonth': instance.optimalMonth,
    };

const _$TimingRecommendationEnumMap = {
  TimingRecommendation.immediate: 'immediate',
  TimingRecommendation.withinMonth: 'within_month',
  TimingRecommendation.withinQuarter: 'within_quarter',
  TimingRecommendation.nextYear: 'next_year',
  TimingRecommendation.waitForImprovement: 'wait_for_improvement',
};

MarketingOptimization _$MarketingOptimizationFromJson(
  Map<String, dynamic> json,
) => MarketingOptimization(
  id: json['id'] as String,
  acquisitionAnalysis: CustomerAcquisitionAnalysis.fromJson(
    json['acquisitionAnalysis'] as Map<String, dynamic>,
  ),
  budgetAllocation: BudgetAllocation.fromJson(
    json['budgetAllocation'] as Map<String, dynamic>,
  ),
  recommendations:
      (json['recommendations'] as List<dynamic>)
          .map(
            (e) => MarketingRecommendation.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  expectedROI: (json['expectedROI'] as num).toDouble(),
);

Map<String, dynamic> _$MarketingOptimizationToJson(
  MarketingOptimization instance,
) => <String, dynamic>{
  'id': instance.id,
  'acquisitionAnalysis': instance.acquisitionAnalysis,
  'budgetAllocation': instance.budgetAllocation,
  'recommendations': instance.recommendations,
  'expectedROI': instance.expectedROI,
};

CustomerAcquisitionAnalysis _$CustomerAcquisitionAnalysisFromJson(
  Map<String, dynamic> json,
) => CustomerAcquisitionAnalysis(
  currentCAC: (json['currentCAC'] as num).toDouble(),
  targetCAC: (json['targetCAC'] as num).toDouble(),
  customerLifetimeValue: (json['customerLifetimeValue'] as num).toDouble(),
  channelPerformance: (json['channelPerformance'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  totalCustomersAcquired: (json['totalCustomersAcquired'] as num?)?.toInt(),
  averageCAC: (json['averageCAC'] as num?)?.toDouble(),
  cacToLtvRatio: (json['cacToLtvRatio'] as num?)?.toDouble(),
  acquisitionTrend: json['acquisitionTrend'] as String?,
);

Map<String, dynamic> _$CustomerAcquisitionAnalysisToJson(
  CustomerAcquisitionAnalysis instance,
) => <String, dynamic>{
  'currentCAC': instance.currentCAC,
  'targetCAC': instance.targetCAC,
  'customerLifetimeValue': instance.customerLifetimeValue,
  'channelPerformance': instance.channelPerformance,
  'totalCustomersAcquired': instance.totalCustomersAcquired,
  'averageCAC': instance.averageCAC,
  'cacToLtvRatio': instance.cacToLtvRatio,
  'acquisitionTrend': instance.acquisitionTrend,
};

BudgetAllocation _$BudgetAllocationFromJson(Map<String, dynamic> json) =>
    BudgetAllocation(
      channelBudgets: (json['channelBudgets'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      totalBudget: (json['totalBudget'] as num).toDouble(),
      strategy: $enumDecode(_$AllocationStrategyEnumMap, json['strategy']),
      channelAllocations: (json['channelAllocations'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, (e as num).toDouble())),
      allocationStrategy: json['allocationStrategy'] as String?,
      expectedImprovement: (json['expectedImprovement'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BudgetAllocationToJson(BudgetAllocation instance) =>
    <String, dynamic>{
      'channelBudgets': instance.channelBudgets,
      'totalBudget': instance.totalBudget,
      'strategy': _$AllocationStrategyEnumMap[instance.strategy]!,
      'channelAllocations': instance.channelAllocations,
      'allocationStrategy': instance.allocationStrategy,
      'expectedImprovement': instance.expectedImprovement,
    };

const _$AllocationStrategyEnumMap = {
  AllocationStrategy.balanced: 'balanced',
  AllocationStrategy.aggressive: 'aggressive',
  AllocationStrategy.conservative: 'conservative',
  AllocationStrategy.performanceBased: 'performance_based',
};

MarketingRecommendation _$MarketingRecommendationFromJson(
  Map<String, dynamic> json,
) => MarketingRecommendation(
  id: json['id'] as String,
  type: $enumDecode(_$RecommendationTypeEnumMap, json['type']),
  description: json['description'] as String,
  priority: (json['priority'] as num).toDouble(),
  expectedImpact: (json['expectedImpact'] as num).toDouble(),
);

Map<String, dynamic> _$MarketingRecommendationToJson(
  MarketingRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$RecommendationTypeEnumMap[instance.type]!,
  'description': instance.description,
  'priority': instance.priority,
  'expectedImpact': instance.expectedImpact,
};

const _$RecommendationTypeEnumMap = {
  RecommendationType.positioning: 'positioning',
  RecommendationType.differentiation: 'differentiation',
  RecommendationType.competitive: 'competitive',
  RecommendationType.increaseSpend: 'increase_spend',
  RecommendationType.decreaseSpend: 'decrease_spend',
  RecommendationType.optimizeOrPause: 'optimize_or_pause',
  RecommendationType.reallocateBudget: 'reallocate_budget',
};

BusinessProjections _$BusinessProjectionsFromJson(Map<String, dynamic> json) =>
    BusinessProjections(
      projectedRevenue: (json['projectedRevenue'] as num).toDouble(),
      projectedExpenses: (json['projectedExpenses'] as num).toDouble(),
      projectedProfit: (json['projectedProfit'] as num).toDouble(),
      timeHorizonMonths: (json['timeHorizonMonths'] as num).toInt(),
      annualRevenue: (json['annualRevenue'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BusinessProjectionsToJson(
  BusinessProjections instance,
) => <String, dynamic>{
  'projectedRevenue': instance.projectedRevenue,
  'projectedExpenses': instance.projectedExpenses,
  'projectedProfit': instance.projectedProfit,
  'timeHorizonMonths': instance.timeHorizonMonths,
  'annualRevenue': instance.annualRevenue,
};

CashFlowImpact _$CashFlowImpactFromJson(Map<String, dynamic> json) =>
    CashFlowImpact(
      immediateImpact: (json['immediateImpact'] as num).toDouble(),
      monthlyImpact: (json['monthlyImpact'] as num).toDouble(),
      cumulativeImpact: (json['cumulativeImpact'] as num).toDouble(),
      monthlyCostIncrease: (json['monthlyCostIncrease'] as num?)?.toDouble(),
      monthlyRevenueIncrease:
          (json['monthlyRevenueIncrease'] as num?)?.toDouble(),
      netMonthlyCashFlow: (json['netMonthlyCashFlow'] as num?)?.toDouble(),
      projectedCashFlow:
          (json['projectedCashFlow'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList(),
      cashFlowRisk: json['cashFlowRisk'] as String?,
    );

Map<String, dynamic> _$CashFlowImpactToJson(CashFlowImpact instance) =>
    <String, dynamic>{
      'immediateImpact': instance.immediateImpact,
      'monthlyImpact': instance.monthlyImpact,
      'cumulativeImpact': instance.cumulativeImpact,
      'monthlyCostIncrease': instance.monthlyCostIncrease,
      'monthlyRevenueIncrease': instance.monthlyRevenueIncrease,
      'netMonthlyCashFlow': instance.netMonthlyCashFlow,
      'projectedCashFlow': instance.projectedCashFlow,
      'cashFlowRisk': instance.cashFlowRisk,
    };

BusinessGoals _$BusinessGoalsFromJson(Map<String, dynamic> json) =>
    BusinessGoals(
      revenueTarget: (json['revenueTarget'] as num).toDouble(),
      profitTarget: (json['profitTarget'] as num).toDouble(),
      marketShareTarget: (json['marketShareTarget'] as num).toDouble(),
      timeframeMonths: (json['timeframeMonths'] as num).toInt(),
      primaryGoal: json['primaryGoal'] as String?,
    );

Map<String, dynamic> _$BusinessGoalsToJson(BusinessGoals instance) =>
    <String, dynamic>{
      'revenueTarget': instance.revenueTarget,
      'profitTarget': instance.profitTarget,
      'marketShareTarget': instance.marketShareTarget,
      'timeframeMonths': instance.timeframeMonths,
      'primaryGoal': instance.primaryGoal,
    };

HistoricalMarketingData _$HistoricalMarketingDataFromJson(
  Map<String, dynamic> json,
) => HistoricalMarketingData(
  channelROI: (json['channelROI'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  channelConversions: (json['channelConversions'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  channelCosts: (json['channelCosts'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  dataPointsCount: (json['dataPointsCount'] as num).toInt(),
  channelData: json['channelData'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$HistoricalMarketingDataToJson(
  HistoricalMarketingData instance,
) => <String, dynamic>{
  'channelROI': instance.channelROI,
  'channelConversions': instance.channelConversions,
  'channelCosts': instance.channelCosts,
  'dataPointsCount': instance.dataPointsCount,
  'channelData': instance.channelData,
};

MarketingProjections _$MarketingProjectionsFromJson(
  Map<String, dynamic> json,
) => MarketingProjections(
  projectedCustomers: (json['projectedCustomers'] as num).toDouble(),
  projectedRevenue: (json['projectedRevenue'] as num).toDouble(),
  projectedROI: (json['projectedROI'] as num).toDouble(),
  channelProjections: (json['channelProjections'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  expectedRevenue: (json['expectedRevenue'] as num?)?.toDouble(),
  expectedLeads: (json['expectedLeads'] as num?)?.toInt(),
  expectedConversions: (json['expectedConversions'] as num?)?.toInt(),
  expectedReach: (json['expectedReach'] as num?)?.toInt(),
  projectedAt:
      json['projectedAt'] == null
          ? null
          : DateTime.parse(json['projectedAt'] as String),
);

Map<String, dynamic> _$MarketingProjectionsToJson(
  MarketingProjections instance,
) => <String, dynamic>{
  'projectedCustomers': instance.projectedCustomers,
  'projectedRevenue': instance.projectedRevenue,
  'projectedROI': instance.projectedROI,
  'channelProjections': instance.channelProjections,
  'expectedRevenue': instance.expectedRevenue,
  'expectedLeads': instance.expectedLeads,
  'expectedConversions': instance.expectedConversions,
  'expectedReach': instance.expectedReach,
  'projectedAt': instance.projectedAt?.toIso8601String(),
};

OptimizationOpportunity _$OptimizationOpportunityFromJson(
  Map<String, dynamic> json,
) => OptimizationOpportunity(
  id: json['id'] as String,
  description: json['description'] as String,
  potentialSavings: (json['potentialSavings'] as num).toDouble(),
  implementationCost: (json['implementationCost'] as num).toDouble(),
  priority: (json['priority'] as num).toDouble(),
  type: json['type'] as String?,
  impact: (json['impact'] as num?)?.toDouble(),
  recommendation: json['recommendation'] as String?,
  potentialGains: (json['potentialGains'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
);

Map<String, dynamic> _$OptimizationOpportunityToJson(
  OptimizationOpportunity instance,
) => <String, dynamic>{
  'id': instance.id,
  'description': instance.description,
  'potentialSavings': instance.potentialSavings,
  'implementationCost': instance.implementationCost,
  'priority': instance.priority,
  'type': instance.type,
  'impact': instance.impact,
  'recommendation': instance.recommendation,
  'potentialGains': instance.potentialGains,
};

ExpansionRisk _$ExpansionRiskFromJson(Map<String, dynamic> json) =>
    ExpansionRisk(
      id: json['id'] as String,
      description: json['description'] as String,
      level: $enumDecode(_$RiskLevelEnumMap, json['level']),
      probability: (json['probability'] as num).toDouble(),
      mitigation: json['mitigation'] as String,
      impact: (json['impact'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ExpansionRiskToJson(ExpansionRisk instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'level': _$RiskLevelEnumMap[instance.level]!,
      'probability': instance.probability,
      'mitigation': instance.mitigation,
      'impact': instance.impact,
    };

MarketFeasibility _$MarketFeasibilityFromJson(Map<String, dynamic> json) =>
    MarketFeasibility(
      marketSize: (json['marketSize'] as num).toDouble(),
      growthPotential: (json['growthPotential'] as num).toDouble(),
      competitionLevel: (json['competitionLevel'] as num).toDouble(),
      isFeasible: json['isFeasible'] as bool,
    );

Map<String, dynamic> _$MarketFeasibilityToJson(MarketFeasibility instance) =>
    <String, dynamic>{
      'marketSize': instance.marketSize,
      'growthPotential': instance.growthPotential,
      'competitionLevel': instance.competitionLevel,
      'isFeasible': instance.isFeasible,
    };

OperationalFeasibility _$OperationalFeasibilityFromJson(
  Map<String, dynamic> json,
) => OperationalFeasibility(
  hasRequiredSkills: json['hasRequiredSkills'] as bool,
  hasInfrastructure: json['hasInfrastructure'] as bool,
  implementationComplexity:
      (json['implementationComplexity'] as num).toDouble(),
  isFeasible: json['isFeasible'] as bool,
);

Map<String, dynamic> _$OperationalFeasibilityToJson(
  OperationalFeasibility instance,
) => <String, dynamic>{
  'hasRequiredSkills': instance.hasRequiredSkills,
  'hasInfrastructure': instance.hasInfrastructure,
  'implementationComplexity': instance.implementationComplexity,
  'isFeasible': instance.isFeasible,
};

HiringPlan _$HiringPlanFromJson(Map<String, dynamic> json) => HiringPlan(
  id: json['id'] as String,
  positions:
      (json['positions'] as List<dynamic>)
          .map((e) => HiringPosition.fromJson(e as Map<String, dynamic>))
          .toList(),
  totalCost: (json['totalCost'] as num).toDouble(),
  timelineMonths: (json['timelineMonths'] as num).toInt(),
);

Map<String, dynamic> _$HiringPlanToJson(HiringPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'positions': instance.positions,
      'totalCost': instance.totalCost,
      'timelineMonths': instance.timelineMonths,
    };

HiringPosition _$HiringPositionFromJson(Map<String, dynamic> json) =>
    HiringPosition(
      role: json['role'] as String,
      salary: (json['salary'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      department: json['department'] as String,
    );

Map<String, dynamic> _$HiringPositionToJson(HiringPosition instance) =>
    <String, dynamic>{
      'role': instance.role,
      'salary': instance.salary,
      'count': instance.count,
      'department': instance.department,
    };

HiringRisk _$HiringRiskFromJson(Map<String, dynamic> json) => HiringRisk(
  type: $enumDecode(_$HiringRiskTypeEnumMap, json['type']),
  description: json['description'] as String,
  severity: $enumDecode(_$RiskSeverityEnumMap, json['severity']),
  impact: json['impact'] as String?,
  mitigation: json['mitigation'] as String?,
);

Map<String, dynamic> _$HiringRiskToJson(HiringRisk instance) =>
    <String, dynamic>{
      'type': _$HiringRiskTypeEnumMap[instance.type]!,
      'description': instance.description,
      'severity': _$RiskSeverityEnumMap[instance.severity]!,
      'impact': instance.impact,
      'mitigation': instance.mitigation,
    };

const _$HiringRiskTypeEnumMap = {
  HiringRiskType.financial: 'financial',
  HiringRiskType.culturalFit: 'cultural_fit',
  HiringRiskType.skillMismatch: 'skill_mismatch',
  HiringRiskType.marketConditions: 'market_conditions',
  HiringRiskType.cashFlow: 'cash_flow',
  HiringRiskType.market: 'market',
};

const _$RiskSeverityEnumMap = {
  RiskSeverity.low: 'low',
  RiskSeverity.medium: 'medium',
  RiskSeverity.high: 'high',
  RiskSeverity.critical: 'critical',
};

MarketingChannel _$MarketingChannelFromJson(Map<String, dynamic> json) =>
    MarketingChannel(
      name: json['name'] as String,
      budget: (json['budget'] as num).toDouble(),
      roi: (json['roi'] as num).toDouble(),
      spend: (json['spend'] as num?)?.toDouble(),
      revenue: (json['revenue'] as num?)?.toDouble(),
      conversions: (json['conversions'] as num?)?.toInt(),
      impressions: (json['impressions'] as num?)?.toInt(),
      recentPerformanceChange:
          (json['recentPerformanceChange'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MarketingChannelToJson(MarketingChannel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'budget': instance.budget,
      'roi': instance.roi,
      'spend': instance.spend,
      'revenue': instance.revenue,
      'conversions': instance.conversions,
      'impressions': instance.impressions,
      'recentPerformanceChange': instance.recentPerformanceChange,
    };

ChannelPerformance _$ChannelPerformanceFromJson(Map<String, dynamic> json) =>
    ChannelPerformance(
      channel: json['channel'] as String,
      roi: (json['roi'] as num).toDouble(),
      cac: (json['cac'] as num).toDouble(),
      conversionRate: (json['conversionRate'] as num).toDouble(),
      costPerAcquisition: (json['costPerAcquisition'] as num?)?.toDouble(),
      reachPotential: (json['reachPotential'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ChannelPerformanceToJson(ChannelPerformance instance) =>
    <String, dynamic>{
      'channel': instance.channel,
      'roi': instance.roi,
      'cac': instance.cac,
      'conversionRate': instance.conversionRate,
      'costPerAcquisition': instance.costPerAcquisition,
      'reachPotential': instance.reachPotential,
    };
