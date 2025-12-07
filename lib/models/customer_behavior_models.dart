import 'package:json_annotation/json_annotation.dart';

part 'customer_behavior_models.g.dart';

/// Enum for customer payment behavior patterns
enum PaymentBehavior {
  excellent, // Always pays early or on time
  good, // Usually pays on time with occasional delays
  average, // Mixed payment history
  poor, // Frequently pays late
  problematic, // Consistently late or defaults
}

/// Enum for customer satisfaction levels
enum SatisfactionLevel { veryHigh, high, medium, low, veryLow }

/// Enum for churn risk levels
enum ChurnRisk { low, medium, high, critical }

/// Model for customer payment pattern analysis
@JsonSerializable()
class CustomerPaymentPattern {
  final String customerId;
  final String businessId;
  final PaymentBehavior behavior;
  final double averagePaymentDelay; // in days
  final double onTimePaymentRate; // percentage
  final double earlyPaymentRate; // percentage
  final double latePaymentRate; // percentage
  final int totalInvoices;
  final int paidInvoices;
  final int overdueInvoices;
  final double averageInvoiceAmount;
  final double totalPaidAmount;
  final DateTime? lastPaymentDate;
  final DateTime? firstTransactionDate;
  final int daysSinceLastPayment;
  final List<double> paymentDelayTrend; // Last 12 months
  final DateTime analyzedAt;

  CustomerPaymentPattern({
    required this.customerId,
    required this.businessId,
    required this.behavior,
    required this.averagePaymentDelay,
    required this.onTimePaymentRate,
    required this.earlyPaymentRate,
    required this.latePaymentRate,
    required this.totalInvoices,
    required this.paidInvoices,
    required this.overdueInvoices,
    required this.averageInvoiceAmount,
    required this.totalPaidAmount,
    this.lastPaymentDate,
    this.firstTransactionDate,
    required this.daysSinceLastPayment,
    required this.paymentDelayTrend,
    required this.analyzedAt,
  });

  factory CustomerPaymentPattern.fromJson(Map<String, dynamic> json) =>
      _$CustomerPaymentPatternFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerPaymentPatternToJson(this);
}

/// Model for customer lifetime value analysis
@JsonSerializable()
class CustomerLifetimeValue {
  final String customerId;
  final String businessId;
  final double currentValue; // Total revenue to date
  final double predictedValue; // Predicted future value
  final double monthlyAverageRevenue;
  final double profitMargin; // percentage
  final int relationshipDurationMonths;
  final double acquisitionCost;
  final double retentionCost;
  final double netValue; // CLV - acquisition - retention costs
  final double roi; // Return on investment
  final List<double> monthlyRevenueTrend; // Last 12 months
  final DateTime analyzedAt;

  CustomerLifetimeValue({
    required this.customerId,
    required this.businessId,
    required this.currentValue,
    required this.predictedValue,
    required this.monthlyAverageRevenue,
    required this.profitMargin,
    required this.relationshipDurationMonths,
    required this.acquisitionCost,
    required this.retentionCost,
    required this.netValue,
    required this.roi,
    required this.monthlyRevenueTrend,
    required this.analyzedAt,
  });

  factory CustomerLifetimeValue.fromJson(Map<String, dynamic> json) =>
      _$CustomerLifetimeValueFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerLifetimeValueToJson(this);
}

/// Model for customer satisfaction analysis
@JsonSerializable()
class CustomerSatisfactionAnalysis {
  final String customerId;
  final String businessId;
  final SatisfactionLevel level;
  final double score; // 0-100
  final int totalInteractions;
  final int positiveInteractions;
  final int negativeInteractions;
  final int neutralInteractions;
  final double responseTime; // Average response time in hours
  final int complaintCount;
  final int resolvedComplaints;
  final double resolutionTime; // Average resolution time in hours
  final List<String> satisfactionFactors; // Factors affecting satisfaction
  final List<String> improvementAreas;
  final DateTime lastInteractionDate;
  final DateTime analyzedAt;

  CustomerSatisfactionAnalysis({
    required this.customerId,
    required this.businessId,
    required this.level,
    required this.score,
    required this.totalInteractions,
    required this.positiveInteractions,
    required this.negativeInteractions,
    required this.neutralInteractions,
    required this.responseTime,
    required this.complaintCount,
    required this.resolvedComplaints,
    required this.resolutionTime,
    required this.satisfactionFactors,
    required this.improvementAreas,
    required this.lastInteractionDate,
    required this.analyzedAt,
  });

  factory CustomerSatisfactionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$CustomerSatisfactionAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerSatisfactionAnalysisToJson(this);
}

/// Model for customer churn prediction
@JsonSerializable()
class CustomerChurnPrediction {
  final String customerId;
  final String businessId;
  final ChurnRisk riskLevel;
  final double churnProbability; // 0-1
  final List<String> riskFactors;
  final List<String> retentionStrategies;
  final int daysSinceLastOrder;
  final double recentActivityScore; // 0-100
  final double engagementScore; // 0-100
  final double satisfactionScore; // 0-100
  final double paymentBehaviorScore; // 0-100
  final double overallHealthScore; // 0-100
  final DateTime? predictedChurnDate;
  final List<String> recommendedActions;
  final DateTime analyzedAt;

  CustomerChurnPrediction({
    required this.customerId,
    required this.businessId,
    required this.riskLevel,
    required this.churnProbability,
    required this.riskFactors,
    required this.retentionStrategies,
    required this.daysSinceLastOrder,
    required this.recentActivityScore,
    required this.engagementScore,
    required this.satisfactionScore,
    required this.paymentBehaviorScore,
    required this.overallHealthScore,
    this.predictedChurnDate,
    required this.recommendedActions,
    required this.analyzedAt,
  });

  factory CustomerChurnPrediction.fromJson(Map<String, dynamic> json) =>
      _$CustomerChurnPredictionFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerChurnPredictionToJson(this);
}

/// Comprehensive customer behavior analysis
@JsonSerializable()
class CustomerBehaviorAnalysis {
  final String customerId;
  final String businessId;
  final CustomerPaymentPattern paymentPattern;
  final CustomerLifetimeValue lifetimeValue;
  final CustomerSatisfactionAnalysis satisfaction;
  final CustomerChurnPrediction churnPrediction;
  final List<String> overallRecommendations;
  final double overallScore; // 0-100
  final String riskCategory; // Low, Medium, High, Critical
  final DateTime analyzedAt;

  CustomerBehaviorAnalysis({
    required this.customerId,
    required this.businessId,
    required this.paymentPattern,
    required this.lifetimeValue,
    required this.satisfaction,
    required this.churnPrediction,
    required this.overallRecommendations,
    required this.overallScore,
    required this.riskCategory,
    required this.analyzedAt,
  });

  factory CustomerBehaviorAnalysis.fromJson(Map<String, dynamic> json) =>
      _$CustomerBehaviorAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerBehaviorAnalysisToJson(this);
}

/// Model for customer interaction tracking
@JsonSerializable()
class CustomerInteraction {
  final String id;
  final String customerId;
  final String businessId;
  final String type; // call, email, whatsapp, meeting, complaint, etc.
  final String channel; // phone, email, whatsapp, in-person, etc.
  final String sentiment; // positive, negative, neutral
  final String? subject;
  final String? description;
  final String? outcome;
  final int durationMinutes;
  final bool resolved;
  final String? followUpRequired;
  final DateTime interactionDate;
  final DateTime createdAt;

  CustomerInteraction({
    required this.id,
    required this.customerId,
    required this.businessId,
    required this.type,
    required this.channel,
    required this.sentiment,
    this.subject,
    this.description,
    this.outcome,
    required this.durationMinutes,
    required this.resolved,
    this.followUpRequired,
    required this.interactionDate,
    required this.createdAt,
  });

  factory CustomerInteraction.fromJson(Map<String, dynamic> json) =>
      _$CustomerInteractionFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerInteractionToJson(this);
}
