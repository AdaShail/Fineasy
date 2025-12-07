// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_behavior_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerPaymentPattern _$CustomerPaymentPatternFromJson(
  Map<String, dynamic> json,
) => CustomerPaymentPattern(
  customerId: json['customerId'] as String,
  businessId: json['businessId'] as String,
  behavior: $enumDecode(_$PaymentBehaviorEnumMap, json['behavior']),
  averagePaymentDelay: (json['averagePaymentDelay'] as num).toDouble(),
  onTimePaymentRate: (json['onTimePaymentRate'] as num).toDouble(),
  earlyPaymentRate: (json['earlyPaymentRate'] as num).toDouble(),
  latePaymentRate: (json['latePaymentRate'] as num).toDouble(),
  totalInvoices: (json['totalInvoices'] as num).toInt(),
  paidInvoices: (json['paidInvoices'] as num).toInt(),
  overdueInvoices: (json['overdueInvoices'] as num).toInt(),
  averageInvoiceAmount: (json['averageInvoiceAmount'] as num).toDouble(),
  totalPaidAmount: (json['totalPaidAmount'] as num).toDouble(),
  lastPaymentDate:
      json['lastPaymentDate'] == null
          ? null
          : DateTime.parse(json['lastPaymentDate'] as String),
  firstTransactionDate:
      json['firstTransactionDate'] == null
          ? null
          : DateTime.parse(json['firstTransactionDate'] as String),
  daysSinceLastPayment: (json['daysSinceLastPayment'] as num).toInt(),
  paymentDelayTrend:
      (json['paymentDelayTrend'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$CustomerPaymentPatternToJson(
  CustomerPaymentPattern instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'businessId': instance.businessId,
  'behavior': _$PaymentBehaviorEnumMap[instance.behavior]!,
  'averagePaymentDelay': instance.averagePaymentDelay,
  'onTimePaymentRate': instance.onTimePaymentRate,
  'earlyPaymentRate': instance.earlyPaymentRate,
  'latePaymentRate': instance.latePaymentRate,
  'totalInvoices': instance.totalInvoices,
  'paidInvoices': instance.paidInvoices,
  'overdueInvoices': instance.overdueInvoices,
  'averageInvoiceAmount': instance.averageInvoiceAmount,
  'totalPaidAmount': instance.totalPaidAmount,
  'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
  'firstTransactionDate': instance.firstTransactionDate?.toIso8601String(),
  'daysSinceLastPayment': instance.daysSinceLastPayment,
  'paymentDelayTrend': instance.paymentDelayTrend,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

const _$PaymentBehaviorEnumMap = {
  PaymentBehavior.excellent: 'excellent',
  PaymentBehavior.good: 'good',
  PaymentBehavior.average: 'average',
  PaymentBehavior.poor: 'poor',
  PaymentBehavior.problematic: 'problematic',
};

CustomerLifetimeValue _$CustomerLifetimeValueFromJson(
  Map<String, dynamic> json,
) => CustomerLifetimeValue(
  customerId: json['customerId'] as String,
  businessId: json['businessId'] as String,
  currentValue: (json['currentValue'] as num).toDouble(),
  predictedValue: (json['predictedValue'] as num).toDouble(),
  monthlyAverageRevenue: (json['monthlyAverageRevenue'] as num).toDouble(),
  profitMargin: (json['profitMargin'] as num).toDouble(),
  relationshipDurationMonths:
      (json['relationshipDurationMonths'] as num).toInt(),
  acquisitionCost: (json['acquisitionCost'] as num).toDouble(),
  retentionCost: (json['retentionCost'] as num).toDouble(),
  netValue: (json['netValue'] as num).toDouble(),
  roi: (json['roi'] as num).toDouble(),
  monthlyRevenueTrend:
      (json['monthlyRevenueTrend'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$CustomerLifetimeValueToJson(
  CustomerLifetimeValue instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'businessId': instance.businessId,
  'currentValue': instance.currentValue,
  'predictedValue': instance.predictedValue,
  'monthlyAverageRevenue': instance.monthlyAverageRevenue,
  'profitMargin': instance.profitMargin,
  'relationshipDurationMonths': instance.relationshipDurationMonths,
  'acquisitionCost': instance.acquisitionCost,
  'retentionCost': instance.retentionCost,
  'netValue': instance.netValue,
  'roi': instance.roi,
  'monthlyRevenueTrend': instance.monthlyRevenueTrend,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

CustomerSatisfactionAnalysis _$CustomerSatisfactionAnalysisFromJson(
  Map<String, dynamic> json,
) => CustomerSatisfactionAnalysis(
  customerId: json['customerId'] as String,
  businessId: json['businessId'] as String,
  level: $enumDecode(_$SatisfactionLevelEnumMap, json['level']),
  score: (json['score'] as num).toDouble(),
  totalInteractions: (json['totalInteractions'] as num).toInt(),
  positiveInteractions: (json['positiveInteractions'] as num).toInt(),
  negativeInteractions: (json['negativeInteractions'] as num).toInt(),
  neutralInteractions: (json['neutralInteractions'] as num).toInt(),
  responseTime: (json['responseTime'] as num).toDouble(),
  complaintCount: (json['complaintCount'] as num).toInt(),
  resolvedComplaints: (json['resolvedComplaints'] as num).toInt(),
  resolutionTime: (json['resolutionTime'] as num).toDouble(),
  satisfactionFactors:
      (json['satisfactionFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  improvementAreas:
      (json['improvementAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  lastInteractionDate: DateTime.parse(json['lastInteractionDate'] as String),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$CustomerSatisfactionAnalysisToJson(
  CustomerSatisfactionAnalysis instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'businessId': instance.businessId,
  'level': _$SatisfactionLevelEnumMap[instance.level]!,
  'score': instance.score,
  'totalInteractions': instance.totalInteractions,
  'positiveInteractions': instance.positiveInteractions,
  'negativeInteractions': instance.negativeInteractions,
  'neutralInteractions': instance.neutralInteractions,
  'responseTime': instance.responseTime,
  'complaintCount': instance.complaintCount,
  'resolvedComplaints': instance.resolvedComplaints,
  'resolutionTime': instance.resolutionTime,
  'satisfactionFactors': instance.satisfactionFactors,
  'improvementAreas': instance.improvementAreas,
  'lastInteractionDate': instance.lastInteractionDate.toIso8601String(),
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

const _$SatisfactionLevelEnumMap = {
  SatisfactionLevel.veryHigh: 'veryHigh',
  SatisfactionLevel.high: 'high',
  SatisfactionLevel.medium: 'medium',
  SatisfactionLevel.low: 'low',
  SatisfactionLevel.veryLow: 'veryLow',
};

CustomerChurnPrediction _$CustomerChurnPredictionFromJson(
  Map<String, dynamic> json,
) => CustomerChurnPrediction(
  customerId: json['customerId'] as String,
  businessId: json['businessId'] as String,
  riskLevel: $enumDecode(_$ChurnRiskEnumMap, json['riskLevel']),
  churnProbability: (json['churnProbability'] as num).toDouble(),
  riskFactors:
      (json['riskFactors'] as List<dynamic>).map((e) => e as String).toList(),
  retentionStrategies:
      (json['retentionStrategies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  daysSinceLastOrder: (json['daysSinceLastOrder'] as num).toInt(),
  recentActivityScore: (json['recentActivityScore'] as num).toDouble(),
  engagementScore: (json['engagementScore'] as num).toDouble(),
  satisfactionScore: (json['satisfactionScore'] as num).toDouble(),
  paymentBehaviorScore: (json['paymentBehaviorScore'] as num).toDouble(),
  overallHealthScore: (json['overallHealthScore'] as num).toDouble(),
  predictedChurnDate:
      json['predictedChurnDate'] == null
          ? null
          : DateTime.parse(json['predictedChurnDate'] as String),
  recommendedActions:
      (json['recommendedActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$CustomerChurnPredictionToJson(
  CustomerChurnPrediction instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'businessId': instance.businessId,
  'riskLevel': _$ChurnRiskEnumMap[instance.riskLevel]!,
  'churnProbability': instance.churnProbability,
  'riskFactors': instance.riskFactors,
  'retentionStrategies': instance.retentionStrategies,
  'daysSinceLastOrder': instance.daysSinceLastOrder,
  'recentActivityScore': instance.recentActivityScore,
  'engagementScore': instance.engagementScore,
  'satisfactionScore': instance.satisfactionScore,
  'paymentBehaviorScore': instance.paymentBehaviorScore,
  'overallHealthScore': instance.overallHealthScore,
  'predictedChurnDate': instance.predictedChurnDate?.toIso8601String(),
  'recommendedActions': instance.recommendedActions,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

const _$ChurnRiskEnumMap = {
  ChurnRisk.low: 'low',
  ChurnRisk.medium: 'medium',
  ChurnRisk.high: 'high',
  ChurnRisk.critical: 'critical',
};

CustomerBehaviorAnalysis _$CustomerBehaviorAnalysisFromJson(
  Map<String, dynamic> json,
) => CustomerBehaviorAnalysis(
  customerId: json['customerId'] as String,
  businessId: json['businessId'] as String,
  paymentPattern: CustomerPaymentPattern.fromJson(
    json['paymentPattern'] as Map<String, dynamic>,
  ),
  lifetimeValue: CustomerLifetimeValue.fromJson(
    json['lifetimeValue'] as Map<String, dynamic>,
  ),
  satisfaction: CustomerSatisfactionAnalysis.fromJson(
    json['satisfaction'] as Map<String, dynamic>,
  ),
  churnPrediction: CustomerChurnPrediction.fromJson(
    json['churnPrediction'] as Map<String, dynamic>,
  ),
  overallRecommendations:
      (json['overallRecommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  overallScore: (json['overallScore'] as num).toDouble(),
  riskCategory: json['riskCategory'] as String,
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$CustomerBehaviorAnalysisToJson(
  CustomerBehaviorAnalysis instance,
) => <String, dynamic>{
  'customerId': instance.customerId,
  'businessId': instance.businessId,
  'paymentPattern': instance.paymentPattern,
  'lifetimeValue': instance.lifetimeValue,
  'satisfaction': instance.satisfaction,
  'churnPrediction': instance.churnPrediction,
  'overallRecommendations': instance.overallRecommendations,
  'overallScore': instance.overallScore,
  'riskCategory': instance.riskCategory,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

CustomerInteraction _$CustomerInteractionFromJson(Map<String, dynamic> json) =>
    CustomerInteraction(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      businessId: json['businessId'] as String,
      type: json['type'] as String,
      channel: json['channel'] as String,
      sentiment: json['sentiment'] as String,
      subject: json['subject'] as String?,
      description: json['description'] as String?,
      outcome: json['outcome'] as String?,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      resolved: json['resolved'] as bool,
      followUpRequired: json['followUpRequired'] as String?,
      interactionDate: DateTime.parse(json['interactionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CustomerInteractionToJson(
  CustomerInteraction instance,
) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'businessId': instance.businessId,
  'type': instance.type,
  'channel': instance.channel,
  'sentiment': instance.sentiment,
  'subject': instance.subject,
  'description': instance.description,
  'outcome': instance.outcome,
  'durationMinutes': instance.durationMinutes,
  'resolved': instance.resolved,
  'followUpRequired': instance.followUpRequired,
  'interactionDate': instance.interactionDate.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};
