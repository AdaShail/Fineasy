// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorization_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRole _$UserRoleFromJson(Map<String, dynamic> json) => UserRole(
  userId: json['userId'] as String,
  businessId: json['businessId'] as String,
  role: $enumDecode(_$AutoPilotRoleEnumMap, json['role']),
  permissions:
      (json['permissions'] as List<dynamic>)
          .map((e) => $enumDecode(_$AutoPilotPermissionEnumMap, e))
          .toList(),
  assignedAt: DateTime.parse(json['assignedAt'] as String),
  expiresAt:
      json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
  assignedBy: json['assignedBy'] as String,
  isActive: json['isActive'] as bool? ?? true,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$UserRoleToJson(UserRole instance) => <String, dynamic>{
  'userId': instance.userId,
  'businessId': instance.businessId,
  'role': _$AutoPilotRoleEnumMap[instance.role]!,
  'permissions':
      instance.permissions
          .map((e) => _$AutoPilotPermissionEnumMap[e]!)
          .toList(),
  'assignedAt': instance.assignedAt.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'assignedBy': instance.assignedBy,
  'isActive': instance.isActive,
  'metadata': instance.metadata,
};

const _$AutoPilotRoleEnumMap = {
  AutoPilotRole.owner: 'owner',
  AutoPilotRole.admin: 'admin',
  AutoPilotRole.manager: 'manager',
  AutoPilotRole.operator: 'operator',
  AutoPilotRole.viewer: 'viewer',
};

const _$AutoPilotPermissionEnumMap = {
  AutoPilotPermission.viewDecisions: 'view_decisions',
  AutoPilotPermission.approveDecisions: 'approve_decisions',
  AutoPilotPermission.executeActions: 'execute_actions',
  AutoPilotPermission.modifySettings: 'modify_settings',
  AutoPilotPermission.emergencyOverride: 'emergency_override',
  AutoPilotPermission.delegatePermissions: 'delegate_permissions',
  AutoPilotPermission.viewAuditLogs: 'view_audit_logs',
  AutoPilotPermission.manageWorkflows: 'manage_workflows',
  AutoPilotPermission.configureThresholds: 'configure_thresholds',
  AutoPilotPermission.accessSensitiveData: 'access_sensitive_data',
  AutoPilotPermission.manageUsers: 'manage_users',
  AutoPilotPermission.configureAutopilot: 'configure_autopilot',
  AutoPilotPermission.auditAccess: 'audit_access',
};

ApprovalWorkflow _$ApprovalWorkflowFromJson(Map<String, dynamic> json) =>
    ApprovalWorkflow(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      requiredLevel: $enumDecode(_$ApprovalLevelEnumMap, json['requiredLevel']),
      approverRoles:
          (json['approverRoles'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      approverUserIds:
          (json['approverUserIds'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      minimumApprovals: (json['minimumApprovals'] as num).toInt(),
      timeoutDuration: Duration(
        microseconds: (json['timeoutDuration'] as num).toInt(),
      ),
      allowEmergencyOverride: json['allowEmergencyOverride'] as bool? ?? false,
      conditions: json['conditions'] as Map<String, dynamic>? ?? const {},
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$ApprovalWorkflowToJson(ApprovalWorkflow instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'name': instance.name,
      'description': instance.description,
      'requiredLevel': _$ApprovalLevelEnumMap[instance.requiredLevel]!,
      'approverRoles': instance.approverRoles,
      'approverUserIds': instance.approverUserIds,
      'minimumApprovals': instance.minimumApprovals,
      'timeoutDuration': instance.timeoutDuration.inMicroseconds,
      'allowEmergencyOverride': instance.allowEmergencyOverride,
      'conditions': instance.conditions,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
    };

const _$ApprovalLevelEnumMap = {
  ApprovalLevel.none: 'none',
  ApprovalLevel.single: 'single',
  ApprovalLevel.dual: 'dual',
  ApprovalLevel.committee: 'committee',
  ApprovalLevel.board: 'board',
};

ApprovalRequest _$ApprovalRequestFromJson(Map<String, dynamic> json) =>
    ApprovalRequest(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      workflowId: json['workflowId'] as String,
      requesterId: json['requesterId'] as String,
      decisionId: json['decisionId'] as String,
      actionId: json['actionId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      urgency: $enumDecode(_$UrgencyLevelEnumMap, json['urgency']),
      status: $enumDecode(_$ApprovalStatusEnumMap, json['status']),
      responses:
          (json['responses'] as List<dynamic>)
              .map((e) => ApprovalResponse.fromJson(e as Map<String, dynamic>))
              .toList(),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      approvedAt:
          json['approvedAt'] == null
              ? null
              : DateTime.parse(json['approvedAt'] as String),
      rejectedAt:
          json['rejectedAt'] == null
              ? null
              : DateTime.parse(json['rejectedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      context: json['context'] as Map<String, dynamic>? ?? const {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ApprovalRequestToJson(ApprovalRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'workflowId': instance.workflowId,
      'requesterId': instance.requesterId,
      'decisionId': instance.decisionId,
      'actionId': instance.actionId,
      'title': instance.title,
      'description': instance.description,
      'urgency': _$UrgencyLevelEnumMap[instance.urgency]!,
      'status': _$ApprovalStatusEnumMap[instance.status]!,
      'responses': instance.responses,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'rejectedAt': instance.rejectedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'context': instance.context,
      'metadata': instance.metadata,
    };

const _$UrgencyLevelEnumMap = {
  UrgencyLevel.low: 'low',
  UrgencyLevel.medium: 'medium',
  UrgencyLevel.high: 'high',
  UrgencyLevel.critical: 'critical',
  UrgencyLevel.emergency: 'emergency',
};

const _$ApprovalStatusEnumMap = {
  ApprovalStatus.pending: 'pending',
  ApprovalStatus.approved: 'approved',
  ApprovalStatus.rejected: 'rejected',
  ApprovalStatus.expired: 'expired',
  ApprovalStatus.overridden: 'overridden',
};

ApprovalResponse _$ApprovalResponseFromJson(Map<String, dynamic> json) =>
    ApprovalResponse(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      approverId: json['approverId'] as String,
      decision: $enumDecode(_$ApprovalStatusEnumMap, json['decision']),
      comments: json['comments'] as String?,
      respondedAt: DateTime.parse(json['respondedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$ApprovalResponseToJson(ApprovalResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requestId': instance.requestId,
      'approverId': instance.approverId,
      'decision': _$ApprovalStatusEnumMap[instance.decision]!,
      'comments': instance.comments,
      'respondedAt': instance.respondedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

EmergencyOverride _$EmergencyOverrideFromJson(Map<String, dynamic> json) =>
    EmergencyOverride(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      userId: json['userId'] as String,
      requestId: json['requestId'] as String,
      reason: json['reason'] as String,
      urgency: $enumDecode(_$UrgencyLevelEnumMap, json['urgency']),
      overriddenAt: DateTime.parse(json['overriddenAt'] as String),
      approvedBy: json['approvedBy'] as String?,
      approvedAt:
          json['approvedAt'] == null
              ? null
              : DateTime.parse(json['approvedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      context: json['context'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$EmergencyOverrideToJson(EmergencyOverride instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'userId': instance.userId,
      'requestId': instance.requestId,
      'reason': instance.reason,
      'urgency': _$UrgencyLevelEnumMap[instance.urgency]!,
      'overriddenAt': instance.overriddenAt.toIso8601String(),
      'approvedBy': instance.approvedBy,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'isActive': instance.isActive,
      'context': instance.context,
    };

PermissionDelegation _$PermissionDelegationFromJson(
  Map<String, dynamic> json,
) => PermissionDelegation(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  delegatorId: json['delegatorId'] as String,
  delegateeId: json['delegateeId'] as String,
  permissions:
      (json['permissions'] as List<dynamic>)
          .map((e) => $enumDecode(_$AutoPilotPermissionEnumMap, e))
          .toList(),
  delegatedAt: DateTime.parse(json['delegatedAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  reason: json['reason'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  conditions: json['conditions'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$PermissionDelegationToJson(
  PermissionDelegation instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'delegatorId': instance.delegatorId,
  'delegateeId': instance.delegateeId,
  'permissions':
      instance.permissions
          .map((e) => _$AutoPilotPermissionEnumMap[e]!)
          .toList(),
  'delegatedAt': instance.delegatedAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'reason': instance.reason,
  'isActive': instance.isActive,
  'conditions': instance.conditions,
};

AuthorizationContext _$AuthorizationContextFromJson(
  Map<String, dynamic> json,
) => AuthorizationContext(
  userId: json['userId'] as String,
  businessId: json['businessId'] as String,
  sessionId: json['sessionId'] as String,
  deviceId: json['deviceId'] as String?,
  ipAddress: json['ipAddress'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$AuthorizationContextToJson(
  AuthorizationContext instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'businessId': instance.businessId,
  'sessionId': instance.sessionId,
  'deviceId': instance.deviceId,
  'ipAddress': instance.ipAddress,
  'timestamp': instance.timestamp.toIso8601String(),
  'metadata': instance.metadata,
};

EscalationRule _$EscalationRuleFromJson(Map<String, dynamic> json) =>
    EscalationRule(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      name: json['name'] as String,
      timeoutDuration: Duration(
        microseconds: (json['timeoutDuration'] as num).toInt(),
      ),
      escalationPath:
          (json['escalationPath'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      conditions: json['conditions'] as Map<String, dynamic>? ?? const {},
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$EscalationRuleToJson(EscalationRule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'name': instance.name,
      'timeoutDuration': instance.timeoutDuration.inMicroseconds,
      'escalationPath': instance.escalationPath,
      'conditions': instance.conditions,
      'isActive': instance.isActive,
    };
