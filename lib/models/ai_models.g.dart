// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FraudAlert _$FraudAlertFromJson(Map<String, dynamic> json) => FraudAlert(
  id: json['id'] as String,
  type: $enumDecode(_$FraudTypeEnumMap, json['type']),
  message: json['message'] as String,
  confidenceScore: (json['confidence_score'] as num).toDouble(),
  evidence: json['evidence'] as Map<String, dynamic>,
  detectedAt: DateTime.parse(json['detected_at'] as String),
);

Map<String, dynamic> _$FraudAlertToJson(FraudAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$FraudTypeEnumMap[instance.type]!,
      'message': instance.message,
      'confidence_score': instance.confidenceScore,
      'evidence': instance.evidence,
      'detected_at': instance.detectedAt.toIso8601String(),
    };

const _$FraudTypeEnumMap = {
  FraudType.duplicateInvoice: 'duplicate_invoice',
  FraudType.paymentMismatch: 'payment_mismatch',
  FraudType.suspiciousPattern: 'suspicious_pattern',
  FraudType.duplicateSupplierBill: 'duplicate_supplier_bill',
};

FraudAnalysisResponse _$FraudAnalysisResponseFromJson(
  Map<String, dynamic> json,
) => FraudAnalysisResponse(
  businessId: json['business_id'] as String,
  alerts:
      (json['alerts'] as List<dynamic>)
          .map((e) => FraudAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
  riskScore: (json['risk_score'] as num).toDouble(),
  analysisMetadata: json['analysis_metadata'] as Map<String, dynamic>,
  analyzedAt: DateTime.parse(json['analyzed_at'] as String),
);

Map<String, dynamic> _$FraudAnalysisResponseToJson(
  FraudAnalysisResponse instance,
) => <String, dynamic>{
  'business_id': instance.businessId,
  'alerts': instance.alerts,
  'risk_score': instance.riskScore,
  'analysis_metadata': instance.analysisMetadata,
  'analyzed_at': instance.analyzedAt.toIso8601String(),
};

BusinessInsight _$BusinessInsightFromJson(Map<String, dynamic> json) =>
    BusinessInsight(
      id: json['insight_id'] as String,
      type: $enumDecode(_$InsightTypeEnumMap, json['insight_type']),
      title: json['title'] as String,
      description: json['description'] as String,
      recommendations:
          (json['recommendations'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      impactScore: (json['impact_score'] as num?)?.toDouble(),
      validUntil:
          json['valid_until'] == null
              ? null
              : DateTime.parse(json['valid_until'] as String),
      priority: json['priority'] as String?,
      category: json['category'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$BusinessInsightToJson(BusinessInsight instance) =>
    <String, dynamic>{
      'insight_id': instance.id,
      'insight_type': _$InsightTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'recommendations': instance.recommendations,
      'impact_score': instance.impactScore,
      'valid_until': instance.validUntil?.toIso8601String(),
      'priority': instance.priority,
      'category': instance.category,
      'data': instance.data,
    };

const _$InsightTypeEnumMap = {
  InsightType.cashFlowPrediction: 'cash_flow_prediction',
  InsightType.customerAnalysis: 'customer_analysis',
  InsightType.workingCapital: 'working_capital',
  InsightType.expenseTrend: 'expense_trend',
  InsightType.revenueForecast: 'revenue_forecast',
  InsightType.general: 'general',
};

BusinessInsightsResponse _$BusinessInsightsResponseFromJson(
  Map<String, dynamic> json,
) => BusinessInsightsResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  insights:
      (json['insights'] as List<dynamic>)
          .map((e) => BusinessInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
  businessId: json['business_id'] as String?,
  generatedAt:
      json['generated_at'] == null
          ? null
          : DateTime.parse(json['generated_at'] as String),
  nextUpdate:
      json['next_update'] == null
          ? null
          : DateTime.parse(json['next_update'] as String),
);

Map<String, dynamic> _$BusinessInsightsResponseToJson(
  BusinessInsightsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'timestamp': instance.timestamp.toIso8601String(),
  'insights': instance.insights,
  'business_id': instance.businessId,
  'generated_at': instance.generatedAt?.toIso8601String(),
  'next_update': instance.nextUpdate?.toIso8601String(),
};

ComplianceIssue _$ComplianceIssueFromJson(Map<String, dynamic> json) =>
    ComplianceIssue(
      id: json['id'] as String,
      type: $enumDecode(_$ComplianceTypeEnumMap, json['type']),
      description: json['description'] as String,
      plainLanguageExplanation: json['plain_language_explanation'] as String,
      suggestedFixes:
          (json['suggested_fixes'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      severity: $enumDecode(_$ComplianceSeverityEnumMap, json['severity']),
    );

Map<String, dynamic> _$ComplianceIssueToJson(ComplianceIssue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ComplianceTypeEnumMap[instance.type]!,
      'description': instance.description,
      'plain_language_explanation': instance.plainLanguageExplanation,
      'suggested_fixes': instance.suggestedFixes,
      'severity': _$ComplianceSeverityEnumMap[instance.severity]!,
    };

const _$ComplianceTypeEnumMap = {
  ComplianceType.gstMismatch: 'gst_mismatch',
  ComplianceType.missingGstin: 'missing_gstin',
  ComplianceType.taxCalculationError: 'tax_calculation_error',
  ComplianceType.incompleteInvoiceData: 'incomplete_invoice_data',
  ComplianceType.warning: 'warning',
};

const _$ComplianceSeverityEnumMap = {
  ComplianceSeverity.low: 'low',
  ComplianceSeverity.medium: 'medium',
  ComplianceSeverity.high: 'high',
  ComplianceSeverity.critical: 'critical',
};

ComplianceResponse _$ComplianceResponseFromJson(Map<String, dynamic> json) =>
    ComplianceResponse(
      invoiceId: json['invoice_id'] as String,
      issues:
          (json['issues'] as List<dynamic>)
              .map((e) => ComplianceIssue.fromJson(e as Map<String, dynamic>))
              .toList(),
      overallStatus: $enumDecode(
        _$ComplianceStatusEnumMap,
        json['overall_status'],
      ),
      lastChecked: DateTime.parse(json['last_checked'] as String),
    );

Map<String, dynamic> _$ComplianceResponseToJson(ComplianceResponse instance) =>
    <String, dynamic>{
      'invoice_id': instance.invoiceId,
      'issues': instance.issues,
      'overall_status': _$ComplianceStatusEnumMap[instance.overallStatus]!,
      'last_checked': instance.lastChecked.toIso8601String(),
    };

const _$ComplianceStatusEnumMap = {
  ComplianceStatus.compliant: 'compliant',
  ComplianceStatus.issuesFound: 'issues_found',
  ComplianceStatus.criticalIssues: 'critical_issues',
  ComplianceStatus.warning: 'warning',
  ComplianceStatus.unknown: 'unknown',
};

InvoiceGenerationRequest _$InvoiceGenerationRequestFromJson(
  Map<String, dynamic> json,
) => InvoiceGenerationRequest(
  rawInput: json['raw_input'] as String,
  businessId: json['business_id'] as String,
);

Map<String, dynamic> _$InvoiceGenerationRequestToJson(
  InvoiceGenerationRequest instance,
) => <String, dynamic>{
  'raw_input': instance.rawInput,
  'business_id': instance.businessId,
};

InvoiceGenerationResponse _$InvoiceGenerationResponseFromJson(
  Map<String, dynamic> json,
) => InvoiceGenerationResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  invoiceId: json['invoice_id'] as String?,
  invoiceData: json['invoice_data'] as Map<String, dynamic>?,
  extractedEntities: json['extracted_entities'] as Map<String, dynamic>?,
  confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
  errors: (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
  suggestions:
      (json['suggestions'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$InvoiceGenerationResponseToJson(
  InvoiceGenerationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'invoice_id': instance.invoiceId,
  'invoice_data': instance.invoiceData,
  'extracted_entities': instance.extractedEntities,
  'confidence_score': instance.confidenceScore,
  'errors': instance.errors,
  'suggestions': instance.suggestions,
};

AISettings _$AISettingsFromJson(Map<String, dynamic> json) => AISettings(
  fraudDetectionEnabled: json['fraud_detection_enabled'] as bool,
  predictiveInsightsEnabled: json['predictive_insights_enabled'] as bool,
  complianceCheckingEnabled: json['compliance_checking_enabled'] as bool,
  nlpInvoiceEnabled: json['nlp_invoice_enabled'] as bool,
  dataSharingEnabled: json['data_sharing_enabled'] as bool,
  anonymizeData: json['anonymize_data'] as bool,
  notificationPreferences: AINotificationPreferences.fromJson(
    json['notification_preferences'] as Map<String, dynamic>,
  ),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AISettingsToJson(AISettings instance) =>
    <String, dynamic>{
      'fraud_detection_enabled': instance.fraudDetectionEnabled,
      'predictive_insights_enabled': instance.predictiveInsightsEnabled,
      'compliance_checking_enabled': instance.complianceCheckingEnabled,
      'nlp_invoice_enabled': instance.nlpInvoiceEnabled,
      'data_sharing_enabled': instance.dataSharingEnabled,
      'anonymize_data': instance.anonymizeData,
      'notification_preferences': instance.notificationPreferences,
      'updated_at': instance.updatedAt.toIso8601String(),
    };

AINotificationPreferences _$AINotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => AINotificationPreferences(
  fraudAlerts: json['fraud_alerts'] as bool,
  insightNotifications: json['insight_notifications'] as bool,
  complianceReminders: json['compliance_reminders'] as bool,
  performanceUpdates: json['performance_updates'] as bool,
);

Map<String, dynamic> _$AINotificationPreferencesToJson(
  AINotificationPreferences instance,
) => <String, dynamic>{
  'fraud_alerts': instance.fraudAlerts,
  'insight_notifications': instance.insightNotifications,
  'compliance_reminders': instance.complianceReminders,
  'performance_updates': instance.performanceUpdates,
};

AIModelPerformance _$AIModelPerformanceFromJson(Map<String, dynamic> json) =>
    AIModelPerformance(
      modelName: json['model_name'] as String,
      modelType: json['model_type'] as String,
      accuracyScore: (json['accuracy_score'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      totalPredictions: (json['total_predictions'] as num).toInt(),
      correctPredictions: (json['correct_predictions'] as num).toInt(),
      responseTimeMs: (json['response_time_ms'] as num).toDouble(),
    );

Map<String, dynamic> _$AIModelPerformanceToJson(AIModelPerformance instance) =>
    <String, dynamic>{
      'model_name': instance.modelName,
      'model_type': instance.modelType,
      'accuracy_score': instance.accuracyScore,
      'last_updated': instance.lastUpdated.toIso8601String(),
      'total_predictions': instance.totalPredictions,
      'correct_predictions': instance.correctPredictions,
      'response_time_ms': instance.responseTimeMs,
    };

AIFeedback _$AIFeedbackFromJson(Map<String, dynamic> json) => AIFeedback(
  id: json['id'] as String,
  feedbackType: json['feedback_type'] as String,
  entityId: json['entity_id'] as String,
  helpful: json['helpful'] as bool,
  comment: json['comment'] as String?,
  submittedAt: DateTime.parse(json['submitted_at'] as String),
);

Map<String, dynamic> _$AIFeedbackToJson(AIFeedback instance) =>
    <String, dynamic>{
      'id': instance.id,
      'feedback_type': instance.feedbackType,
      'entity_id': instance.entityId,
      'helpful': instance.helpful,
      'comment': instance.comment,
      'submitted_at': instance.submittedAt.toIso8601String(),
    };

AIServiceStatus _$AIServiceStatusFromJson(Map<String, dynamic> json) =>
    AIServiceStatus(
      isAvailable: json['is_available'] as bool,
      status: json['status'] as String,
      message: json['message'] as String,
      lastChecked: DateTime.parse(json['last_checked'] as String),
      features: Map<String, bool>.from(json['features'] as Map),
    );

Map<String, dynamic> _$AIServiceStatusToJson(AIServiceStatus instance) =>
    <String, dynamic>{
      'is_available': instance.isAvailable,
      'status': instance.status,
      'message': instance.message,
      'last_checked': instance.lastChecked.toIso8601String(),
      'features': instance.features,
    };

AIErrorResponse _$AIErrorResponseFromJson(Map<String, dynamic> json) =>
    AIErrorResponse(
      message: json['message'] as String,
      code: json['code'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AIErrorResponseToJson(AIErrorResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'details': instance.details,
    };
