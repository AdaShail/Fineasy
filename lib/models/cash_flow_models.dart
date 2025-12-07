import 'package:json_annotation/json_annotation.dart';

part 'cash_flow_models.g.dart';

/// Cash flow prediction model
@JsonSerializable()
class CashFlowPrediction {
  final String id;
  final String businessId;
  final DateTime predictionDate;
  final double predictedAmount;
  final double confidence;
  final Map<String, dynamic> breakdown;
  final List<CashFlowTrend> trends;
  final DateTime createdAt;
  final double? predictedBalance;
  final double? confidenceScore;
  final int? predictionHorizonDays;
  final List<CashFlowItem>? expectedInflows;
  final List<CashFlowItem>? expectedOutflows;
  final List<String>? riskFactors;

  const CashFlowPrediction({
    required this.id,
    required this.businessId,
    required this.predictionDate,
    required this.predictedAmount,
    required this.confidence,
    required this.breakdown,
    required this.trends,
    required this.createdAt,
    this.predictedBalance,
    this.confidenceScore,
    this.predictionHorizonDays,
    this.expectedInflows,
    this.expectedOutflows,
    this.riskFactors,
  });

  factory CashFlowPrediction.fromJson(Map<String, dynamic> json) =>
      _$CashFlowPredictionFromJson(json);

  Map<String, dynamic> toJson() => _$CashFlowPredictionToJson(this);
}

/// Cash flow trend analysis
@JsonSerializable()
class CashFlowTrend {
  final String id;
  final String businessId;
  final String trendType;
  final double amount;
  final double probability;
  final double trendStrength;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> metadata;
  final String? description;
  final String? seasonalPattern;
  final DateTime? detectedAt;
  final double? confidenceScore;

  const CashFlowTrend({
    required this.id,
    required this.businessId,
    required this.trendType,
    required this.amount,
    required this.probability,
    required this.trendStrength,
    required this.startDate,
    required this.endDate,
    this.metadata = const {},
    this.description,
    this.seasonalPattern,
    this.detectedAt,
    this.confidenceScore,
  });

  factory CashFlowTrend.fromJson(Map<String, dynamic> json) =>
      _$CashFlowTrendFromJson(json);

  Map<String, dynamic> toJson() => _$CashFlowTrendToJson(this);
}

/// Cash flow alert
@JsonSerializable()
class CashFlowAlert {
  final String id;
  final String businessId;
  final String alertType;
  final String severity;
  final String message;
  final double amount;
  final DateTime triggeredAt;
  final Map<String, dynamic> context;
  final String? severityLevel;
  final double? predictedShortfallAmount;
  final DateTime? shortfallDate;
  final List<String>? recommendedActions;
  final DateTime? createdAt;
  final bool? isResolved;

  const CashFlowAlert({
    required this.id,
    required this.businessId,
    required this.alertType,
    required this.severity,
    required this.message,
    required this.amount,
    required this.triggeredAt,
    this.context = const {},
    this.severityLevel,
    this.predictedShortfallAmount,
    this.shortfallDate,
    this.recommendedActions,
    this.createdAt,
    this.isResolved,
  });

  factory CashFlowAlert.fromJson(Map<String, dynamic> json) =>
      _$CashFlowAlertFromJson(json);

  Map<String, dynamic> toJson() => _$CashFlowAlertToJson(this);
}

/// Cash flow item
@JsonSerializable()
class CashFlowItem {
  final String id;
  final String businessId;
  final String type;
  final double amount;
  final DateTime date;
  final String description;
  final String category;
  final Map<String, dynamic> metadata;
  final double? probability;
  final DateTime? expectedDate;
  final String? sourceId;
  final String? sourceType;

  const CashFlowItem({
    required this.id,
    required this.businessId,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.category,
    this.metadata = const {},
    this.probability,
    this.expectedDate,
    this.sourceId,
    this.sourceType,
  });

  factory CashFlowItem.fromJson(Map<String, dynamic> json) =>
      _$CashFlowItemFromJson(json);

  Map<String, dynamic> toJson() => _$CashFlowItemToJson(this);
}
