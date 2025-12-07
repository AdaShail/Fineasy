// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_extension_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkflowStep _$WorkflowStepFromJson(Map<String, dynamic> json) => WorkflowStep(
  id: json['id'] as String,
  workflowId: json['workflowId'] as String,
  stepNumber: (json['stepNumber'] as num).toInt(),
  stepType: $enumDecode(_$StepTypeEnumMap, json['stepType']),
  name: json['name'] as String,
  description: json['description'] as String,
  configuration: json['configuration'] as Map<String, dynamic>,
  isRequired: json['isRequired'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  type: $enumDecodeNullable(_$StepTypeEnumMap, json['type']),
  dependencies:
      (json['dependencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  successCriteria: json['successCriteria'] as Map<String, dynamic>?,
  failureHandling: json['failureHandling'] as Map<String, dynamic>?,
  stepOrder: (json['stepOrder'] as num?)?.toInt(),
  isOptional: json['isOptional'] as bool?,
);

Map<String, dynamic> _$WorkflowStepToJson(WorkflowStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workflowId': instance.workflowId,
      'stepNumber': instance.stepNumber,
      'stepType': _$StepTypeEnumMap[instance.stepType]!,
      'name': instance.name,
      'description': instance.description,
      'configuration': instance.configuration,
      'isRequired': instance.isRequired,
      'createdAt': instance.createdAt.toIso8601String(),
      'type': _$StepTypeEnumMap[instance.type],
      'dependencies': instance.dependencies,
      'successCriteria': instance.successCriteria,
      'failureHandling': instance.failureHandling,
      'stepOrder': instance.stepOrder,
      'isOptional': instance.isOptional,
    };

const _$StepTypeEnumMap = {
  StepType.validation: 'validation',
  StepType.notification: 'notification',
  StepType.approval: 'approval',
  StepType.action: 'action',
  StepType.condition: 'condition',
  StepType.integration: 'integration',
  StepType.delay: 'delay',
};

WorkflowDefinition _$WorkflowDefinitionFromJson(Map<String, dynamic> json) =>
    WorkflowDefinition(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      type: $enumDecode(_$WorkflowTypeEnumMap, json['type']),
      name: json['name'] as String,
      description: json['description'] as String,
      steps:
          (json['steps'] as List<dynamic>)
              .map((e) => WorkflowStep.fromJson(e as Map<String, dynamic>))
              .toList(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      triggers:
          (json['triggers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      conditions: json['conditions'] as Map<String, dynamic>?,
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WorkflowDefinitionToJson(WorkflowDefinition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'type': _$WorkflowTypeEnumMap[instance.type]!,
      'name': instance.name,
      'description': instance.description,
      'steps': instance.steps,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'triggers': instance.triggers,
      'conditions': instance.conditions,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$WorkflowTypeEnumMap = {
  WorkflowType.invoice: 'invoice',
  WorkflowType.customer: 'customer',
  WorkflowType.supplier: 'supplier',
  WorkflowType.payment: 'payment',
  WorkflowType.expense: 'expense',
  WorkflowType.customerOnboarding: 'customerOnboarding',
  WorkflowType.invoiceAutomation: 'invoiceAutomation',
  WorkflowType.paymentProcessing: 'paymentProcessing',
};

WorkflowExecution _$WorkflowExecutionFromJson(Map<String, dynamic> json) =>
    WorkflowExecution(
      id: json['id'] as String,
      workflowId: json['workflowId'] as String,
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String,
      status: json['status'] as String,
      currentStep: (json['currentStep'] as num).toInt(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt:
          json['completedAt'] == null
              ? null
              : DateTime.parse(json['completedAt'] as String),
      context: json['context'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$WorkflowExecutionToJson(WorkflowExecution instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workflowId': instance.workflowId,
      'entityId': instance.entityId,
      'entityType': instance.entityType,
      'status': instance.status,
      'currentStep': instance.currentStep,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'context': instance.context,
    };

EscalationStep _$EscalationStepFromJson(Map<String, dynamic> json) =>
    EscalationStep(
      id: json['id'] as String,
      workflowId: json['workflowId'] as String,
      triggerAfterDays: (json['triggerAfterDays'] as num).toInt(),
      action: json['action'] as String,
      notifyUsers:
          (json['notifyUsers'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      daysOverdue: (json['daysOverdue'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$EscalationStepToJson(EscalationStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workflowId': instance.workflowId,
      'triggerAfterDays': instance.triggerAfterDays,
      'action': instance.action,
      'notifyUsers': instance.notifyUsers,
      'createdAt': instance.createdAt.toIso8601String(),
      'daysOverdue': instance.daysOverdue,
      'isActive': instance.isActive,
    };

CustomerWorkflowConfig _$CustomerWorkflowConfigFromJson(
  Map<String, dynamic> json,
) => CustomerWorkflowConfig(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  autoSendWelcome: json['autoSendWelcome'] as bool,
  autoFollowUp: json['autoFollowUp'] as bool,
  followUpDays: (json['followUpDays'] as num).toInt(),
  enableCreditCheck: json['enableCreditCheck'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  autoOnboardingEnabled: json['autoOnboardingEnabled'] as bool?,
  satisfactionMonitoringEnabled: json['satisfactionMonitoringEnabled'] as bool?,
  loyaltyProgramEnabled: json['loyaltyProgramEnabled'] as bool?,
  segmentationEnabled: json['segmentationEnabled'] as bool?,
  onboardingSteps:
      (json['onboardingSteps'] as List<dynamic>?)
          ?.map((e) => WorkflowStep.fromJson(e as Map<String, dynamic>))
          .toList(),
  escalationSteps:
      (json['escalationSteps'] as List<dynamic>?)
          ?.map((e) => EscalationStep.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CustomerWorkflowConfigToJson(
  CustomerWorkflowConfig instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'autoSendWelcome': instance.autoSendWelcome,
  'autoFollowUp': instance.autoFollowUp,
  'followUpDays': instance.followUpDays,
  'enableCreditCheck': instance.enableCreditCheck,
  'createdAt': instance.createdAt.toIso8601String(),
  'autoOnboardingEnabled': instance.autoOnboardingEnabled,
  'satisfactionMonitoringEnabled': instance.satisfactionMonitoringEnabled,
  'loyaltyProgramEnabled': instance.loyaltyProgramEnabled,
  'segmentationEnabled': instance.segmentationEnabled,
  'onboardingSteps': instance.onboardingSteps,
  'escalationSteps': instance.escalationSteps,
};

InvoiceWorkflowConfig _$InvoiceWorkflowConfigFromJson(
  Map<String, dynamic> json,
) => InvoiceWorkflowConfig(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  autoSendOnCreation: json['autoSendOnCreation'] as bool,
  enableReminders: json['enableReminders'] as bool,
  reminderDays:
      (json['reminderDays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
  enableEscalation: json['enableEscalation'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  autoGenerateRecurring: json['autoGenerateRecurring'] as bool?,
  autoSendReminders: json['autoSendReminders'] as bool?,
  autoReconcilePayments: json['autoReconcilePayments'] as bool?,
  escalationEnabled: json['escalationEnabled'] as bool?,
  escalationSteps:
      (json['escalationSteps'] as List<dynamic>?)
          ?.map((e) => EscalationStep.fromJson(e as Map<String, dynamic>))
          .toList(),
  reminderSchedule:
      (json['reminderSchedule'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
);

Map<String, dynamic> _$InvoiceWorkflowConfigToJson(
  InvoiceWorkflowConfig instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'autoSendOnCreation': instance.autoSendOnCreation,
  'enableReminders': instance.enableReminders,
  'reminderDays': instance.reminderDays,
  'enableEscalation': instance.enableEscalation,
  'createdAt': instance.createdAt.toIso8601String(),
  'autoGenerateRecurring': instance.autoGenerateRecurring,
  'autoSendReminders': instance.autoSendReminders,
  'autoReconcilePayments': instance.autoReconcilePayments,
  'escalationEnabled': instance.escalationEnabled,
  'escalationSteps': instance.escalationSteps,
  'reminderSchedule': instance.reminderSchedule,
};
