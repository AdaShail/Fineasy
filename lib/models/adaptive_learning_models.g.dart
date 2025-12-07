// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adaptive_learning_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferenceProfile _$UserPreferenceProfileFromJson(
  Map<String, dynamic> json,
) => UserPreferenceProfile(
  businessId: json['businessId'] as String,
  preferences: (json['preferences'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  confidenceScores: (json['confidenceScores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$UserPreferenceProfileToJson(
  UserPreferenceProfile instance,
) => <String, dynamic>{
  'businessId': instance.businessId,
  'preferences': instance.preferences,
  'confidenceScores': instance.confidenceScores,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

BusinessPattern _$BusinessPatternFromJson(Map<String, dynamic> json) =>
    BusinessPattern(
      id: json['id'] as String,
      patternType: json['patternType'] as String,
      description: json['description'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
      confidence: (json['confidence'] as num).toDouble(),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );

Map<String, dynamic> _$BusinessPatternToJson(BusinessPattern instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patternType': instance.patternType,
      'description': instance.description,
      'parameters': instance.parameters,
      'confidence': instance.confidence,
      'detectedAt': instance.detectedAt.toIso8601String(),
    };

BusinessPatternModel _$BusinessPatternModelFromJson(
  Map<String, dynamic> json,
) => BusinessPatternModel(
  businessId: json['businessId'] as String,
  detectedPatterns:
      (json['detectedPatterns'] as List<dynamic>)
          .map((e) => BusinessPattern.fromJson(e as Map<String, dynamic>))
          .toList(),
  seasonalityFactors: (json['seasonalityFactors'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  trendAnalysis: TrendAnalysis.fromJson(
    json['trendAnalysis'] as Map<String, dynamic>,
  ),
  anomalyThresholds: (json['anomalyThresholds'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  lastAnalyzed: DateTime.parse(json['lastAnalyzed'] as String),
);

Map<String, dynamic> _$BusinessPatternModelToJson(
  BusinessPatternModel instance,
) => <String, dynamic>{
  'businessId': instance.businessId,
  'detectedPatterns': instance.detectedPatterns,
  'seasonalityFactors': instance.seasonalityFactors,
  'trendAnalysis': instance.trendAnalysis,
  'anomalyThresholds': instance.anomalyThresholds,
  'lastAnalyzed': instance.lastAnalyzed.toIso8601String(),
};

TrendAnalysis _$TrendAnalysisFromJson(Map<String, dynamic> json) =>
    TrendAnalysis(
      revenue: (json['revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      customerGrowth: (json['customerGrowth'] as num).toDouble(),
      efficiency: (json['efficiency'] as num).toDouble(),
    );

Map<String, dynamic> _$TrendAnalysisToJson(TrendAnalysis instance) =>
    <String, dynamic>{
      'revenue': instance.revenue,
      'expenses': instance.expenses,
      'customerGrowth': instance.customerGrowth,
      'efficiency': instance.efficiency,
    };

DecisionOptimization _$DecisionOptimizationFromJson(
  Map<String, dynamic> json,
) => DecisionOptimization(
  originalDecision: json['originalDecision'] as Map<String, dynamic>,
  optimizedDecision: json['optimizedDecision'] as Map<String, dynamic>,
  confidenceAdjustment: (json['confidenceAdjustment'] as num).toDouble(),
  optimizationReasoning: json['optimizationReasoning'] as String,
  appliedAt: DateTime.parse(json['appliedAt'] as String),
);

Map<String, dynamic> _$DecisionOptimizationToJson(
  DecisionOptimization instance,
) => <String, dynamic>{
  'originalDecision': instance.originalDecision,
  'optimizedDecision': instance.optimizedDecision,
  'confidenceAdjustment': instance.confidenceAdjustment,
  'optimizationReasoning': instance.optimizationReasoning,
  'appliedAt': instance.appliedAt.toIso8601String(),
};

DecisionOptimizationModel _$DecisionOptimizationModelFromJson(
  Map<String, dynamic> json,
) => DecisionOptimizationModel(
  businessId: json['businessId'] as String,
  optimizationRules: json['optimizationRules'] as Map<String, dynamic>,
  contextWeights: (json['contextWeights'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  performanceHistory:
      (json['performanceHistory'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$DecisionOptimizationModelToJson(
  DecisionOptimizationModel instance,
) => <String, dynamic>{
  'businessId': instance.businessId,
  'optimizationRules': instance.optimizationRules,
  'contextWeights': instance.contextWeights,
  'performanceHistory': instance.performanceHistory,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

ModelPerformanceMetrics _$ModelPerformanceMetricsFromJson(
  Map<String, dynamic> json,
) => ModelPerformanceMetrics(
  accuracy: (json['accuracy'] as num).toDouble(),
  precision: (json['precision'] as num).toDouble(),
  recall: (json['recall'] as num).toDouble(),
  f1Score: (json['f1Score'] as num).toDouble(),
);

Map<String, dynamic> _$ModelPerformanceMetricsToJson(
  ModelPerformanceMetrics instance,
) => <String, dynamic>{
  'accuracy': instance.accuracy,
  'precision': instance.precision,
  'recall': instance.recall,
  'f1Score': instance.f1Score,
};

PersonalizedRecommendation _$PersonalizedRecommendationFromJson(
  Map<String, dynamic> json,
) => PersonalizedRecommendation(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  parameters: json['parameters'] as Map<String, dynamic>,
  reasoning: json['reasoning'] as String,
  generatedAt: DateTime.parse(json['generatedAt'] as String),
);

Map<String, dynamic> _$PersonalizedRecommendationToJson(
  PersonalizedRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'confidence': instance.confidence,
  'parameters': instance.parameters,
  'reasoning': instance.reasoning,
  'generatedAt': instance.generatedAt.toIso8601String(),
};

LearningAnalytics _$LearningAnalyticsFromJson(Map<String, dynamic> json) =>
    LearningAnalytics(
      businessId: json['businessId'] as String,
      learningProgress: (json['learningProgress'] as num).toDouble(),
      preferenceAccuracy: (json['preferenceAccuracy'] as num).toDouble(),
      patternRecognitionScore:
          (json['patternRecognitionScore'] as num).toDouble(),
      optimizationEffectiveness:
          (json['optimizationEffectiveness'] as num).toDouble(),
      totalFeedbackSamples: (json['totalFeedbackSamples'] as num).toInt(),
      lastModelUpdate: DateTime.parse(json['lastModelUpdate'] as String),
      improvementTrends: (json['improvementTrends'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
    );

Map<String, dynamic> _$LearningAnalyticsToJson(LearningAnalytics instance) =>
    <String, dynamic>{
      'businessId': instance.businessId,
      'learningProgress': instance.learningProgress,
      'preferenceAccuracy': instance.preferenceAccuracy,
      'patternRecognitionScore': instance.patternRecognitionScore,
      'optimizationEffectiveness': instance.optimizationEffectiveness,
      'totalFeedbackSamples': instance.totalFeedbackSamples,
      'lastModelUpdate': instance.lastModelUpdate.toIso8601String(),
      'improvementTrends': instance.improvementTrends,
    };

UserFeedback _$UserFeedbackFromJson(Map<String, dynamic> json) => UserFeedback(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  decisionType: json['decisionType'] as String,
  outcome: (json['outcome'] as num).toDouble(),
  comments: json['comments'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$UserFeedbackToJson(UserFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'decisionType': instance.decisionType,
      'outcome': instance.outcome,
      'comments': instance.comments,
      'timestamp': instance.timestamp.toIso8601String(),
    };
