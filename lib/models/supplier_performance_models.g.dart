// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_performance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplierDeliveryPerformance _$SupplierDeliveryPerformanceFromJson(
  Map<String, dynamic> json,
) => SupplierDeliveryPerformance(
  supplierId: json['supplierId'] as String,
  businessId: json['businessId'] as String,
  performance: $enumDecode(_$DeliveryPerformanceEnumMap, json['performance']),
  onTimeDeliveryRate: (json['onTimeDeliveryRate'] as num).toDouble(),
  earlyDeliveryRate: (json['earlyDeliveryRate'] as num).toDouble(),
  lateDeliveryRate: (json['lateDeliveryRate'] as num).toDouble(),
  averageDeliveryDelay: (json['averageDeliveryDelay'] as num).toDouble(),
  totalOrders: (json['totalOrders'] as num).toInt(),
  onTimeOrders: (json['onTimeOrders'] as num).toInt(),
  lateOrders: (json['lateOrders'] as num).toInt(),
  cancelledOrders: (json['cancelledOrders'] as num).toInt(),
  lastDeliveryDate:
      json['lastDeliveryDate'] == null
          ? null
          : DateTime.parse(json['lastDeliveryDate'] as String),
  deliveryDelayTrend:
      (json['deliveryDelayTrend'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$SupplierDeliveryPerformanceToJson(
  SupplierDeliveryPerformance instance,
) => <String, dynamic>{
  'supplierId': instance.supplierId,
  'businessId': instance.businessId,
  'performance': _$DeliveryPerformanceEnumMap[instance.performance]!,
  'onTimeDeliveryRate': instance.onTimeDeliveryRate,
  'earlyDeliveryRate': instance.earlyDeliveryRate,
  'lateDeliveryRate': instance.lateDeliveryRate,
  'averageDeliveryDelay': instance.averageDeliveryDelay,
  'totalOrders': instance.totalOrders,
  'onTimeOrders': instance.onTimeOrders,
  'lateOrders': instance.lateOrders,
  'cancelledOrders': instance.cancelledOrders,
  'lastDeliveryDate': instance.lastDeliveryDate?.toIso8601String(),
  'deliveryDelayTrend': instance.deliveryDelayTrend,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

const _$DeliveryPerformanceEnumMap = {
  DeliveryPerformance.excellent: 'excellent',
  DeliveryPerformance.good: 'good',
  DeliveryPerformance.average: 'average',
  DeliveryPerformance.poor: 'poor',
  DeliveryPerformance.unreliable: 'unreliable',
};

SupplierQualityAssessment _$SupplierQualityAssessmentFromJson(
  Map<String, dynamic> json,
) => SupplierQualityAssessment(
  supplierId: json['supplierId'] as String,
  businessId: json['businessId'] as String,
  overallRating: $enumDecode(_$QualityRatingEnumMap, json['overallRating']),
  qualityScore: (json['qualityScore'] as num).toDouble(),
  totalDeliveries: (json['totalDeliveries'] as num).toInt(),
  acceptedDeliveries: (json['acceptedDeliveries'] as num).toInt(),
  rejectedDeliveries: (json['rejectedDeliveries'] as num).toInt(),
  returnedDeliveries: (json['returnedDeliveries'] as num).toInt(),
  defectRate: (json['defectRate'] as num).toDouble(),
  returnRate: (json['returnRate'] as num).toDouble(),
  qualityIssues:
      (json['qualityIssues'] as List<dynamic>).map((e) => e as String).toList(),
  improvementAreas:
      (json['improvementAreas'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  lastQualityIncident:
      json['lastQualityIncident'] == null
          ? null
          : DateTime.parse(json['lastQualityIncident'] as String),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$SupplierQualityAssessmentToJson(
  SupplierQualityAssessment instance,
) => <String, dynamic>{
  'supplierId': instance.supplierId,
  'businessId': instance.businessId,
  'overallRating': _$QualityRatingEnumMap[instance.overallRating]!,
  'qualityScore': instance.qualityScore,
  'totalDeliveries': instance.totalDeliveries,
  'acceptedDeliveries': instance.acceptedDeliveries,
  'rejectedDeliveries': instance.rejectedDeliveries,
  'returnedDeliveries': instance.returnedDeliveries,
  'defectRate': instance.defectRate,
  'returnRate': instance.returnRate,
  'qualityIssues': instance.qualityIssues,
  'improvementAreas': instance.improvementAreas,
  'lastQualityIncident': instance.lastQualityIncident?.toIso8601String(),
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

const _$QualityRatingEnumMap = {
  QualityRating.excellent: 'excellent',
  QualityRating.good: 'good',
  QualityRating.average: 'average',
  QualityRating.poor: 'poor',
  QualityRating.unacceptable: 'unacceptable',
};

SupplierCostAnalysis _$SupplierCostAnalysisFromJson(
  Map<String, dynamic> json,
) => SupplierCostAnalysis(
  supplierId: json['supplierId'] as String,
  businessId: json['businessId'] as String,
  totalSpend: (json['totalSpend'] as num).toDouble(),
  averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
  costPerUnit: (json['costPerUnit'] as num).toDouble(),
  priceVariance: (json['priceVariance'] as num).toDouble(),
  costTrend: (json['costTrend'] as num).toDouble(),
  monthlySpendTrend:
      (json['monthlySpendTrend'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
  costOptimizationOpportunities:
      (json['costOptimizationOpportunities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  negotiationRecommendations:
      (json['negotiationRecommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$SupplierCostAnalysisToJson(
  SupplierCostAnalysis instance,
) => <String, dynamic>{
  'supplierId': instance.supplierId,
  'businessId': instance.businessId,
  'totalSpend': instance.totalSpend,
  'averageOrderValue': instance.averageOrderValue,
  'costPerUnit': instance.costPerUnit,
  'priceVariance': instance.priceVariance,
  'costTrend': instance.costTrend,
  'monthlySpendTrend': instance.monthlySpendTrend,
  'costOptimizationOpportunities': instance.costOptimizationOpportunities,
  'negotiationRecommendations': instance.negotiationRecommendations,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

SupplierRelationshipScore _$SupplierRelationshipScoreFromJson(
  Map<String, dynamic> json,
) => SupplierRelationshipScore(
  supplierId: json['supplierId'] as String,
  businessId: json['businessId'] as String,
  overallScore: (json['overallScore'] as num).toDouble(),
  deliveryScore: (json['deliveryScore'] as num).toDouble(),
  qualityScore: (json['qualityScore'] as num).toDouble(),
  costScore: (json['costScore'] as num).toDouble(),
  communicationScore: (json['communicationScore'] as num).toDouble(),
  reliabilityScore: (json['reliabilityScore'] as num).toDouble(),
  innovationScore: (json['innovationScore'] as num).toDouble(),
  rating: $enumDecode(_$PerformanceRatingEnumMap, json['rating']),
  strengths:
      (json['strengths'] as List<dynamic>).map((e) => e as String).toList(),
  weaknesses:
      (json['weaknesses'] as List<dynamic>).map((e) => e as String).toList(),
  improvementActions:
      (json['improvementActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$SupplierRelationshipScoreToJson(
  SupplierRelationshipScore instance,
) => <String, dynamic>{
  'supplierId': instance.supplierId,
  'businessId': instance.businessId,
  'overallScore': instance.overallScore,
  'deliveryScore': instance.deliveryScore,
  'qualityScore': instance.qualityScore,
  'costScore': instance.costScore,
  'communicationScore': instance.communicationScore,
  'reliabilityScore': instance.reliabilityScore,
  'innovationScore': instance.innovationScore,
  'rating': _$PerformanceRatingEnumMap[instance.rating]!,
  'strengths': instance.strengths,
  'weaknesses': instance.weaknesses,
  'improvementActions': instance.improvementActions,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

const _$PerformanceRatingEnumMap = {
  PerformanceRating.excellent: 'excellent',
  PerformanceRating.good: 'good',
  PerformanceRating.average: 'average',
  PerformanceRating.poor: 'poor',
  PerformanceRating.critical: 'critical',
};

SupplierRiskAssessment _$SupplierRiskAssessmentFromJson(
  Map<String, dynamic> json,
) => SupplierRiskAssessment(
  supplierId: json['supplierId'] as String,
  businessId: json['businessId'] as String,
  riskLevel: $enumDecode(_$SupplierRiskEnumMap, json['riskLevel']),
  riskScore: (json['riskScore'] as num).toDouble(),
  riskFactors:
      (json['riskFactors'] as List<dynamic>).map((e) => e as String).toList(),
  mitigationStrategies:
      (json['mitigationStrategies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  financialRisk: (json['financialRisk'] as num).toDouble(),
  operationalRisk: (json['operationalRisk'] as num).toDouble(),
  reputationalRisk: (json['reputationalRisk'] as num).toDouble(),
  concentrationRisk: (json['concentrationRisk'] as num).toDouble(),
  requiresBackupSupplier: json['requiresBackupSupplier'] as bool,
  requiresContractReview: json['requiresContractReview'] as bool,
  assessedAt: DateTime.parse(json['assessedAt'] as String),
);

Map<String, dynamic> _$SupplierRiskAssessmentToJson(
  SupplierRiskAssessment instance,
) => <String, dynamic>{
  'supplierId': instance.supplierId,
  'businessId': instance.businessId,
  'riskLevel': _$SupplierRiskEnumMap[instance.riskLevel]!,
  'riskScore': instance.riskScore,
  'riskFactors': instance.riskFactors,
  'mitigationStrategies': instance.mitigationStrategies,
  'financialRisk': instance.financialRisk,
  'operationalRisk': instance.operationalRisk,
  'reputationalRisk': instance.reputationalRisk,
  'concentrationRisk': instance.concentrationRisk,
  'requiresBackupSupplier': instance.requiresBackupSupplier,
  'requiresContractReview': instance.requiresContractReview,
  'assessedAt': instance.assessedAt.toIso8601String(),
};

const _$SupplierRiskEnumMap = {
  SupplierRisk.low: 'low',
  SupplierRisk.medium: 'medium',
  SupplierRisk.high: 'high',
  SupplierRisk.critical: 'critical',
};

SupplierPerformanceAnalysis _$SupplierPerformanceAnalysisFromJson(
  Map<String, dynamic> json,
) => SupplierPerformanceAnalysis(
  supplierId: json['supplierId'] as String,
  businessId: json['businessId'] as String,
  deliveryPerformance: SupplierDeliveryPerformance.fromJson(
    json['deliveryPerformance'] as Map<String, dynamic>,
  ),
  qualityAssessment: SupplierQualityAssessment.fromJson(
    json['qualityAssessment'] as Map<String, dynamic>,
  ),
  costAnalysis: SupplierCostAnalysis.fromJson(
    json['costAnalysis'] as Map<String, dynamic>,
  ),
  relationshipScore: SupplierRelationshipScore.fromJson(
    json['relationshipScore'] as Map<String, dynamic>,
  ),
  riskAssessment: SupplierRiskAssessment.fromJson(
    json['riskAssessment'] as Map<String, dynamic>,
  ),
  overallRecommendations:
      (json['overallRecommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  performanceCategory: json['performanceCategory'] as String,
  recommendedForContinuation: json['recommendedForContinuation'] as bool,
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$SupplierPerformanceAnalysisToJson(
  SupplierPerformanceAnalysis instance,
) => <String, dynamic>{
  'supplierId': instance.supplierId,
  'businessId': instance.businessId,
  'deliveryPerformance': instance.deliveryPerformance,
  'qualityAssessment': instance.qualityAssessment,
  'costAnalysis': instance.costAnalysis,
  'relationshipScore': instance.relationshipScore,
  'riskAssessment': instance.riskAssessment,
  'overallRecommendations': instance.overallRecommendations,
  'performanceCategory': instance.performanceCategory,
  'recommendedForContinuation': instance.recommendedForContinuation,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

SupplierDiversificationAnalysis _$SupplierDiversificationAnalysisFromJson(
  Map<String, dynamic> json,
) => SupplierDiversificationAnalysis(
  businessId: json['businessId'] as String,
  totalSuppliers: (json['totalSuppliers'] as num).toInt(),
  activeSuppliers: (json['activeSuppliers'] as num).toInt(),
  concentrationRisk: (json['concentrationRisk'] as num).toDouble(),
  topSupplierDependency: json['topSupplierDependency'] as String,
  criticalSuppliers:
      (json['criticalSuppliers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  diversificationOpportunities:
      (json['diversificationOpportunities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  riskMitigationStrategies:
      (json['riskMitigationStrategies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  supplierSpendDistribution: (json['supplierSpendDistribution']
          as Map<String, dynamic>)
      .map((k, e) => MapEntry(k, (e as num).toDouble())),
  analyzedAt: DateTime.parse(json['analyzedAt'] as String),
);

Map<String, dynamic> _$SupplierDiversificationAnalysisToJson(
  SupplierDiversificationAnalysis instance,
) => <String, dynamic>{
  'businessId': instance.businessId,
  'totalSuppliers': instance.totalSuppliers,
  'activeSuppliers': instance.activeSuppliers,
  'concentrationRisk': instance.concentrationRisk,
  'topSupplierDependency': instance.topSupplierDependency,
  'criticalSuppliers': instance.criticalSuppliers,
  'diversificationOpportunities': instance.diversificationOpportunities,
  'riskMitigationStrategies': instance.riskMitigationStrategies,
  'supplierSpendDistribution': instance.supplierSpendDistribution,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
};

SupplierInteraction _$SupplierInteractionFromJson(Map<String, dynamic> json) =>
    SupplierInteraction(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      businessId: json['businessId'] as String,
      type: json['type'] as String,
      channel: json['channel'] as String,
      subject: json['subject'] as String?,
      description: json['description'] as String?,
      outcome: json['outcome'] as String?,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      resolved: json['resolved'] as bool,
      followUpRequired: json['followUpRequired'] as String?,
      interactionDate: DateTime.parse(json['interactionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SupplierInteractionToJson(
  SupplierInteraction instance,
) => <String, dynamic>{
  'id': instance.id,
  'supplierId': instance.supplierId,
  'businessId': instance.businessId,
  'type': instance.type,
  'channel': instance.channel,
  'subject': instance.subject,
  'description': instance.description,
  'outcome': instance.outcome,
  'durationMinutes': instance.durationMinutes,
  'resolved': instance.resolved,
  'followUpRequired': instance.followUpRequired,
  'interactionDate': instance.interactionDate.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

SupplierOrder _$SupplierOrderFromJson(Map<String, dynamic> json) =>
    SupplierOrder(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      businessId: json['businessId'] as String,
      orderNumber: json['orderNumber'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      expectedDeliveryDate: DateTime.parse(
        json['expectedDeliveryDate'] as String,
      ),
      actualDeliveryDate:
          json['actualDeliveryDate'] == null
              ? null
              : DateTime.parse(json['actualDeliveryDate'] as String),
      orderValue: (json['orderValue'] as num).toDouble(),
      status: json['status'] as String,
      onTime: json['onTime'] as bool,
      deliveryDelayDays: (json['deliveryDelayDays'] as num).toInt(),
      qualityRating: json['qualityRating'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SupplierOrderToJson(SupplierOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'supplierId': instance.supplierId,
      'businessId': instance.businessId,
      'orderNumber': instance.orderNumber,
      'orderDate': instance.orderDate.toIso8601String(),
      'expectedDeliveryDate': instance.expectedDeliveryDate.toIso8601String(),
      'actualDeliveryDate': instance.actualDeliveryDate?.toIso8601String(),
      'orderValue': instance.orderValue,
      'status': instance.status,
      'onTime': instance.onTime,
      'deliveryDelayDays': instance.deliveryDelayDays,
      'qualityRating': instance.qualityRating,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
