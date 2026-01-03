import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/accounting/rbac_models.dart';
import 'audit_service.dart';
import '../models/audit_models.dart';

/// Service for managing role-based access control for accounting features
class AccountingRBACService {
  final Uuid _uuid = const Uuid();
  final AuditService _auditService = AuditService();

  // In-memory storage - in production, use database
  final Map<String, AccountingUserRole> _userRoles = {};
  final Map<String, AccessControlRule> _accessRules = {};
  final Map<String, UserSession> _sessions = {};
  final List<AccessAuditLog> _auditLogs = [];

  StreamController<AccessAuditLog>? _auditController;

  Stream<AccessAuditLog> get auditStream {
    _auditController ??= StreamController<AccessAuditLog>.broadcast();
    return _auditController!.stream;
  }

  /// Initialize RBAC service for a user
  Future<void> initialize(String userId, String businessId) async {
    try {
      // Create default admin role if no role exists
      final existingRole = await getUserRole(userId, businessId);
      if (existingRole == null) {
        await assignRole(
          userId: userId,
          businessId: businessId,
          role: AccountingRole.financeManager,
          assignedBy: 'system',
        );
      }

    } catch (e) {
      rethrow;
    }
  }

  /// Assign role to user
  Future<AccountingUserRole> assignRole({
    required String userId,
    required String businessId,
    required AccountingRole role,
    required String assignedBy,
    List<String>? restrictedAccounts,
    List<String>? restrictedCostCenters,
    DateTime? expiresAt,
  }) async {
    try {
      final permissions = _getDefaultPermissionsForRole(role);

      final userRole = AccountingUserRole(
        id: _uuid.v4(),
        userId: userId,
        businessId: businessId,
        role: role,
        permissions: permissions,
        restrictedAccounts: restrictedAccounts ?? [],
        restrictedCostCenters: restrictedCostCenters ?? [],
        assignedAt: DateTime.now(),
        expiresAt: expiresAt,
        assignedBy: assignedBy,
        isActive: true,
      );

      final key = '${userId}_$businessId';
      _userRoles[key] = userRole;

      await _logAudit(
        businessId: businessId,
        userId: assignedBy,
        action: 'assign_role',
        resourceType: 'user_role',
        resourceId: userRole.id,
        granted: true,
        context: {
          'target_user': userId,
          'role': role.toString(),
          'permissions_count': permissions.length,
        },
      );

      return userRole;
    } catch (e) {
      rethrow;
    }
  }

  /// Get user role
  Future<AccountingUserRole?> getUserRole(
    String userId,
    String businessId,
  ) async {
    try {
      final key = '${userId}_$businessId';
      final role = _userRoles[key];

      // Check if role has expired
      if (role != null &&
          role.expiresAt != null &&
          role.expiresAt!.isBefore(DateTime.now())) {
        return null;
      }

      return role;
    } catch (e) {
      return null;
    }
  }

  /// Check if user has specific permission
  Future<bool> hasPermission({
    required String userId,
    required String businessId,
    required AccountingPermission permission,
    String? resourceId,
    String? resourceType,
  }) async {
    try {
      final userRole = await getUserRole(userId, businessId);
      if (userRole == null || !userRole.isActive) {
        await _logAudit(
          businessId: businessId,
          userId: userId,
          action: 'check_permission',
          resourceType: resourceType ?? 'unknown',
          resourceId: resourceId ?? 'unknown',
          granted: false,
          denialReason: 'No active role found',
        );
        return false;
      }

      // Check basic permission
      if (!userRole.permissions.contains(permission)) {
        await _logAudit(
          businessId: businessId,
          userId: userId,
          action: 'check_permission',
          resourceType: resourceType ?? 'unknown',
          resourceId: resourceId ?? 'unknown',
          granted: false,
          denialReason: 'Permission not granted: ${permission.toString()}',
        );
        return false;
      }

      // Check resource-specific access rules
      if (resourceId != null && resourceType != null) {
        final hasResourceAccess = await _checkResourceAccess(
          userId: userId,
          businessId: businessId,
          resourceType: resourceType,
          resourceId: resourceId,
          userRole: userRole,
        );

        if (!hasResourceAccess) {
          await _logAudit(
            businessId: businessId,
            userId: userId,
            action: 'check_permission',
            resourceType: resourceType,
            resourceId: resourceId,
            granted: false,
            denialReason: 'Resource access denied',
          );
          return false;
        }
      }

      await _logAudit(
        businessId: businessId,
        userId: userId,
        action: 'check_permission',
        resourceType: resourceType ?? 'unknown',
        resourceId: resourceId ?? 'unknown',
        granted: true,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Grant additional permission to user
  Future<bool> grantPermission({
    required String userId,
    required String businessId,
    required AccountingPermission permission,
    required String grantedBy,
  }) async {
    try {
      final userRole = await getUserRole(userId, businessId);
      if (userRole == null) {
        throw Exception('User role not found');
      }

      if (userRole.permissions.contains(permission)) {
        return true; // Already has permission
      }

      final updatedPermissions = [...userRole.permissions, permission];
      final updatedRole = userRole.copyWith(permissions: updatedPermissions);

      final key = '${userId}_$businessId';
      _userRoles[key] = updatedRole;

      await _logAudit(
        businessId: businessId,
        userId: grantedBy,
        action: 'grant_permission',
        resourceType: 'user_role',
        resourceId: userRole.id,
        granted: true,
        context: {'target_user': userId, 'permission': permission.toString()},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Revoke permission from user
  Future<bool> revokePermission({
    required String userId,
    required String businessId,
    required AccountingPermission permission,
    required String revokedBy,
  }) async {
    try {
      final userRole = await getUserRole(userId, businessId);
      if (userRole == null) {
        throw Exception('User role not found');
      }

      final updatedPermissions =
          userRole.permissions.where((p) => p != permission).toList();
      final updatedRole = userRole.copyWith(permissions: updatedPermissions);

      final key = '${userId}_$businessId';
      _userRoles[key] = updatedRole;

      await _logAudit(
        businessId: businessId,
        userId: revokedBy,
        action: 'revoke_permission',
        resourceType: 'user_role',
        resourceId: userRole.id,
        granted: true,
        context: {'target_user': userId, 'permission': permission.toString()},
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create access control rule for specific resource
  Future<AccessControlRule> createAccessRule({
    required String businessId,
    required String resourceType,
    required String resourceId,
    required String createdBy,
    List<String>? allowedUserIds,
    List<AccountingRole>? allowedRoles,
    List<AccountingPermission>? requiredPermissions,
    Map<String, dynamic>? conditions,
  }) async {
    try {
      final rule = AccessControlRule(
        id: _uuid.v4(),
        businessId: businessId,
        resourceType: resourceType,
        resourceId: resourceId,
        allowedUserIds: allowedUserIds ?? [],
        allowedRoles: allowedRoles ?? [],
        requiredPermissions: requiredPermissions ?? [],
        conditions: conditions ?? {},
        isActive: true,
        createdAt: DateTime.now(),
        createdBy: createdBy,
      );

      _accessRules[rule.id] = rule;

      await _logAudit(
        businessId: businessId,
        userId: createdBy,
        action: 'create_access_rule',
        resourceType: resourceType,
        resourceId: resourceId,
        granted: true,
      );

      return rule;
    } catch (e) {
      rethrow;
    }
  }

  /// Start user session
  Future<UserSession> startSession({
    required String userId,
    required String businessId,
    required String deviceId,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final session = UserSession(
        id: _uuid.v4(),
        userId: userId,
        businessId: businessId,
        deviceId: deviceId,
        ipAddress: ipAddress,
        userAgent: userAgent,
        startedAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
        isActive: true,
      );

      _sessions[session.id] = session;

      await _logAudit(
        businessId: businessId,
        userId: userId,
        action: 'start_session',
        resourceType: 'session',
        resourceId: session.id,
        granted: true,
        context: {'device_id': deviceId, 'ip_address': ipAddress},
      );

      return session;
    } catch (e) {
      rethrow;
    }
  }

  /// End user session
  Future<void> endSession(String sessionId) async {
    try {
      final session = _sessions[sessionId];
      if (session == null) return;

      final updatedSession = UserSession(
        id: session.id,
        userId: session.userId,
        businessId: session.businessId,
        deviceId: session.deviceId,
        ipAddress: session.ipAddress,
        userAgent: session.userAgent,
        startedAt: session.startedAt,
        endedAt: DateTime.now(),
        lastActivityAt: session.lastActivityAt,
        isActive: false,
      );

      _sessions[sessionId] = updatedSession;

      await _logAudit(
        businessId: session.businessId,
        userId: session.userId,
        action: 'end_session',
        resourceType: 'session',
        resourceId: sessionId,
        granted: true,
      );
    } catch (e) {
    }
  }

  /// Get audit logs for a business
  Future<List<AccessAuditLog>> getAuditLogs({
    required String businessId,
    String? userId,
    String? resourceType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      var logs = _auditLogs.where((log) => log.businessId == businessId);

      if (userId != null) {
        logs = logs.where((log) => log.userId == userId);
      }

      if (resourceType != null) {
        logs = logs.where((log) => log.resourceType == resourceType);
      }

      if (startDate != null) {
        logs = logs.where((log) => log.timestamp.isAfter(startDate));
      }

      if (endDate != null) {
        logs = logs.where((log) => log.timestamp.isBefore(endDate));
      }

      return logs.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all users with roles in a business
  Future<List<AccountingUserRole>> getBusinessUsers(String businessId) async {
    try {
      return _userRoles.values
          .where((role) => role.businessId == businessId && role.isActive)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Private helper methods

  List<AccountingPermission> _getDefaultPermissionsForRole(
    AccountingRole role,
  ) {
    switch (role) {
      case AccountingRole.cfo:
        return AccountingPermission.values; // All permissions

      case AccountingRole.financeManager:
        return [
          AccountingPermission.viewAccounts,
          AccountingPermission.createAccounts,
          AccountingPermission.editAccounts,
          AccountingPermission.viewJournalEntries,
          AccountingPermission.createJournalEntries,
          AccountingPermission.editJournalEntries,
          AccountingPermission.postJournalEntries,
          AccountingPermission.viewFinancialReports,
          AccountingPermission.exportFinancialReports,
          AccountingPermission.viewBankReconciliation,
          AccountingPermission.performBankReconciliation,
          AccountingPermission.viewInventory,
          AccountingPermission.manageInventory,
          AccountingPermission.viewGSTReports,
          AccountingPermission.fileGSTReturns,
          AccountingPermission.viewPayroll,
          AccountingPermission.processPayroll,
          AccountingPermission.viewPaymentSchedules,
          AccountingPermission.createPaymentSchedules,
          AccountingPermission.viewAuditTrail,
        ];

      case AccountingRole.accountant:
        return [
          AccountingPermission.viewAccounts,
          AccountingPermission.createAccounts,
          AccountingPermission.editAccounts,
          AccountingPermission.viewJournalEntries,
          AccountingPermission.createJournalEntries,
          AccountingPermission.editJournalEntries,
          AccountingPermission.postJournalEntries,
          AccountingPermission.viewFinancialReports,
          AccountingPermission.viewBankReconciliation,
          AccountingPermission.performBankReconciliation,
          AccountingPermission.viewInventory,
          AccountingPermission.viewGSTReports,
          AccountingPermission.viewPaymentSchedules,
        ];

      case AccountingRole.auditor:
        return [
          AccountingPermission.viewAccounts,
          AccountingPermission.viewJournalEntries,
          AccountingPermission.viewFinancialReports,
          AccountingPermission.exportFinancialReports,
          AccountingPermission.viewBankReconciliation,
          AccountingPermission.viewInventory,
          AccountingPermission.viewGSTReports,
          AccountingPermission.viewPayroll,
          AccountingPermission.viewPaymentSchedules,
          AccountingPermission.viewAuditTrail,
        ];

      case AccountingRole.dataEntry:
        return [
          AccountingPermission.viewAccounts,
          AccountingPermission.viewJournalEntries,
          AccountingPermission.createJournalEntries,
          AccountingPermission.viewInventory,
        ];

      case AccountingRole.viewer:
        return [
          AccountingPermission.viewAccounts,
          AccountingPermission.viewJournalEntries,
          AccountingPermission.viewFinancialReports,
          AccountingPermission.viewInventory,
          AccountingPermission.viewGSTReports,
        ];
    }
  }

  Future<bool> _checkResourceAccess({
    required String userId,
    required String businessId,
    required String resourceType,
    required String resourceId,
    required AccountingUserRole userRole,
  }) async {
    try {
      // Check if there are specific access rules for this resource
      final rules = _accessRules.values.where(
        (rule) =>
            rule.businessId == businessId &&
            rule.resourceType == resourceType &&
            rule.resourceId == resourceId &&
            rule.isActive,
      );

      if (rules.isEmpty) {
        return true; // No specific rules, allow access based on permissions
      }

      // Check if user matches any rule
      for (final rule in rules) {
        // Check if user is explicitly allowed
        if (rule.allowedUserIds.contains(userId)) {
          return true;
        }

        // Check if user's role is allowed
        if (rule.allowedRoles.contains(userRole.role)) {
          return true;
        }

        // Check if user has all required permissions
        if (rule.requiredPermissions.isNotEmpty) {
          final hasAllPermissions = rule.requiredPermissions.every(
            (perm) => userRole.permissions.contains(perm),
          );
          if (hasAllPermissions) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _logAudit({
    required String businessId,
    required String userId,
    required String action,
    required String resourceType,
    required String resourceId,
    required bool granted,
    String? denialReason,
    Map<String, dynamic>? context,
  }) async {
    try {
      final log = AccessAuditLog(
        id: _uuid.v4(),
        businessId: businessId,
        userId: userId,
        action: action,
        resourceType: resourceType,
        resourceId: resourceId,
        granted: granted,
        denialReason: denialReason,
        context: context ?? {},
        timestamp: DateTime.now(),
      );

      _auditLogs.add(log);
      if (_auditController != null && !_auditController!.isClosed) {
        _auditController!.add(log);
      }

      // Also log to main audit service
      await _auditService.logAuditEvent(
        businessId,
        AuditEventType.authorization,
        resourceType,
        resourceId,
        action,
        userId: userId,
        metadata: {
          'granted': granted,
          'denial_reason': denialReason,
          ...?context,
        },
      );
    } catch (e) {
    }
  }

  /// Dispose resources
  void dispose() {
    _auditController?.close();
    _auditController = null;
  }

  /// Clear all data (for testing)
  void clearAll() {
    _userRoles.clear();
    _accessRules.clear();
    _sessions.clear();
    _auditLogs.clear();
  }
}
