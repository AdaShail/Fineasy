// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningFeedback _$LearningFeedbackFromJson(Map<String, dynamic> json) =>
    LearningFeedback(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      decisionId: json['decisionId'] as String?,
      actionId: json['actionId'] as String?,
      feedbackType: $enumDecode(_$FeedbackTypeEnumMap, json['feedbackType']),
      outcomeType: $enumDecode(_$OutcomeTypeEnumMap, json['outcomeType']),
      actualOutcome: (json['actualOutcome'] as num?)?.toDouble(),
      predictedOutcome: (json['predictedOutcome'] as num?)?.toDouble(),
      userFeedback: json['userFeedback'] as String?,
      contextData: json['contextData'] as Map<String, dynamic>,
      learningContext: $enumDecode(
        _$LearningContextEnumMap,
        json['learningContext'],
      ),
      userRating: (json['userRating'] as num?)?.toDouble(),
      correctionSuggestion: json['correctionSuggestion'] as String?,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      processedAt:
          json['processedAt'] == null
              ? null
              : DateTime.parse(json['processedAt'] as String),
      isProcessed: json['isProcessed'] as bool? ?? false,
    );

Map<String, dynamic> _$LearningFeedbackToJson(LearningFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'decisionId': instance.decisionId,
      'actionId': instance.actionId,
      'feedbackType': _$FeedbackTypeEnumMap[instance.feedbackType]!,
      'outcomeType': _$OutcomeTypeEnumMap[instance.outcomeType]!,
      'actualOutcome': instance.actualOutcome,
      'predictedOutcome': instance.predictedOutcome,
      'userFeedback': instance.userFeedback,
      'contextData': instance.contextData,
      'learningContext': _$LearningContextEnumMap[instance.learningContext]!,
      'userRating': instance.userRating,
      'correctionSuggestion': instance.correctionSuggestion,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'processedAt': instance.processedAt?.toIso8601String(),
      'isProcessed': instance.isProcessed,
    };

const _$FeedbackTypeEnumMap = {
  FeedbackType.decisionOverride: 'decision_override',
  FeedbackType.actionApproval: 'action_approval',
  FeedbackType.outcomeRating: 'outcome_rating',
  FeedbackType.userCorrection: 'user_correction',
  FeedbackType.performanceFeedback: 'performance_feedback',
};

const _$OutcomeTypeEnumMap = {
  OutcomeType.success: 'success',
  OutcomeType.partialSuccess: 'partial_success',
  OutcomeType.failure: 'failure',
  OutcomeType.unknown: 'unknown',
};

const _$LearningContextEnumMap = {
  LearningContext.cashFlowManagement: 'cash_flow_management',
  LearningContext.customerRelationship: 'customer_relationship',
  LearningContext.supplierManagement: 'supplier_management',
  LearningContext.riskAssessment: 'risk_assessment',
  LearningContext.opportunityIdentification: 'opportunity_identification',
};

DecisionOutcome _$DecisionOutcomeFromJson(Map<String, dynamic> json) =>
    DecisionOutcome(
      id: json['id'] as String,
      decisionId: json['decisionId'] as String,
      businessId: json['businessId'] as String,
      outcomeType: $enumDecode(_$OutcomeTypeEnumMap, json['outcomeType']),
      measuredImpact: (json['measuredImpact'] as num?)?.toDouble(),
      predictedImpact: (json['predictedImpact'] as num?)?.toDouble(),
      metrics: json['metrics'] as Map<String, dynamic>,
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      notes: json['notes'] as String?,
      accuracyScore: (json['accuracyScore'] as num).toDouble(),
    );

Map<String, dynamic> _$DecisionOutcomeToJson(DecisionOutcome instance) =>
    <String, dynamic>{
      'id': instance.id,
      'decisionId': instance.decisionId,
      'businessId': instance.businessId,
      'outcomeType': _$OutcomeTypeEnumMap[instance.outcomeType]!,
      'measuredImpact': instance.measuredImpact,
      'predictedImpact': instance.predictedImpact,
      'metrics': instance.metrics,
      'measuredAt': instance.measuredAt.toIso8601String(),
      'notes': instance.notes,
      'accuracyScore': instance.accuracyScore,
    };

ModelVersion _$ModelVersionFromJson(Map<String, dynamic> json) => ModelVersion(
  id: json['id'] as String,
  modelName: json['modelName'] as String,
  version: json['version'] as String,
  parameters: json['parameters'] as Map<String, dynamic>,
  performanceMetrics: (json['performanceMetrics'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  deployedAt:
      json['deployedAt'] == null
          ? null
          : DateTime.parse(json['deployedAt'] as String),
  isActive: json['isActive'] as bool? ?? false,
  trainingDataHash: json['trainingDataHash'] as String?,
  trainingDataSize: (json['trainingDataSize'] as num).toInt(),
);

Map<String, dynamic> _$ModelVersionToJson(ModelVersion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'modelName': instance.modelName,
      'version': instance.version,
      'parameters': instance.parameters,
      'performanceMetrics': instance.performanceMetrics,
      'createdAt': instance.createdAt.toIso8601String(),
      'deployedAt': instance.deployedAt?.toIso8601String(),
      'isActive': instance.isActive,
      'trainingDataHash': instance.trainingDataHash,
      'trainingDataSize': instance.trainingDataSize,
    };

LearningProgress _$LearningProgressFromJson(Map<String, dynamic> json) =>
    LearningProgress(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      context: $enumDecode(_$LearningContextEnumMap, json['context']),
      accuracyMetrics: (json['accuracyMetrics'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      improvementMetrics: (json['improvementMetrics'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      feedbackCount: (json['feedbackCount'] as num).toInt(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      learningRate: (json['learningRate'] as num).toDouble(),
      adaptationHistory: json['adaptationHistory'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$LearningProgressToJson(LearningProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'context': _$LearningContextEnumMap[instance.context]!,
      'accuracyMetrics': instance.accuracyMetrics,
      'improvementMetrics': instance.improvementMetrics,
      'feedbackCount': instance.feedbackCount,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'learningRate': instance.learningRate,
      'adaptationHistory': instance.adaptationHistory,
    };

UserPreference _$UserPreferenceFromJson(Map<String, dynamic> json) =>
    UserPreference(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      preferenceType: json['preferenceType'] as String,
      preferenceData: json['preferenceData'] as Map<String, dynamic>,
      confidence: (json['confidence'] as num).toDouble(),
      learnedAt: DateTime.parse(json['learnedAt'] as String),
      lastUsed: DateTime.parse(json['lastUsed'] as String),
      usageCount: (json['usageCount'] as num).toInt(),
    );

Map<String, dynamic> _$UserPreferenceToJson(UserPreference instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'preferenceType': instance.preferenceType,
      'preferenceData': instance.preferenceData,
      'confidence': instance.confidence,
      'learnedAt': instance.learnedAt.toIso8601String(),
      'lastUsed': instance.lastUsed.toIso8601String(),
      'usageCount': instance.usageCount,
    };

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
  originalDecision: json['originalDecision'],
  optimizedDecision: json['optimizedDecision'],
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
