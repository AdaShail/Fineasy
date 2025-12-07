// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditTrailEntry _$AuditTrailEntryFromJson(Map<String, dynamic> json) =>
    AuditTrailEntry(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      userId: json['userId'] as String,
      eventType: $enumDecode(_$AuditEventTypeEnumMap, json['eventType']),
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String,
      action: json['action'] as String,
      beforeState: json['beforeState'] as Map<String, dynamic>,
      afterState: json['afterState'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>,
      reasoning: json['reasoning'] as String?,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      sessionId: json['sessionId'] as String?,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
      severity: $enumDecode(_$AuditSeverityEnumMap, json['severity']),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AuditTrailEntryToJson(AuditTrailEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'userId': instance.userId,
      'eventType': _$AuditEventTypeEnumMap[instance.eventType]!,
      'entityId': instance.entityId,
      'entityType': instance.entityType,
      'action': instance.action,
      'beforeState': instance.beforeState,
      'afterState': instance.afterState,
      'metadata': instance.metadata,
      'reasoning': instance.reasoning,
      'confidenceScore': instance.confidenceScore,
      'timestamp': instance.timestamp.toIso8601String(),
      'sessionId': instance.sessionId,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'severity': _$AuditSeverityEnumMap[instance.severity]!,
      'tags': instance.tags,
    };

const _$AuditEventTypeEnumMap = {
  AuditEventType.aiDecision: 'ai_decision',
  AuditEventType.actionExecution: 'action_execution',
  AuditEventType.userOverride: 'user_override',
  AuditEventType.systemError: 'system_error',
  AuditEventType.configurationChange: 'configuration_change',
  AuditEventType.dataAccess: 'data_access',
  AuditEventType.authentication: 'authentication',
  AuditEventType.authorization: 'authorization',
  AuditEventType.workflowExecution: 'workflow_execution',
  AuditEventType.modelPrediction: 'model_prediction',
};

const _$AuditSeverityEnumMap = {
  AuditSeverity.low: 'low',
  AuditSeverity.medium: 'medium',
  AuditSeverity.high: 'high',
  AuditSeverity.critical: 'critical',
};

DecisionExplanation _$DecisionExplanationFromJson(Map<String, dynamic> json) =>
    DecisionExplanation(
      decisionId: json['decisionId'] as String,
      businessId: json['businessId'] as String,
      decisionType: json['decisionType'] as String,
      summary: json['summary'] as String,
      reasoningSteps:
          (json['reasoningSteps'] as List<dynamic>)
              .map((e) => ReasoningStep.fromJson(e as Map<String, dynamic>))
              .toList(),
      inputData: json['inputData'] as Map<String, dynamic>,
      outputData: json['outputData'] as Map<String, dynamic>,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      alternatives:
          (json['alternatives'] as List<dynamic>)
              .map((e) => AlternativeOption.fromJson(e as Map<String, dynamic>))
              .toList(),
      risks:
          (json['risks'] as List<dynamic>)
              .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
              .toList(),
      assumptions:
          (json['assumptions'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DecisionExplanationToJson(
  DecisionExplanation instance,
) => <String, dynamic>{
  'decisionId': instance.decisionId,
  'businessId': instance.businessId,
  'decisionType': instance.decisionType,
  'summary': instance.summary,
  'reasoningSteps': instance.reasoningSteps,
  'inputData': instance.inputData,
  'outputData': instance.outputData,
  'confidenceScore': instance.confidenceScore,
  'alternatives': instance.alternatives,
  'risks': instance.risks,
  'assumptions': instance.assumptions,
  'createdAt': instance.createdAt.toIso8601String(),
};

ReasoningStep _$ReasoningStepFromJson(Map<String, dynamic> json) =>
    ReasoningStep(
      stepNumber: (json['stepNumber'] as num).toInt(),
      description: json['description'] as String,
      rationale: json['rationale'] as String,
      data: json['data'] as Map<String, dynamic>,
      weight: (json['weight'] as num).toDouble(),
      source: json['source'] as String?,
    );

Map<String, dynamic> _$ReasoningStepToJson(ReasoningStep instance) =>
    <String, dynamic>{
      'stepNumber': instance.stepNumber,
      'description': instance.description,
      'rationale': instance.rationale,
      'data': instance.data,
      'weight': instance.weight,
      'source': instance.source,
    };

AlternativeOption _$AlternativeOptionFromJson(Map<String, dynamic> json) =>
    AlternativeOption(
      id: json['id'] as String,
      description: json['description'] as String,
      score: (json['score'] as num).toDouble(),
      whyNotChosen: json['whyNotChosen'] as String,
      pros: json['pros'] as Map<String, dynamic>,
      cons: json['cons'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AlternativeOptionToJson(AlternativeOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'score': instance.score,
      'whyNotChosen': instance.whyNotChosen,
      'pros': instance.pros,
      'cons': instance.cons,
    };

RiskFactor _$RiskFactorFromJson(Map<String, dynamic> json) => RiskFactor(
  id: json['id'] as String,
  description: json['description'] as String,
  level: $enumDecode(_$RiskLevelEnumMap, json['level']),
  probability: (json['probability'] as num).toDouble(),
  mitigation: json['mitigation'] as String,
  impact: json['impact'] as String,
);

Map<String, dynamic> _$RiskFactorToJson(RiskFactor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'level': _$RiskLevelEnumMap[instance.level]!,
      'probability': instance.probability,
      'mitigation': instance.mitigation,
      'impact': instance.impact,
    };

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.medium: 'medium',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
};

AuditSearchCriteria _$AuditSearchCriteriaFromJson(Map<String, dynamic> json) =>
    AuditSearchCriteria(
      businessId: json['businessId'] as String?,
      userId: json['userId'] as String?,
      eventTypes:
          (json['eventTypes'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$AuditEventTypeEnumMap, e))
              .toList(),
      entityTypes:
          (json['entityTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      severities:
          (json['severities'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$AuditSeverityEnumMap, e))
              .toList(),
      startDate:
          json['startDate'] == null
              ? null
              : DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] == null
              ? null
              : DateTime.parse(json['endDate'] as String),
      searchText: json['searchText'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      limit: (json['limit'] as num?)?.toInt(),
      offset: (json['offset'] as num?)?.toInt(),
      sortBy: json['sortBy'] as String?,
      sortOrder: $enumDecodeNullable(_$SortOrderEnumMap, json['sortOrder']),
    );

Map<String, dynamic> _$AuditSearchCriteriaToJson(
  AuditSearchCriteria instance,
) => <String, dynamic>{
  'businessId': instance.businessId,
  'userId': instance.userId,
  'eventTypes':
      instance.eventTypes?.map((e) => _$AuditEventTypeEnumMap[e]!).toList(),
  'entityTypes': instance.entityTypes,
  'severities':
      instance.severities?.map((e) => _$AuditSeverityEnumMap[e]!).toList(),
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'searchText': instance.searchText,
  'tags': instance.tags,
  'limit': instance.limit,
  'offset': instance.offset,
  'sortBy': instance.sortBy,
  'sortOrder': _$SortOrderEnumMap[instance.sortOrder],
};

const _$SortOrderEnumMap = {
  SortOrder.ascending: 'asc',
  SortOrder.descending: 'desc',
};

AuditSearchResult _$AuditSearchResultFromJson(Map<String, dynamic> json) =>
    AuditSearchResult(
      entries:
          (json['entries'] as List<dynamic>)
              .map((e) => AuditTrailEntry.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      hasMore: json['hasMore'] as bool,
      eventTypeCounts: Map<String, int>.from(json['eventTypeCounts'] as Map),
      severityCounts: Map<String, int>.from(json['severityCounts'] as Map),
    );

Map<String, dynamic> _$AuditSearchResultToJson(AuditSearchResult instance) =>
    <String, dynamic>{
      'entries': instance.entries,
      'totalCount': instance.totalCount,
      'pageSize': instance.pageSize,
      'currentPage': instance.currentPage,
      'hasMore': instance.hasMore,
      'eventTypeCounts': instance.eventTypeCounts,
      'severityCounts': instance.severityCounts,
    };

ComplianceReportConfig _$ComplianceReportConfigFromJson(
  Map<String, dynamic> json,
) => ComplianceReportConfig(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  reportType: json['reportType'] as String,
  title: json['title'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  includedEventTypes:
      (json['includedEventTypes'] as List<dynamic>)
          .map((e) => $enumDecode(_$AuditEventTypeEnumMap, e))
          .toList(),
  includedEntityTypes:
      (json['includedEntityTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  filters: json['filters'] as Map<String, dynamic>,
  format: $enumDecode(_$ReportFormatEnumMap, json['format']),
  includeExplanations: json['includeExplanations'] as bool,
  includeRiskAnalysis: json['includeRiskAnalysis'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  createdBy: json['createdBy'] as String,
);

Map<String, dynamic> _$ComplianceReportConfigToJson(
  ComplianceReportConfig instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'reportType': instance.reportType,
  'title': instance.title,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'includedEventTypes':
      instance.includedEventTypes
          .map((e) => _$AuditEventTypeEnumMap[e]!)
          .toList(),
  'includedEntityTypes': instance.includedEntityTypes,
  'filters': instance.filters,
  'format': _$ReportFormatEnumMap[instance.format]!,
  'includeExplanations': instance.includeExplanations,
  'includeRiskAnalysis': instance.includeRiskAnalysis,
  'createdAt': instance.createdAt.toIso8601String(),
  'createdBy': instance.createdBy,
};

const _$ReportFormatEnumMap = {
  ReportFormat.pdf: 'pdf',
  ReportFormat.excel: 'excel',
  ReportFormat.csv: 'csv',
  ReportFormat.json: 'json',
};

ComplianceReport _$ComplianceReportFromJson(Map<String, dynamic> json) =>
    ComplianceReport(
      id: json['id'] as String,
      configId: json['configId'] as String,
      businessId: json['businessId'] as String,
      title: json['title'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      generatedBy: json['generatedBy'] as String,
      status: $enumDecode(_$ReportStatusEnumMap, json['status']),
      filePath: json['filePath'] as String?,
      totalEntries: (json['totalEntries'] as num).toInt(),
      summaryStats: Map<String, int>.from(json['summaryStats'] as Map),
      issues:
          (json['issues'] as List<dynamic>)
              .map((e) => ComplianceIssue.fromJson(e as Map<String, dynamic>))
              .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ComplianceReportToJson(ComplianceReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'configId': instance.configId,
      'businessId': instance.businessId,
      'title': instance.title,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'generatedBy': instance.generatedBy,
      'status': _$ReportStatusEnumMap[instance.status]!,
      'filePath': instance.filePath,
      'totalEntries': instance.totalEntries,
      'summaryStats': instance.summaryStats,
      'issues': instance.issues,
      'metadata': instance.metadata,
    };

const _$ReportStatusEnumMap = {
  ReportStatus.generating: 'generating',
  ReportStatus.completed: 'completed',
  ReportStatus.failed: 'failed',
};

ComplianceIssue _$ComplianceIssueFromJson(Map<String, dynamic> json) =>
    ComplianceIssue(
      id: json['id'] as String,
      description: json['description'] as String,
      severity: $enumDecode(_$IssueSeverityEnumMap, json['severity']),
      category: json['category'] as String,
      relatedEntryIds:
          (json['relatedEntryIds'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      recommendation: json['recommendation'] as String,
      identifiedAt: DateTime.parse(json['identifiedAt'] as String),
    );

Map<String, dynamic> _$ComplianceIssueToJson(ComplianceIssue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'severity': _$IssueSeverityEnumMap[instance.severity]!,
      'category': instance.category,
      'relatedEntryIds': instance.relatedEntryIds,
      'recommendation': instance.recommendation,
      'identifiedAt': instance.identifiedAt.toIso8601String(),
    };

const _$IssueSeverityEnumMap = {
  IssueSeverity.info: 'info',
  IssueSeverity.warning: 'warning',
  IssueSeverity.error: 'error',
  IssueSeverity.critical: 'critical',
};

AuditTrail _$AuditTrailFromJson(Map<String, dynamic> json) => AuditTrail(
  id: json['id'] as String,
  businessId: json['businessId'] as String,
  userId: json['userId'] as String,
  eventType: $enumDecode(_$AuditEventTypeEnumMap, json['eventType']),
  entityId: json['entityId'] as String,
  entityType: json['entityType'] as String,
  action: json['action'] as String,
  beforeState: json['beforeState'] as Map<String, dynamic>,
  afterState: json['afterState'] as Map<String, dynamic>,
  metadata: json['metadata'] as Map<String, dynamic>,
  reasoning: json['reasoning'] as String?,
  confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  sessionId: json['sessionId'] as String?,
  ipAddress: json['ipAddress'] as String?,
  userAgent: json['userAgent'] as String?,
  severity: $enumDecode(_$AuditSeverityEnumMap, json['severity']),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$AuditTrailToJson(AuditTrail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'userId': instance.userId,
      'eventType': _$AuditEventTypeEnumMap[instance.eventType]!,
      'entityId': instance.entityId,
      'entityType': instance.entityType,
      'action': instance.action,
      'beforeState': instance.beforeState,
      'afterState': instance.afterState,
      'metadata': instance.metadata,
      'reasoning': instance.reasoning,
      'confidenceScore': instance.confidenceScore,
      'timestamp': instance.timestamp.toIso8601String(),
      'sessionId': instance.sessionId,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
      'severity': _$AuditSeverityEnumMap[instance.severity]!,
      'tags': instance.tags,
    };

AlgorithmicAudit _$AlgorithmicAuditFromJson(Map<String, dynamic> json) =>
    AlgorithmicAudit(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      modelName: json['modelName'] as String,
      modelVersion: json['modelVersion'] as String,
      conductedAt: DateTime.parse(json['conductedAt'] as String),
      conductedBy: json['conductedBy'] as String,
      performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>,
      biasMetrics: json['biasMetrics'] as Map<String, dynamic>,
      fairnessMetrics: json['fairnessMetrics'] as Map<String, dynamic>,
      issues:
          (json['issues'] as List<dynamic>).map((e) => e as String).toList(),
      recommendations:
          (json['recommendations'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      status: $enumDecode(_$AuditStatusEnumMap, json['status']),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AlgorithmicAuditToJson(AlgorithmicAudit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessId': instance.businessId,
      'modelName': instance.modelName,
      'modelVersion': instance.modelVersion,
      'conductedAt': instance.conductedAt.toIso8601String(),
      'conductedBy': instance.conductedBy,
      'performanceMetrics': instance.performanceMetrics,
      'biasMetrics': instance.biasMetrics,
      'fairnessMetrics': instance.fairnessMetrics,
      'issues': instance.issues,
      'recommendations': instance.recommendations,
      'status': _$AuditStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
    };

const _$AuditStatusEnumMap = {
  AuditStatus.pending: 'pending',
  AuditStatus.inProgress: 'in_progress',
  AuditStatus.completed: 'completed',
  AuditStatus.failed: 'failed',
};
