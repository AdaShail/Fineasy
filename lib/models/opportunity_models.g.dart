// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opportunity_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessOpportunity _$BusinessOpportunityFromJson(
  Map<String, dynamic> json,
) => BusinessOpportunity(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  type: $enumDecode(_$OpportunityTypeEnumMap, json['type']),
  title: json['title'] as String,
  description: json['description'] as String,
  estimatedValue: (json['estimatedValue'] as num).toDouble(),
  estimatedCost: (json['estimatedCost'] as num).toDouble(),
  roi: (json['roi'] as num).toDouble(),
  priorityScore: (json['priorityScore'] as num).toDouble(),
  requirements:
      (json['requirements'] as List<dynamic>).map((e) => e as String).toList(),
  risks: (json['risks'] as List<dynamic>).map((e) => e as String).toList(),
  identifiedAt: DateTime.parse(json['identifiedAt'] as String),
  potentialImpact: (json['potentialImpact'] as num?)?.toDouble(),
  implementationCost: (json['implementationCost'] as num?)?.toDouble(),
  timeToImplement:
      json['timeToImplement'] == null
          ? null
          : Duration(microseconds: (json['timeToImplement'] as num).toInt()),
  confidence: (json['confidence'] as num?)?.toDouble(),
  expectedROI: (json['expectedROI'] as num?)?.toDouble(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BusinessOpportunityToJson(
  BusinessOpportunity instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'type': _$OpportunityTypeEnumMap[instance.type]!,
  'title': instance.title,
  'description': instance.description,
  'estimatedValue': instance.estimatedValue,
  'estimatedCost': instance.estimatedCost,
  'roi': instance.roi,
  'priorityScore': instance.priorityScore,
  'requirements': instance.requirements,
  'risks': instance.risks,
  'identifiedAt': instance.identifiedAt.toIso8601String(),
  'potentialImpact': instance.potentialImpact,
  'implementationCost': instance.implementationCost,
  'timeToImplement': instance.timeToImplement?.inMicroseconds,
  'confidence': instance.confidence,
  'expectedROI': instance.expectedROI,
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$OpportunityTypeEnumMap = {
  OpportunityType.marketExpansion: 'marketExpansion',
  OpportunityType.productDiversification: 'productDiversification',
  OpportunityType.costReduction: 'costReduction',
  OpportunityType.revenueGrowth: 'revenueGrowth',
  OpportunityType.processImprovement: 'processImprovement',
  OpportunityType.customerAcquisition: 'customerAcquisition',
  OpportunityType.partnershipOpportunity: 'partnershipOpportunity',
  OpportunityType.pricingOptimization: 'pricingOptimization',
  OpportunityType.upselling: 'upselling',
  OpportunityType.newProduct: 'newProduct',
  OpportunityType.processAutomation: 'processAutomation',
  OpportunityType.supplierOptimization: 'supplierOptimization',
  OpportunityType.competitivePositioning: 'competitivePositioning',
  OpportunityType.marketTrend: 'marketTrend',
  OpportunityType.strategicPartnership: 'strategicPartnership',
  OpportunityType.customerRetention: 'customerRetention',
  OpportunityType.customerSatisfaction: 'customerSatisfaction',
  OpportunityType.digitalTransformation: 'digitalTransformation',
  OpportunityType.aiImplementation: 'aiImplementation',
};
