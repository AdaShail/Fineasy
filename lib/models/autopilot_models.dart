import 'package:json_annotation/json_annotation.dart';

part 'autopilot_models.g.dart';

// Enums for AutoPilot
enum DecisionType {
  @JsonValue('cash_flow_management')
  cashFlowManagement,
  @JsonValue('customer_relationship')
  customerRelationship,
  @JsonValue('supplier_negotiation')
  supplierNegotiation,
  @JsonValue('risk_mitigation')
  riskMitigation,
  @JsonValue('growth_opportunity')
  growthOpportunity,
  @JsonValue('compliance_action')
  complianceAction,
  @JsonValue('operational_optimization')
  operationalOptimization,
  @JsonValue('market_expansion')
  marketExpansion,
  @JsonValue('product_launch')
  productLaunch,
  @JsonValue('expansion')
  expansion,
}

enum ActionType {
  @JsonValue('send_reminder')
  sendReminder,
  @JsonValue('schedule_payment')
  schedulePayment,
  @JsonValue('negotiate_terms')
  negotiateTerms,
  @JsonValue('create_invoice')
  createInvoice,
  @JsonValue('update_inventory')
  updateInventory,
  @JsonValue('send_notification')
  sendNotification,
  @JsonValue('generate_report')
  generateReport,
  @JsonValue('optimize_pricing')
  optimizePricing,
  @JsonValue('adjust_credit_limit')
  adjustCreditLimit,
  @JsonValue('update_pricing')
  updatePricing,
  @JsonValue('block_transaction')
  blockTransaction,
  @JsonValue('reserve_funds')
  reserveFunds,
  @JsonValue('escalate_issue')
  escalateIssue,
}

enum DecisionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('executed')
  executed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}

enum ActionPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

enum ActionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}

enum AutonomyLevel {
  @JsonValue('manual')
  manual,
  @JsonValue('supervised')
  supervised,
  @JsonValue('autonomous')
  autonomous,
}

enum SystemStatus {
  @JsonValue('active')
  active,
  @JsonValue('paused')
  paused,
  @JsonValue('error')
  error,
  @JsonValue('maintenance')
  maintenance,
}

enum IntegrationType {
  @JsonValue('whatsapp')
  whatsapp,
  @JsonValue('email')
  email,
  @JsonValue('sms')
  sms,
  @JsonValue('banking')
  banking,
  @JsonValue('gst')
  gst,
  @JsonValue('payment')
  payment,
}

enum TestStatus {
  @JsonValue('not_tested')
  notTested,
  @JsonValue('testing')
  testing,
  @JsonValue('success')
  success,
  @JsonValue('failed')
  failed,
}

enum AutoPilotFeature {
  @JsonValue('cash_flow_management')
  cashFlowManagement,
  @JsonValue('customer_relationship')
  customerRelationship,
  @JsonValue('supplier_management')
  supplierManagement,
  @JsonValue('risk_assessment')
  riskAssessment,
  @JsonValue('growth_opportunities')
  growthOpportunities,
  @JsonValue('compliance_monitoring')
  complianceMonitoring,
  @JsonValue('operational_optimization')
  operationalOptimization,
  @JsonValue('payment_reminders')
  paymentReminders,
}

enum DecisionComplexity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
}

enum BusinessRuleType {
  @JsonValue('threshold')
  threshold,
  @JsonValue('approval')
  approval,
  @JsonValue('notification')
  notification,
  @JsonValue('automation')
  automation,
  @JsonValue('cash_flow')
  cashFlow,
  @JsonValue('payment')
  payment,
  @JsonValue('expense')
  expense,
  @JsonValue('customer')
  customer,
  @JsonValue('supplier')
  supplier,
  @JsonValue('compliance')
  compliance,
}

enum RiskType {
  @JsonValue('financial')
  financial,
  @JsonValue('operational')
  operational,
  @JsonValue('market')
  market,
  @JsonValue('compliance')
  compliance,
  @JsonValue('overall')
  overall,
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

enum RiskSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

enum InvestmentRecommendation {
  @JsonValue('strongly_recommended')
  stronglyRecommended,
  @JsonValue('recommended')
  recommended,
  @JsonValue('neutral')
  neutral,
  @JsonValue('not_recommended')
  notRecommended,
  @JsonValue('conditional')
  conditional,
}

enum ExpansionType {
  @JsonValue('geographic')
  geographic,
  @JsonValue('product_line')
  productLine,
  @JsonValue('market_segment')
  marketSegment,
  @JsonValue('vertical_integration')
  verticalIntegration,
  @JsonValue('new_market')
  newMarket,
  @JsonValue('new_product')
  newProduct,
  @JsonValue('scale_up')
  scaleUp,
  @JsonValue('acquisition')
  acquisition,
}

enum ExpansionRecommendation {
  @JsonValue('proceed')
  proceed,
  @JsonValue('proceed_with_caution')
  proceedWithCaution,
  @JsonValue('delay')
  delay,
  @JsonValue('not_recommended')
  notRecommended,
  @JsonValue('requires_more_analysis')
  requiresMoreAnalysis,
}

enum HiringRecommendation {
  @JsonValue('hire_immediately')
  hireImmediately,
  @JsonValue('hire_within_quarter')
  hireWithinQuarter,
  @JsonValue('delay_hiring')
  delayHiring,
  @JsonValue('not_recommended')
  notRecommended,
  @JsonValue('strongly_recommended')
  stronglyRecommended,
  @JsonValue('recommended')
  recommended,
  @JsonValue('conditional')
  conditional,
}

enum TimingRecommendation {
  @JsonValue('immediate')
  immediate,
  @JsonValue('within_month')
  withinMonth,
  @JsonValue('within_quarter')
  withinQuarter,
  @JsonValue('next_year')
  nextYear,
  @JsonValue('wait_for_improvement')
  waitForImprovement,
}

enum HiringRiskType {
  @JsonValue('financial')
  financial,
  @JsonValue('cultural_fit')
  culturalFit,
  @JsonValue('skill_mismatch')
  skillMismatch,
  @JsonValue('market_conditions')
  marketConditions,
  @JsonValue('cash_flow')
  cashFlow,
  @JsonValue('market')
  market,
}

enum RecommendationType {
  @JsonValue('positioning')
  positioning,
  @JsonValue('differentiation')
  differentiation,
  @JsonValue('competitive')
  competitive,
  @JsonValue('increase_spend')
  increaseSpend,
  @JsonValue('decrease_spend')
  decreaseSpend,
  @JsonValue('optimize_or_pause')
  optimizeOrPause,
  @JsonValue('reallocate_budget')
  reallocateBudget,
}

enum Priority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
}

enum ChannelEffectiveness {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
}

enum TrendDirection {
  @JsonValue('improving')
  improving,
  @JsonValue('stable')
  stable,
  @JsonValue('declining')
  declining,
  @JsonValue('up')
  up,
  @JsonValue('down')
  down,
}

enum AcquisitionTrend {
  @JsonValue('improving')
  improving,
  @JsonValue('stable')
  stable,
  @JsonValue('declining')
  declining,
}

enum AllocationStrategy {
  @JsonValue('performance_based')
  performanceBased,
  @JsonValue('diversified')
  diversified,
  @JsonValue('aggressive_growth')
  aggressiveGrowth,
}

enum RecommendationPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
}

// Core AutoPilot Models
@JsonSerializable()
class AutoPilotDecision {
  final String id;
  @JsonKey(name: 'business_id')
  final String businessId;
  final DecisionType type;
  final String title;
  final String description;
  final String? reasoning;
  @JsonKey(name: 'estimated_cost')
  final double estimatedCost;
  @JsonKey(name: 'estimated_benefit')
  final double estimatedBenefit;
  final DecisionComplexity complexity;
  @JsonKey(name: 'confidence_score')
  final double confidenceScore;
  final DecisionStatus status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'requires_approval')
  final bool requiresApproval;
  final List<AutoPilotAction> actions;
  @JsonKey(name: 'recommended_actions')
  final List<AutoPilotAction> recommendedActions;
  @JsonKey(name: 'risk_factors')
  final List<String> riskFactors;
  final Map<String, dynamic> metadata;

  AutoPilotDecision({
    required this.id,
    required this.businessId,
    required this.type,
    required this.title,
    required this.description,
    this.reasoning,
    required this.estimatedCost,
    required this.estimatedBenefit,
    required this.complexity,
    required this.confidenceScore,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.requiresApproval,
    required this.actions,
    required this.recommendedActions,
    required this.riskFactors,
    required this.metadata,
  });

  factory AutoPilotDecision.fromJson(Map<String, dynamic> json) =>
      _$AutoPilotDecisionFromJson(json);
  Map<String, dynamic> toJson() => _$AutoPilotDecisionToJson(this);

  AutoPilotDecision copyWith({
    String? id,
    String? businessId,
    DecisionType? type,
    String? title,
    String? description,
    String? reasoning,
    double? estimatedCost,
    double? estimatedBenefit,
    DecisionComplexity? complexity,
    double? confidenceScore,
    DecisionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? requiresApproval,
    List<AutoPilotAction>? actions,
    List<AutoPilotAction>? recommendedActions,
    List<String>? riskFactors,
    Map<String, dynamic>? metadata,
  }) {
    return AutoPilotDecision(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      reasoning: reasoning ?? this.reasoning,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      estimatedBenefit: estimatedBenefit ?? this.estimatedBenefit,
      complexity: complexity ?? this.complexity,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      actions: actions ?? this.actions,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      riskFactors: riskFactors ?? this.riskFactors,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class AutoPilotAction {
  final String id;
  @JsonKey(name: 'decision_id')
  final String decisionId;
  final ActionType type;
  final String description;
  final ActionPriority priority;
  final ActionStatus status;
  @JsonKey(name: 'scheduled_at')
  final DateTime? scheduledAt;
  @JsonKey(name: 'executed_at')
  final DateTime? executedAt;
  final bool success;
  @JsonKey(name: 'error_message')
  final String? errorMessage;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> result;
  @JsonKey(name: 'required_approvals')
  final List<String> requiredApprovals;
  @JsonKey(name: 'is_reversible')
  final bool isReversible;
  @JsonKey(name: 'rollback_data')
  final Map<String, dynamic>? rollbackData;

  AutoPilotAction({
    required this.id,
    required this.decisionId,
    required this.type,
    required this.description,
    required this.priority,
    required this.status,
    this.scheduledAt,
    this.executedAt,
    required this.success,
    this.errorMessage,
    required this.parameters,
    required this.result,
    required this.requiredApprovals,
    required this.isReversible,
    this.rollbackData,
  });

  factory AutoPilotAction.fromJson(Map<String, dynamic> json) =>
      _$AutoPilotActionFromJson(json);
  Map<String, dynamic> toJson() => _$AutoPilotActionToJson(this);
}

@JsonSerializable()
class AutoPilotConfig {
  final String id;
  @JsonKey(name: 'business_id')
  final String businessId;
  @JsonKey(name: 'enabled_features')
  final List<AutoPilotFeature> enabledFeatures;
  @JsonKey(name: 'confidence_threshold')
  final double confidenceThreshold;
  @JsonKey(name: 'approval_required_threshold')
  final double approvalRequiredThreshold;
  @JsonKey(name: 'business_rules')
  final List<BusinessRule> businessRules;
  @JsonKey(name: 'notification_settings')
  final Map<String, bool> notificationSettings;
  @JsonKey(name: 'autonomy_level')
  final AutonomyLevel autonomyLevel;
  @JsonKey(name: 'integration_settings')
  final Map<String, dynamic> integrationSettings;
  @JsonKey(name: 'auto_execute_low_risk')
  final bool autoExecuteLowRisk;
  @JsonKey(name: 'notify_all_actions')
  final bool notifyAllActions;
  @JsonKey(name: 'learn_from_overrides')
  final bool learnFromOverrides;
  @JsonKey(name: 'payment_approval_threshold')
  final double paymentApprovalThreshold;
  @JsonKey(name: 'credit_limit_approval_threshold')
  final double creditLimitApprovalThreshold;

  AutoPilotConfig({
    required this.id,
    required this.businessId,
    required this.enabledFeatures,
    required this.confidenceThreshold,
    required this.approvalRequiredThreshold,
    required this.businessRules,
    required this.notificationSettings,
    required this.autonomyLevel,
    this.integrationSettings = const {},
    this.autoExecuteLowRisk = false,
    this.notifyAllActions = true,
    this.learnFromOverrides = true,
    this.paymentApprovalThreshold = 10000.0,
    this.creditLimitApprovalThreshold = 50000.0,
  });

  factory AutoPilotConfig.fromJson(Map<String, dynamic> json) =>
      _$AutoPilotConfigFromJson(json);
  Map<String, dynamic> toJson() => _$AutoPilotConfigToJson(this);

  AutoPilotConfig copyWith({
    String? id,
    String? businessId,
    List<AutoPilotFeature>? enabledFeatures,
    double? confidenceThreshold,
    double? approvalRequiredThreshold,
    List<BusinessRule>? businessRules,
    Map<String, bool>? notificationSettings,
    AutonomyLevel? autonomyLevel,
    Map<String, dynamic>? integrationSettings,
    bool? autoExecuteLowRisk,
    bool? notifyAllActions,
    bool? learnFromOverrides,
    double? paymentApprovalThreshold,
    double? creditLimitApprovalThreshold,
  }) {
    return AutoPilotConfig(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      enabledFeatures: enabledFeatures ?? this.enabledFeatures,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      approvalRequiredThreshold:
          approvalRequiredThreshold ?? this.approvalRequiredThreshold,
      businessRules: businessRules ?? this.businessRules,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      autonomyLevel: autonomyLevel ?? this.autonomyLevel,
      integrationSettings: integrationSettings ?? this.integrationSettings,
      autoExecuteLowRisk: autoExecuteLowRisk ?? this.autoExecuteLowRisk,
      notifyAllActions: notifyAllActions ?? this.notifyAllActions,
      learnFromOverrides: learnFromOverrides ?? this.learnFromOverrides,
      paymentApprovalThreshold:
          paymentApprovalThreshold ?? this.paymentApprovalThreshold,
      creditLimitApprovalThreshold:
          creditLimitApprovalThreshold ?? this.creditLimitApprovalThreshold,
    );
  }
}

@JsonSerializable()
class BusinessRule {
  final String id;
  final String name;
  final String description;
  final BusinessRuleType type;
  final String condition;
  final String action;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  BusinessRule({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.condition,
    required this.action,
    required this.isActive,
    required this.createdAt,
  });

  factory BusinessRule.fromJson(Map<String, dynamic> json) =>
      _$BusinessRuleFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessRuleToJson(this);

  BusinessRule copyWith({
    String? id,
    String? name,
    String? description,
    BusinessRuleType? type,
    String? condition,
    String? action,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return BusinessRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      condition: condition ?? this.condition,
      action: action ?? this.action,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ROI Analysis Models
@JsonSerializable()
class ROIAnalysis {
  final String id;
  final double initialInvestment;
  final double npv; // Net Present Value
  final double irr; // Internal Rate of Return
  final double paybackPeriod;
  final double profitabilityIndex;
  final RiskLevel riskLevel;
  final String recommendation;
  final List<double> projectedCashFlows;
  final double discountRate;
  final DateTime calculatedAt;

  ROIAnalysis({
    required this.id,
    required this.initialInvestment,
    required this.npv,
    required this.irr,
    required this.paybackPeriod,
    required this.profitabilityIndex,
    required this.riskLevel,
    required this.recommendation,
    required this.projectedCashFlows,
    required this.discountRate,
    required this.calculatedAt,
  });

  factory ROIAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ROIAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$ROIAnalysisToJson(this);
}

// Hiring Decision Models
@JsonSerializable()
class HiringDecisionAnalysis {
  final String id;
  final HiringPlan hiringPlan;
  final double estimatedCost;
  final double expectedROI;
  final List<HiringRisk> risks;
  final HiringRecommendation recommendation;
  final double confidenceScore;
  final DateTime analysisDate;

  HiringDecisionAnalysis({
    required this.id,
    required this.hiringPlan,
    required this.estimatedCost,
    required this.expectedROI,
    required this.risks,
    required this.recommendation,
    required this.confidenceScore,
    required this.analysisDate,
  });

  factory HiringDecisionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$HiringDecisionAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$HiringDecisionAnalysisToJson(this);
}

@JsonSerializable()
class HiringPlan {
  final String position;
  final String department;
  final double salary;
  final DateTime startDate;
  final String justification;

  HiringPlan({
    required this.position,
    required this.department,
    required this.salary,
    required this.startDate,
    required this.justification,
  });

  factory HiringPlan.fromJson(Map<String, dynamic> json) =>
      _$HiringPlanFromJson(json);
  Map<String, dynamic> toJson() => _$HiringPlanToJson(this);
}

@JsonSerializable()
class HiringRisk {
  final HiringRiskType type;
  final String description;
  final RiskSeverity severity;
  final double probability;

  HiringRisk({
    required this.type,
    required this.description,
    required this.severity,
    required this.probability,
  });

  factory HiringRisk.fromJson(Map<String, dynamic> json) =>
      _$HiringRiskFromJson(json);
  Map<String, dynamic> toJson() => _$HiringRiskToJson(this);
}

// Marketing Channel Models
@JsonSerializable()
class MarketingChannel {
  final String name;
  final String type;
  final double estimatedROI;
  final double estimatedConversionRate;
  final double estimatedCPA;
  final double estimatedLTV;
  final double reachPotential;
  final double scalability;
  final double competitiveIntensity;

  MarketingChannel({
    required this.name,
    required this.type,
    required this.estimatedROI,
    required this.estimatedConversionRate,
    required this.estimatedCPA,
    required this.estimatedLTV,
    required this.reachPotential,
    required this.scalability,
    required this.competitiveIntensity,
  });

  factory MarketingChannel.fromJson(Map<String, dynamic> json) =>
      _$MarketingChannelFromJson(json);
  Map<String, dynamic> toJson() => _$MarketingChannelToJson(this);
}

@JsonSerializable()
class ChannelPerformance {
  @JsonKey(name: 'channel_name')
  final String channelName;
  final double roi;
  @JsonKey(name: 'customer_acquisition_cost')
  final double customerAcquisitionCost;
  @JsonKey(name: 'conversion_rate')
  final double conversionRate;
  final ChannelEffectiveness effectiveness;
  @JsonKey(name: 'trend_direction')
  final TrendDirection trendDirection;

  ChannelPerformance({
    required this.channelName,
    required this.roi,
    required this.customerAcquisitionCost,
    required this.conversionRate,
    required this.effectiveness,
    required this.trendDirection,
  });

  factory ChannelPerformance.fromJson(Map<String, dynamic> json) =>
      _$ChannelPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$ChannelPerformanceToJson(this);
}

// Decision Explanation Models
@JsonSerializable()
class DecisionExplanation {
  final String decisionId;
  final String reasoning;
  final List<String> factors;
  final Map<String, double> weights;
  final double confidence;

  DecisionExplanation({
    required this.decisionId,
    required this.reasoning,
    required this.factors,
    required this.weights,
    required this.confidence,
  });

  factory DecisionExplanation.fromJson(Map<String, dynamic> json) =>
      _$DecisionExplanationFromJson(json);
  Map<String, dynamic> toJson() => _$DecisionExplanationToJson(this);
}

// Action Result Models
@JsonSerializable()
class ActionResult {
  final String actionId;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic> data;
  final DateTime executedAt;

  ActionResult({
    required this.actionId,
    required this.success,
    this.errorMessage,
    required this.data,
    required this.executedAt,
  });

  factory ActionResult.fromJson(Map<String, dynamic> json) =>
      _$ActionResultFromJson(json);
  Map<String, dynamic> toJson() => _$ActionResultToJson(this);
}

// Business Event Models
@JsonSerializable()
class BusinessEvent {
  final String id;
  final String type;
  @JsonKey(name: 'event_type')
  final String eventType;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final String businessId;

  BusinessEvent({
    required this.id,
    required this.type,
    required this.eventType,
    required this.description,
    required this.timestamp,
    required this.data,
    required this.businessId,
  });

  factory BusinessEvent.fromJson(Map<String, dynamic> json) =>
      _$BusinessEventFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessEventToJson(this);
}

// AutoPilot Status Models
@JsonSerializable()
class AutoPilotStatus {
  final bool isActive;
  final String mode;
  final int activeDecisions;
  final int completedActions;
  final double systemHealth;
  final DateTime lastUpdate;
  final bool active;
  final bool paused;
  final bool error;
  final bool maintenance;

  AutoPilotStatus({
    required this.isActive,
    required this.mode,
    required this.activeDecisions,
    required this.completedActions,
    required this.systemHealth,
    required this.lastUpdate,
    required this.active,
    required this.paused,
    required this.error,
    required this.maintenance,
  });

  factory AutoPilotStatus.fromJson(Map<String, dynamic> json) =>
      _$AutoPilotStatusFromJson(json);
  Map<String, dynamic> toJson() => _$AutoPilotStatusToJson(this);
}

// Conversation Models
@JsonSerializable()
class ConversationContext {
  final String id;
  final String businessId;
  final DateTime startedAt;
  DateTime lastActivity;
  final Map<String, dynamic> context;

  ConversationContext({
    required this.id,
    required this.businessId,
    required this.startedAt,
    required this.lastActivity,
    required this.context,
  });

  factory ConversationContext.fromJson(Map<String, dynamic> json) =>
      _$ConversationContextFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationContextToJson(this);
}

@JsonSerializable()
class ConversationTurn {
  final String id;
  final String conversationId;
  final String userMessage;
  final String aiResponse;
  final DateTime timestamp;

  ConversationTurn({
    required this.id,
    required this.conversationId,
    required this.userMessage,
    required this.aiResponse,
    required this.timestamp,
  });

  factory ConversationTurn.fromJson(Map<String, dynamic> json) =>
      _$ConversationTurnFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationTurnToJson(this);
}

@JsonSerializable()
class AIResponse {
  final String message;
  final String? action;
  final Map<String, dynamic>? parameters;
  final double confidence;

  AIResponse({
    required this.message,
    this.action,
    this.parameters,
    required this.confidence,
  });

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AIResponseToJson(this);
}

// Notification Models
enum NotificationType {
  @JsonValue('decision')
  decision,
  @JsonValue('action')
  action,
  @JsonValue('action_required')
  actionRequired,
  @JsonValue('action_completed')
  actionCompleted,
  @JsonValue('action_failed')
  actionFailed,
  @JsonValue('error')
  error,
  @JsonValue('success')
  success,
  @JsonValue('warning')
  warning,
  @JsonValue('system_alert')
  systemAlert,
  @JsonValue('system_error')
  systemError,
  @JsonValue('business_insight')
  businessInsight,
  @JsonValue('performance_alert')
  performanceAlert,
}

enum NotificationPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

enum NotificationFilter {
  @JsonValue('all')
  all,
  @JsonValue('unread')
  unread,
  @JsonValue('decisions')
  decisions,
  @JsonValue('actions')
  actions,
  @JsonValue('errors')
  errors,
}

@JsonSerializable()
class AutoPilotNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final String? relatedId;

  AutoPilotNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.medium,
    required this.isRead,
    required this.createdAt,
    this.metadata,
    this.relatedId,
  });

  factory AutoPilotNotification.fromJson(Map<String, dynamic> json) =>
      _$AutoPilotNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AutoPilotNotificationToJson(this);

  AutoPilotNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    String? relatedId,
  }) {
    return AutoPilotNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}

// Business Context and Decision Models
@JsonSerializable()
class BusinessContext {
  @JsonKey(name: 'business_id')
  final String businessId;
  @JsonKey(name: 'financial_state')
  final Map<String, dynamic> financialState;
  @JsonKey(name: 'customer_relationships')
  final Map<String, dynamic> customerRelationships;
  @JsonKey(name: 'supplier_relationships')
  final Map<String, dynamic> supplierRelationships;
  @JsonKey(name: 'market_conditions')
  final Map<String, dynamic> marketConditions;
  @JsonKey(name: 'compliance_status')
  final Map<String, dynamic> complianceStatus;
  @JsonKey(name: 'operational_metrics')
  final Map<String, dynamic> operationalMetrics;
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

  BusinessContext({
    required this.businessId,
    required this.financialState,
    required this.customerRelationships,
    required this.supplierRelationships,
    required this.marketConditions,
    required this.complianceStatus,
    required this.operationalMetrics,
    required this.lastUpdated,
  });

  factory BusinessContext.fromJson(Map<String, dynamic> json) =>
      _$BusinessContextFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessContextToJson(this);

  BusinessContext copyWith({
    String? businessId,
    Map<String, dynamic>? financialState,
    Map<String, dynamic>? customerRelationships,
    Map<String, dynamic>? supplierRelationships,
    Map<String, dynamic>? marketConditions,
    Map<String, dynamic>? complianceStatus,
    Map<String, dynamic>? operationalMetrics,
    DateTime? lastUpdated,
  }) {
    return BusinessContext(
      businessId: businessId ?? this.businessId,
      financialState: financialState ?? this.financialState,
      customerRelationships:
          customerRelationships ?? this.customerRelationships,
      supplierRelationships:
          supplierRelationships ?? this.supplierRelationships,
      marketConditions: marketConditions ?? this.marketConditions,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      operationalMetrics: operationalMetrics ?? this.operationalMetrics,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

@JsonSerializable()
class BusinessDecision {
  final String id;
  @JsonKey(name: 'business_id')
  final String businessId;
  final DecisionType type;
  final String description;
  @JsonKey(name: 'estimated_cost')
  final double? estimatedCost;
  final String? timeline;
  final DecisionComplexity? complexity;
  final Map<String, dynamic>? parameters;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  BusinessDecision({
    required this.id,
    required this.businessId,
    required this.type,
    required this.description,
    this.estimatedCost,
    this.timeline,
    this.complexity,
    this.parameters,
    required this.createdAt,
  });

  factory BusinessDecision.fromJson(Map<String, dynamic> json) =>
      _$BusinessDecisionFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessDecisionToJson(this);
}

// AI Action Model
@JsonSerializable()
class AIAction {
  final String id;
  final String type;
  final String description;
  final Map<String, dynamic> parameters;
  final ActionPriority priority;
  final ActionStatus status;
  final DateTime createdAt;
  final DateTime? executedAt;

  AIAction({
    required this.id,
    required this.type,
    required this.description,
    required this.parameters,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.executedAt,
  });

  factory AIAction.fromJson(Map<String, dynamic> json) =>
      _$AIActionFromJson(json);
  Map<String, dynamic> toJson() => _$AIActionToJson(this);
}

// Integration Models
@JsonSerializable()
class IntegrationConfig {
  final String id;
  final IntegrationType type;
  final bool isEnabled;
  final bool isConfigured;
  final Map<String, dynamic> settings;
  @JsonKey(name: 'last_tested')
  final DateTime? lastTested;
  @JsonKey(name: 'test_status')
  final TestStatus testStatus;
  @JsonKey(name: 'error_message')
  final String? errorMessage;

  IntegrationConfig({
    required this.id,
    required this.type,
    required this.isEnabled,
    required this.isConfigured,
    required this.settings,
    this.lastTested,
    this.testStatus = TestStatus.notTested,
    this.errorMessage,
  });

  factory IntegrationConfig.fromJson(Map<String, dynamic> json) =>
      _$IntegrationConfigFromJson(json);
  Map<String, dynamic> toJson() => _$IntegrationConfigToJson(this);

  IntegrationConfig copyWith({
    String? id,
    IntegrationType? type,
    bool? isEnabled,
    bool? isConfigured,
    Map<String, dynamic>? settings,
    DateTime? lastTested,
    TestStatus? testStatus,
    String? errorMessage,
  }) {
    return IntegrationConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      isConfigured: isConfigured ?? this.isConfigured,
      settings: settings ?? this.settings,
      lastTested: lastTested ?? this.lastTested,
      testStatus: testStatus ?? this.testStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
