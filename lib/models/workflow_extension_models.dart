import 'package:json_annotation/json_annotation.dart';

part 'workflow_extension_models.g.dart';

// Workflow Extension Models
enum StepType {
  validation,
  notification,
  approval,
  action,
  condition,
  integration,
  delay,
}

enum WorkflowType {
  invoice,
  customer,
  supplier,
  payment,
  expense,
  customerOnboarding,
  invoiceAutomation,
  paymentProcessing,
}

@JsonSerializable()
class WorkflowStep {
  final String id;
  final String workflowId;
  final int stepNumber;
  final StepType stepType;
  final String name;
  final String description;
  final Map<String, dynamic> configuration;
  final bool isRequired;
  final DateTime createdAt;
  final StepType? type;
  final List<String>? dependencies;
  final Map<String, dynamic>? successCriteria;
  final Map<String, dynamic>? failureHandling;
  final int? stepOrder;
  final bool? isOptional;

  WorkflowStep({
    required this.id,
    required this.workflowId,
    required this.stepNumber,
    required this.stepType,
    required this.name,
    required this.description,
    required this.configuration,
    required this.isRequired,
    required this.createdAt,
    this.type,
    this.dependencies,
    this.successCriteria,
    this.failureHandling,
    this.stepOrder,
    this.isOptional,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> json) =>
      _$WorkflowStepFromJson(json);
  Map<String, dynamic> toJson() => _$WorkflowStepToJson(this);
}

@JsonSerializable()
class WorkflowDefinition {
  final String id;
  final String businessId;
  final WorkflowType type;
  final String name;
  final String description;
  final List<WorkflowStep> steps;
  final bool isActive;
  final DateTime createdAt;
  final List<String>? triggers;
  final Map<String, dynamic>? conditions;
  final DateTime? updatedAt;

  WorkflowDefinition({
    required this.id,
    required this.businessId,
    required this.type,
    required this.name,
    required this.description,
    required this.steps,
    required this.isActive,
    required this.createdAt,
    this.triggers,
    this.conditions,
    this.updatedAt,
  });

  factory WorkflowDefinition.fromJson(Map<String, dynamic> json) =>
      _$WorkflowDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$WorkflowDefinitionToJson(this);
}

@JsonSerializable()
class WorkflowExecution {
  final String id;
  final String workflowId;
  final String entityId;
  final String entityType;
  final String status;
  final int currentStep;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> context;

  WorkflowExecution({
    required this.id,
    required this.workflowId,
    required this.entityId,
    required this.entityType,
    required this.status,
    required this.currentStep,
    required this.startedAt,
    this.completedAt,
    required this.context,
  });

  factory WorkflowExecution.fromJson(Map<String, dynamic> json) =>
      _$WorkflowExecutionFromJson(json);
  Map<String, dynamic> toJson() => _$WorkflowExecutionToJson(this);
}

@JsonSerializable()
class EscalationStep {
  final String id;
  final String workflowId;
  final int triggerAfterDays;
  final String action;
  final List<String> notifyUsers;
  final DateTime createdAt;
  final int? daysOverdue;
  final bool? isActive;

  EscalationStep({
    required this.id,
    required this.workflowId,
    required this.triggerAfterDays,
    required this.action,
    required this.notifyUsers,
    required this.createdAt,
    this.daysOverdue,
    this.isActive,
  });

  factory EscalationStep.fromJson(Map<String, dynamic> json) =>
      _$EscalationStepFromJson(json);
  Map<String, dynamic> toJson() => _$EscalationStepToJson(this);
}

@JsonSerializable()
class CustomerWorkflowConfig {
  final String id;
  final String businessId;
  final bool autoSendWelcome;
  final bool autoFollowUp;
  final int followUpDays;
  final bool enableCreditCheck;
  final DateTime createdAt;
  final bool? autoOnboardingEnabled;
  final bool? satisfactionMonitoringEnabled;
  final bool? loyaltyProgramEnabled;
  final bool? segmentationEnabled;
  final List<WorkflowStep>? onboardingSteps;
  final List<EscalationStep>? escalationSteps;

  CustomerWorkflowConfig({
    required this.id,
    required this.businessId,
    required this.autoSendWelcome,
    required this.autoFollowUp,
    required this.followUpDays,
    required this.enableCreditCheck,
    required this.createdAt,
    this.autoOnboardingEnabled,
    this.satisfactionMonitoringEnabled,
    this.loyaltyProgramEnabled,
    this.segmentationEnabled,
    this.onboardingSteps,
    this.escalationSteps,
  });

  factory CustomerWorkflowConfig.fromJson(Map<String, dynamic> json) =>
      _$CustomerWorkflowConfigFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerWorkflowConfigToJson(this);
}

@JsonSerializable()
class InvoiceWorkflowConfig {
  final String id;
  final String businessId;
  final bool autoSendOnCreation;
  final bool enableReminders;
  final List<int> reminderDays;
  final bool enableEscalation;
  final DateTime createdAt;
  final bool? autoGenerateRecurring;
  final bool? autoSendReminders;
  final bool? autoReconcilePayments;
  final bool? escalationEnabled;
  final List<EscalationStep>? escalationSteps;
  final List<int>? reminderSchedule;

  InvoiceWorkflowConfig({
    required this.id,
    required this.businessId,
    required this.autoSendOnCreation,
    required this.enableReminders,
    required this.reminderDays,
    required this.enableEscalation,
    required this.createdAt,
    this.autoGenerateRecurring,
    this.autoSendReminders,
    this.autoReconcilePayments,
    this.escalationEnabled,
    this.escalationSteps,
    this.reminderSchedule,
  });

  factory InvoiceWorkflowConfig.fromJson(Map<String, dynamic> json) =>
      _$InvoiceWorkflowConfigFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceWorkflowConfigToJson(this);
}
