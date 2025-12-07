// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rbac_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountingUserRole _$AccountingUserRoleFromJson(Map<String, dynamic> json) =>
    AccountingUserRole(
      id: json['id'] as String,
      userId: json['userId'] as String,
      businessId: json['businessId'] as String,
      role: $enumDecode(_$AccountingRoleEnumMap, json['role']),
      permissions:
          (json['permissions'] as List<dynamic>)
              .map((e) => $enumDecode(_$AccountingPermissionEnumMap, e))
              .toList(),
      restrictedAccounts:
          (json['restrictedAccounts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      restrictedCostCenters:
          (json['restrictedCostCenters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      expiresAt:
          json['expiresAt'] == null
              ? null
              : DateTime.parse(json['expiresAt'] as String),
      assignedBy: json['assignedBy'] as String,
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AccountingUserRoleToJson(AccountingUserRole instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'businessId': instance.businessId,
      'role': _$AccountingRoleEnumMap[instance.role]!,
      'permissions':
          instance.permissions
              .map((e) => _$AccountingPermissionEnumMap[e]!)
              .toList(),
      'restrictedAccounts': instance.restrictedAccounts,
      'restrictedCostCenters': instance.restrictedCostCenters,
      'assignedAt': instance.assignedAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'assignedBy': instance.assignedBy,
      'isActive': instance.isActive,
      'metadata': instance.metadata,
    };

const _$AccountingRoleEnumMap = {
  AccountingRole.accountant: 'accountant',
  AccountingRole.auditor: 'auditor',
  AccountingRole.financeManager: 'finance_manager',
  AccountingRole.cfo: 'cfo',
  AccountingRole.dataEntry: 'data_entry',
  AccountingRole.viewer: 'viewer',
};

const _$AccountingPermissionEnumMap = {
  AccountingPermission.viewAccounts: 'view_accounts',
  AccountingPermission.createAccounts: 'create_accounts',
  AccountingPermission.editAccounts: 'edit_accounts',
  AccountingPermission.deleteAccounts: 'delete_accounts',
  AccountingPermission.viewJournalEntries: 'view_journal_entries',
  AccountingPermission.createJournalEntries: 'create_journal_entries',
  AccountingPermission.editJournalEntries: 'edit_journal_entries',
  AccountingPermission.postJournalEntries: 'post_journal_entries',
  AccountingPermission.reverseJournalEntries: 'reverse_journal_entries',
  AccountingPermission.viewFinancialReports: 'view_financial_reports',
  AccountingPermission.exportFinancialReports: 'export_financial_reports',
  AccountingPermission.viewBankReconciliation: 'view_bank_reconciliation',
  AccountingPermission.performBankReconciliation: 'perform_bank_reconciliation',
  AccountingPermission.viewInventory: 'view_inventory',
  AccountingPermission.manageInventory: 'manage_inventory',
  AccountingPermission.adjustStock: 'adjust_stock',
  AccountingPermission.viewGSTReports: 'view_gst_reports',
  AccountingPermission.fileGSTReturns: 'file_gst_returns',
  AccountingPermission.generateEInvoice: 'generate_e_invoice',
  AccountingPermission.generateEWayBill: 'generate_eway_bill',
  AccountingPermission.viewPayroll: 'view_payroll',
  AccountingPermission.processPayroll: 'process_payroll',
  AccountingPermission.approvePayroll: 'approve_payroll',
  AccountingPermission.viewPaymentSchedules: 'view_payment_schedules',
  AccountingPermission.createPaymentSchedules: 'create_payment_schedules',
  AccountingPermission.approvePayments: 'approve_payments',
  AccountingPermission.executePayments: 'execute_payments',
  AccountingPermission.manageUsers: 'manage_users',
  AccountingPermission.configureSystem: 'configure_system',
  AccountingPermission.viewAuditTrail: 'view_audit_trail',
};

AccessControlRule _$AccessControlRuleFromJson(Map<String, dynamic> json) =>
    AccessControlRule(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      resourceType: json['resourceType'] as String,
      resourceId: json['resourceId'] as String,
      allowedUserIds:
          (json['allowedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      allowedRoles:
          (json['allowedRoles'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$AccountingRoleEnumMap, e))
              .toList() ??
          const [],
      requiredPermissions:
          (json['requiredPermissions'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$AccountingPermissionEnumMap, e))
              .toList() ??
          const [],
      conditions: json['conditions'] as Map<String, dynamic>? ?? const {},
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$AccessControlRuleToJson(
  AccessControlRule instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'resourceType': instance.resourceType,
  'resourceId': instance.resourceId,
  'allowedUserIds': instance.allowedUserIds,
  'allowedRoles':
      instance.allowedRoles.map((e) => _$AccountingRoleEnumMap[e]!).toList(),
  'requiredPermissions':
      instance.requiredPermissions
          .map((e) => _$AccountingPermissionEnumMap[e]!)
          .toList(),
  'conditions': instance.conditions,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'createdBy': instance.createdBy,
};

AccessAuditLog _$AccessAuditLogFromJson(Map<String, dynamic> json) =>
    AccessAuditLog(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      userId: json['userId'] as String,
      action: json['action'] as String,
      resourceType: json['resourceType'] as String,
      resourceId: json['resourceId'] as String,
      granted: json['granted'] as bool,
      denialReason: json['denialReason'] as String?,
      context: json['context'] as Map<String, dynamic>? ?? const {},
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$AccessAuditLogToJson(AccessAuditLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'userId': instance.userId,
      'action': instance.action,
      'resourceType': instance.resourceType,
      'resourceId': instance.resourceId,
      'granted': instance.granted,
      'denialReason': instance.denialReason,
      'context': instance.context,
      'timestamp': instance.timestamp.toIso8601String(),
    };

UserSession _$UserSessionFromJson(Map<String, dynamic> json) => UserSession(
  id: json['id'] as String,
  userId: json['userId'] as String,
  businessId: json['businessId'] as String,
  deviceId: json['deviceId'] as String,
  ipAddress: json['ipAddress'] as String?,
  userAgent: json['userAgent'] as String?,
  startedAt: DateTime.parse(json['startedAt'] as String),
  endedAt:
      json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
  lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$UserSessionToJson(UserSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'businessId': instance.businessId,
      'deviceId': instance.deviceId,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt.toIso8601String(),
      'isActive': instance.isActive,
      'metadata': instance.metadata,
    };

FieldEncryptionConfig _$FieldEncryptionConfigFromJson(
  Map<String, dynamic> json,
) => FieldEncryptionConfig(
  fieldName: json['fieldName'] as String,
  encryptionAlgorithm: json['encryptionAlgorithm'] as String,
  isEncrypted: json['isEncrypted'] as bool? ?? true,
  decryptionRoles:
      (json['decryptionRoles'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$AccountingRoleEnumMap, e))
          .toList() ??
      const [],
  decryptionUserIds:
      (json['decryptionUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$FieldEncryptionConfigToJson(
  FieldEncryptionConfig instance,
) => <String, dynamic>{
  'fieldName': instance.fieldName,
  'encryptionAlgorithm': instance.encryptionAlgorithm,
  'isEncrypted': instance.isEncrypted,
  'decryptionRoles':
      instance.decryptionRoles.map((e) => _$AccountingRoleEnumMap[e]!).toList(),
  'decryptionUserIds': instance.decryptionUserIds,
};
