import 'package:json_annotation/json_annotation.dart';

part 'audit_models.g.dart';

/// Represents an audit trail entry for AI decisions and actions
@JsonSerializable()
class AuditTrailEntry {
  final String id;
  final String businessId;
  final String userId;
  final AuditEventType eventType;
  final String entityId;
  final String entityType;
  final String action;
  final Map<String, dynamic> beforeState;
  final Map<String, dynamic> afterState;
  final Map<String, dynamic> metadata;
  final String? reasoning;
  final double? confidenceScore;
  final DateTime timestamp;
  final String? sessionId;
  final String? ipAddress;
  final String? userAgent;
  final AuditSeverity severity;
  final List<String> tags;

  const AuditTrailEntry({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.eventType,
    required this.entityId,
    required this.entityType,
    required this.action,
    required this.beforeState,
    required this.afterState,
    required this.metadata,
    this.reasoning,
    this.confidenceScore,
    required this.timestamp,
    this.sessionId,
    this.ipAddress,
    this.userAgent,
    required this.severity,
    required this.tags,
  });

  factory AuditTrailEntry.fromJson(Map<String, dynamic> json) =>
      _$AuditTrailEntryFromJson(json);

  Map<String, dynamic> toJson() => _$AuditTrailEntryToJson(this);
}

/// Types of audit events
enum AuditEventType {
  @JsonValue('ai_decision')
  aiDecision,
  @JsonValue('action_execution')
  actionExecution,
  @JsonValue('user_override')
  userOverride,
  @JsonValue('system_error')
  systemError,
  @JsonValue('configuration_change')
  configurationChange,
  @JsonValue('data_access')
  dataAccess,
  @JsonValue('authentication')
  authentication,
  @JsonValue('authorization')
  authorization,
  @JsonValue('workflow_execution')
  workflowExecution,
  @JsonValue('model_prediction')
  modelPrediction,
}

/// Severity levels for audit events
enum AuditSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

/// Decision explanation for transparency
@JsonSerializable()
class DecisionExplanation {
  final String decisionId;
  final String businessId;
  final String decisionType;
  final String summary;
  final List<ReasoningStep> reasoningSteps;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> outputData;
  final double confidenceScore;
  final List<AlternativeOption> alternatives;
  final List<RiskFactor> risks;
  final List<String> assumptions;
  final DateTime createdAt;

  const DecisionExplanation({
    required this.decisionId,
    required this.businessId,
    required this.decisionType,
    required this.summary,
    required this.reasoningSteps,
    required this.inputData,
    required this.outputData,
    required this.confidenceScore,
    required this.alternatives,
    required this.risks,
    required this.assumptions,
    required this.createdAt,
  });

  factory DecisionExplanation.fromJson(Map<String, dynamic> json) =>
      _$DecisionExplanationFromJson(json);

  Map<String, dynamic> toJson() => _$DecisionExplanationToJson(this);
}

/// Individual reasoning step in decision process
@JsonSerializable()
class ReasoningStep {
  final int stepNumber;
  final String description;
  final String rationale;
  final Map<String, dynamic> data;
  final double weight;
  final String? source;

  const ReasoningStep({
    required this.stepNumber,
    required this.description,
    required this.rationale,
    required this.data,
    required this.weight,
    this.source,
  });

  factory ReasoningStep.fromJson(Map<String, dynamic> json) =>
      _$ReasoningStepFromJson(json);

  Map<String, dynamic> toJson() => _$ReasoningStepToJson(this);
}

/// Alternative options considered in decision
@JsonSerializable()
class AlternativeOption {
  final String id;
  final String description;
  final double score;
  final String whyNotChosen;
  final Map<String, dynamic> pros;
  final Map<String, dynamic> cons;

  const AlternativeOption({
    required this.id,
    required this.description,
    required this.score,
    required this.whyNotChosen,
    required this.pros,
    required this.cons,
  });

  factory AlternativeOption.fromJson(Map<String, dynamic> json) =>
      _$AlternativeOptionFromJson(json);

  Map<String, dynamic> toJson() => _$AlternativeOptionToJson(this);
}

/// Risk factors identified in decision
@JsonSerializable()
class RiskFactor {
  final String id;
  final String description;
  final RiskLevel level;
  final double probability;
  final String mitigation;
  final String impact;

  const RiskFactor({
    required this.id,
    required this.description,
    required this.level,
    required this.probability,
    required this.mitigation,
    required this.impact,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorFromJson(json);

  Map<String, dynamic> toJson() => _$RiskFactorToJson(this);
}

enum RiskLevel {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

/// Audit search criteria
@JsonSerializable()
class AuditSearchCriteria {
  final String? businessId;
  final String? userId;
  final List<AuditEventType>? eventTypes;
  final List<String>? entityTypes;
  final List<AuditSeverity>? severities;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchText;
  final List<String>? tags;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final SortOrder? sortOrder;

  const AuditSearchCriteria({
    this.businessId,
    this.userId,
    this.eventTypes,
    this.entityTypes,
    this.severities,
    this.startDate,
    this.endDate,
    this.searchText,
    this.tags,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  factory AuditSearchCriteria.fromJson(Map<String, dynamic> json) =>
      _$AuditSearchCriteriaFromJson(json);

  Map<String, dynamic> toJson() => _$AuditSearchCriteriaToJson(this);
}

enum SortOrder {
  @JsonValue('asc')
  ascending,
  @JsonValue('desc')
  descending,
}

/// Audit search results
@JsonSerializable()
class AuditSearchResult {
  final List<AuditTrailEntry> entries;
  final int totalCount;
  final int pageSize;
  final int currentPage;
  final bool hasMore;
  final Map<String, int> eventTypeCounts;
  final Map<String, int> severityCounts;

  const AuditSearchResult({
    required this.entries,
    required this.totalCount,
    required this.pageSize,
    required this.currentPage,
    required this.hasMore,
    required this.eventTypeCounts,
    required this.severityCounts,
  });

  factory AuditSearchResult.fromJson(Map<String, dynamic> json) =>
      _$AuditSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$AuditSearchResultToJson(this);
}

/// Compliance report configuration
@JsonSerializable()
class ComplianceReportConfig {
  final String id;
  final String businessId;
  final String reportType;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<AuditEventType> includedEventTypes;
  final List<String> includedEntityTypes;
  final Map<String, dynamic> filters;
  final ReportFormat format;
  final bool includeExplanations;
  final bool includeRiskAnalysis;
  final DateTime createdAt;
  final String createdBy;

  const ComplianceReportConfig({
    required this.id,
    required this.businessId,
    required this.reportType,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.includedEventTypes,
    required this.includedEntityTypes,
    required this.filters,
    required this.format,
    required this.includeExplanations,
    required this.includeRiskAnalysis,
    required this.createdAt,
    required this.createdBy,
  });

  factory ComplianceReportConfig.fromJson(Map<String, dynamic> json) =>
      _$ComplianceReportConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ComplianceReportConfigToJson(this);
}

enum ReportFormat {
  @JsonValue('pdf')
  pdf,
  @JsonValue('excel')
  excel,
  @JsonValue('csv')
  csv,
  @JsonValue('json')
  json,
}

/// Generated compliance report
@JsonSerializable()
class ComplianceReport {
  final String id;
  final String configId;
  final String businessId;
  final String title;
  final DateTime generatedAt;
  final String generatedBy;
  final ReportStatus status;
  final String? filePath;
  final int totalEntries;
  final Map<String, int> summaryStats;
  final List<ComplianceIssue> issues;
  final Map<String, dynamic> metadata;

  const ComplianceReport({
    required this.id,
    required this.configId,
    required this.businessId,
    required this.title,
    required this.generatedAt,
    required this.generatedBy,
    required this.status,
    this.filePath,
    required this.totalEntries,
    required this.summaryStats,
    required this.issues,
    required this.metadata,
  });

  factory ComplianceReport.fromJson(Map<String, dynamic> json) =>
      _$ComplianceReportFromJson(json);

  Map<String, dynamic> toJson() => _$ComplianceReportToJson(this);
}

enum ReportStatus {
  @JsonValue('generating')
  generating,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
}

/// Compliance issue identified in audit
@JsonSerializable()
class ComplianceIssue {
  final String id;
  final String description;
  final IssueSeverity severity;
  final String category;
  final List<String> relatedEntryIds;
  final String recommendation;
  final DateTime identifiedAt;

  const ComplianceIssue({
    required this.id,
    required this.description,
    required this.severity,
    required this.category,
    required this.relatedEntryIds,
    required this.recommendation,
    required this.identifiedAt,
  });

  factory ComplianceIssue.fromJson(Map<String, dynamic> json) =>
      _$ComplianceIssueFromJson(json);

  Map<String, dynamic> toJson() => _$ComplianceIssueToJson(this);
}

enum IssueSeverity {
  @JsonValue('info')
  info,
  @JsonValue('warning')
  warning,
  @JsonValue('error')
  error,
  @JsonValue('critical')
  critical,
}

/// Audit trail for tracking AI decisions and actions
@JsonSerializable()
class AuditTrail {
  final String id;
  final String businessId;
  final String userId;
  final AuditEventType eventType;
  final String entityId;
  final String entityType;
  final String action;
  final Map<String, dynamic> beforeState;
  final Map<String, dynamic> afterState;
  final Map<String, dynamic> metadata;
  final String? reasoning;
  final double? confidenceScore;
  final DateTime timestamp;
  final String? sessionId;
  final String? ipAddress;
  final String? userAgent;
  final AuditSeverity severity;
  final List<String> tags;

  const AuditTrail({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.eventType,
    required this.entityId,
    required this.entityType,
    required this.action,
    required this.beforeState,
    required this.afterState,
    required this.metadata,
    this.reasoning,
    this.confidenceScore,
    required this.timestamp,
    this.sessionId,
    this.ipAddress,
    this.userAgent,
    required this.severity,
    required this.tags,
  });

  factory AuditTrail.fromJson(Map<String, dynamic> json) =>
      _$AuditTrailFromJson(json);

  Map<String, dynamic> toJson() => _$AuditTrailToJson(this);
}

/// Algorithmic audit for AI model performance and bias detection
@JsonSerializable()
class AlgorithmicAudit {
  final String id;
  final String businessId;
  final String modelName;
  final String modelVersion;
  final DateTime conductedAt;
  final String conductedBy;
  final Map<String, dynamic> performanceMetrics;
  final Map<String, dynamic> biasMetrics;
  final Map<String, dynamic> fairnessMetrics;
  final List<String> issues;
  final List<String> recommendations;
  final AuditStatus status;
  final Map<String, dynamic> metadata;

  const AlgorithmicAudit({
    required this.id,
    required this.businessId,
    required this.modelName,
    required this.modelVersion,
    required this.conductedAt,
    required this.conductedBy,
    required this.performanceMetrics,
    required this.biasMetrics,
    required this.fairnessMetrics,
    required this.issues,
    required this.recommendations,
    required this.status,
    required this.metadata,
  });

  factory AlgorithmicAudit.fromJson(Map<String, dynamic> json) =>
      _$AlgorithmicAuditFromJson(json);

  Map<String, dynamic> toJson() => _$AlgorithmicAuditToJson(this);
}

enum AuditStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
}

/// User role for authorization
enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('user')
  user,
  @JsonValue('viewer')
  viewer,
  @JsonValue('auditor')
  auditor,
}
