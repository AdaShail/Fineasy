import 'package:json_annotation/json_annotation.dart';

part 'learning_models.g.dart';

/// Represents different types of feedback that can be collected
enum FeedbackType {
  @JsonValue('decision_override')
  decisionOverride,
  @JsonValue('action_approval')
  actionApproval,
  @JsonValue('outcome_rating')
  outcomeRating,
  @JsonValue('user_correction')
  userCorrection,
  @JsonValue('performance_feedback')
  performanceFeedback,
}

/// Represents the outcome of a decision or action
enum OutcomeType {
  @JsonValue('success')
  success,
  @JsonValue('partial_success')
  partialSuccess,
  @JsonValue('failure')
  failure,
  @JsonValue('unknown')
  unknown,
}

/// Represents different learning contexts
enum LearningContext {
  @JsonValue('cash_flow_management')
  cashFlowManagement,
  @JsonValue('customer_relationship')
  customerRelationship,
  @JsonValue('supplier_management')
  supplierManagement,
  @JsonValue('risk_assessment')
  riskAssessment,
  @JsonValue('opportunity_identification')
  opportunityIdentification,
}

/// Model for collecting user feedback on AI decisions and actions
@JsonSerializable()
class LearningFeedback {
  final String id;
  final String businessId;
  final String? decisionId;
  final String? actionId;
  final FeedbackType feedbackType;
  final OutcomeType outcomeType;
  final double? actualOutcome;
  final double? predictedOutcome;
  final String? userFeedback;
  final Map<String, dynamic> contextData;
  final LearningContext learningContext;
  final double? userRating; // 1-5 scale
  final String? correctionSuggestion;
  final DateTime recordedAt;
  final DateTime? processedAt;
  final bool isProcessed;

  const LearningFeedback({
    required this.id,
    required this.businessId,
    this.decisionId,
    this.actionId,
    required this.feedbackType,
    required this.outcomeType,
    this.actualOutcome,
    this.predictedOutcome,
    this.userFeedback,
    required this.contextData,
    required this.learningContext,
    this.userRating,
    this.correctionSuggestion,
    required this.recordedAt,
    this.processedAt,
    this.isProcessed = false,
  });

  factory LearningFeedback.fromJson(Map<String, dynamic> json) =>
      _$LearningFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$LearningFeedbackToJson(this);

  LearningFeedback copyWith({
    String? id,
    String? businessId,
    String? decisionId,
    String? actionId,
    FeedbackType? feedbackType,
    OutcomeType? outcomeType,
    double? actualOutcome,
    double? predictedOutcome,
    String? userFeedback,
    Map<String, dynamic>? contextData,
    LearningContext? learningContext,
    double? userRating,
    String? correctionSuggestion,
    DateTime? recordedAt,
    DateTime? processedAt,
    bool? isProcessed,
  }) {
    return LearningFeedback(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      decisionId: decisionId ?? this.decisionId,
      actionId: actionId ?? this.actionId,
      feedbackType: feedbackType ?? this.feedbackType,
      outcomeType: outcomeType ?? this.outcomeType,
      actualOutcome: actualOutcome ?? this.actualOutcome,
      predictedOutcome: predictedOutcome ?? this.predictedOutcome,
      userFeedback: userFeedback ?? this.userFeedback,
      contextData: contextData ?? this.contextData,
      learningContext: learningContext ?? this.learningContext,
      userRating: userRating ?? this.userRating,
      correctionSuggestion: correctionSuggestion ?? this.correctionSuggestion,
      recordedAt: recordedAt ?? this.recordedAt,
      processedAt: processedAt ?? this.processedAt,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}

/// Model for tracking decision outcomes and effectiveness
@JsonSerializable()
class DecisionOutcome {
  final String id;
  final String decisionId;
  final String businessId;
  final OutcomeType outcomeType;
  final double? measuredImpact;
  final double? predictedImpact;
  final Map<String, dynamic> metrics;
  final DateTime measuredAt;
  final String? notes;
  final double accuracyScore;

  const DecisionOutcome({
    required this.id,
    required this.decisionId,
    required this.businessId,
    required this.outcomeType,
    this.measuredImpact,
    this.predictedImpact,
    required this.metrics,
    required this.measuredAt,
    this.notes,
    required this.accuracyScore,
  });

  factory DecisionOutcome.fromJson(Map<String, dynamic> json) =>
      _$DecisionOutcomeFromJson(json);

  Map<String, dynamic> toJson() => _$DecisionOutcomeToJson(this);
}

/// Model for tracking model performance and versions
@JsonSerializable()
class ModelVersion {
  final String id;
  final String modelName;
  final String version;
  final Map<String, dynamic> parameters;
  final Map<String, double> performanceMetrics;
  final DateTime createdAt;
  final DateTime? deployedAt;
  final bool isActive;
  final String? trainingDataHash;
  final int trainingDataSize;

  const ModelVersion({
    required this.id,
    required this.modelName,
    required this.version,
    required this.parameters,
    required this.performanceMetrics,
    required this.createdAt,
    this.deployedAt,
    this.isActive = false,
    this.trainingDataHash,
    required this.trainingDataSize,
  });

  factory ModelVersion.fromJson(Map<String, dynamic> json) =>
      _$ModelVersionFromJson(json);

  Map<String, dynamic> toJson() => _$ModelVersionToJson(this);
}

/// Model for tracking learning progress and optimization
@JsonSerializable()
class LearningProgress {
  final String id;
  final String businessId;
  final LearningContext context;
  final Map<String, double> accuracyMetrics;
  final Map<String, double> improvementMetrics;
  final int feedbackCount;
  final DateTime lastUpdated;
  final double learningRate;
  final Map<String, dynamic> adaptationHistory;

  const LearningProgress({
    required this.id,
    required this.businessId,
    required this.context,
    required this.accuracyMetrics,
    required this.improvementMetrics,
    required this.feedbackCount,
    required this.lastUpdated,
    required this.learningRate,
    required this.adaptationHistory,
  });

  factory LearningProgress.fromJson(Map<String, dynamic> json) =>
      _$LearningProgressFromJson(json);

  Map<String, dynamic> toJson() => _$LearningProgressToJson(this);
}

/// Model for user preferences and personalization
@JsonSerializable()
class UserPreference {
  final String id;
  final String businessId;
  final String preferenceType;
  final Map<String, dynamic> preferenceData;
  final double confidence;
  final DateTime learnedAt;
  final DateTime lastUsed;
  final int usageCount;

  const UserPreference({
    required this.id,
    required this.businessId,
    required this.preferenceType,
    required this.preferenceData,
    required this.confidence,
    required this.learnedAt,
    required this.lastUsed,
    required this.usageCount,
  });

  factory UserPreference.fromJson(Map<String, dynamic> json) =>
      _$UserPreferenceFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferenceToJson(this);
}

/// Model for comprehensive user preference profile
@JsonSerializable()
class UserPreferenceProfile {
  final String businessId;
  final Map<String, double> preferences;
  final Map<String, double> confidenceScores;
  final DateTime lastUpdated;

  UserPreferenceProfile({
    required this.businessId,
    required this.preferences,
    required this.confidenceScores,
    required this.lastUpdated,
  });

  factory UserPreferenceProfile.fromJson(Map<String, dynamic> json) =>
      _$UserPreferenceProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferenceProfileToJson(this);

  double getAccuracyScore() {
    if (confidenceScores.isEmpty) return 0.0;
    return confidenceScores.values.reduce((a, b) => a + b) /
        confidenceScores.length;
  }
}

/// Model for business pattern recognition
@JsonSerializable()
class BusinessPattern {
  final String id;
  final String patternType;
  final String description;
  final Map<String, dynamic> parameters;
  final double confidence;
  final DateTime detectedAt;

  const BusinessPattern({
    required this.id,
    required this.patternType,
    required this.description,
    required this.parameters,
    required this.confidence,
    required this.detectedAt,
  });

  factory BusinessPattern.fromJson(Map<String, dynamic> json) =>
      _$BusinessPatternFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessPatternToJson(this);
}

/// Model for business pattern analysis
@JsonSerializable()
class BusinessPatternModel {
  final String businessId;
  final List<BusinessPattern> detectedPatterns;
  final Map<String, double> seasonalityFactors;
  final TrendAnalysis trendAnalysis;
  final Map<String, double> anomalyThresholds;
  final DateTime lastAnalyzed;

  BusinessPatternModel({
    required this.businessId,
    required this.detectedPatterns,
    required this.seasonalityFactors,
    required this.trendAnalysis,
    required this.anomalyThresholds,
    required this.lastAnalyzed,
  });

  factory BusinessPatternModel.fromJson(Map<String, dynamic> json) =>
      _$BusinessPatternModelFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessPatternModelToJson(this);

  double getRecognitionScore() {
    if (detectedPatterns.isEmpty) return 0.0;
    return detectedPatterns.map((p) => p.confidence).reduce((a, b) => a + b) /
        detectedPatterns.length;
  }
}

/// Model for trend analysis
@JsonSerializable()
class TrendAnalysis {
  final double revenue;
  final double expenses;
  final double customerGrowth;
  final double efficiency;

  const TrendAnalysis({
    required this.revenue,
    required this.expenses,
    required this.customerGrowth,
    required this.efficiency,
  });

  factory TrendAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TrendAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$TrendAnalysisToJson(this);
}

/// Model for decision optimization
@JsonSerializable()
class DecisionOptimization {
  final dynamic originalDecision; // AutoPilotDecision
  final dynamic optimizedDecision; // AutoPilotDecision
  final double confidenceAdjustment;
  final String optimizationReasoning;
  final DateTime appliedAt;

  const DecisionOptimization({
    required this.originalDecision,
    required this.optimizedDecision,
    required this.confidenceAdjustment,
    required this.optimizationReasoning,
    required this.appliedAt,
  });

  factory DecisionOptimization.fromJson(Map<String, dynamic> json) =>
      _$DecisionOptimizationFromJson(json);

  Map<String, dynamic> toJson() => _$DecisionOptimizationToJson(this);
}

/// Model for decision optimization configuration
@JsonSerializable()
class DecisionOptimizationModel {
  final String businessId;
  final Map<String, dynamic> optimizationRules;
  final Map<String, double> contextWeights;
  final List<Map<String, dynamic>> performanceHistory;
  final DateTime lastUpdated;

  DecisionOptimizationModel({
    required this.businessId,
    required this.optimizationRules,
    required this.contextWeights,
    required this.performanceHistory,
    required this.lastUpdated,
  });

  factory DecisionOptimizationModel.fromJson(Map<String, dynamic> json) =>
      _$DecisionOptimizationModelFromJson(json);

  Map<String, dynamic> toJson() => _$DecisionOptimizationModelToJson(this);

  double getEffectivenessScore() {
    if (performanceHistory.isEmpty) return 0.0;
    final scores = performanceHistory.map((h) => h['score'] as double? ?? 0.0);
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  void updateWeights(ModelPerformanceMetrics metrics) {
    // Update weights based on performance metrics
    performanceHistory.add({
      'timestamp': DateTime.now().toIso8601String(),
      'score': metrics.f1Score,
      'accuracy': metrics.accuracy,
    });

    // Keep only recent history
    if (performanceHistory.length > 100) {
      performanceHistory.removeRange(0, performanceHistory.length - 100);
    }
  }
}

/// Model for model performance metrics
@JsonSerializable()
class ModelPerformanceMetrics {
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;

  const ModelPerformanceMetrics({
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
  });

  factory ModelPerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$ModelPerformanceMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$ModelPerformanceMetricsToJson(this);
}

/// Model for personalized recommendations
@JsonSerializable()
class PersonalizedRecommendation {
  final String id;
  final String title;
  final String description;
  final double confidence;
  final Map<String, dynamic> parameters;
  final String reasoning;
  final DateTime generatedAt;

  const PersonalizedRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.confidence,
    required this.parameters,
    required this.reasoning,
    required this.generatedAt,
  });

  factory PersonalizedRecommendation.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalizedRecommendationToJson(this);
}

/// Model for learning analytics
@JsonSerializable()
class LearningAnalytics {
  final String businessId;
  final double learningProgress;
  final double preferenceAccuracy;
  final double patternRecognitionScore;
  final double optimizationEffectiveness;
  final int totalFeedbackSamples;
  final DateTime lastModelUpdate;
  final Map<String, double> improvementTrends;

  const LearningAnalytics({
    required this.businessId,
    required this.learningProgress,
    required this.preferenceAccuracy,
    required this.patternRecognitionScore,
    required this.optimizationEffectiveness,
    required this.totalFeedbackSamples,
    required this.lastModelUpdate,
    required this.improvementTrends,
  });

  factory LearningAnalytics.fromJson(Map<String, dynamic> json) =>
      _$LearningAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$LearningAnalyticsToJson(this);
}

/// Extended user feedback model for adaptive learning
@JsonSerializable()
class UserFeedback {
  final String id;
  final String businessId;
  final String decisionType;
  final double outcome;
  final String? comments;
  final DateTime timestamp;

  const UserFeedback({
    required this.id,
    required this.businessId,
    required this.decisionType,
    required this.outcome,
    this.comments,
    required this.timestamp,
  });

  factory UserFeedback.fromJson(Map<String, dynamic> json) =>
      _$UserFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$UserFeedbackToJson(this);
}
