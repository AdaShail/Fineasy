import 'package:json_annotation/json_annotation.dart';

part 'ai_models.g.dart';

// Enums for AI models
enum FraudType {
  @JsonValue('duplicate_invoice')
  duplicateInvoice,
  @JsonValue('payment_mismatch')
  paymentMismatch,
  @JsonValue('suspicious_pattern')
  suspiciousPattern,
  @JsonValue('duplicate_supplier_bill')
  duplicateSupplierBill,
}

enum InsightType {
  @JsonValue('cash_flow_prediction')
  cashFlowPrediction,
  @JsonValue('customer_analysis')
  customerAnalysis,
  @JsonValue('working_capital')
  workingCapital,
  @JsonValue('expense_trend')
  expenseTrend,
  @JsonValue('revenue_forecast')
  revenueForecast,
  @JsonValue('general')
  general,
}

enum ComplianceType {
  @JsonValue('gst_mismatch')
  gstMismatch,
  @JsonValue('missing_gstin')
  missingGstin,
  @JsonValue('tax_calculation_error')
  taxCalculationError,
  @JsonValue('incomplete_invoice_data')
  incompleteInvoiceData,
  @JsonValue('warning')
  warning,
}

enum ComplianceSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

enum ComplianceStatus {
  @JsonValue('compliant')
  compliant,
  @JsonValue('issues_found')
  issuesFound,
  @JsonValue('critical_issues')
  criticalIssues,
  @JsonValue('warning')
  warning,
  @JsonValue('unknown')
  unknown,
}

// Fraud Detection Models
@JsonSerializable()
class FraudAlert {
  final String id;
  final FraudType type;
  final String message;
  @JsonKey(name: 'confidence_score')
  final double confidenceScore;
  final Map<String, dynamic> evidence;
  @JsonKey(name: 'detected_at')
  final DateTime detectedAt;

  FraudAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.confidenceScore,
    required this.evidence,
    required this.detectedAt,
  });

  factory FraudAlert.fromJson(Map<String, dynamic> json) =>
      _$FraudAlertFromJson(json);
  Map<String, dynamic> toJson() => _$FraudAlertToJson(this);
}

@JsonSerializable()
class FraudAnalysisResponse {
  @JsonKey(name: 'business_id')
  final String businessId;
  final List<FraudAlert> alerts;
  @JsonKey(name: 'risk_score')
  final double riskScore;
  @JsonKey(name: 'analysis_metadata')
  final Map<String, dynamic> analysisMetadata;
  @JsonKey(name: 'analyzed_at')
  final DateTime analyzedAt;

  FraudAnalysisResponse({
    required this.businessId,
    required this.alerts,
    required this.riskScore,
    required this.analysisMetadata,
    required this.analyzedAt,
  });

  factory FraudAnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$FraudAnalysisResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FraudAnalysisResponseToJson(this);
}

// Business Insights Models
@JsonSerializable()
class BusinessInsight {
  @JsonKey(name: 'insight_id')
  final String id;
  @JsonKey(name: 'insight_type')
  final InsightType type;
  final String title;
  final String description;
  final List<String> recommendations;
  @JsonKey(name: 'impact_score')
  final double? impactScore;
  @JsonKey(name: 'valid_until')
  final DateTime? validUntil;
  final String? priority;
  final String? category;
  final Map<String, dynamic>? data;

  BusinessInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.recommendations,
    this.impactScore,
    this.validUntil,
    this.priority,
    this.category,
    this.data,
  });

  factory BusinessInsight.fromJson(Map<String, dynamic> json) =>
      _$BusinessInsightFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessInsightToJson(this);
}

@JsonSerializable()
class BusinessInsightsResponse {
  final bool success;
  final String? message;
  final DateTime timestamp;
  final List<BusinessInsight> insights;
  @JsonKey(name: 'business_id')
  final String? businessId;
  @JsonKey(name: 'generated_at')
  final DateTime? generatedAt;
  @JsonKey(name: 'next_update')
  final DateTime? nextUpdate;

  BusinessInsightsResponse({
    required this.success,
    this.message,
    required this.timestamp,
    required this.insights,
    this.businessId,
    this.generatedAt,
    this.nextUpdate,
  });

  factory BusinessInsightsResponse.fromJson(Map<String, dynamic> json) =>
      _$BusinessInsightsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessInsightsResponseToJson(this);
}

// Compliance Models
@JsonSerializable()
class ComplianceIssue {
  final String id;
  final ComplianceType type;
  final String description;
  @JsonKey(name: 'plain_language_explanation')
  final String plainLanguageExplanation;
  @JsonKey(name: 'suggested_fixes')
  final List<String> suggestedFixes;
  final ComplianceSeverity severity;

  ComplianceIssue({
    required this.id,
    required this.type,
    required this.description,
    required this.plainLanguageExplanation,
    required this.suggestedFixes,
    required this.severity,
  });

  factory ComplianceIssue.fromJson(Map<String, dynamic> json) =>
      _$ComplianceIssueFromJson(json);
  Map<String, dynamic> toJson() => _$ComplianceIssueToJson(this);
}

@JsonSerializable()
class ComplianceResponse {
  @JsonKey(name: 'invoice_id')
  final String invoiceId;
  final List<ComplianceIssue> issues;
  @JsonKey(name: 'overall_status')
  final ComplianceStatus overallStatus;
  @JsonKey(name: 'last_checked')
  final DateTime lastChecked;

  ComplianceResponse({
    required this.invoiceId,
    required this.issues,
    required this.overallStatus,
    required this.lastChecked,
  });

  factory ComplianceResponse.fromJson(Map<String, dynamic> json) =>
      _$ComplianceResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ComplianceResponseToJson(this);
}

// NLP Invoice Models
@JsonSerializable()
class InvoiceGenerationRequest {
  @JsonKey(name: 'raw_input')
  final String rawInput;
  @JsonKey(name: 'business_id')
  final String businessId;

  InvoiceGenerationRequest({required this.rawInput, required this.businessId});

  factory InvoiceGenerationRequest.fromJson(Map<String, dynamic> json) =>
      _$InvoiceGenerationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceGenerationRequestToJson(this);
}

@JsonSerializable()
class InvoiceGenerationResponse {
  final bool success;
  final String? message;
  @JsonKey(name: 'invoice_id')
  final String? invoiceId;
  @JsonKey(name: 'invoice_data')
  final Map<String, dynamic>? invoiceData;
  @JsonKey(name: 'extracted_entities')
  final Map<String, dynamic>? extractedEntities;
  @JsonKey(name: 'confidence_score')
  final double? confidenceScore;
  final List<String> errors;
  final List<String> suggestions;

  InvoiceGenerationResponse({
    required this.success,
    this.message,
    this.invoiceId,
    this.invoiceData,
    this.extractedEntities,
    this.confidenceScore,
    required this.errors,
    required this.suggestions,
  });

  factory InvoiceGenerationResponse.fromJson(Map<String, dynamic> json) =>
      _$InvoiceGenerationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceGenerationResponseToJson(this);
}

// AI Settings Models
@JsonSerializable()
class AISettings {
  @JsonKey(name: 'fraud_detection_enabled')
  final bool fraudDetectionEnabled;
  @JsonKey(name: 'predictive_insights_enabled')
  final bool predictiveInsightsEnabled;
  @JsonKey(name: 'compliance_checking_enabled')
  final bool complianceCheckingEnabled;
  @JsonKey(name: 'nlp_invoice_enabled')
  final bool nlpInvoiceEnabled;
  @JsonKey(name: 'data_sharing_enabled')
  final bool dataSharingEnabled;
  @JsonKey(name: 'anonymize_data')
  final bool anonymizeData;
  @JsonKey(name: 'notification_preferences')
  final AINotificationPreferences notificationPreferences;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  AISettings({
    required this.fraudDetectionEnabled,
    required this.predictiveInsightsEnabled,
    required this.complianceCheckingEnabled,
    required this.nlpInvoiceEnabled,
    required this.dataSharingEnabled,
    required this.anonymizeData,
    required this.notificationPreferences,
    required this.updatedAt,
  });

  factory AISettings.fromJson(Map<String, dynamic> json) =>
      _$AISettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AISettingsToJson(this);

  AISettings copyWith({
    bool? fraudDetectionEnabled,
    bool? predictiveInsightsEnabled,
    bool? complianceCheckingEnabled,
    bool? nlpInvoiceEnabled,
    bool? dataSharingEnabled,
    bool? anonymizeData,
    AINotificationPreferences? notificationPreferences,
    DateTime? updatedAt,
  }) {
    return AISettings(
      fraudDetectionEnabled:
          fraudDetectionEnabled ?? this.fraudDetectionEnabled,
      predictiveInsightsEnabled:
          predictiveInsightsEnabled ?? this.predictiveInsightsEnabled,
      complianceCheckingEnabled:
          complianceCheckingEnabled ?? this.complianceCheckingEnabled,
      nlpInvoiceEnabled: nlpInvoiceEnabled ?? this.nlpInvoiceEnabled,
      dataSharingEnabled: dataSharingEnabled ?? this.dataSharingEnabled,
      anonymizeData: anonymizeData ?? this.anonymizeData,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class AINotificationPreferences {
  @JsonKey(name: 'fraud_alerts')
  final bool fraudAlerts;
  @JsonKey(name: 'insight_notifications')
  final bool insightNotifications;
  @JsonKey(name: 'compliance_reminders')
  final bool complianceReminders;
  @JsonKey(name: 'performance_updates')
  final bool performanceUpdates;

  AINotificationPreferences({
    required this.fraudAlerts,
    required this.insightNotifications,
    required this.complianceReminders,
    required this.performanceUpdates,
  });

  factory AINotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$AINotificationPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$AINotificationPreferencesToJson(this);

  AINotificationPreferences copyWith({
    bool? fraudAlerts,
    bool? insightNotifications,
    bool? complianceReminders,
    bool? performanceUpdates,
  }) {
    return AINotificationPreferences(
      fraudAlerts: fraudAlerts ?? this.fraudAlerts,
      insightNotifications: insightNotifications ?? this.insightNotifications,
      complianceReminders: complianceReminders ?? this.complianceReminders,
      performanceUpdates: performanceUpdates ?? this.performanceUpdates,
    );
  }
}

@JsonSerializable()
class AIModelPerformance {
  @JsonKey(name: 'model_name')
  final String modelName;
  @JsonKey(name: 'model_type')
  final String modelType;
  @JsonKey(name: 'accuracy_score')
  final double accuracyScore;
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;
  @JsonKey(name: 'total_predictions')
  final int totalPredictions;
  @JsonKey(name: 'correct_predictions')
  final int correctPredictions;
  @JsonKey(name: 'response_time_ms')
  final double responseTimeMs;

  AIModelPerformance({
    required this.modelName,
    required this.modelType,
    required this.accuracyScore,
    required this.lastUpdated,
    required this.totalPredictions,
    required this.correctPredictions,
    required this.responseTimeMs,
  });

  factory AIModelPerformance.fromJson(Map<String, dynamic> json) =>
      _$AIModelPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$AIModelPerformanceToJson(this);
}

@JsonSerializable()
class AIFeedback {
  final String id;
  @JsonKey(name: 'feedback_type')
  final String feedbackType;
  @JsonKey(name: 'entity_id')
  final String entityId;
  final bool helpful;
  final String? comment;
  @JsonKey(name: 'submitted_at')
  final DateTime submittedAt;

  AIFeedback({
    required this.id,
    required this.feedbackType,
    required this.entityId,
    required this.helpful,
    this.comment,
    required this.submittedAt,
  });

  factory AIFeedback.fromJson(Map<String, dynamic> json) =>
      _$AIFeedbackFromJson(json);
  Map<String, dynamic> toJson() => _$AIFeedbackToJson(this);
}

// Service Status Models
@JsonSerializable()
class AIServiceStatus {
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  final String status;
  final String message;
  @JsonKey(name: 'last_checked')
  final DateTime lastChecked;
  final Map<String, bool> features;

  AIServiceStatus({
    required this.isAvailable,
    required this.status,
    required this.message,
    required this.lastChecked,
    required this.features,
  });

  factory AIServiceStatus.fromJson(Map<String, dynamic> json) =>
      _$AIServiceStatusFromJson(json);
  Map<String, dynamic> toJson() => _$AIServiceStatusToJson(this);
}

// Error Models
@JsonSerializable()
class AIErrorResponse {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  AIErrorResponse({required this.message, this.code, this.details});

  factory AIErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$AIErrorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AIErrorResponseToJson(this);
}
