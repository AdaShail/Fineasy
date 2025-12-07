// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_flow_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CashFlowPrediction _$CashFlowPredictionFromJson(Map<String, dynamic> json) =>
    CashFlowPrediction(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      predictionDate: DateTime.parse(json['predictionDate'] as String),
      predictedAmount: (json['predictedAmount'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      breakdown: json['breakdown'] as Map<String, dynamic>,
      trends:
          (json['trends'] as List<dynamic>)
              .map((e) => CashFlowTrend.fromJson(e as Map<String, dynamic>))
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      predictedBalance: (json['predictedBalance'] as num?)?.toDouble(),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      predictionHorizonDays: (json['predictionHorizonDays'] as num?)?.toInt(),
      expectedInflows:
          (json['expectedInflows'] as List<dynamic>?)
              ?.map((e) => CashFlowItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      expectedOutflows:
          (json['expectedOutflows'] as List<dynamic>?)
              ?.map((e) => CashFlowItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      riskFactors:
          (json['riskFactors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$CashFlowPredictionToJson(CashFlowPrediction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'predictionDate': instance.predictionDate.toIso8601String(),
      'predictedAmount': instance.predictedAmount,
      'confidence': instance.confidence,
      'breakdown': instance.breakdown,
      'trends': instance.trends,
      'createdAt': instance.createdAt.toIso8601String(),
      'predictedBalance': instance.predictedBalance,
      'confidenceScore': instance.confidenceScore,
      'predictionHorizonDays': instance.predictionHorizonDays,
      'expectedInflows': instance.expectedInflows,
      'expectedOutflows': instance.expectedOutflows,
      'riskFactors': instance.riskFactors,
    };

CashFlowTrend _$CashFlowTrendFromJson(Map<String, dynamic> json) =>
    CashFlowTrend(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      trendType: json['trendType'] as String,
      amount: (json['amount'] as num).toDouble(),
      probability: (json['probability'] as num).toDouble(),
      trendStrength: (json['trendStrength'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      description: json['description'] as String?,
      seasonalPattern: json['seasonalPattern'] as String?,
      detectedAt:
          json['detectedAt'] == null
              ? null
              : DateTime.parse(json['detectedAt'] as String),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CashFlowTrendToJson(CashFlowTrend instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'trendType': instance.trendType,
      'amount': instance.amount,
      'probability': instance.probability,
      'trendStrength': instance.trendStrength,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'metadata': instance.metadata,
      'description': instance.description,
      'seasonalPattern': instance.seasonalPattern,
      'detectedAt': instance.detectedAt?.toIso8601String(),
      'confidenceScore': instance.confidenceScore,
    };

CashFlowAlert _$CashFlowAlertFromJson(Map<String, dynamic> json) =>
    CashFlowAlert(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      alertType: json['alertType'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
      amount: (json['amount'] as num).toDouble(),
      triggeredAt: DateTime.parse(json['triggeredAt'] as String),
      context: json['context'] as Map<String, dynamic>? ?? const {},
      severityLevel: json['severityLevel'] as String?,
      predictedShortfallAmount:
          (json['predictedShortfallAmount'] as num?)?.toDouble(),
      shortfallDate:
          json['shortfallDate'] == null
              ? null
              : DateTime.parse(json['shortfallDate'] as String),
      recommendedActions:
          (json['recommendedActions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      isResolved: json['isResolved'] as bool?,
    );

Map<String, dynamic> _$CashFlowAlertToJson(CashFlowAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'alertType': instance.alertType,
      'severity': instance.severity,
      'message': instance.message,
      'amount': instance.amount,
      'triggeredAt': instance.triggeredAt.toIso8601String(),
      'context': instance.context,
      'severityLevel': instance.severityLevel,
      'predictedShortfallAmount': instance.predictedShortfallAmount,
      'shortfallDate': instance.shortfallDate?.toIso8601String(),
      'recommendedActions': instance.recommendedActions,
      'createdAt': instance.createdAt?.toIso8601String(),
      'isResolved': instance.isResolved,
    };

CashFlowItem _$CashFlowItemFromJson(Map<String, dynamic> json) => CashFlowItem(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  description: json['description'] as String,
  category: json['category'] as String,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  probability: (json['probability'] as num?)?.toDouble(),
  expectedDate:
      json['expectedDate'] == null
          ? null
          : DateTime.parse(json['expectedDate'] as String),
  sourceId: json['sourceId'] as String?,
  sourceType: json['sourceType'] as String?,
);

Map<String, dynamic> _$CashFlowItemToJson(CashFlowItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'type': instance.type,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'description': instance.description,
      'category': instance.category,
      'metadata': instance.metadata,
      'probability': instance.probability,
      'expectedDate': instance.expectedDate?.toIso8601String(),
      'sourceId': instance.sourceId,
      'sourceType': instance.sourceType,
    };
