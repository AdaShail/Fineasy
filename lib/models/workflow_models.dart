import 'package:json_annotation/json_annotation.dart';

part 'workflow_models.g.dart';

enum WorkflowType {
  invoice,
  payment,
  customer,
  supplier,
  expense,
  approval,
  notification,
  automation,
  supplierManagement,
}

enum WorkflowStatus { pending, running, completed, failed, cancelled, paused }

enum StepType {
  validation,
  approval,
  notification,
  dataUpdate,
  calculation,
  integration,
  decision,
  automation,
  action,
  condition,
  delay,
}

@JsonSerializable()
class WorkflowDefinition {
  final String id;
  final String name;
  final String description;
  final WorkflowType type;
  final List<WorkflowStep> steps;
  final Map<String, dynamic> configuration;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String businessId;
  final List<WorkflowTrigger> triggers;

  const WorkflowDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.steps,
    required this.configuration,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    required this.businessId,
    this.triggers = const [],
  });

  factory WorkflowDefinition.fromJson(Map<String, dynamic> json) =>
      _$WorkflowDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$WorkflowDefinitionToJson(this);
}

@JsonSerializable()
class WorkflowStep {
  final String id;
  final String workflowId;
  final String name;
  final String description;
  final StepType type;
  final int stepOrder;
  final Map<String, dynamic> configuration;
  final List<String> dependencies;
  final bool isRequired;
  final Duration? timeout;
  final Map<String, dynamic> successCriteria;
  final Map<String, dynamic> failureHandling;
  final bool isOptional;

  const WorkflowStep({
    required this.id,
    required this.workflowId,
    required this.name,
    required this.description,
    required this.type,
    required this.stepOrder,
    required this.configuration,
    this.dependencies = const [],
    this.isRequired = true,
    this.timeout,
    this.successCriteria = const {},
    this.failureHandling = const {},
    this.isOptional = false,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> json) =>
      _$WorkflowStepFromJson(json);

  Map<String, dynamic> toJson() => _$WorkflowStepToJson(this);
}

@JsonSerializable()
class WorkflowExecution {
  final String id;
  final String workflowId;
  final String businessId;
  final WorkflowStatus status;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> outputData;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final List<WorkflowStepExecution> stepExecutions;
  final Map<String, dynamic> stepResults;
  final int currentStep;
  final Map<String, dynamic> executionContext;
  final int retryCount;

  const WorkflowExecution({
    required this.id,
    required this.workflowId,
    required this.businessId,
    required this.status,
    required this.inputData,
    this.outputData = const {},
    required this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.stepExecutions = const [],
    this.stepResults = const {},
    this.currentStep = 0,
    this.executionContext = const {},
    this.retryCount = 0,
  });

  factory WorkflowExecution.fromJson(Map<String, dynamic> json) =>
      _$WorkflowExecutionFromJson(json);

  Map<String, dynamic> toJson() => _$WorkflowExecutionToJson(this);
}

@JsonSerializable()
class WorkflowStepExecution {
  final String id;
  final String executionId;
  final String stepId;
  final WorkflowStatus status;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> outputData;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? errorMessage;

  const WorkflowStepExecution({
    required this.id,
    required this.executionId,
    required this.stepId,
    required this.status,
    required this.inputData,
    this.outputData = const {},
    required this.startedAt,
    this.completedAt,
    this.errorMessage,
  });

  factory WorkflowStepExecution.fromJson(Map<String, dynamic> json) =>
      _$WorkflowStepExecutionFromJson(json);

  Map<String, dynamic> toJson() => _$WorkflowStepExecutionToJson(this);
}

@JsonSerializable()
class WorkflowTrigger {
  final String id;
  final String workflowId;
  final String triggerType;
  final Map<String, dynamic> conditions;
  final bool isActive;
  final DateTime createdAt;

  const WorkflowTrigger({
    required this.id,
    required this.workflowId,
    required this.triggerType,
    required this.conditions,
    this.isActive = true,
    required this.createdAt,
  });

  factory WorkflowTrigger.fromJson(Map<String, dynamic> json) =>
      _$WorkflowTriggerFromJson(json);

  Map<String, dynamic> toJson() => _$WorkflowTriggerToJson(this);
}

@JsonSerializable()
class SupplierWorkflowConfig {
  final String id;
  final String businessId;
  final String supplierId;
  final WorkflowType workflowType;
  final Map<String, dynamic> configuration;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool autoEvaluationEnabled;
  final bool autoPOGenerationEnabled;
  final bool performanceMonitoringEnabled;
  final bool contractManagementEnabled;
  final Map<String, dynamic> evaluationCriteria;

  const SupplierWorkflowConfig({
    required this.id,
    required this.businessId,
    required this.supplierId,
    required this.workflowType,
    required this.configuration,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.autoEvaluationEnabled = false,
    this.autoPOGenerationEnabled = false,
    this.performanceMonitoringEnabled = false,
    this.contractManagementEnabled = false,
    this.evaluationCriteria = const {},
  });

  factory SupplierWorkflowConfig.fromJson(Map<String, dynamic> json) =>
      _$SupplierWorkflowConfigFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierWorkflowConfigToJson(this);
}
