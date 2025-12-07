import 'package:json_annotation/json_annotation.dart';

part 'opportunity_models.g.dart';

// Enums
enum OpportunityType {
  marketExpansion,
  productDiversification,
  costReduction,
  revenueGrowth,
  processImprovement,
  customerAcquisition,
  partnershipOpportunity,
  pricingOptimization,
  upselling,
  newProduct,
  processAutomation,
  supplierOptimization,
  competitivePositioning,
  marketTrend,
  strategicPartnership,
  customerRetention,
  customerSatisfaction,
  digitalTransformation,
  aiImplementation,
}

// Opportunity Models
@JsonSerializable()
class BusinessOpportunity {
  final String id;
  final String businessId;
  final OpportunityType type;
  final String title;
  final String description;
  final double estimatedValue;
  final double estimatedCost;
  final double roi;
  final double priorityScore;
  final List<String> requirements;
  final List<String> risks;
  final DateTime identifiedAt;
  final double? potentialImpact;
  final double? implementationCost;
  final Duration? timeToImplement;
  final double? confidence;
  final double? expectedROI;
  final DateTime? createdAt;

  BusinessOpportunity({
    required this.id,
    required this.businessId,
    required this.type,
    required this.title,
    required this.description,
    required this.estimatedValue,
    required this.estimatedCost,
    required this.roi,
    required this.priorityScore,
    required this.requirements,
    required this.risks,
    required this.identifiedAt,
    this.potentialImpact,
    this.implementationCost,
    this.timeToImplement,
    this.confidence,
    this.expectedROI,
    this.createdAt,
  });

  factory BusinessOpportunity.fromJson(Map<String, dynamic> json) =>
      _$BusinessOpportunityFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessOpportunityToJson(this);
}
