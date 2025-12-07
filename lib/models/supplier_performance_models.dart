import 'package:json_annotation/json_annotation.dart';

part 'supplier_performance_models.g.dart';

/// Enum for supplier performance ratings
enum PerformanceRating { excellent, good, average, poor, critical }

/// Enum for delivery performance levels
enum DeliveryPerformance {
  excellent, // Always on time or early
  good, // Usually on time
  average, // Mixed delivery performance
  poor, // Frequently late
  unreliable, // Consistently late or missed deliveries
}

/// Enum for quality ratings
enum QualityRating { excellent, good, average, poor, unacceptable }

/// Enum for supplier risk levels
enum SupplierRisk { low, medium, high, critical }

/// Model for supplier delivery performance tracking
@JsonSerializable()
class SupplierDeliveryPerformance {
  final String supplierId;
  final String businessId;
  final DeliveryPerformance performance;
  final double onTimeDeliveryRate; // percentage
  final double earlyDeliveryRate; // percentage
  final double lateDeliveryRate; // percentage
  final double averageDeliveryDelay; // in days
  final int totalOrders;
  final int onTimeOrders;
  final int lateOrders;
  final int cancelledOrders;
  final DateTime? lastDeliveryDate;
  final List<double> deliveryDelayTrend; // Last 12 months
  final DateTime analyzedAt;

  SupplierDeliveryPerformance({
    required this.supplierId,
    required this.businessId,
    required this.performance,
    required this.onTimeDeliveryRate,
    required this.earlyDeliveryRate,
    required this.lateDeliveryRate,
    required this.averageDeliveryDelay,
    required this.totalOrders,
    required this.onTimeOrders,
    required this.lateOrders,
    required this.cancelledOrders,
    this.lastDeliveryDate,
    required this.deliveryDelayTrend,
    required this.analyzedAt,
  });

  factory SupplierDeliveryPerformance.fromJson(Map<String, dynamic> json) =>
      _$SupplierDeliveryPerformanceFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierDeliveryPerformanceToJson(this);
}

/// Model for supplier quality assessment
@JsonSerializable()
class SupplierQualityAssessment {
  final String supplierId;
  final String businessId;
  final QualityRating overallRating;
  final double qualityScore; // 0-100
  final int totalDeliveries;
  final int acceptedDeliveries;
  final int rejectedDeliveries;
  final int returnedDeliveries;
  final double defectRate; // percentage
  final double returnRate; // percentage
  final List<String> qualityIssues;
  final List<String> improvementAreas;
  final DateTime? lastQualityIncident;
  final DateTime analyzedAt;

  SupplierQualityAssessment({
    required this.supplierId,
    required this.businessId,
    required this.overallRating,
    required this.qualityScore,
    required this.totalDeliveries,
    required this.acceptedDeliveries,
    required this.rejectedDeliveries,
    required this.returnedDeliveries,
    required this.defectRate,
    required this.returnRate,
    required this.qualityIssues,
    required this.improvementAreas,
    this.lastQualityIncident,
    required this.analyzedAt,
  });

  factory SupplierQualityAssessment.fromJson(Map<String, dynamic> json) =>
      _$SupplierQualityAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierQualityAssessmentToJson(this);
}

/// Model for supplier cost analysis
@JsonSerializable()
class SupplierCostAnalysis {
  final String supplierId;
  final String businessId;
  final double totalSpend; // Total amount spent with supplier
  final double averageOrderValue;
  final double costPerUnit;
  final double priceVariance; // Variance from market price
  final double costTrend; // Positive = increasing, Negative = decreasing
  final List<double> monthlySpendTrend; // Last 12 months
  final List<String> costOptimizationOpportunities;
  final List<String> negotiationRecommendations;
  final DateTime analyzedAt;

  SupplierCostAnalysis({
    required this.supplierId,
    required this.businessId,
    required this.totalSpend,
    required this.averageOrderValue,
    required this.costPerUnit,
    required this.priceVariance,
    required this.costTrend,
    required this.monthlySpendTrend,
    required this.costOptimizationOpportunities,
    required this.negotiationRecommendations,
    required this.analyzedAt,
  });

  factory SupplierCostAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SupplierCostAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierCostAnalysisToJson(this);
}

/// Model for supplier relationship scoring
@JsonSerializable()
class SupplierRelationshipScore {
  final String supplierId;
  final String businessId;
  final double overallScore; // 0-100
  final double deliveryScore;
  final double qualityScore;
  final double costScore;
  final double communicationScore;
  final double reliabilityScore;
  final double innovationScore;
  final PerformanceRating rating;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> improvementActions;
  final DateTime analyzedAt;

  SupplierRelationshipScore({
    required this.supplierId,
    required this.businessId,
    required this.overallScore,
    required this.deliveryScore,
    required this.qualityScore,
    required this.costScore,
    required this.communicationScore,
    required this.reliabilityScore,
    required this.innovationScore,
    required this.rating,
    required this.strengths,
    required this.weaknesses,
    required this.improvementActions,
    required this.analyzedAt,
  });

  factory SupplierRelationshipScore.fromJson(Map<String, dynamic> json) =>
      _$SupplierRelationshipScoreFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierRelationshipScoreToJson(this);
}

/// Model for supplier risk assessment
@JsonSerializable()
class SupplierRiskAssessment {
  final String supplierId;
  final String businessId;
  final SupplierRisk riskLevel;
  final double riskScore; // 0-100
  final List<String> riskFactors;
  final List<String> mitigationStrategies;
  final double financialRisk;
  final double operationalRisk;
  final double reputationalRisk;
  final double concentrationRisk; // Risk from over-dependence
  final bool requiresBackupSupplier;
  final bool requiresContractReview;
  final DateTime assessedAt;

  SupplierRiskAssessment({
    required this.supplierId,
    required this.businessId,
    required this.riskLevel,
    required this.riskScore,
    required this.riskFactors,
    required this.mitigationStrategies,
    required this.financialRisk,
    required this.operationalRisk,
    required this.reputationalRisk,
    required this.concentrationRisk,
    required this.requiresBackupSupplier,
    required this.requiresContractReview,
    required this.assessedAt,
  });

  factory SupplierRiskAssessment.fromJson(Map<String, dynamic> json) =>
      _$SupplierRiskAssessmentFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierRiskAssessmentToJson(this);
}

/// Comprehensive supplier performance analysis
@JsonSerializable()
class SupplierPerformanceAnalysis {
  final String supplierId;
  final String businessId;
  final SupplierDeliveryPerformance deliveryPerformance;
  final SupplierQualityAssessment qualityAssessment;
  final SupplierCostAnalysis costAnalysis;
  final SupplierRelationshipScore relationshipScore;
  final SupplierRiskAssessment riskAssessment;
  final List<String> overallRecommendations;
  final String performanceCategory; // Excellent, Good, Average, Poor, Critical
  final bool recommendedForContinuation;
  final DateTime analyzedAt;

  SupplierPerformanceAnalysis({
    required this.supplierId,
    required this.businessId,
    required this.deliveryPerformance,
    required this.qualityAssessment,
    required this.costAnalysis,
    required this.relationshipScore,
    required this.riskAssessment,
    required this.overallRecommendations,
    required this.performanceCategory,
    required this.recommendedForContinuation,
    required this.analyzedAt,
  });

  factory SupplierPerformanceAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SupplierPerformanceAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierPerformanceAnalysisToJson(this);
}

/// Model for supplier diversification analysis
@JsonSerializable()
class SupplierDiversificationAnalysis {
  final String businessId;
  final int totalSuppliers;
  final int activeSuppliers;
  final double concentrationRisk; // 0-100, higher is riskier
  final String topSupplierDependency; // Percentage of spend on top supplier
  final List<String> criticalSuppliers; // Suppliers with high dependency
  final List<String> diversificationOpportunities;
  final List<String> riskMitigationStrategies;
  final Map<String, double> supplierSpendDistribution;
  final DateTime analyzedAt;

  SupplierDiversificationAnalysis({
    required this.businessId,
    required this.totalSuppliers,
    required this.activeSuppliers,
    required this.concentrationRisk,
    required this.topSupplierDependency,
    required this.criticalSuppliers,
    required this.diversificationOpportunities,
    required this.riskMitigationStrategies,
    required this.supplierSpendDistribution,
    required this.analyzedAt,
  });

  factory SupplierDiversificationAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SupplierDiversificationAnalysisFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SupplierDiversificationAnalysisToJson(this);
}

/// Model for tracking supplier interactions and communications
@JsonSerializable()
class SupplierInteraction {
  final String id;
  final String supplierId;
  final String businessId;
  final String type; // meeting, call, email, negotiation, complaint, etc.
  final String channel; // phone, email, in-person, etc.
  final String? subject;
  final String? description;
  final String? outcome;
  final int durationMinutes;
  final bool resolved;
  final String? followUpRequired;
  final DateTime interactionDate;
  final DateTime createdAt;

  SupplierInteraction({
    required this.id,
    required this.supplierId,
    required this.businessId,
    required this.type,
    required this.channel,
    this.subject,
    this.description,
    this.outcome,
    required this.durationMinutes,
    required this.resolved,
    this.followUpRequired,
    required this.interactionDate,
    required this.createdAt,
  });

  factory SupplierInteraction.fromJson(Map<String, dynamic> json) =>
      _$SupplierInteractionFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierInteractionToJson(this);
}

/// Model for supplier order tracking
@JsonSerializable()
class SupplierOrder {
  final String id;
  final String supplierId;
  final String businessId;
  final String orderNumber;
  final DateTime orderDate;
  final DateTime expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final double orderValue;
  final String status; // pending, confirmed, shipped, delivered, cancelled
  final bool onTime;
  final int deliveryDelayDays;
  final String? qualityRating;
  final String? notes;
  final DateTime createdAt;

  SupplierOrder({
    required this.id,
    required this.supplierId,
    required this.businessId,
    required this.orderNumber,
    required this.orderDate,
    required this.expectedDeliveryDate,
    this.actualDeliveryDate,
    required this.orderValue,
    required this.status,
    required this.onTime,
    required this.deliveryDelayDays,
    this.qualityRating,
    this.notes,
    required this.createdAt,
  });

  factory SupplierOrder.fromJson(Map<String, dynamic> json) =>
      _$SupplierOrderFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierOrderToJson(this);
}
