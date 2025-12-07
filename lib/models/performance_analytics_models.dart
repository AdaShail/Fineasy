import 'package:json_annotation/json_annotation.dart';

part 'performance_analytics_models.g.dart';

/// Represents the outcome tracking for an AI decision
@JsonSerializable()
class DecisionOutcome {
  final String id;
  final String decisionId;
  final String businessId;
  final DecisionOutcomeType type;
  final double predictedValue;
  final double actualValue;
  final double accuracyScore;
  final Map<String, dynamic> metrics;
  final DateTime recordedAt;
  final String? notes;

  const DecisionOutcome({
    required this.id,
    required this.decisionId,
    required this.businessId,
    required this.type,
    required this.predictedValue,
    required this.actualValue,
    required this.accuracyScore,
    required this.metrics,
    required this.recordedAt,
    this.notes,
  });

  factory DecisionOutcome.fromJson(Map<String, dynamic> json) =>
      _$DecisionOutcomeFromJson(json);

  Map<String, dynamic> toJson() => _$DecisionOutcomeToJson(this);
}

/// Types of decision outcomes that can be tracked
enum DecisionOutcomeType {
  cashFlowPrediction,
  customerBehavior,
  paymentRecovery,
  expenseOptimization,
  riskAssessment,
  opportunityIdentification,
  supplierPerformance,
  complianceAction,
}

/// Performance metrics for the AI system
@JsonSerializable()
class AIPerformanceMetrics {
  final String businessId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalDecisions;
  final int successfulDecisions;
  final double overallAccuracy;
  final double averageConfidence;
  final Map<DecisionOutcomeType, double> accuracyByType;
  final Map<String, double> keyMetrics;
  final DateTime calculatedAt;

  const AIPerformanceMetrics({
    required this.businessId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalDecisions,
    required this.successfulDecisions,
    required this.overallAccuracy,
    required this.averageConfidence,
    required this.accuracyByType,
    required this.keyMetrics,
    required this.calculatedAt,
  });

  factory AIPerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$AIPerformanceMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$AIPerformanceMetricsToJson(this);
}

/// ROI calculation for automated decisions and actions
@JsonSerializable()
class AutomationROI {
  final String id;
  final String businessId;
  final String actionId;
  final ROICategory category;
  final double costSavings;
  final double timeSavings; // in hours
  final double revenueImpact;
  final double implementationCost;
  final double netROI;
  final double roiPercentage;
  final Map<String, dynamic> breakdown;
  final DateTime calculatedAt;

  const AutomationROI({
    required this.id,
    required this.businessId,
    required this.actionId,
    required this.category,
    required this.costSavings,
    required this.timeSavings,
    required this.revenueImpact,
    required this.implementationCost,
    required this.netROI,
    required this.roiPercentage,
    required this.breakdown,
    required this.calculatedAt,
  });

  factory AutomationROI.fromJson(Map<String, dynamic> json) =>
      _$AutomationROIFromJson(json);

  Map<String, dynamic> toJson() => _$AutomationROIToJson(this);
}

/// Categories for ROI calculation
enum ROICategory {
  paymentReminders,
  expenseControl,
  customerManagement,
  supplierNegotiation,
  complianceAutomation,
  riskMitigation,
  processOptimization,
}

/// Business impact measurement
@JsonSerializable()
class BusinessImpactMetrics {
  final String businessId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double cashFlowImprovement;
  final double customerSatisfactionDelta;
  final double operationalEfficiencyGain;
  final double complianceScoreImprovement;
  final int automatedTasksCount;
  final double totalTimeSaved; // in hours
  final double totalCostSavings;
  final Map<String, double> categoryImpacts;
  final DateTime calculatedAt;

  const BusinessImpactMetrics({
    required this.businessId,
    required this.periodStart,
    required this.periodEnd,
    required this.cashFlowImprovement,
    required this.customerSatisfactionDelta,
    required this.operationalEfficiencyGain,
    required this.complianceScoreImprovement,
    required this.automatedTasksCount,
    required this.totalTimeSaved,
    required this.totalCostSavings,
    required this.categoryImpacts,
    required this.calculatedAt,
  });

  factory BusinessImpactMetrics.fromJson(Map<String, dynamic> json) =>
      _$BusinessImpactMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessImpactMetricsToJson(this);
}

/// Performance dashboard data
@JsonSerializable()
class PerformanceDashboardData {
  final String businessId;
  final AIPerformanceMetrics aiMetrics;
  final BusinessImpactMetrics businessImpact;
  final List<AutomationROI> topROIActions;
  final List<DecisionOutcome> recentOutcomes;
  final Map<String, dynamic> trends;
  final List<PerformanceAlert> alerts;
  final DateTime generatedAt;

  const PerformanceDashboardData({
    required this.businessId,
    required this.aiMetrics,
    required this.businessImpact,
    required this.topROIActions,
    required this.recentOutcomes,
    required this.trends,
    required this.alerts,
    required this.generatedAt,
  });

  factory PerformanceDashboardData.fromJson(Map<String, dynamic> json) =>
      _$PerformanceDashboardDataFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceDashboardDataToJson(this);
}

/// Performance alerts for system monitoring
@JsonSerializable()
class PerformanceAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String description;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isResolved;

  const PerformanceAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.data,
    required this.createdAt,
    required this.isResolved,
  });

  factory PerformanceAlert.fromJson(Map<String, dynamic> json) =>
      _$PerformanceAlertFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceAlertToJson(this);
}

/// Types of performance alerts
enum AlertType {
  accuracyDrop,
  performanceDegradation,
  roiDecline,
  systemError,
  dataQualityIssue,
}

/// Severity levels for alerts
enum AlertSeverity { low, medium, high, critical }

/// Performance report configuration
@JsonSerializable()
class PerformanceReportConfig {
  final String businessId;
  final ReportType type;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> includedMetrics;
  final Map<String, dynamic> filters;
  final ReportFormat format;

  const PerformanceReportConfig({
    required this.businessId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.includedMetrics,
    required this.filters,
    required this.format,
  });

  factory PerformanceReportConfig.fromJson(Map<String, dynamic> json) =>
      _$PerformanceReportConfigFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceReportConfigToJson(this);
}

/// Types of performance reports
enum ReportType { weekly, monthly, quarterly, annual, custom }

/// Report output formats
enum ReportFormat { json, pdf, excel, dashboard }
