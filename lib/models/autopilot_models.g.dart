// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autopilot_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutoPilotDecision _$AutoPilotDecisionFromJson(Map<String, dynamic> json) =>
    AutoPilotDecision(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      type: $enumDecode(_$DecisionTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      reasoning: json['reasoning'] as String?,
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
      estimatedBenefit: (json['estimated_benefit'] as num).toDouble(),
      complexity: $enumDecode(_$DecisionComplexityEnumMap, json['complexity']),
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      status: $enumDecode(_$DecisionStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      requiresApproval: json['requires_approval'] as bool,
      actions:
          (json['actions'] as List<dynamic>)
              .map((e) => AutoPilotAction.fromJson(e as Map<String, dynamic>))
              .toList(),
      recommendedActions:
          (json['recommended_actions'] as List<dynamic>)
              .map((e) => AutoPilotAction.fromJson(e as Map<String, dynamic>))
              .toList(),
      riskFactors:
          (json['risk_factors'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AutoPilotDecisionToJson(AutoPilotDecision instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business_id': instance.businessId,
      'type': _$DecisionTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'reasoning': instance.reasoning,
      'estimated_cost': instance.estimatedCost,
      'estimated_benefit': instance.estimatedBenefit,
      'complexity': _$DecisionComplexityEnumMap[instance.complexity]!,
      'confidence_score': instance.confidenceScore,
      'status': _$DecisionStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'requires_approval': instance.requiresApproval,
      'actions': instance.actions,
      'recommended_actions': instance.recommendedActions,
      'risk_factors': instance.riskFactors,
      'metadata': instance.metadata,
    };

const _$DecisionTypeEnumMap = {
  DecisionType.cashFlowManagement: 'cash_flow_management',
  DecisionType.customerRelationship: 'customer_relationship',
  DecisionType.supplierNegotiation: 'supplier_negotiation',
  DecisionType.riskMitigation: 'risk_mitigation',
  DecisionType.growthOpportunity: 'growth_opportunity',
  DecisionType.complianceAction: 'compliance_action',
  DecisionType.operationalOptimization: 'operational_optimization',
  DecisionType.marketExpansion: 'market_expansion',
  DecisionType.productLaunch: 'product_launch',
  DecisionType.expansion: 'expansion',
};

const _$DecisionComplexityEnumMap = {
  DecisionComplexity.low: 'low',
  DecisionComplexity.medium: 'medium',
  DecisionComplexity.high: 'high',
};

const _$DecisionStatusEnumMap = {
  DecisionStatus.pending: 'pending',
  DecisionStatus.approved: 'approved',
  DecisionStatus.rejected: 'rejected',
  DecisionStatus.executed: 'executed',
  DecisionStatus.failed: 'failed',
  DecisionStatus.cancelled: 'cancelled',
};

AutoPilotAction _$AutoPilotActionFromJson(Map<String, dynamic> json) =>
    AutoPilotAction(
      id: json['id'] as String,
      decisionId: json['decision_id'] as String,
      type: $enumDecode(_$ActionTypeEnumMap, json['type']),
      description: json['description'] as String,
      priority: $enumDecode(_$ActionPriorityEnumMap, json['priority']),
      status: $enumDecode(_$ActionStatusEnumMap, json['status']),
      scheduledAt:
          json['scheduled_at'] == null
              ? null
              : DateTime.parse(json['scheduled_at'] as String),
      executedAt:
          json['executed_at'] == null
              ? null
              : DateTime.parse(json['executed_at'] as String),
      success: json['success'] as bool,
      errorMessage: json['error_message'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>,
      result: json['result'] as Map<String, dynamic>,
      requiredApprovals:
          (json['required_approvals'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      isReversible: json['is_reversible'] as bool,
      rollbackData: json['rollback_data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AutoPilotActionToJson(AutoPilotAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'decision_id': instance.decisionId,
      'type': _$ActionTypeEnumMap[instance.type]!,
      'description': instance.description,
      'priority': _$ActionPriorityEnumMap[instance.priority]!,
      'status': _$ActionStatusEnumMap[instance.status]!,
      'scheduled_at': instance.scheduledAt?.toIso8601String(),
      'executed_at': instance.executedAt?.toIso8601String(),
      'success': instance.success,
      'error_message': instance.errorMessage,
      'parameters': instance.parameters,
      'result': instance.result,
      'required_approvals': instance.requiredApprovals,
      'is_reversible': instance.isReversible,
      'rollback_data': instance.rollbackData,
    };

const _$ActionTypeEnumMap = {
  ActionType.sendReminder: 'send_reminder',
  ActionType.schedulePayment: 'schedule_payment',
  ActionType.negotiateTerms: 'negotiate_terms',
  ActionType.createInvoice: 'create_invoice',
  ActionType.updateInventory: 'update_inventory',
  ActionType.sendNotification: 'send_notification',
  ActionType.generateReport: 'generate_report',
  ActionType.optimizePricing: 'optimize_pricing',
  ActionType.adjustCreditLimit: 'adjust_credit_limit',
  ActionType.updatePricing: 'update_pricing',
  ActionType.blockTransaction: 'block_transaction',
  ActionType.reserveFunds: 'reserve_funds',
  ActionType.escalateIssue: 'escalate_issue',
};

const _$ActionPriorityEnumMap = {
  ActionPriority.low: 'low',
  ActionPriority.medium: 'medium',
  ActionPriority.high: 'high',
  ActionPriority.urgent: 'urgent',
};

const _$ActionStatusEnumMap = {
  ActionStatus.pending: 'pending',
  ActionStatus.scheduled: 'scheduled',
  ActionStatus.inProgress: 'in_progress',
  ActionStatus.completed: 'completed',
  ActionStatus.failed: 'failed',
  ActionStatus.cancelled: 'cancelled',
};

AutoPilotConfig _$AutoPilotConfigFromJson(
  Map<String, dynamic> json,
) => AutoPilotConfig(
  id: json['id'] as String,
  businessId: json['business_id'] as String,
  enabledFeatures:
      (json['enabled_features'] as List<dynamic>)
          .map((e) => $enumDecode(_$AutoPilotFeatureEnumMap, e))
          .toList(),
  confidenceThreshold: (json['confidence_threshold'] as num).toDouble(),
  approvalRequiredThreshold:
      (json['approval_required_threshold'] as num).toDouble(),
  businessRules:
      (json['business_rules'] as List<dynamic>)
          .map((e) => BusinessRule.fromJson(e as Map<String, dynamic>))
          .toList(),
  notificationSettings: Map<String, bool>.from(
    json['notification_settings'] as Map,
  ),
  autonomyLevel: $enumDecode(_$AutonomyLevelEnumMap, json['autonomy_level']),
  integrationSettings:
      json['integration_settings'] as Map<String, dynamic>? ?? const {},
  autoExecuteLowRisk: json['auto_execute_low_risk'] as bool? ?? false,
  notifyAllActions: json['notify_all_actions'] as bool? ?? true,
  learnFromOverrides: json['learn_from_overrides'] as bool? ?? true,
  paymentApprovalThreshold:
      (json['payment_approval_threshold'] as num?)?.toDouble() ?? 10000.0,
  creditLimitApprovalThreshold:
      (json['credit_limit_approval_threshold'] as num?)?.toDouble() ?? 50000.0,
);

Map<String, dynamic> _$AutoPilotConfigToJson(AutoPilotConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business_id': instance.businessId,
      'enabled_features':
          instance.enabledFeatures
              .map((e) => _$AutoPilotFeatureEnumMap[e]!)
              .toList(),
      'confidence_threshold': instance.confidenceThreshold,
      'approval_required_threshold': instance.approvalRequiredThreshold,
      'business_rules': instance.businessRules,
      'notification_settings': instance.notificationSettings,
      'autonomy_level': _$AutonomyLevelEnumMap[instance.autonomyLevel]!,
      'integration_settings': instance.integrationSettings,
      'auto_execute_low_risk': instance.autoExecuteLowRisk,
      'notify_all_actions': instance.notifyAllActions,
      'learn_from_overrides': instance.learnFromOverrides,
      'payment_approval_threshold': instance.paymentApprovalThreshold,
      'credit_limit_approval_threshold': instance.creditLimitApprovalThreshold,
    };

const _$AutoPilotFeatureEnumMap = {
  AutoPilotFeature.cashFlowManagement: 'cash_flow_management',
  AutoPilotFeature.customerRelationship: 'customer_relationship',
  AutoPilotFeature.supplierManagement: 'supplier_management',
  AutoPilotFeature.riskAssessment: 'risk_assessment',
  AutoPilotFeature.growthOpportunities: 'growth_opportunities',
  AutoPilotFeature.complianceMonitoring: 'compliance_monitoring',
  AutoPilotFeature.operationalOptimization: 'operational_optimization',
  AutoPilotFeature.paymentReminders: 'payment_reminders',
};

const _$AutonomyLevelEnumMap = {
  AutonomyLevel.manual: 'manual',
  AutonomyLevel.supervised: 'supervised',
  AutonomyLevel.autonomous: 'autonomous',
};

BusinessRule _$BusinessRuleFromJson(Map<String, dynamic> json) => BusinessRule(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$BusinessRuleTypeEnumMap, json['type']),
  condition: json['condition'] as String,
  action: json['action'] as String,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BusinessRuleToJson(BusinessRule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$BusinessRuleTypeEnumMap[instance.type]!,
      'condition': instance.condition,
      'action': instance.action,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$BusinessRuleTypeEnumMap = {
  BusinessRuleType.threshold: 'threshold',
  BusinessRuleType.approval: 'approval',
  BusinessRuleType.notification: 'notification',
  BusinessRuleType.automation: 'automation',
  BusinessRuleType.cashFlow: 'cash_flow',
  BusinessRuleType.payment: 'payment',
  BusinessRuleType.expense: 'expense',
  BusinessRuleType.customer: 'customer',
  BusinessRuleType.supplier: 'supplier',
  BusinessRuleType.compliance: 'compliance',
};

ROIAnalysis _$ROIAnalysisFromJson(Map<String, dynamic> json) => ROIAnalysis(
  id: json['id'] as String,
  initialInvestment: (json['initialInvestment'] as num).toDouble(),
  npv: (json['npv'] as num).toDouble(),
  irr: (json['irr'] as num).toDouble(),
  paybackPeriod: (json['paybackPeriod'] as num).toDouble(),
  profitabilityIndex: (json['profitabilityIndex'] as num).toDouble(),
  riskLevel: $enumDecode(_$RiskLevelEnumMap, json['riskLevel']),
  recommendation: json['recommendation'] as String,
  projectedCashFlows:
      (json['projectedCashFlows'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
  discountRate: (json['discountRate'] as num).toDouble(),
  calculatedAt: DateTime.parse(json['calculatedAt'] as String),
);

Map<String, dynamic> _$ROIAnalysisToJson(ROIAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'initialInvestment': instance.initialInvestment,
      'npv': instance.npv,
      'irr': instance.irr,
      'paybackPeriod': instance.paybackPeriod,
      'profitabilityIndex': instance.profitabilityIndex,
      'riskLevel': _$RiskLevelEnumMap[instance.riskLevel]!,
      'recommendation': instance.recommendation,
      'projectedCashFlows': instance.projectedCashFlows,
      'discountRate': instance.discountRate,
      'calculatedAt': instance.calculatedAt.toIso8601String(),
    };

const _$RiskLevelEnumMap = {
  RiskLevel.low: 'low',
  RiskLevel.medium: 'medium',
  RiskLevel.high: 'high',
  RiskLevel.critical: 'critical',
};

HiringDecisionAnalysis _$HiringDecisionAnalysisFromJson(
  Map<String, dynamic> json,
) => HiringDecisionAnalysis(
  id: json['id'] as String,
  hiringPlan: HiringPlan.fromJson(json['hiringPlan'] as Map<String, dynamic>),
  estimatedCost: (json['estimatedCost'] as num).toDouble(),
  expectedROI: (json['expectedROI'] as num).toDouble(),
  risks:
      (json['risks'] as List<dynamic>)
          .map((e) => HiringRisk.fromJson(e as Map<String, dynamic>))
          .toList(),
  recommendation: $enumDecode(
    _$HiringRecommendationEnumMap,
    json['recommendation'],
  ),
  confidenceScore: (json['confidenceScore'] as num).toDouble(),
  analysisDate: DateTime.parse(json['analysisDate'] as String),
);

Map<String, dynamic> _$HiringDecisionAnalysisToJson(
  HiringDecisionAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'hiringPlan': instance.hiringPlan,
  'estimatedCost': instance.estimatedCost,
  'expectedROI': instance.expectedROI,
  'risks': instance.risks,
  'recommendation': _$HiringRecommendationEnumMap[instance.recommendation]!,
  'confidenceScore': instance.confidenceScore,
  'analysisDate': instance.analysisDate.toIso8601String(),
};

const _$HiringRecommendationEnumMap = {
  HiringRecommendation.hireImmediately: 'hire_immediately',
  HiringRecommendation.hireWithinQuarter: 'hire_within_quarter',
  HiringRecommendation.delayHiring: 'delay_hiring',
  HiringRecommendation.notRecommended: 'not_recommended',
  HiringRecommendation.stronglyRecommended: 'strongly_recommended',
  HiringRecommendation.recommended: 'recommended',
  HiringRecommendation.conditional: 'conditional',
};

HiringPlan _$HiringPlanFromJson(Map<String, dynamic> json) => HiringPlan(
  position: json['position'] as String,
  department: json['department'] as String,
  salary: (json['salary'] as num).toDouble(),
  startDate: DateTime.parse(json['startDate'] as String),
  justification: json['justification'] as String,
);

Map<String, dynamic> _$HiringPlanToJson(HiringPlan instance) =>
    <String, dynamic>{
      'position': instance.position,
      'department': instance.department,
      'salary': instance.salary,
      'startDate': instance.startDate.toIso8601String(),
      'justification': instance.justification,
    };

HiringRisk _$HiringRiskFromJson(Map<String, dynamic> json) => HiringRisk(
  type: $enumDecode(_$HiringRiskTypeEnumMap, json['type']),
  description: json['description'] as String,
  severity: $enumDecode(_$RiskSeverityEnumMap, json['severity']),
  probability: (json['probability'] as num).toDouble(),
);

Map<String, dynamic> _$HiringRiskToJson(HiringRisk instance) =>
    <String, dynamic>{
      'type': _$HiringRiskTypeEnumMap[instance.type]!,
      'description': instance.description,
      'severity': _$RiskSeverityEnumMap[instance.severity]!,
      'probability': instance.probability,
    };

const _$HiringRiskTypeEnumMap = {
  HiringRiskType.financial: 'financial',
  HiringRiskType.culturalFit: 'cultural_fit',
  HiringRiskType.skillMismatch: 'skill_mismatch',
  HiringRiskType.marketConditions: 'market_conditions',
  HiringRiskType.cashFlow: 'cash_flow',
  HiringRiskType.market: 'market',
};

const _$RiskSeverityEnumMap = {
  RiskSeverity.low: 'low',
  RiskSeverity.medium: 'medium',
  RiskSeverity.high: 'high',
  RiskSeverity.critical: 'critical',
};

MarketingChannel _$MarketingChannelFromJson(Map<String, dynamic> json) =>
    MarketingChannel(
      name: json['name'] as String,
      type: json['type'] as String,
      estimatedROI: (json['estimatedROI'] as num).toDouble(),
      estimatedConversionRate:
          (json['estimatedConversionRate'] as num).toDouble(),
      estimatedCPA: (json['estimatedCPA'] as num).toDouble(),
      estimatedLTV: (json['estimatedLTV'] as num).toDouble(),
      reachPotential: (json['reachPotential'] as num).toDouble(),
      scalability: (json['scalability'] as num).toDouble(),
      competitiveIntensity: (json['competitiveIntensity'] as num).toDouble(),
    );

Map<String, dynamic> _$MarketingChannelToJson(MarketingChannel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'estimatedROI': instance.estimatedROI,
      'estimatedConversionRate': instance.estimatedConversionRate,
      'estimatedCPA': instance.estimatedCPA,
      'estimatedLTV': instance.estimatedLTV,
      'reachPotential': instance.reachPotential,
      'scalability': instance.scalability,
      'competitiveIntensity': instance.competitiveIntensity,
    };

ChannelPerformance _$ChannelPerformanceFromJson(Map<String, dynamic> json) =>
    ChannelPerformance(
      channelName: json['channel_name'] as String,
      roi: (json['roi'] as num).toDouble(),
      customerAcquisitionCost:
          (json['customer_acquisition_cost'] as num).toDouble(),
      conversionRate: (json['conversion_rate'] as num).toDouble(),
      effectiveness: $enumDecode(
        _$ChannelEffectivenessEnumMap,
        json['effectiveness'],
      ),
      trendDirection: $enumDecode(
        _$TrendDirectionEnumMap,
        json['trend_direction'],
      ),
    );

Map<String, dynamic> _$ChannelPerformanceToJson(ChannelPerformance instance) =>
    <String, dynamic>{
      'channel_name': instance.channelName,
      'roi': instance.roi,
      'customer_acquisition_cost': instance.customerAcquisitionCost,
      'conversion_rate': instance.conversionRate,
      'effectiveness': _$ChannelEffectivenessEnumMap[instance.effectiveness]!,
      'trend_direction': _$TrendDirectionEnumMap[instance.trendDirection]!,
    };

const _$ChannelEffectivenessEnumMap = {
  ChannelEffectiveness.low: 'low',
  ChannelEffectiveness.medium: 'medium',
  ChannelEffectiveness.high: 'high',
};

const _$TrendDirectionEnumMap = {
  TrendDirection.improving: 'improving',
  TrendDirection.stable: 'stable',
  TrendDirection.declining: 'declining',
  TrendDirection.up: 'up',
  TrendDirection.down: 'down',
};

DecisionExplanation _$DecisionExplanationFromJson(Map<String, dynamic> json) =>
    DecisionExplanation(
      decisionId: json['decisionId'] as String,
      reasoning: json['reasoning'] as String,
      factors:
          (json['factors'] as List<dynamic>).map((e) => e as String).toList(),
      weights: (json['weights'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$DecisionExplanationToJson(
  DecisionExplanation instance,
) => <String, dynamic>{
  'decisionId': instance.decisionId,
  'reasoning': instance.reasoning,
  'factors': instance.factors,
  'weights': instance.weights,
  'confidence': instance.confidence,
};

ActionResult _$ActionResultFromJson(Map<String, dynamic> json) => ActionResult(
  actionId: json['actionId'] as String,
  success: json['success'] as bool,
  errorMessage: json['errorMessage'] as String?,
  data: json['data'] as Map<String, dynamic>,
  executedAt: DateTime.parse(json['executedAt'] as String),
);

Map<String, dynamic> _$ActionResultToJson(ActionResult instance) =>
    <String, dynamic>{
      'actionId': instance.actionId,
      'success': instance.success,
      'errorMessage': instance.errorMessage,
      'data': instance.data,
      'executedAt': instance.executedAt.toIso8601String(),
    };

BusinessEvent _$BusinessEventFromJson(Map<String, dynamic> json) =>
    BusinessEvent(
      id: json['id'] as String,
      type: json['type'] as String,
      eventType: json['event_type'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>,
      businessId: json['businessId'] as String,
    );

Map<String, dynamic> _$BusinessEventToJson(BusinessEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'event_type': instance.eventType,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'data': instance.data,
      'businessId': instance.businessId,
    };

AutoPilotStatus _$AutoPilotStatusFromJson(Map<String, dynamic> json) =>
    AutoPilotStatus(
      isActive: json['isActive'] as bool,
      mode: json['mode'] as String,
      activeDecisions: (json['activeDecisions'] as num).toInt(),
      completedActions: (json['completedActions'] as num).toInt(),
      systemHealth: (json['systemHealth'] as num).toDouble(),
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      active: json['active'] as bool,
      paused: json['paused'] as bool,
      error: json['error'] as bool,
      maintenance: json['maintenance'] as bool,
    );

Map<String, dynamic> _$AutoPilotStatusToJson(AutoPilotStatus instance) =>
    <String, dynamic>{
      'isActive': instance.isActive,
      'mode': instance.mode,
      'activeDecisions': instance.activeDecisions,
      'completedActions': instance.completedActions,
      'systemHealth': instance.systemHealth,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'active': instance.active,
      'paused': instance.paused,
      'error': instance.error,
      'maintenance': instance.maintenance,
    };

ConversationContext _$ConversationContextFromJson(Map<String, dynamic> json) =>
    ConversationContext(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      context: json['context'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ConversationContextToJson(
  ConversationContext instance,
) => <String, dynamic>{
  'id': instance.id,
  'businessId': instance.businessId,
  'startedAt': instance.startedAt.toIso8601String(),
  'lastActivity': instance.lastActivity.toIso8601String(),
  'context': instance.context,
};

ConversationTurn _$ConversationTurnFromJson(Map<String, dynamic> json) =>
    ConversationTurn(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      userMessage: json['userMessage'] as String,
      aiResponse: json['aiResponse'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$ConversationTurnToJson(ConversationTurn instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'userMessage': instance.userMessage,
      'aiResponse': instance.aiResponse,
      'timestamp': instance.timestamp.toIso8601String(),
    };

AIResponse _$AIResponseFromJson(Map<String, dynamic> json) => AIResponse(
  message: json['message'] as String,
  action: json['action'] as String?,
  parameters: json['parameters'] as Map<String, dynamic>?,
  confidence: (json['confidence'] as num).toDouble(),
);

Map<String, dynamic> _$AIResponseToJson(AIResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'action': instance.action,
      'parameters': instance.parameters,
      'confidence': instance.confidence,
    };

AutoPilotNotification _$AutoPilotNotificationFromJson(
  Map<String, dynamic> json,
) => AutoPilotNotification(
  id: json['id'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  priority:
      $enumDecodeNullable(_$NotificationPriorityEnumMap, json['priority']) ??
      NotificationPriority.medium,
  isRead: json['isRead'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>?,
  relatedId: json['relatedId'] as String?,
);

Map<String, dynamic> _$AutoPilotNotificationToJson(
  AutoPilotNotification instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'message': instance.message,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'priority': _$NotificationPriorityEnumMap[instance.priority]!,
  'isRead': instance.isRead,
  'createdAt': instance.createdAt.toIso8601String(),
  'metadata': instance.metadata,
  'relatedId': instance.relatedId,
};

const _$NotificationTypeEnumMap = {
  NotificationType.decision: 'decision',
  NotificationType.action: 'action',
  NotificationType.actionRequired: 'action_required',
  NotificationType.actionCompleted: 'action_completed',
  NotificationType.actionFailed: 'action_failed',
  NotificationType.error: 'error',
  NotificationType.success: 'success',
  NotificationType.warning: 'warning',
  NotificationType.systemAlert: 'system_alert',
  NotificationType.systemError: 'system_error',
  NotificationType.businessInsight: 'business_insight',
  NotificationType.performanceAlert: 'performance_alert',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.medium: 'medium',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
};

BusinessContext _$BusinessContextFromJson(
  Map<String, dynamic> json,
) => BusinessContext(
  businessId: json['business_id'] as String,
  financialState: json['financial_state'] as Map<String, dynamic>,
  customerRelationships: json['customer_relationships'] as Map<String, dynamic>,
  supplierRelationships: json['supplier_relationships'] as Map<String, dynamic>,
  marketConditions: json['market_conditions'] as Map<String, dynamic>,
  complianceStatus: json['compliance_status'] as Map<String, dynamic>,
  operationalMetrics: json['operational_metrics'] as Map<String, dynamic>,
  lastUpdated: DateTime.parse(json['last_updated'] as String),
);

Map<String, dynamic> _$BusinessContextToJson(BusinessContext instance) =>
    <String, dynamic>{
      'business_id': instance.businessId,
      'financial_state': instance.financialState,
      'customer_relationships': instance.customerRelationships,
      'supplier_relationships': instance.supplierRelationships,
      'market_conditions': instance.marketConditions,
      'compliance_status': instance.complianceStatus,
      'operational_metrics': instance.operationalMetrics,
      'last_updated': instance.lastUpdated.toIso8601String(),
    };

BusinessDecision _$BusinessDecisionFromJson(Map<String, dynamic> json) =>
    BusinessDecision(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      type: $enumDecode(_$DecisionTypeEnumMap, json['type']),
      description: json['description'] as String,
      estimatedCost: (json['estimated_cost'] as num?)?.toDouble(),
      timeline: json['timeline'] as String?,
      complexity: $enumDecodeNullable(
        _$DecisionComplexityEnumMap,
        json['complexity'],
      ),
      parameters: json['parameters'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$BusinessDecisionToJson(BusinessDecision instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business_id': instance.businessId,
      'type': _$DecisionTypeEnumMap[instance.type]!,
      'description': instance.description,
      'estimated_cost': instance.estimatedCost,
      'timeline': instance.timeline,
      'complexity': _$DecisionComplexityEnumMap[instance.complexity],
      'parameters': instance.parameters,
      'created_at': instance.createdAt.toIso8601String(),
    };

AIAction _$AIActionFromJson(Map<String, dynamic> json) => AIAction(
  id: json['id'] as String,
  type: json['type'] as String,
  description: json['description'] as String,
  parameters: json['parameters'] as Map<String, dynamic>,
  priority: $enumDecode(_$ActionPriorityEnumMap, json['priority']),
  status: $enumDecode(_$ActionStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  executedAt:
      json['executedAt'] == null
          ? null
          : DateTime.parse(json['executedAt'] as String),
);

Map<String, dynamic> _$AIActionToJson(AIAction instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'description': instance.description,
  'parameters': instance.parameters,
  'priority': _$ActionPriorityEnumMap[instance.priority]!,
  'status': _$ActionStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'executedAt': instance.executedAt?.toIso8601String(),
};

IntegrationConfig _$IntegrationConfigFromJson(Map<String, dynamic> json) =>
    IntegrationConfig(
      id: json['id'] as String,
      type: $enumDecode(_$IntegrationTypeEnumMap, json['type']),
      isEnabled: json['isEnabled'] as bool,
      isConfigured: json['isConfigured'] as bool,
      settings: json['settings'] as Map<String, dynamic>,
      lastTested:
          json['last_tested'] == null
              ? null
              : DateTime.parse(json['last_tested'] as String),
      testStatus:
          $enumDecodeNullable(_$TestStatusEnumMap, json['test_status']) ??
          TestStatus.notTested,
      errorMessage: json['error_message'] as String?,
    );

Map<String, dynamic> _$IntegrationConfigToJson(IntegrationConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$IntegrationTypeEnumMap[instance.type]!,
      'isEnabled': instance.isEnabled,
      'isConfigured': instance.isConfigured,
      'settings': instance.settings,
      'last_tested': instance.lastTested?.toIso8601String(),
      'test_status': _$TestStatusEnumMap[instance.testStatus]!,
      'error_message': instance.errorMessage,
    };

const _$IntegrationTypeEnumMap = {
  IntegrationType.whatsapp: 'whatsapp',
  IntegrationType.email: 'email',
  IntegrationType.sms: 'sms',
  IntegrationType.banking: 'banking',
  IntegrationType.gst: 'gst',
  IntegrationType.payment: 'payment',
};

const _$TestStatusEnumMap = {
  TestStatus.notTested: 'not_tested',
  TestStatus.testing: 'testing',
  TestStatus.success: 'success',
  TestStatus.failed: 'failed',
};
