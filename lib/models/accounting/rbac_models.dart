import 'package:json_annotation/json_annotation.dart';

part 'rbac_models.g.dart';

/// Accounting-specific roles for Tally integration
enum AccountingRole {
  @JsonValue('accountant')
  accountant,
  @JsonValue('auditor')
  auditor,
  @JsonValue('finance_manager')
  financeManager,
  @JsonValue('cfo')
  cfo,
  @JsonValue('data_entry')
  dataEntry,
  @JsonValue('viewer')
  viewer,
}

/// Accounting-specific permissions
enum AccountingPermission {
  // Chart of Accounts
  @JsonValue('view_accounts')
  viewAccounts,
  @JsonValue('create_accounts')
  createAccounts,
  @JsonValue('edit_accounts')
  editAccounts,
  @JsonValue('delete_accounts')
  deleteAccounts,

  // Journal Entries
  @JsonValue('view_journal_entries')
  viewJournalEntries,
  @JsonValue('create_journal_entries')
  createJournalEntries,
  @JsonValue('edit_journal_entries')
  editJournalEntries,
  @JsonValue('post_journal_entries')
  postJournalEntries,
  @JsonValue('reverse_journal_entries')
  reverseJournalEntries,

  // Financial Reports
  @JsonValue('view_financial_reports')
  viewFinancialReports,
  @JsonValue('export_financial_reports')
  exportFinancialReports,

  // Bank Reconciliation
  @JsonValue('view_bank_reconciliation')
  viewBankReconciliation,
  @JsonValue('perform_bank_reconciliation')
  performBankReconciliation,

  // Inventory
  @JsonValue('view_inventory')
  viewInventory,
  @JsonValue('manage_inventory')
  manageInventory,
  @JsonValue('adjust_stock')
  adjustStock,

  // GST & Compliance
  @JsonValue('view_gst_reports')
  viewGSTReports,
  @JsonValue('file_gst_returns')
  fileGSTReturns,
  @JsonValue('generate_e_invoice')
  generateEInvoice,
  @JsonValue('generate_eway_bill')
  generateEWayBill,

  // Payroll
  @JsonValue('view_payroll')
  viewPayroll,
  @JsonValue('process_payroll')
  processPayroll,
  @JsonValue('approve_payroll')
  approvePayroll,

  // Payment Scheduling
  @JsonValue('view_payment_schedules')
  viewPaymentSchedules,
  @JsonValue('create_payment_schedules')
  createPaymentSchedules,
  @JsonValue('approve_payments')
  approvePayments,
  @JsonValue('execute_payments')
  executePayments,

  // System Administration
  @JsonValue('manage_users')
  manageUsers,
  @JsonValue('configure_system')
  configureSystem,
  @JsonValue('view_audit_trail')
  viewAuditTrail,
}

/// User role assignment for accounting features
@JsonSerializable()
class AccountingUserRole {
  final String id;
  final String userId;
  final String businessId;
  final AccountingRole role;
  final List<AccountingPermission> permissions;
  final List<String> restrictedAccounts; // Specific accounts user can access
  final List<String>
  restrictedCostCenters; // Specific cost centers user can access
  final DateTime assignedAt;
  final DateTime? expiresAt;
  final String assignedBy;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const AccountingUserRole({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.role,
    required this.permissions,
    this.restrictedAccounts = const [],
    this.restrictedCostCenters = const [],
    required this.assignedAt,
    this.expiresAt,
    required this.assignedBy,
    this.isActive = true,
    this.metadata = const {},
  });

  factory AccountingUserRole.fromJson(Map<String, dynamic> json) =>
      _$AccountingUserRoleFromJson(json);
  Map<String, dynamic> toJson() => _$AccountingUserRoleToJson(this);

  AccountingUserRole copyWith({
    String? id,
    String? userId,
    String? businessId,
    AccountingRole? role,
    List<AccountingPermission>? permissions,
    List<String>? restrictedAccounts,
    List<String>? restrictedCostCenters,
    DateTime? assignedAt,
    DateTime? expiresAt,
    String? assignedBy,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return AccountingUserRole(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      restrictedAccounts: restrictedAccounts ?? this.restrictedAccounts,
      restrictedCostCenters:
          restrictedCostCenters ?? this.restrictedCostCenters,
      assignedAt: assignedAt ?? this.assignedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      assignedBy: assignedBy ?? this.assignedBy,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Access control rule for specific resources
@JsonSerializable()
class AccessControlRule {
  final String id;
  final String businessId;
  final String resourceType; // 'account', 'cost_center', 'journal_entry', etc.
  final String resourceId;
  final List<String> allowedUserIds;
  final List<AccountingRole> allowedRoles;
  final List<AccountingPermission> requiredPermissions;
  final Map<String, dynamic> conditions;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  const AccessControlRule({
    required this.id,
    required this.businessId,
    required this.resourceType,
    required this.resourceId,
    this.allowedUserIds = const [],
    this.allowedRoles = const [],
    this.requiredPermissions = const [],
    this.conditions = const {},
    this.isActive = true,
    required this.createdAt,
    required this.createdBy,
  });

  factory AccessControlRule.fromJson(Map<String, dynamic> json) =>
      _$AccessControlRuleFromJson(json);
  Map<String, dynamic> toJson() => _$AccessControlRuleToJson(this);
}

/// Audit log for access control events
@JsonSerializable()
class AccessAuditLog {
  final String id;
  final String businessId;
  final String userId;
  final String action;
  final String resourceType;
  final String resourceId;
  final bool granted;
  final String? denialReason;
  final Map<String, dynamic> context;
  final DateTime timestamp;

  const AccessAuditLog({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.granted,
    this.denialReason,
    this.context = const {},
    required this.timestamp,
  });

  factory AccessAuditLog.fromJson(Map<String, dynamic> json) =>
      _$AccessAuditLogFromJson(json);
  Map<String, dynamic> toJson() => _$AccessAuditLogToJson(this);
}

/// Session tracking for security
@JsonSerializable()
class UserSession {
  final String id;
  final String userId;
  final String businessId;
  final String deviceId;
  final String? ipAddress;
  final String? userAgent;
  final DateTime startedAt;
  final DateTime? endedAt;
  final DateTime lastActivityAt;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const UserSession({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.deviceId,
    this.ipAddress,
    this.userAgent,
    required this.startedAt,
    this.endedAt,
    required this.lastActivityAt,
    this.isActive = true,
    this.metadata = const {},
  });

  factory UserSession.fromJson(Map<String, dynamic> json) =>
      _$UserSessionFromJson(json);
  Map<String, dynamic> toJson() => _$UserSessionToJson(this);
}

/// Field-level encryption configuration
@JsonSerializable()
class FieldEncryptionConfig {
  final String fieldName;
  final String encryptionAlgorithm;
  final bool isEncrypted;
  final List<AccountingRole> decryptionRoles;
  final List<String> decryptionUserIds;

  const FieldEncryptionConfig({
    required this.fieldName,
    required this.encryptionAlgorithm,
    this.isEncrypted = true,
    this.decryptionRoles = const [],
    this.decryptionUserIds = const [],
  });

  factory FieldEncryptionConfig.fromJson(Map<String, dynamic> json) =>
      _$FieldEncryptionConfigFromJson(json);
  Map<String, dynamic> toJson() => _$FieldEncryptionConfigToJson(this);
}
