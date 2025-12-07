import 'package:json_annotation/json_annotation.dart';

part 'adaptive_learning_models.g.dart';

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
  final Map<String, dynamic> originalDecision;
  final Map<String, dynamic> optimizedDecision;
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
