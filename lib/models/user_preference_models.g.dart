// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preference_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferenceProfile _$UserPreferenceProfileFromJson(
  Map<String, dynamic> json,
) => UserPreferenceProfile(
  userId: json['userId'] as String,
  businessId: json['businessId'] as String,
  decisionPreferences: (json['decisionPreferences'] as Map<String, dynamic>)
      .map((k, e) => MapEntry(k, (e as num).toDouble())),
  riskTolerance: (json['riskTolerance'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  behaviorPatterns: json['behaviorPatterns'] as Map<String, dynamic>,
  featureUsage: Map<String, int>.from(json['featureUsage'] as Map),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserPreferenceProfileToJson(
  UserPreferenceProfile instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'businessId': instance.businessId,
  'decisionPreferences': instance.decisionPreferences,
  'riskTolerance': instance.riskTolerance,
  'behaviorPatterns': instance.behaviorPatterns,
  'featureUsage': instance.featureUsage,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

PersonalizedRecommendation _$PersonalizedRecommendationFromJson(
  Map<String, dynamic> json,
) => PersonalizedRecommendation(
  id: json['id'] as String,
  userId: json['userId'] as String,
  businessId: json['businessId'] as String,
  recommendationType: json['recommendationType'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  confidenceScore: (json['confidenceScore'] as num).toDouble(),
  recommendationData: json['recommendationData'] as Map<String, dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isViewed: json['isViewed'] as bool? ?? false,
  isAccepted: json['isAccepted'] as bool? ?? false,
);

Map<String, dynamic> _$PersonalizedRecommendationToJson(
  PersonalizedRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'businessId': instance.businessId,
  'recommendationType': instance.recommendationType,
  'title': instance.title,
  'description': instance.description,
  'confidenceScore': instance.confidenceScore,
  'recommendationData': instance.recommendationData,
  'createdAt': instance.createdAt.toIso8601String(),
  'isViewed': instance.isViewed,
  'isAccepted': instance.isAccepted,
};

UserFeedback _$UserFeedbackFromJson(Map<String, dynamic> json) => UserFeedback(
  id: json['id'] as String,
  userId: json['userId'] as String,
  businessId: json['businessId'] as String,
  decisionType: json['decisionType'] as String,
  outcome: json['outcome'] as String,
  rating: (json['rating'] as num).toDouble(),
  comments: json['comments'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  contextData: json['contextData'] as Map<String, dynamic>,
);

Map<String, dynamic> _$UserFeedbackToJson(UserFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'businessId': instance.businessId,
      'decisionType': instance.decisionType,
      'outcome': instance.outcome,
      'rating': instance.rating,
      'comments': instance.comments,
      'timestamp': instance.timestamp.toIso8601String(),
      'contextData': instance.contextData,
    };
