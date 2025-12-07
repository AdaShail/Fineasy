// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rollback_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionRollback _$ActionRollbackFromJson(Map<String, dynamic> json) =>
    ActionRollback(
      actionId: json['actionId'] as String,
      businessId: json['businessId'] as String,
      actionType: json['actionType'] as String,
      originalData: json['originalData'] as Map<String, dynamic>,
      rollbackData: json['rollbackData'] as Map<String, dynamic>,
      status: $enumDecode(_$RollbackStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt:
          json['completedAt'] == null
              ? null
              : DateTime.parse(json['completedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
      steps:
          (json['steps'] as List<dynamic>)
              .map((e) => RollbackStep.fromJson(e as Map<String, dynamic>))
              .toList(),
      id: json['id'] as String?,
      rollbackType: json['rollbackType'] as String?,
      rollbackSteps:
          (json['rollbackSteps'] as List<dynamic>?)
              ?.map((e) => RollbackStep.fromJson(e as Map<String, dynamic>))
              .toList(),
      initiatedBy: json['initiatedBy'] as String?,
      initiatedAt:
          json['initiatedAt'] == null
              ? null
              : DateTime.parse(json['initiatedAt'] as String),
    );

Map<String, dynamic> _$ActionRollbackToJson(ActionRollback instance) =>
    <String, dynamic>{
      'actionId': instance.actionId,
      'businessId': instance.businessId,
      'actionType': instance.actionType,
      'originalData': instance.originalData,
      'rollbackData': instance.rollbackData,
      'status': _$RollbackStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'steps': instance.steps,
      'id': instance.id,
      'rollbackType': instance.rollbackType,
      'rollbackSteps': instance.rollbackSteps,
      'initiatedBy': instance.initiatedBy,
      'initiatedAt': instance.initiatedAt?.toIso8601String(),
    };

const _$RollbackStatusEnumMap = {
  RollbackStatus.pending: 'pending',
  RollbackStatus.inProgress: 'inProgress',
  RollbackStatus.completed: 'completed',
  RollbackStatus.failed: 'failed',
  RollbackStatus.cancelled: 'cancelled',
  RollbackStatus.available: 'available',
};

DataBackup _$DataBackupFromJson(Map<String, dynamic> json) => DataBackup(
  backupId: json['backupId'] as String,
  businessId: json['businessId'] as String,
  entityType: json['entityType'] as String,
  entityId: json['entityId'] as String,
  backupData: json['backupData'] as Map<String, dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  isRestored: json['isRestored'] as bool? ?? false,
  restoredAt: json['restoredAt'] as String?,
  id: json['id'] as String?,
  backupType: json['backupType'] as String?,
  restoredBy: json['restoredBy'] as String?,
);

Map<String, dynamic> _$DataBackupToJson(DataBackup instance) =>
    <String, dynamic>{
      'backupId': instance.backupId,
      'businessId': instance.businessId,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'backupData': instance.backupData,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'isRestored': instance.isRestored,
      'restoredAt': instance.restoredAt,
      'id': instance.id,
      'backupType': instance.backupType,
      'restoredBy': instance.restoredBy,
    };

EmergencyStop _$EmergencyStopFromJson(Map<String, dynamic> json) =>
    EmergencyStop(
      stopId: json['stopId'] as String,
      businessId: json['businessId'] as String,
      reason: json['reason'] as String,
      initiatedAt: DateTime.parse(json['initiatedAt'] as String),
      resolvedAt:
          json['resolvedAt'] == null
              ? null
              : DateTime.parse(json['resolvedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      affectedSystems:
          (json['affectedSystems'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      stopDetails: json['stopDetails'] as Map<String, dynamic>,
      id: json['id'] as String?,
      initiatedBy: json['initiatedBy'] as String?,
      stopType: json['stopType'] as String?,
      affectedFeatures:
          (json['affectedFeatures'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      deactivatedAt:
          json['deactivatedAt'] == null
              ? null
              : DateTime.parse(json['deactivatedAt'] as String),
      deactivatedBy: json['deactivatedBy'] as String?,
    );

Map<String, dynamic> _$EmergencyStopToJson(EmergencyStop instance) =>
    <String, dynamic>{
      'stopId': instance.stopId,
      'businessId': instance.businessId,
      'reason': instance.reason,
      'initiatedAt': instance.initiatedAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'isActive': instance.isActive,
      'affectedSystems': instance.affectedSystems,
      'stopDetails': instance.stopDetails,
      'id': instance.id,
      'initiatedBy': instance.initiatedBy,
      'stopType': instance.stopType,
      'affectedFeatures': instance.affectedFeatures,
      'createdAt': instance.createdAt?.toIso8601String(),
      'deactivatedAt': instance.deactivatedAt?.toIso8601String(),
      'deactivatedBy': instance.deactivatedBy,
    };

RollbackStep _$RollbackStepFromJson(Map<String, dynamic> json) => RollbackStep(
  stepId: json['stepId'] as String,
  rollbackId: json['rollbackId'] as String,
  stepType: json['stepType'] as String,
  description: json['description'] as String,
  status: $enumDecode(_$RollbackStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt:
      json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
  stepData: json['stepData'] as Map<String, dynamic>,
  errorMessage: json['errorMessage'] as String?,
  id: json['id'] as String?,
  stepNumber: (json['stepNumber'] as num?)?.toInt(),
  rollbackAction: json['rollbackAction'] as String?,
  rollbackParameters: json['rollbackParameters'] as Map<String, dynamic>?,
  executedAt:
      json['executedAt'] == null
          ? null
          : DateTime.parse(json['executedAt'] as String),
);

Map<String, dynamic> _$RollbackStepToJson(RollbackStep instance) =>
    <String, dynamic>{
      'stepId': instance.stepId,
      'rollbackId': instance.rollbackId,
      'stepType': instance.stepType,
      'description': instance.description,
      'status': _$RollbackStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'stepData': instance.stepData,
      'errorMessage': instance.errorMessage,
      'id': instance.id,
      'stepNumber': instance.stepNumber,
      'rollbackAction': instance.rollbackAction,
      'rollbackParameters': instance.rollbackParameters,
      'executedAt': instance.executedAt?.toIso8601String(),
    };
