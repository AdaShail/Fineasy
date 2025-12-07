import 'package:json_annotation/json_annotation.dart';

part 'rollback_models.g.dart';

enum RollbackStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
  available,
}

@JsonSerializable()
class ActionRollback {
  final String actionId;
  final String businessId;
  final String actionType;
  final Map<String, dynamic> originalData;
  final Map<String, dynamic> rollbackData;
  final RollbackStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final List<RollbackStep> steps;
  final String? id;
  final String? rollbackType;
  final List<RollbackStep>? rollbackSteps;
  final String? initiatedBy;
  final DateTime? initiatedAt;

  const ActionRollback({
    required this.actionId,
    required this.businessId,
    required this.actionType,
    required this.originalData,
    required this.rollbackData,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    required this.steps,
    this.id,
    this.rollbackType,
    this.rollbackSteps,
    this.initiatedBy,
    this.initiatedAt,
  });

  factory ActionRollback.fromJson(Map<String, dynamic> json) =>
      _$ActionRollbackFromJson(json);

  Map<String, dynamic> toJson() => _$ActionRollbackToJson(this);
}

@JsonSerializable()
class DataBackup {
  final String backupId;
  final String businessId;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> backupData;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isRestored;
  final String? restoredAt;
  final String? id;
  final String? backupType;
  final String? restoredBy;

  const DataBackup({
    required this.backupId,
    required this.businessId,
    required this.entityType,
    required this.entityId,
    required this.backupData,
    required this.createdAt,
    required this.expiresAt,
    this.isRestored = false,
    this.restoredAt,
    this.id,
    this.backupType,
    this.restoredBy,
  });

  factory DataBackup.fromJson(Map<String, dynamic> json) =>
      _$DataBackupFromJson(json);

  Map<String, dynamic> toJson() => _$DataBackupToJson(this);
}

@JsonSerializable()
class EmergencyStop {
  final String stopId;
  final String businessId;
  final String reason;
  final DateTime initiatedAt;
  final DateTime? resolvedAt;
  final bool isActive;
  final List<String> affectedSystems;
  final Map<String, dynamic> stopDetails;
  final String? id;
  final String? initiatedBy;
  final String? stopType;
  final List<String>? affectedFeatures;
  final DateTime? createdAt;
  final DateTime? deactivatedAt;
  final String? deactivatedBy;

  const EmergencyStop({
    required this.stopId,
    required this.businessId,
    required this.reason,
    required this.initiatedAt,
    this.resolvedAt,
    this.isActive = true,
    required this.affectedSystems,
    required this.stopDetails,
    this.id,
    this.initiatedBy,
    this.stopType,
    this.affectedFeatures,
    this.createdAt,
    this.deactivatedAt,
    this.deactivatedBy,
  });

  factory EmergencyStop.fromJson(Map<String, dynamic> json) =>
      _$EmergencyStopFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyStopToJson(this);
}

@JsonSerializable()
class RollbackStep {
  final String stepId;
  final String rollbackId;
  final String stepType;
  final String description;
  final RollbackStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic> stepData;
  final String? errorMessage;
  final String? id;
  final int? stepNumber;
  final String? rollbackAction;
  final Map<String, dynamic>? rollbackParameters;
  final DateTime? executedAt;

  const RollbackStep({
    required this.stepId,
    required this.rollbackId,
    required this.stepType,
    required this.description,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.stepData,
    this.errorMessage,
    this.id,
    this.stepNumber,
    this.rollbackAction,
    this.rollbackParameters,
    this.executedAt,
  });

  factory RollbackStep.fromJson(Map<String, dynamic> json) =>
      _$RollbackStepFromJson(json);

  Map<String, dynamic> toJson() => _$RollbackStepToJson(this);
}
