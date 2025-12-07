import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/authorization_models.dart';
import '../models/autopilot_models.dart';
// import '../services/auth_service.dart'; // Commented out as not used

/// Service for managing authorization and approval workflows for AI AutoPilot
class AuthorizationService {
  // final AuthService _authService = AuthService(); // Commented out as not used
  final Uuid _uuid = const Uuid();

  // In-memory storage for demo purposes - in production, use database
  final Map<String, UserPermission> _userPermissions = {};
  final Map<String, ApprovalWorkflow> _approvalWorkflows = {};
  final Map<String, ApprovalRequest> _approvalRequests = {};
  final Map<String, EmergencyOverride> _emergencyOverrides = {};
  final Map<String, PermissionDelegation> _delegations = {};

  // Enhanced authorization features
  final StreamController<Map<String, dynamic>> _authorizationController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get authorizationStream =>
      _authorizationController.stream;

  /// Check if user has specific permission for a business
  Future<bool> hasPermission(
    String userId,
    String businessId,
    PermissionType permission,
  ) async {
    try {
      final userPermission = await getUserPermission(userId, businessId);
      if (userPermission == null || !userPermission.isActive) {
        return false;
      }

      // Check if permission has expired
      if (userPermission.expiresAt != null &&
          userPermission.expiresAt!.isBefore(DateTime.now())) {
        return false;
      }

      return userPermission.permissions.contains(permission);
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }

  /// Get user permission for a business
  Future<UserPermission?> getUserPermission(
    String userId,
    String businessId,
  ) async {
    try {
      final key = '${userId}_$businessId';
      return _userPermissions[key];
    } catch (e) {
      debugPrint('Error getting user permission: $e');
      return null;
    }
  }

  /// Grant permission to user
  Future<bool> grantPermission(
    String userId,
    String businessId,
    AutoPilotRole role,
    List<PermissionType> permissions,
    String grantedBy, {
    DateTime? expiresAt,
  }) async {
    try {
      // Check if granter has permission to manage users
      final canGrant = await hasPermission(
        grantedBy,
        businessId,
        PermissionType.manageUsers,
      );

      if (!canGrant) {
        throw Exception('Insufficient permissions to grant access');
      }

      final permission = UserRole(
        userId: userId,
        businessId: businessId,
        role: role,
        permissions: permissions,
        assignedAt: DateTime.now(),
        expiresAt: expiresAt,
        assignedBy: grantedBy,
        isActive: true,
      );

      final key = '${userId}_$businessId';
      _userPermissions[key] = permission;

      return true;
    } catch (e) {
      debugPrint('Error granting permission: $e');
      return false;
    }
  }

  /// Revoke user permission
  Future<bool> revokePermission(
    String userId,
    String businessId,
    String revokedBy,
  ) async {
    try {
      // Check if revoker has permission to manage users
      final canRevoke = await hasPermission(
        revokedBy,
        businessId,
        PermissionType.manageUsers,
      );

      if (!canRevoke) {
        throw Exception('Insufficient permissions to revoke access');
      }

      final key = '${userId}_$businessId';
      final permission = _userPermissions[key];

      if (permission != null) {
        _userPermissions[key] = permission.copyWith(isActive: false);
      }

      return true;
    } catch (e) {
      debugPrint('Error revoking permission: $e');
      return false;
    }
  }

  /// Create approval workflow
  Future<String?> createApprovalWorkflow(
    String businessId,
    String name,
    String description,
    List<DecisionType> decisionTypes,
    ApprovalLevel approvalLevel,
    List<UserRole> requiredRoles,
    Map<String, dynamic> thresholdConditions,
    int timeoutHours,
    List<EscalationRule> escalationRules,
    String createdBy,
  ) async {
    try {
      // Check if creator has permission to configure autopilot
      final canCreate = await hasPermission(
        createdBy,
        businessId,
        PermissionType.configureAutopilot,
      );

      if (!canCreate) {
        throw Exception('Insufficient permissions to create approval workflow');
      }

      final workflow = ApprovalWorkflow(
        id: _uuid.v4(),
        businessId: businessId,
        name: name,
        description: description,
        requiredLevel: approvalLevel,
        approverRoles:
            requiredRoles.map((role) => role.role.toString()).toList(),
        approverUserIds: [],
        minimumApprovals: 1,
        timeoutDuration: Duration(hours: timeoutHours),
        allowEmergencyOverride: true,
        conditions: thresholdConditions,
        isActive: true,
        createdAt: DateTime.now(),
        createdBy: 'system',
      );

      _approvalWorkflows[workflow.id] = workflow;
      return workflow.id;
    } catch (e) {
      debugPrint('Error creating approval workflow: $e');
      return null;
    }
  }

  /// Get approval workflow for decision
  Future<ApprovalWorkflow?> getApprovalWorkflowForDecision(
    String businessId,
    DecisionType decisionType,
    Map<String, dynamic> decisionContext,
  ) async {
    try {
      // Find matching workflow
      for (final workflow in _approvalWorkflows.values) {
        if (workflow.businessId == businessId &&
            workflow.isActive &&
            workflow.conditions.containsKey('decision_types')) {
          // Check threshold conditions
          if (_meetsThresholdConditions(workflow.conditions, decisionContext)) {
            return workflow;
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error getting approval workflow: $e');
      return null;
    }
  }

  /// Check if decision requires approval
  Future<bool> requiresApproval(
    String businessId,
    DecisionType decisionType,
    Map<String, dynamic> decisionContext,
  ) async {
    try {
      final workflow = await getApprovalWorkflowForDecision(
        businessId,
        decisionType,
        decisionContext,
      );

      return workflow != null;
    } catch (e) {
      debugPrint('Error checking approval requirement: $e');
      return false;
    }
  }

  /// Create approval request
  Future<String?> createApprovalRequest(
    String decisionId,
    String businessId,
    DecisionType decisionType,
    Map<String, dynamic> decisionContext,
    String requestedBy,
  ) async {
    try {
      final workflow = await getApprovalWorkflowForDecision(
        businessId,
        decisionType,
        decisionContext,
      );

      if (workflow == null) {
        throw Exception('No approval workflow found for decision');
      }

      // Find required approvers based on roles
      // Find required approvers based on roles
      // final requiredApprovers = await _findRequiredApprovers(
      //   businessId,
      //   workflow.approverRoles,
      // );

      final request = ApprovalRequest(
        id: _uuid.v4(),
        businessId: businessId,
        workflowId: workflow.id,
        requesterId: requestedBy,
        decisionId: decisionId,
        actionId: decisionId,
        title: 'Approval Required',
        description: 'Decision requires approval',
        urgency: UrgencyLevel.medium,
        status: ApprovalStatus.pending,
        responses: [],
        requestedAt: DateTime.now(),
        expiresAt: DateTime.now().add(workflow.timeoutDuration),
        context: decisionContext,
      );

      _approvalRequests[request.id] = request;
      return request.id;
    } catch (e) {
      debugPrint('Error creating approval request: $e');
      return null;
    }
  }

  /// Submit approval response
  Future<bool> submitApprovalResponse(
    String requestId,
    String approverId,
    ApprovalStatus status,
    String? comments,
  ) async {
    try {
      final request = _approvalRequests[requestId];
      if (request == null) {
        throw Exception('Approval request not found');
      }

      // Check if request has expired
      if (request.expiresAt.isBefore(DateTime.now())) {
        _approvalRequests[requestId] = ApprovalRequest(
          id: request.id,
          businessId: request.businessId,
          workflowId: request.workflowId,
          requesterId: request.requesterId,
          decisionId: request.decisionId,
          actionId: request.actionId,
          title: request.title,
          description: request.description,
          urgency: request.urgency,
          status: ApprovalStatus.expired,
          responses: request.responses,
          requestedAt: request.requestedAt,
          expiresAt: request.expiresAt,
          context: request.context,
        );
        return false;
      }

      // Check if approver is authorized (simplified check)
      // TODO: Implement proper authorization check based on workflow
      // if (!request.requiredApprovers.contains(approverId)) {
      //   throw Exception('User not authorized to approve this request');
      // }

      // Get approver role
      final approverPermission = await getUserPermission(
        approverId,
        request.businessId,
      );

      if (approverPermission == null) {
        throw Exception('Approver permission not found');
      }

      final response = ApprovalResponse(
        id: _uuid.v4(),
        requestId: requestId,
        approverId: approverId,
        decision: status,
        comments: comments,
        respondedAt: DateTime.now(),
      );

      // Add response to request
      final updatedApprovers = List<ApprovalResponse>.from(request.responses)
        ..add(response);

      // Determine final status
      ApprovalStatus finalStatus = ApprovalStatus.pending;
      DateTime? completedAt;

      if (status == ApprovalStatus.rejected) {
        finalStatus = ApprovalStatus.rejected;
        completedAt = DateTime.now();
      } else if (status == ApprovalStatus.approved) {
        // Check if all required approvals are received
        final workflow = _approvalWorkflows[request.workflowId];
        if (workflow != null &&
            _hasAllRequiredApprovals(workflow, updatedApprovers)) {
          finalStatus = ApprovalStatus.approved;
          completedAt = DateTime.now();
        }
      }

      final updatedResponses = [...request.responses, response];

      _approvalRequests[requestId] = ApprovalRequest(
        id: request.id,
        businessId: request.businessId,
        workflowId: request.workflowId,
        requesterId: request.requesterId,
        decisionId: request.decisionId,
        actionId: request.actionId,
        title: request.title,
        description: request.description,
        urgency: request.urgency,
        status: finalStatus,
        responses: updatedResponses,
        requestedAt: request.requestedAt,
        approvedAt: finalStatus == ApprovalStatus.approved ? completedAt : null,
        rejectedAt: finalStatus == ApprovalStatus.rejected ? completedAt : null,
        expiresAt: request.expiresAt,
        context: request.context,
      );

      return true;
    } catch (e) {
      debugPrint('Error submitting approval response: $e');
      return false;
    }
  }

  /// Get approval request status
  Future<ApprovalRequest?> getApprovalRequest(String requestId) async {
    try {
      return _approvalRequests[requestId];
    } catch (e) {
      debugPrint('Error getting approval request: $e');
      return null;
    }
  }

  /// Get pending approval requests for user
  Future<List<ApprovalRequest>> getPendingApprovalRequests(
    String userId,
    String businessId,
  ) async {
    try {
      final pendingRequests = <ApprovalRequest>[];

      for (final request in _approvalRequests.values) {
        if (request.status == ApprovalStatus.pending &&
            request.expiresAt.isAfter(DateTime.now())) {
          // TODO: Check if user is in required approvers list

          // Check if user hasn't already responded
          final hasResponded = request.responses.any(
            (response) => response.approverId == userId,
          );

          if (!hasResponded) {
            pendingRequests.add(request);
          }
        }
      }

      return pendingRequests;
    } catch (e) {
      debugPrint('Error getting pending approval requests: $e');
      return [];
    }
  }

  /// Create emergency override
  Future<String?> createEmergencyOverride(
    String businessId,
    String initiatedBy,
    String overrideType,
    String reason,
    List<String> affectedDecisions,
    int overrideDurationHours,
  ) async {
    try {
      // Check if user has emergency override permission
      final canOverride = await hasPermission(
        initiatedBy,
        businessId,
        PermissionType.emergencyOverride,
      );

      if (!canOverride) {
        throw Exception('Insufficient permissions for emergency override');
      }

      final override = EmergencyOverride(
        id: _uuid.v4(),
        businessId: businessId,
        userId: initiatedBy,
        requestId:
            affectedDecisions.isNotEmpty ? affectedDecisions.first : 'unknown',
        reason: reason,
        urgency: UrgencyLevel.emergency,
        overriddenAt: DateTime.now(),
        isActive: true,
        context: {
          'override_type': overrideType,
          'affected_decisions': affectedDecisions,
          'duration_hours': overrideDurationHours,
        },
      );

      _emergencyOverrides[override.id] = override;
      return override.id;
    } catch (e) {
      debugPrint('Error creating emergency override: $e');
      return null;
    }
  }

  /// Check if emergency override is active
  Future<bool> hasActiveEmergencyOverride(
    String businessId,
    String decisionId,
  ) async {
    try {
      for (final override in _emergencyOverrides.values) {
        if (override.businessId == businessId &&
            override.isActive &&
            override.overriddenAt
                .add(Duration(hours: 24))
                .isAfter(DateTime.now()) &&
            (override.context['affected_decisions'] == null ||
                (override.context['affected_decisions'] as List).contains(
                  decisionId,
                ))) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error checking emergency override: $e');
      return false;
    }
  }

  /// Deactivate emergency override
  Future<bool> deactivateEmergencyOverride(
    String overrideId,
    String deactivatedBy,
  ) async {
    try {
      final override = _emergencyOverrides[overrideId];
      if (override == null) {
        throw Exception('Emergency override not found');
      }

      // Check if user has permission to deactivate
      final canDeactivate = await hasPermission(
        deactivatedBy,
        override.businessId,
        PermissionType.emergencyOverride,
      );

      if (!canDeactivate) {
        throw Exception('Insufficient permissions to deactivate override');
      }

      _emergencyOverrides[overrideId] = EmergencyOverride(
        id: override.id,
        businessId: override.businessId,
        userId: override.userId,
        requestId: override.requestId,
        reason: override.reason,
        urgency: override.urgency,
        overriddenAt: override.overriddenAt,
        approvedBy: deactivatedBy,
        approvedAt: DateTime.now(),
        isActive: false,
        context: override.context,
      );

      return true;
    } catch (e) {
      debugPrint('Error deactivating emergency override: $e');
      return false;
    }
  }

  /// Get default permissions for role
  List<PermissionType> getDefaultPermissionsForRole(AutoPilotRole role) {
    switch (role) {
      case AutoPilotRole.owner:
        return PermissionType.values; // All permissions
      case AutoPilotRole.admin:
        return [
          PermissionType.viewDecisions,
          PermissionType.approveDecisions,
          PermissionType.executeActions,
          PermissionType.configureAutopilot,
          PermissionType.auditAccess,
          PermissionType.manageUsers,
        ];
      case AutoPilotRole.manager:
        return [
          PermissionType.viewDecisions,
          PermissionType.approveDecisions,
          PermissionType.executeActions,
          PermissionType.auditAccess,
        ];
      case AutoPilotRole.operator:
        return [
          PermissionType.viewDecisions,
          PermissionType.approveDecisions,
          PermissionType.auditAccess,
        ];
      case AutoPilotRole.viewer:
        return [PermissionType.viewDecisions];
    }
  }

  /// Enhanced authorization methods for AI AutoPilot

  /// Initialize authorization service
  Future<void> initialize(String userId, String businessId) async {
    try {
      // Load user permissions and set up default admin role for testing
      await grantPermission(
        userId,
        businessId,
        AutoPilotRole.admin,
        getDefaultPermissionsForRole(AutoPilotRole.admin),
        'system',
      );

      _authorizationController.add({
        'type': 'initialized',
        'userId': userId,
        'businessId': businessId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error initializing authorization service: $e');
      rethrow;
    }
  }

  /// Check if user has specific permission with enhanced validation
  Future<bool> hasPermissionEnhanced(
    String userId,
    String businessId,
    PermissionType permission, {
    Map<String, dynamic>? context,
  }) async {
    try {
      // Check basic permission
      final hasBasicPermission = await hasPermission(
        userId,
        businessId,
        permission,
      );
      if (hasBasicPermission) return true;

      // Check delegated permissions
      final delegatedPermissions = await getDelegatedPermissions(
        userId,
        businessId,
      );
      return delegatedPermissions.contains(permission);
    } catch (e) {
      debugPrint('Error checking enhanced permission: $e');
      return false;
    }
  }

  /// Get delegated permissions for a user
  Future<List<PermissionType>> getDelegatedPermissions(
    String userId,
    String businessId,
  ) async {
    try {
      final permissions = <PermissionType>[];

      for (final delegation in _delegations.values) {
        if (delegation.delegateeId == userId &&
            delegation.businessId == businessId &&
            delegation.isActive &&
            delegation.expiresAt.isAfter(DateTime.now())) {
          permissions.addAll(delegation.permissions);
        }
      }

      return permissions;
    } catch (e) {
      debugPrint('Error getting delegated permissions: $e');
      return [];
    }
  }

  /// Delegate permissions to another user
  Future<String?> delegatePermissions({
    required String businessId,
    required String delegatorId,
    required String delegateeId,
    required List<PermissionType> permissions,
    required Duration duration,
    String? reason,
    Map<String, dynamic> conditions = const {},
  }) async {
    try {
      // Check if delegator has permission to delegate
      final canDelegate = await hasPermission(
        delegatorId,
        businessId,
        PermissionType.manageUsers,
      );

      if (!canDelegate) {
        throw Exception('Insufficient permissions to delegate');
      }

      // Verify delegator has all permissions they're trying to delegate
      for (final permission in permissions) {
        final hasPermission = await hasPermissionEnhanced(
          delegatorId,
          businessId,
          permission,
        );
        if (!hasPermission) {
          throw Exception(
            'Cannot delegate permission not possessed: $permission',
          );
        }
      }

      final delegation = PermissionDelegation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: businessId,
        delegatorId: delegatorId,
        delegateeId: delegateeId,
        permissions: permissions,
        delegatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(duration),
        reason: reason,
        isActive: true,
        conditions: conditions,
      );

      _delegations[delegation.id] = delegation;

      _authorizationController.add({
        'type': 'permissions_delegated',
        'delegationId': delegation.id,
        'delegatorId': delegatorId,
        'delegateeId': delegateeId,
        'permissions': permissions.map((p) => p.toString()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      return delegation.id;
    } catch (e) {
      debugPrint('Error delegating permissions: $e');
      return null;
    }
  }

  /// Revoke permission delegation
  Future<bool> revokeDelegation(String delegationId) async {
    try {
      final delegation = _delegations[delegationId];
      if (delegation == null) return false;

      _delegations[delegationId] = PermissionDelegation(
        id: delegation.id,
        businessId: delegation.businessId,
        delegatorId: delegation.delegatorId,
        delegateeId: delegation.delegateeId,
        permissions: delegation.permissions,
        delegatedAt: delegation.delegatedAt,
        expiresAt: delegation.expiresAt,
        reason: delegation.reason,
        isActive: false,
        conditions: delegation.conditions,
      );

      _authorizationController.add({
        'type': 'delegation_revoked',
        'delegationId': delegationId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error revoking delegation: $e');
      return false;
    }
  }

  /// Enhanced emergency override with comprehensive validation
  Future<String?> executeEmergencyOverrideEnhanced({
    required String businessId,
    required String userId,
    required String requestId,
    required String reason,
    required String urgencyLevel,
    Map<String, dynamic> context = const {},
  }) async {
    try {
      // Validate emergency override permission
      final canOverride = await hasPermission(
        userId,
        businessId,
        PermissionType.emergencyOverride,
      );

      if (!canOverride) {
        throw Exception('User does not have emergency override permission');
      }

      // Validate urgency level
      if (urgencyLevel != 'emergency' && urgencyLevel != 'critical') {
        throw Exception(
          'Emergency override only allowed for critical or emergency situations',
        );
      }

      final overrideId = await createEmergencyOverride(
        businessId,
        userId,
        'enhanced_override',
        reason,
        [requestId],
        24, // 24 hour duration
      );

      if (overrideId != null) {
        _authorizationController.add({
          'type': 'emergency_override',
          'overrideId': overrideId,
          'requestId': requestId,
          'userId': userId,
          'urgency': urgencyLevel,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }

      return overrideId;
    } catch (e) {
      debugPrint('Error executing enhanced emergency override: $e');
      return null;
    }
  }

  /// Execute emergency override (required by AuthorizationManagerService)
  Future<String?> executeEmergencyOverride({
    required String businessId,
    required String userId,
    required String requestId,
    required String reason,
    required UrgencyLevel urgency,
    Map<String, dynamic> context = const {},
  }) async {
    return executeEmergencyOverrideEnhanced(
      businessId: businessId,
      userId: userId,
      requestId: requestId,
      reason: reason,
      urgencyLevel: urgency.toString().split('.').last,
      context: context,
    );
  }

  /// Get user role for a specific business
  Future<UserRole?> getUserRole(String userId, String businessId) async {
    try {
      return await getUserPermission(userId, businessId);
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  /// Get effective permissions for a user (direct + delegated)
  Future<List<AutoPilotPermission>> getEffectivePermissions(
    String userId,
    String businessId,
  ) async {
    try {
      final permissions = <AutoPilotPermission>{};

      // Get direct permissions
      final userPermission = await getUserPermission(userId, businessId);
      if (userPermission != null && userPermission.isActive) {
        permissions.addAll(userPermission.permissions);
      }

      // Get delegated permissions
      final delegatedPermissions = await getDelegatedPermissions(
        userId,
        businessId,
      );
      permissions.addAll(delegatedPermissions);

      return permissions.toList();
    } catch (e) {
      debugPrint('Error getting effective permissions: $e');
      return [];
    }
  }

  /// Get pending approvals for a user
  Future<List<ApprovalRequest>> getPendingApprovals(
    String userId,
    String businessId,
  ) async {
    try {
      return await getPendingApprovalRequests(userId, businessId);
    } catch (e) {
      debugPrint('Error getting pending approvals: $e');
      return [];
    }
  }

  /// Get comprehensive authorization status for a user
  Future<Map<String, dynamic>> getUserAuthorizationStatus(
    String userId,
    String businessId,
  ) async {
    try {
      final userPermission = await getUserPermission(userId, businessId);
      final delegatedPermissions = await getDelegatedPermissions(
        userId,
        businessId,
      );
      final pendingApprovals = await getPendingApprovalRequests(
        userId,
        businessId,
      );

      return {
        'userId': userId,
        'businessId': businessId,
        'role': userPermission?.role.toString(),
        'directPermissions':
            userPermission?.permissions.map((p) => p.toString()).toList() ?? [],
        'delegatedPermissions':
            delegatedPermissions.map((p) => p.toString()).toList(),
        'pendingApprovals': pendingApprovals.length,
        'isActive': userPermission?.isActive ?? false,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting user authorization status: $e');
      return {};
    }
  }

  /// Check if approval is required for a decision
  bool isApprovalRequiredForDecision(AutoPilotDecision decision) {
    try {
      // Determine if approval is required based on decision properties
      if (decision.confidenceScore < 0.7) {
        return true;
      }
      if (decision.type == DecisionType.riskMitigation) {
        return true;
      }
      if (decision.recommendedActions.any(
        (action) =>
            action.type == ActionType.blockTransaction ||
            action.type == ActionType.reserveFunds,
      )) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking approval requirement: $e');
      return true; // Default to requiring approval on error
    }
  }

  /// Enhanced approval request with automatic workflow selection
  Future<String?> requestDecisionApproval({
    required String businessId,
    required String requesterId,
    required AutoPilotDecision decision,
    Map<String, dynamic> additionalContext = const {},
  }) async {
    try {
      final urgencyLevel = _determineUrgencyLevel(decision);

      final context = {
        'decision_type': decision.type.toString(),
        'confidence_score': decision.confidenceScore,
        'action_count': decision.recommendedActions.length,
        'urgency': urgencyLevel,
        ...additionalContext,
      };

      return await createApprovalRequest(
        decision.id,
        businessId,
        decision.type,
        context,
        requesterId,
      );
    } catch (e) {
      debugPrint('Error requesting decision approval: $e');
      return null;
    }
  }

  String _determineUrgencyLevel(AutoPilotDecision decision) {
    if (decision.confidenceScore < 0.3) return 'critical';
    if (decision.type == DecisionType.riskMitigation) return 'high';
    if (decision.confidenceScore < 0.7) return 'medium';
    return 'low';
  }

  /// Dispose resources
  void dispose() {
    _authorizationController.close();
  }

  // Private helper methods

  bool _meetsThresholdConditions(
    Map<String, dynamic> thresholdConditions,
    Map<String, dynamic> decisionContext,
  ) {
    try {
      for (final entry in thresholdConditions.entries) {
        final key = entry.key;
        final threshold = entry.value;
        final contextValue = decisionContext[key];

        if (contextValue == null) continue;

        // Handle different threshold types
        if (threshold is num && contextValue is num) {
          if (contextValue >= threshold) return true;
        } else if (threshold is String && contextValue is String) {
          if (contextValue == threshold) return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error checking threshold conditions: $e');
      return false;
    }
  }

  // Commented out as not currently used
  // Future<List<String>> _findRequiredApprovers(
  //   String businessId,
  //   List<String> requiredRoles,
  // ) async {
  //   try {
  //     final approvers = <String>[];
  //
  //     // Find users with required roles
  //     for (final permission in _userPermissions.values) {
  //       if (permission.businessId == businessId &&
  //           permission.isActive &&
  //           requiredRoles.contains(permission.role.toString())) {
  //         approvers.add(permission.userId);
  //       }
  //     }
  //
  //     return approvers;
  //   } catch (e) {
  //     debugPrint('Error finding required approvers: $e');
  //     return [];
  //   }
  // }

  bool _hasAllRequiredApprovals(
    ApprovalWorkflow workflow,
    List<ApprovalResponse> responses,
  ) {
    try {
      final approvedResponses =
          responses
              .where((r) => r.decision == ApprovalStatus.approved)
              .toList();

      switch (workflow.requiredLevel) {
        case ApprovalLevel.none:
          return true;
        case ApprovalLevel.single:
          return approvedResponses.isNotEmpty;
        case ApprovalLevel.dual:
          return approvedResponses.length >= 2;
        case ApprovalLevel.committee:
          // Require majority of required approvers
          final requiredCount = (workflow.approverRoles.length * 0.6).ceil();
          return approvedResponses.length >= requiredCount;
        case ApprovalLevel.board:
          return approvedResponses.length >= workflow.minimumApprovals;
      }
    } catch (e) {
      debugPrint('Error checking required approvals: $e');
      return false;
    }
  }
}
