import 'package:json_annotation/json_annotation.dart';

part 'security_models.g.dart';

enum PermissionType {
  read,
  write,
  delete,
  admin,
  execute,
  approve,
  viewDecisions,
  executeActions,
}

enum UserRole { owner, admin, manager, employee, viewer, auditor }

enum ApprovalLevel { none, manager, admin, owner, board, single, dual }

@JsonSerializable()
class BiasDetectionResult {
  final String detectionId;
  final String businessId;
  final String decisionType;
  final Map<String, double> biasScores;
  final bool thresholdExceeded;
  final List<String> detectedBiases;
  final Map<String, dynamic> analysisData;
  final DateTime analyzedAt;
  final String biasType;

  const BiasDetectionResult({
    required this.detectionId,
    required this.businessId,
    required this.decisionType,
    required this.biasScores,
    required this.thresholdExceeded,
    required this.detectedBiases,
    required this.analysisData,
    required this.analyzedAt,
    required this.biasType,
  });

  factory BiasDetectionResult.fromJson(Map<String, dynamic> json) =>
      _$BiasDetectionResultFromJson(json);

  Map<String, dynamic> toJson() => _$BiasDetectionResultToJson(this);
}

@JsonSerializable()
class FairnessMonitoring {
  final String monitoringId;
  final String businessId;
  final String decisionType;
  final double overallFairnessScore;
  final Map<String, double> demographicScores;
  final List<String> fairnessViolations;
  final Map<String, dynamic> monitoringData;
  final DateTime monitoredAt;

  const FairnessMonitoring({
    required this.monitoringId,
    required this.businessId,
    required this.decisionType,
    required this.overallFairnessScore,
    required this.demographicScores,
    required this.fairnessViolations,
    required this.monitoringData,
    required this.monitoredAt,
  });

  factory FairnessMonitoring.fromJson(Map<String, dynamic> json) =>
      _$FairnessMonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$FairnessMonitoringToJson(this);
}
