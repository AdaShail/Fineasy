import 'package:json_annotation/json_annotation.dart';

part 'user_preference_models.g.dart';

@JsonSerializable()
class UserPreferenceProfile {
  final String userId;
  final String businessId;
  final Map<String, double> decisionPreferences;
  final Map<String, double> riskTolerance;
  final Map<String, dynamic> behaviorPatterns;
  final Map<String, int> featureUsage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserPreferenceProfile({
    required this.userId,
    required this.businessId,
    required this.decisionPreferences,
    required this.riskTolerance,
    required this.behaviorPatterns,
    required this.featureUsage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferenceProfile.fromJson(Map<String, dynamic> json) =>
      _$UserPreferenceProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferenceProfileToJson(this);
}

@JsonSerializable()
class PersonalizedRecommendation {
  final String id;
  final String userId;
  final String businessId;
  final String recommendationType;
  final String title;
  final String description;
  final double confidenceScore;
  final Map<String, dynamic> recommendationData;
  final DateTime createdAt;
  final bool isViewed;
  final bool isAccepted;

  const PersonalizedRecommendation({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.recommendationType,
    required this.title,
    required this.description,
    required this.confidenceScore,
    required this.recommendationData,
    required this.createdAt,
    this.isViewed = false,
    this.isAccepted = false,
  });

  factory PersonalizedRecommendation.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalizedRecommendationToJson(this);
}

@JsonSerializable()
class UserFeedback {
  final String id;
  final String userId;
  final String businessId;
  final String decisionType;
  final String outcome;
  final double rating;
  final String? comments;
  final DateTime timestamp;
  final Map<String, dynamic> contextData;

  const UserFeedback({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.decisionType,
    required this.outcome,
    required this.rating,
    this.comments,
    required this.timestamp,
    required this.contextData,
  });

  factory UserFeedback.fromJson(Map<String, dynamic> json) =>
      _$UserFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$UserFeedbackToJson(this);
}
