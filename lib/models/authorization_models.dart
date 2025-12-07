import 'package:json_annotation/json_annotation.dart';

part 'authorization_models.g.dart';

// Type aliases for backward compatibility
typedef PermissionType = AutoPilotPermission;
typedef UserPermission = UserRole;

/// Represents different roles in the AI AutoPilot system
enum AutoPilotRole {
  @JsonValue('owner')
  owner,
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('operator')
  operator,
  @JsonValue('viewer')
  viewer,
}

/// Represents different permission types for AutoPilot features
enum AutoPilotPermission {
  @JsonValue('view_decisions')
  viewDecisions,
  @JsonValue('approve_decisions')
  approveDecisions,
  @JsonValue('execute_actions')
  executeActions,
  @JsonValue('modify_settings')
  modifySettings,
  @JsonValue('emergency_override')
  emergencyOverride,
  @JsonValue('delegate_permissions')
  delegatePermissions,
  @JsonValue('view_audit_logs')
  viewAuditLogs,
  @JsonValue('manage_workflows')
  manageWorkflows,
  @JsonValue('configure_thresholds')
  configureThresholds,
  @JsonValue('access_sensitive_data')
  accessSensitiveData,
  @JsonValue('manage_users')
  manageUsers,
  @JsonValue('configure_autopilot')
  configureAutopilot,
  @JsonValue('audit_access')
  auditAccess,
}

/// Represents approval levels for different types of decisions
enum ApprovalLevel {
  @JsonValue('none')
  none,
  @JsonValue('single')
  single,
  @JsonValue('dual')
  dual,
  @JsonValue('committee')
  committee,
  @JsonValue('board')
  board,
}

/// Represents the urgency level of a decision or action
enum UrgencyLevel {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
  @JsonValue('emergency')
  emergency,
}

/// Represents the status of an approval request
enum ApprovalStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('expired')
  expired,
  @JsonValue('overridden')
  overridden,
}

@JsonSerializable()
class UserRole {
  final String userId;
  final String businessId;
  final AutoPilotRole role;
  final List<AutoPilotPermission> permissions;
  final DateTime assignedAt;
  final DateTime? expiresAt;
  final String assignedBy;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const UserRole({
    required this.userId,
    required this.businessId,
    required this.role,
    required this.permissions,
    required this.assignedAt,
    this.expiresAt,
    required this.assignedBy,
    this.isActive = true,
    this.metadata = const {},
  });

  factory UserRole.fromJson(Map<String, dynamic> json) =>
      _$UserRoleFromJson(json);
  Map<String, dynamic> toJson() => _$UserRoleToJson(this);

  UserRole copyWith({
    String? userId,
    String? businessId,
    AutoPilotRole? role,
    List<AutoPilotPermission>? permissions,
    DateTime? assignedAt,
    DateTime? expiresAt,
    String? assignedBy,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return UserRole(
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      assignedAt: assignedAt ?? this.assignedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      assignedBy: assignedBy ?? this.assignedBy,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class ApprovalWorkflow {
  final String id;
  final String businessId;
  final String name;
  final String description;
  final ApprovalLevel requiredLevel;
  final List<String> approverRoles;
  final List<String> approverUserIds;
  final int minimumApprovals;
  final Duration timeoutDuration;
  final bool allowEmergencyOverride;
  final Map<String, dynamic> conditions;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  const ApprovalWorkflow({
    required this.id,
    required this.businessId,
    required this.name,
    required this.description,
    required this.requiredLevel,
    required this.approverRoles,
    required this.approverUserIds,
    required this.minimumApprovals,
    required this.timeoutDuration,
    this.allowEmergencyOverride = false,
    this.conditions = const {},
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  factory ApprovalWorkflow.fromJson(Map<String, dynamic> json) =>
      _$ApprovalWorkflowFromJson(json);
  Map<String, dynamic> toJson() => _$ApprovalWorkflowToJson(this);
}

@JsonSerializable()
class ApprovalRequest {
  final String id;
  final String businessId;
  final String workflowId;
  final String requesterId;
  final String decisionId;
  final String actionId;
  final String title;
  final String description;
  final UrgencyLevel urgency;
  final ApprovalStatus status;
  final List<ApprovalResponse> responses;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime expiresAt;
  final Map<String, dynamic> context;
  final Map<String, dynamic> metadata;

  const ApprovalRequest({
    required this.id,
    required this.businessId,
    required this.workflowId,
    required this.requesterId,
    required this.decisionId,
    required this.actionId,
    required this.title,
    required this.description,
    required this.urgency,
    required this.status,
    required this.responses,
    required this.requestedAt,
    this.approvedAt,
    this.rejectedAt,
    required this.expiresAt,
    this.context = const {},
    this.metadata = const {},
  });

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) =>
      _$ApprovalRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ApprovalRequestToJson(this);
}

@JsonSerializable()
class ApprovalResponse {
  final String id;
  final String requestId;
  final String approverId;
  final ApprovalStatus decision;
  final String? comments;
  final DateTime respondedAt;
  final Map<String, dynamic> metadata;

  const ApprovalResponse({
    required this.id,
    required this.requestId,
    required this.approverId,
    required this.decision,
    this.comments,
    required this.respondedAt,
    this.metadata = const {},
  });

  factory ApprovalResponse.fromJson(Map<String, dynamic> json) =>
      _$ApprovalResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApprovalResponseToJson(this);
}

@JsonSerializable()
class EmergencyOverride {
  final String id;
  final String businessId;
  final String userId;
  final String requestId;
  final String reason;
  final UrgencyLevel urgency;
  final DateTime overriddenAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final bool isActive;
  final Map<String, dynamic> context;

  const EmergencyOverride({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.requestId,
    required this.reason,
    required this.urgency,
    required this.overriddenAt,
    this.approvedBy,
    this.approvedAt,
    this.isActive = true,
    this.context = const {},
  });

  factory EmergencyOverride.fromJson(Map<String, dynamic> json) =>
      _$EmergencyOverrideFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyOverrideToJson(this);
}

@JsonSerializable()
class PermissionDelegation {
  final String id;
  final String businessId;
  final String delegatorId;
  final String delegateeId;
  final List<AutoPilotPermission> permissions;
  final DateTime delegatedAt;
  final DateTime expiresAt;
  final String? reason;
  final bool isActive;
  final Map<String, dynamic> conditions;

  const PermissionDelegation({
    required this.id,
    required this.businessId,
    required this.delegatorId,
    required this.delegateeId,
    required this.permissions,
    required this.delegatedAt,
    required this.expiresAt,
    this.reason,
    this.isActive = true,
    this.conditions = const {},
  });

  factory PermissionDelegation.fromJson(Map<String, dynamic> json) =>
      _$PermissionDelegationFromJson(json);
  Map<String, dynamic> toJson() => _$PermissionDelegationToJson(this);
}

@JsonSerializable()
class AuthorizationContext {
  final String userId;
  final String businessId;
  final String sessionId;
  final String? deviceId;
  final String? ipAddress;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const AuthorizationContext({
    required this.userId,
    required this.businessId,
    required this.sessionId,
    this.deviceId,
    this.ipAddress,
    required this.timestamp,
    this.metadata = const {},
  });

  factory AuthorizationContext.fromJson(Map<String, dynamic> json) =>
      _$AuthorizationContextFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorizationContextToJson(this);
}

@JsonSerializable()
class EscalationRule {
  final String id;
  final String businessId;
  final String name;
  final Duration timeoutDuration;
  final List<String> escalationPath;
  final Map<String, dynamic> conditions;
  final bool isActive;

  const EscalationRule({
    required this.id,
    required this.businessId,
    required this.name,
    required this.timeoutDuration,
    required this.escalationPath,
    this.conditions = const {},
    this.isActive = true,
  });

  factory EscalationRule.fromJson(Map<String, dynamic> json) =>
      _$EscalationRuleFromJson(json);
  Map<String, dynamic> toJson() => _$EscalationRuleToJson(this);
}
