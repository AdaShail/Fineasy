// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BiasDetectionResult _$BiasDetectionResultFromJson(Map<String, dynamic> json) =>
    BiasDetectionResult(
      detectionId: json['detectionId'] as String,
      businessId: json['businessId'] as String,
      decisionType: json['decisionType'] as String,
      biasScores: (json['biasScores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      thresholdExceeded: json['thresholdExceeded'] as bool,
      detectedBiases:
          (json['detectedBiases'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      analysisData: json['analysisData'] as Map<String, dynamic>,
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      biasType: json['biasType'] as String,
    );

Map<String, dynamic> _$BiasDetectionResultToJson(
  BiasDetectionResult instance,
) => <String, dynamic>{
  'detectionId': instance.detectionId,
  'businessId': instance.businessId,
  'decisionType': instance.decisionType,
  'biasScores': instance.biasScores,
  'thresholdExceeded': instance.thresholdExceeded,
  'detectedBiases': instance.detectedBiases,
  'analysisData': instance.analysisData,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
  'biasType': instance.biasType,
};

FairnessMonitoring _$FairnessMonitoringFromJson(Map<String, dynamic> json) =>
    FairnessMonitoring(
      monitoringId: json['monitoringId'] as String,
      businessId: json['businessId'] as String,
      decisionType: json['decisionType'] as String,
      overallFairnessScore: (json['overallFairnessScore'] as num).toDouble(),
      demographicScores: (json['demographicScores'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      fairnessViolations:
          (json['fairnessViolations'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      monitoringData: json['monitoringData'] as Map<String, dynamic>,
      monitoredAt: DateTime.parse(json['monitoredAt'] as String),
    );

Map<String, dynamic> _$FairnessMonitoringToJson(FairnessMonitoring instance) =>
    <String, dynamic>{
      'monitoringId': instance.monitoringId,
      'businessId': instance.businessId,
      'decisionType': instance.decisionType,
      'overallFairnessScore': instance.overallFairnessScore,
      'demographicScores': instance.demographicScores,
      'fairnessViolations': instance.fairnessViolations,
      'monitoringData': instance.monitoringData,
      'monitoredAt': instance.monitoredAt.toIso8601String(),
    };
