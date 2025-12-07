// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkflowDefinition _$WorkflowDefinitionFromJson(Map<String, dynamic> json) =>
    WorkflowDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$WorkflowTypeEnumMap, json['type']),
      steps:
          (json['steps'] as List<dynamic>)
              .map((e) => WorkflowStep.fromJson(e as Map<String, dynamic>))
              .toList(),
      configuration: json['configuration'] as Map<String, dynamic>,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      businessId: json['businessId'] as String,
      triggers:
          (json['triggers'] as List<dynamic>?)
              ?.map((e) => WorkflowTrigger.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WorkflowDefinitionToJson(WorkflowDefinition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$WorkflowTypeEnumMap[instance.type]!,
      'steps': instance.steps,
      'configuration': instance.configuration,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'businessId': instance.businessId,
      'triggers': instance.triggers,
    };

const _$WorkflowTypeEnumMap = {
  WorkflowType.invoice: 'invoice',
  WorkflowType.payment: 'payment',
  WorkflowType.customer: 'customer',
  WorkflowType.supplier: 'supplier',
  WorkflowType.expense: 'expense',
  WorkflowType.approval: 'approval',
  WorkflowType.notification: 'notification',
  WorkflowType.automation: 'automation',
  WorkflowType.supplierManagement: 'supplierManagement',
};

WorkflowStep _$WorkflowStepFromJson(Map<String, dynamic> json) => WorkflowStep(
  id: json['id'] as String,
  workflowId: json['workflowId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$StepTypeEnumMap, json['type']),
  stepOrder: (json['stepOrder'] as num).toInt(),
  configuration: json['configuration'] as Map<String, dynamic>,
  dependencies:
      (json['dependencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isRequired: json['isRequired'] as bool? ?? true,
  timeout:
      json['timeout'] == null
          ? null
          : Duration(microseconds: (json['timeout'] as num).toInt()),
  successCriteria: json['successCriteria'] as Map<String, dynamic>? ?? const {},
  failureHandling: json['failureHandling'] as Map<String, dynamic>? ?? const {},
  isOptional: json['isOptional'] as bool? ?? false,
);

Map<String, dynamic> _$WorkflowStepToJson(WorkflowStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workflowId': instance.workflowId,
      'name': instance.name,
      'description': instance.description,
      'type': _$StepTypeEnumMap[instance.type]!,
      'stepOrder': instance.stepOrder,
      'configuration': instance.configuration,
      'dependencies': instance.dependencies,
      'isRequired': instance.isRequired,
      'timeout': instance.timeout?.inMicroseconds,
      'successCriteria': instance.successCriteria,
      'failureHandling': instance.failureHandling,
      'isOptional': instance.isOptional,
    };

const _$StepTypeEnumMap = {
  StepType.validation: 'validation',
  StepType.approval: 'approval',
  StepType.notification: 'notification',
  StepType.dataUpdate: 'dataUpdate',
  StepType.calculation: 'calculation',
  StepType.integration: 'integration',
  StepType.decision: 'decision',
  StepType.automation: 'automation',
  StepType.action: 'action',
  StepType.condition: 'condition',
  StepType.delay: 'delay',
};

WorkflowExecution _$WorkflowExecutionFromJson(Map<String, dynamic> json) =>
    WorkflowExecution(
      id: json['id'] as String,
      workflowId: json['workflowId'] as String,
      businessId: json['businessId'] as String,
      status: $enumDecode(_$WorkflowStatusEnumMap, json['status']),
      inputData: json['inputData'] as Map<String, dynamic>,
      outputData: json['outputData'] as Map<String, dynamic>? ?? const {},
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt:
          json['completedAt'] == null
              ? null
              : DateTime.parse(json['completedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
      stepExecutions:
          (json['stepExecutions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    WorkflowStepExecution.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      stepResults: json['stepResults'] as Map<String, dynamic>? ?? const {},
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      executionContext:
          json['executionContext'] as Map<String, dynamic>? ?? const {},
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$WorkflowExecutionToJson(WorkflowExecution instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workflowId': instance.workflowId,
      'businessId': instance.businessId,
      'status': _$WorkflowStatusEnumMap[instance.status]!,
      'inputData': instance.inputData,
      'outputData': instance.outputData,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
      'stepExecutions': instance.stepExecutions,
      'stepResults': instance.stepResults,
      'currentStep': instance.currentStep,
      'executionContext': instance.executionContext,
      'retryCount': instance.retryCount,
    };

const _$WorkflowStatusEnumMap = {
  WorkflowStatus.pending: 'pending',
  WorkflowStatus.running: 'running',
  WorkflowStatus.completed: 'completed',
  WorkflowStatus.failed: 'failed',
  WorkflowStatus.cancelled: 'cancelled',
  WorkflowStatus.paused: 'paused',
};

WorkflowStepExecution _$WorkflowStepExecutionFromJson(
  Map<String, dynamic> json,
) => WorkflowStepExecution(
  id: json['id'] as String,
  executionId: json['executionId'] as String,
  stepId: json['stepId'] as String,
  status: $enumDecode(_$WorkflowStatusEnumMap, json['status']),
  inputData: json['inputData'] as Map<String, dynamic>,
  outputData: json['outputData'] as Map<String, dynamic>? ?? const {},
  startedAt: DateTime.parse(json['startedAt'] as String),
  completedAt:
      json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$WorkflowStepExecutionToJson(
  WorkflowStepExecution instance,
) => <String, dynamic>{
  'id': instance.id,
  'executionId': instance.executionId,
  'stepId': instance.stepId,
  'status': _$WorkflowStatusEnumMap[instance.status]!,
  'inputData': instance.inputData,
  'outputData': instance.outputData,
  'startedAt': instance.startedAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'errorMessage': instance.errorMessage,
};

WorkflowTrigger _$WorkflowTriggerFromJson(Map<String, dynamic> json) =>
    WorkflowTrigger(
      id: json['id'] as String,
      workflowId: json['workflowId'] as String,
      triggerType: json['triggerType'] as String,
      conditions: json['conditions'] as Map<String, dynamic>,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WorkflowTriggerToJson(WorkflowTrigger instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workflowId': instance.workflowId,
      'triggerType': instance.triggerType,
      'conditions': instance.conditions,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };

SupplierWorkflowConfig _$SupplierWorkflowConfigFromJson(
  Map<String, dynamic> json,
) => SupplierWorkflowConfig(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  supplierId: json['supplierId'] as String,
  workflowType: $enumDecode(_$WorkflowTypeEnumMap, json['workflowType']),
  configuration: json['configuration'] as Map<String, dynamic>,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  autoEvaluationEnabled: json['autoEvaluationEnabled'] as bool? ?? false,
  autoPOGenerationEnabled: json['autoPOGenerationEnabled'] as bool? ?? false,
  performanceMonitoringEnabled:
      json['performanceMonitoringEnabled'] as bool? ?? false,
  contractManagementEnabled:
      json['contractManagementEnabled'] as bool? ?? false,
  evaluationCriteria:
      json['evaluationCriteria'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$SupplierWorkflowConfigToJson(
  SupplierWorkflowConfig instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'supplierId': instance.supplierId,
  'workflowType': _$WorkflowTypeEnumMap[instance.workflowType]!,
  'configuration': instance.configuration,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'autoEvaluationEnabled': instance.autoEvaluationEnabled,
  'autoPOGenerationEnabled': instance.autoPOGenerationEnabled,
  'performanceMonitoringEnabled': instance.performanceMonitoringEnabled,
  'contractManagementEnabled': instance.contractManagementEnabled,
  'evaluationCriteria': instance.evaluationCriteria,
};
