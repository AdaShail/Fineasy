import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/audit_models.dart' hide DecisionExplanation;
import '../models/autopilot_models.dart';

/// Service for managing audit trails and decision transparency
class AuditService {
  final Uuid _uuid = const Uuid();

  // In-memory storage for demo purposes - in production, use database
  final Map<String, AuditTrail> _auditTrails = {};
  final Map<String, DecisionExplanation> _decisionExplanations = {};
  final Map<String, AlgorithmicAudit> _algorithmicAudits = {};

  /// Log audit event
  Future<String?> logAuditEvent(
    String businessId,
    AuditEventType eventType,
    String entityType,
    String entityId,
    String eventDescription, {
    String? userId,
    UserRole? userRole,
    Map<String, dynamic>? beforeState,
    Map<String, dynamic>? afterState,
    Map<String, dynamic>? metadata,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final auditTrail = AuditTrail(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: businessId,
        userId: userId ?? 'system',
        eventType: eventType,
        entityId: entityId,
        entityType: entityType,
        action: eventDescription,
        beforeState: beforeState ?? {},
        afterState: afterState ?? {},
        metadata: metadata ?? {},
        timestamp: DateTime.now(),
        severity: AuditSeverity.medium,
        tags: [entityType],
        ipAddress: ipAddress,
        userAgent: userAgent,
      );

      _auditTrails[auditTrail.id] = auditTrail;

      return auditTrail.id;
    } catch (e) {
      return null;
    }
  }

  /// Log decision creation
  Future<String?> logDecisionCreated(
    String businessId,
    String decisionId,
    DecisionType decisionType,
    Map<String, dynamic> decisionData, {
    String? userId,
    UserRole? userRole,
  }) async {
    return await logAuditEvent(
      businessId,
      AuditEventType.aiDecision,
      'decision',
      decisionId,
      'AI decision created: ${decisionType.toString().split('.').last}',
      userId: userId,
      userRole: userRole,
      afterState: decisionData,
      metadata: {
        'decision_type': decisionType.toString(),
        'confidence_score': decisionData['confidence_score'],
      },
    );
  }

  /// Log decision approval
  Future<String?> logDecisionApproved(
    String businessId,
    String decisionId,
    String approverId,
    UserRole approverRole,
    String? comments,
  ) async {
    return await logAuditEvent(
      businessId,
      AuditEventType.authorization,
      'decision',
      decisionId,
      'Decision approved by ${approverRole.toString().split('.').last}',
      userId: approverId,
      userRole: approverRole,
      metadata: {
        'approver_id': approverId,
        'approver_role': approverRole.toString(),
        'comments': comments,
      },
    );
  }

  /// Log decision rejection
  Future<String?> logDecisionRejected(
    String businessId,
    String decisionId,
    String rejectedBy,
    UserRole rejectorRole,
    String? reason,
  ) async {
    return await logAuditEvent(
      businessId,
      AuditEventType.userOverride,
      'decision',
      decisionId,
      'Decision rejected by ${rejectorRole.toString().split('.').last}',
      userId: rejectedBy,
      userRole: rejectorRole,
      metadata: {
        'rejected_by': rejectedBy,
        'rejector_role': rejectorRole.toString(),
        'rejection_reason': reason,
      },
    );
  }

  /// Log action execution
  Future<String?> logActionExecuted(
    String businessId,
    String actionId,
    ActionType actionType,
    bool success,
    Map<String, dynamic>? result, {
    String? userId,
    String? errorMessage,
  }) async {
    return await logAuditEvent(
      businessId,
      success ? AuditEventType.actionExecution : AuditEventType.systemError,
      'action',
      actionId,
      success
          ? 'Action executed successfully: ${actionType.toString().split('.').last}'
          : 'Action execution failed: ${actionType.toString().split('.').last}',
      userId: userId,
      afterState: result,
      metadata: {
        'action_type': actionType.toString(),
        'success': success,
        'error_message': errorMessage,
      },
    );
  }

  /// Log action rollback
  Future<String?> logActionRolledBack(
    String businessId,
    String actionId,
    String rollbackId,
    String initiatedBy,
    String reason,
  ) async {
    return await logAuditEvent(
      businessId,
      AuditEventType.userOverride,
      'action',
      actionId,
      'Action rolled back',
      userId: initiatedBy,
      metadata: {
        'rollback_id': rollbackId,
        'initiated_by': initiatedBy,
        'rollback_reason': reason,
      },
    );
  }

  /// Log configuration change
  Future<String?> logConfigurationChange(
    String businessId,
    String configType,
    String configId,
    Map<String, dynamic> beforeState,
    Map<String, dynamic> afterState,
    String changedBy,
    UserRole userRole,
  ) async {
    return await logAuditEvent(
      businessId,
      AuditEventType.configurationChange,
      configType,
      configId,
      'Configuration changed: $configType',
      userId: changedBy,
      userRole: userRole,
      beforeState: beforeState,
      afterState: afterState,
      metadata: {'config_type': configType, 'changed_by': changedBy},
    );
  }

  /// Log user permission change
  Future<String?> logUserPermissionChange(
    String businessId,
    String targetUserId,
    Map<String, dynamic>? beforePermissions,
    Map<String, dynamic> afterPermissions,
    String changedBy,
    UserRole changerRole,
  ) async {
    return await logAuditEvent(
      businessId,
      AuditEventType.authorization,
      'user_permission',
      targetUserId,
      'User permissions changed',
      userId: changedBy,
      userRole: changerRole,
      beforeState: beforePermissions,
      afterState: afterPermissions,
      metadata: {'target_user_id': targetUserId, 'changed_by': changedBy},
    );
  }

  /// Log emergency override
  Future<String?> logEmergencyOverride(
    String businessId,
    String overrideId,
    String overrideType,
    String initiatedBy,
    String reason,
    List<String> affectedDecisions,
  ) async {
    return await logAuditEvent(
      businessId,
      AuditEventType.userOverride,
      'emergency_override',
      overrideId,
      'Emergency override activated: $overrideType',
      userId: initiatedBy,
      metadata: {
        'override_type': overrideType,
        'initiated_by': initiatedBy,
        'reason': reason,
        'affected_decisions': affectedDecisions,
      },
    );
  }

  /// Log system error
  Future<String?> logSystemError(
    String businessId,
    String errorType,
    String errorMessage,
    Map<String, dynamic>? errorContext,
  ) async {
    return await logAuditEvent(
      businessId,
      AuditEventType.systemError,
      'system',
      'error_${DateTime.now().millisecondsSinceEpoch}',
      'System error occurred: $errorType',
      metadata: {
        'error_type': errorType,
        'error_message': errorMessage,
        'error_context': errorContext,
      },
    );
  }

  /// Create decision explanation
  Future<String?> createDecisionExplanation(
    String businessId,
    String decisionId,
    String explanationText,
    List<ReasoningStep> reasoningSteps,
    List<String> dataSources,
    Map<String, double> confidenceFactors,
    List<AlternativeOption> alternativeOptions,
    Map<String, dynamic> riskAssessment,
  ) async {
    try {
      final explanation = DecisionExplanation(
        decisionId: decisionId,
        reasoning: explanationText,
        factors: dataSources,
        weights: confidenceFactors,
        confidence:
            confidenceFactors.values.isNotEmpty
                ? confidenceFactors.values.reduce((a, b) => a + b) /
                    confidenceFactors.length
                : 0.0,
      );

      _decisionExplanations[decisionId] = explanation;
      return decisionId;
    } catch (e) {
      return null;
    }
  }

  /// Get decision explanation
  Future<DecisionExplanation?> getDecisionExplanation(String decisionId) async {
    try {
      for (final explanation in _decisionExplanations.values) {
        if (explanation.decisionId == decisionId) {
          return explanation;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Search audit trails
  Future<List<AuditTrail>> searchAuditTrails({
    required String businessId,
    AuditEventType? eventType,
    String? entityType,
    String? entityId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      var results =
          _auditTrails.values
              .where((trail) => trail.businessId == businessId)
              .toList();

      // Apply filters
      if (eventType != null) {
        results =
            results.where((trail) => trail.eventType == eventType).toList();
      }

      if (entityType != null) {
        results =
            results.where((trail) => trail.entityType == entityType).toList();
      }

      if (entityId != null) {
        results = results.where((trail) => trail.entityId == entityId).toList();
      }

      if (userId != null) {
        results = results.where((trail) => trail.userId == userId).toList();
      }

      if (startDate != null) {
        results =
            results
                .where((trail) => trail.timestamp.isAfter(startDate))
                .toList();
      }

      if (endDate != null) {
        results =
            results
                .where((trail) => trail.timestamp.isBefore(endDate))
                .toList();
      }

      // Sort by timestamp (newest first)
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Apply pagination
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, results.length);

      return results.sublist(startIndex, endIndex);
    } catch (e) {
      return [];
    }
  }

  /// Get audit trail by ID
  Future<AuditTrail?> getAuditTrail(String auditId) async {
    try {
      return _auditTrails[auditId];
    } catch (e) {
      return null;
    }
  }

  /// Get audit trails for entity
  Future<List<AuditTrail>> getAuditTrailsForEntity(
    String businessId,
    String entityType,
    String entityId,
  ) async {
    try {
      return _auditTrails.values
          .where(
            (trail) =>
                trail.businessId == businessId &&
                trail.entityType == entityType &&
                trail.entityId == entityId,
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      return [];
    }
  }

  /// Generate compliance report
  Future<Map<String, dynamic>> generateComplianceReport(
    String businessId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final auditTrails = await searchAuditTrails(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
        limit: 10000,
      );

      // Analyze audit data
      final eventCounts = <AuditEventType, int>{};
      final userActivity = <String, int>{};
      final entityActivity = <String, int>{};
      final errorEvents = <AuditTrail>[];

      for (final trail in auditTrails) {
        // Count events by type
        eventCounts[trail.eventType] = (eventCounts[trail.eventType] ?? 0) + 1;

        // Count user activity
        userActivity[trail.userId] = (userActivity[trail.userId] ?? 0) + 1;

        // Count entity activity
        final entityKey = '${trail.entityType}:${trail.entityId}';
        entityActivity[entityKey] = (entityActivity[entityKey] ?? 0) + 1;

        // Collect error events
        if (trail.eventType == AuditEventType.systemError ||
            trail.eventType == AuditEventType.systemError) {
          errorEvents.add(trail);
        }
      }

      return {
        'business_id': businessId,
        'report_period': {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
        'total_events': auditTrails.length,
        'event_counts': eventCounts.map((k, v) => MapEntry(k.toString(), v)),
        'user_activity': userActivity,
        'entity_activity': entityActivity,
        'error_events': errorEvents.length,
        'error_details':
            errorEvents
                .map(
                  (e) => {
                    'timestamp': e.timestamp.toIso8601String(),
                    'event_type': e.eventType.toString(),
                    'description': e.action,
                    'metadata': e.metadata,
                  },
                )
                .toList(),
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {};
    }
  }

  /// Create algorithmic audit
  Future<String?> createAlgorithmicAudit(
    String businessId,
    String auditType,
    String modelName,
    DateTime auditPeriodStart,
    DateTime auditPeriodEnd,
    Map<String, double> performanceMetrics,
    Map<String, dynamic> biasAnalysis,
    Map<String, dynamic> fairnessAssessment,
    List<String> recommendations,
    double auditScore,
    String conductedBy,
  ) async {
    try {
      final audit = AlgorithmicAudit(
        id: _uuid.v4(),
        businessId: businessId,
        modelName: modelName,
        modelVersion: '1.0',
        conductedAt: DateTime.now(),
        conductedBy: conductedBy,
        performanceMetrics: performanceMetrics,
        biasMetrics: biasAnalysis,
        fairnessMetrics: fairnessAssessment,
        issues: [],
        recommendations: recommendations,
        status: AuditStatus.completed,
        metadata: {
          'audit_type': auditType,
          'audit_score': auditScore,
          'audit_period_start': auditPeriodStart.toIso8601String(),
          'audit_period_end': auditPeriodEnd.toIso8601String(),
        },
      );

      _algorithmicAudits[audit.id] = audit;

      // Log the audit creation
      await logAuditEvent(
        businessId,
        AuditEventType.configurationChange,
        'algorithmic_audit',
        audit.id,
        'Algorithmic audit conducted for model: $modelName',
        userId: conductedBy,
        metadata: {
          'audit_type': auditType,
          'model_name': modelName,
          'audit_score': auditScore,
        },
      );

      return audit.id;
    } catch (e) {
      return null;
    }
  }

  /// Get algorithmic audits
  Future<List<AlgorithmicAudit>> getAlgorithmicAudits(
    String businessId, {
    String? modelName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var results =
          _algorithmicAudits.values
              .where((audit) => audit.businessId == businessId)
              .toList();

      if (modelName != null) {
        results =
            results.where((audit) => audit.modelName == modelName).toList();
      }

      if (startDate != null) {
        results =
            results
                .where((audit) => audit.conductedAt.isAfter(startDate))
                .toList();
      }

      if (endDate != null) {
        results =
            results
                .where((audit) => audit.conductedAt.isBefore(endDate))
                .toList();
      }

      results.sort((a, b) => b.conductedAt.compareTo(a.conductedAt));
      return results;
    } catch (e) {
      return [];
    }
  }

  /// Export audit data
  Future<Map<String, dynamic>> exportAuditData(
    String businessId,
    DateTime startDate,
    DateTime endDate, {
    List<AuditEventType>? eventTypes,
    String? format = 'json',
  }) async {
    try {
      final auditTrails = await searchAuditTrails(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
        limit: 50000,
      );

      // Filter by event types if specified
      var filteredTrails = auditTrails;
      if (eventTypes != null && eventTypes.isNotEmpty) {
        filteredTrails =
            auditTrails
                .where((trail) => eventTypes.contains(trail.eventType))
                .toList();
      }

      return {
        'export_info': {
          'business_id': businessId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'total_records': filteredTrails.length,
          'format': format,
          'exported_at': DateTime.now().toIso8601String(),
        },
        'audit_trails': filteredTrails.map((trail) => trail.toJson()).toList(),
      };
    } catch (e) {
      return {};
    }
  }

  /// Get audit statistics
  Future<Map<String, dynamic>> getAuditStatistics(
    String businessId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final auditTrails = await searchAuditTrails(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
        limit: 10000,
      );

      final eventTypeStats = <String, int>{};
      final dailyStats = <String, int>{};
      final userStats = <String, int>{};

      for (final trail in auditTrails) {
        // Event type statistics
        final eventType = trail.eventType.toString().split('.').last;
        eventTypeStats[eventType] = (eventTypeStats[eventType] ?? 0) + 1;

        // Daily statistics
        final dateKey = trail.timestamp.toIso8601String().split('T')[0];
        dailyStats[dateKey] = (dailyStats[dateKey] ?? 0) + 1;

        // User statistics
        userStats[trail.userId] = (userStats[trail.userId] ?? 0) + 1;
      }

      return {
        'total_events': auditTrails.length,
        'event_type_distribution': eventTypeStats,
        'daily_activity': dailyStats,
        'user_activity': userStats,
        'period': {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      };
    } catch (e) {
      return {};
    }
  }
}
