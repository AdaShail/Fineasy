import 'package:flutter/material.dart';
import '../models/accounting/rbac_models.dart';
import '../services/accounting_rbac_service.dart';

/// Provider for managing accounting RBAC state
class AccountingRBACProvider extends ChangeNotifier {
  final AccountingRBACService _rbacService = AccountingRBACService();

  AccountingUserRole? _currentUserRole;
  List<AccountingUserRole> _businessUsers = [];
  List<AccessAuditLog> _recentAuditLogs = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  AccountingUserRole? get currentUserRole => _currentUserRole;
  List<AccountingUserRole> get businessUsers => _businessUsers;
  List<AccessAuditLog> get recentAuditLogs => _recentAuditLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AccountingRBACProvider() {
    _initializeAuditStream();
  }

  void _initializeAuditStream() {
    _rbacService.auditStream.listen((log) {
      _recentAuditLogs.insert(0, log);
      if (_recentAuditLogs.length > 100) {
        _recentAuditLogs.removeLast();
      }
      notifyListeners();
    });
  }

  /// Initialize RBAC for current user
  Future<void> initialize(String userId, String businessId) async {
    _setLoading(true);
    try {
      await _rbacService.initialize(userId, businessId);
      await loadUserRole(userId, businessId);
      await loadBusinessUsers(businessId);
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize RBAC: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Load current user's role
  Future<void> loadUserRole(String userId, String businessId) async {
    try {
      _currentUserRole = await _rbacService.getUserRole(userId, businessId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user role: $e';
      debugPrint(_error);
    }
  }

  /// Load all users in the business
  Future<void> loadBusinessUsers(String businessId) async {
    try {
      _businessUsers = await _rbacService.getBusinessUsers(businessId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load business users: $e';
      debugPrint(_error);
    }
  }

  /// Check if current user has permission
  Future<bool> hasPermission({
    required String userId,
    required String businessId,
    required AccountingPermission permission,
    String? resourceId,
    String? resourceType,
  }) async {
    try {
      return await _rbacService.hasPermission(
        userId: userId,
        businessId: businessId,
        permission: permission,
        resourceId: resourceId,
        resourceType: resourceType,
      );
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }

  /// Assign role to user
  Future<bool> assignRole({
    required String userId,
    required String businessId,
    required AccountingRole role,
    required String assignedBy,
    List<String>? restrictedAccounts,
    List<String>? restrictedCostCenters,
    DateTime? expiresAt,
  }) async {
    _setLoading(true);
    try {
      await _rbacService.assignRole(
        userId: userId,
        businessId: businessId,
        role: role,
        assignedBy: assignedBy,
        restrictedAccounts: restrictedAccounts,
        restrictedCostCenters: restrictedCostCenters,
        expiresAt: expiresAt,
      );

      await loadBusinessUsers(businessId);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = 'Failed to assign role: $e';
      debugPrint(_error);
      _setLoading(false);
      return false;
    }
  }

  /// Grant permission to user
  Future<bool> grantPermission({
    required String userId,
    required String businessId,
    required AccountingPermission permission,
    required String grantedBy,
  }) async {
    _setLoading(true);
    try {
      final success = await _rbacService.grantPermission(
        userId: userId,
        businessId: businessId,
        permission: permission,
        grantedBy: grantedBy,
      );

      if (success) {
        await loadBusinessUsers(businessId);
        _error = null;
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _error = 'Failed to grant permission: $e';
      debugPrint(_error);
      _setLoading(false);
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
    _setLoading(true);
    try {
      final success = await _rbacService.revokePermission(
        userId: userId,
        businessId: businessId,
        permission: permission,
        revokedBy: revokedBy,
      );

      if (success) {
        await loadBusinessUsers(businessId);
        _error = null;
      }

      _setLoading(false);
      return success;
    } catch (e) {
      _error = 'Failed to revoke permission: $e';
      debugPrint(_error);
      _setLoading(false);
      return false;
    }
  }

  /// Create access control rule
  Future<AccessControlRule?> createAccessRule({
    required String businessId,
    required String resourceType,
    required String resourceId,
    required String createdBy,
    List<String>? allowedUserIds,
    List<AccountingRole>? allowedRoles,
    List<AccountingPermission>? requiredPermissions,
    Map<String, dynamic>? conditions,
  }) async {
    _setLoading(true);
    try {
      final rule = await _rbacService.createAccessRule(
        businessId: businessId,
        resourceType: resourceType,
        resourceId: resourceId,
        createdBy: createdBy,
        allowedUserIds: allowedUserIds,
        allowedRoles: allowedRoles,
        requiredPermissions: requiredPermissions,
        conditions: conditions,
      );

      _error = null;
      _setLoading(false);
      return rule;
    } catch (e) {
      _error = 'Failed to create access rule: $e';
      debugPrint(_error);
      _setLoading(false);
      return null;
    }
  }

  /// Load audit logs
  Future<void> loadAuditLogs({
    required String businessId,
    String? userId,
    String? resourceType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    _setLoading(true);
    try {
      _recentAuditLogs = await _rbacService.getAuditLogs(
        businessId: businessId,
        userId: userId,
        resourceType: resourceType,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      _error = null;
    } catch (e) {
      _error = 'Failed to load audit logs: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  /// Get role display name
  String getRoleDisplayName(AccountingRole role) {
    switch (role) {
      case AccountingRole.cfo:
        return 'Chief Financial Officer';
      case AccountingRole.financeManager:
        return 'Finance Manager';
      case AccountingRole.accountant:
        return 'Accountant';
      case AccountingRole.auditor:
        return 'Auditor';
      case AccountingRole.dataEntry:
        return 'Data Entry';
      case AccountingRole.viewer:
        return 'Viewer';
    }
  }

  /// Get permission display name
  String getPermissionDisplayName(AccountingPermission permission) {
    final name = permission.toString().split('.').last;
    return name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Check if user can manage other users
  bool canManageUsers() {
    return _currentUserRole?.permissions.contains(
          AccountingPermission.manageUsers,
        ) ??
        false;
  }

  /// Check if user can view audit trail
  bool canViewAuditTrail() {
    return _currentUserRole?.permissions.contains(
          AccountingPermission.viewAuditTrail,
        ) ??
        false;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _rbacService.dispose();
    super.dispose();
  }
}
