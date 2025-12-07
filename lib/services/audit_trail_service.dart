import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/audit_models.dart' hide DecisionExplanation, RiskLevel;
import '../models/autopilot_models.dart';
import 'ai_client_service.dart';

/// Service for comprehensive audit trail management and transparency
class AuditTrailService {
  final AIClientService _aiClient;
  final _uuid = const Uuid();
  final List<AuditTrailEntry> _auditBuffer = [];
  Timer? _flushTimer;

  static const int _bufferSize = 100;
  static const Duration _flushInterval = Duration(seconds: 30);

  AuditTrailService(this._aiClient) {
    _startPeriodicFlush();
  }

  /// Log an AI decision with full transparency data
  Future<void> logAIDecision({
    required String businessId,
    required String userId,
    required AutoPilotDecision decision,
    required Map<String, dynamic> inputContext,
    required DecisionExplanation explanation,
    String? sessionId,
    String? ipAddress,
    String? userAgent,
  }) async {
    final entry = AuditTrailEntry(
      id: _uuid.v4(),
      businessId: businessId,
      userId: userId,
      eventType: AuditEventType.aiDecision,
      entityId: decision.id,
      entityType: 'AutoPilotDecision',
      action: 'ai_decision_made',
      beforeState: inputContext,
      afterState: {
        'decision': decision.toJson(),
        'explanation': explanation.toJson(),
      },
      metadata: {
        'decision_type': decision.type.toString(),
        'confidence_score': decision.confidenceScore,
        'reasoning_steps': explanation.factors.length,
        'alternatives_considered': explanation.weights.length,
        'risks_identified': 0,
      },
      reasoning: explanation.reasoning,
      confidenceScore: decision.confidenceScore,
      timestamp: DateTime.now(),
      sessionId: sessionId,
      ipAddress: ipAddress,
      userAgent: userAgent,
      severity: _determineSeverity(decision.confidenceScore, []),
      tags: [
        'ai_decision',
        decision.type.toString(),
        'confidence_${_getConfidenceLevel(decision.confidenceScore)}',
      ],
    );

    await _addToAuditTrail(entry);
  }

  /// Log action execution with detailed tracking
  Future<void> logActionExecution({
    required String businessId,
    required String userId,
    required AutoPilotAction action,
    required ActionResult result,
    Map<String, dynamic>? beforeState,
    Map<String, dynamic>? afterState,
    String? sessionId,
    String? ipAddress,
    String? userAgent,
  }) async {
    final entry = AuditTrailEntry(
      id: _uuid.v4(),
      businessId: businessId,
      userId: userId,
      eventType: AuditEventType.actionExecution,
      entityId: action.id,
      entityType: 'AutoPilotAction',
      action: 'action_executed',
      beforeState: beforeState ?? {},
      afterState: afterState ?? {},
      metadata: {
        'action_type': action.type.toString(),
        'execution_status': result.success ? 'success' : 'failed',
        'execution_duration_ms':
            DateTime.now().difference(result.executedAt).inMilliseconds,
        'is_reversible': action.isReversible,
        'priority': action.priority.toString(),
        'error_message': result.errorMessage,
      },
      reasoning: result.errorMessage,
      timestamp: DateTime.now(),
      sessionId: sessionId,
      ipAddress: ipAddress,
      userAgent: userAgent,
      severity: !result.success ? AuditSeverity.high : AuditSeverity.medium,
      tags: [
        'action_execution',
        action.type.toString(),
        result.success ? 'success' : 'failed',
        if (!result.success) 'failed',
      ],
    );

    await _addToAuditTrail(entry);
  }

  /// Log user override of AI decision
  Future<void> logUserOverride({
    required String businessId,
    required String userId,
    required String decisionId,
    required String overrideReason,
    required Map<String, dynamic> originalDecision,
    required Map<String, dynamic> userDecision,
    String? sessionId,
    String? ipAddress,
    String? userAgent,
  }) async {
    final entry = AuditTrailEntry(
      id: _uuid.v4(),
      businessId: businessId,
      userId: userId,
      eventType: AuditEventType.userOverride,
      entityId: decisionId,
      entityType: 'DecisionOverride',
      action: 'user_override',
      beforeState: originalDecision,
      afterState: userDecision,
      metadata: {
        'override_reason': overrideReason,
        'override_timestamp': DateTime.now().toIso8601String(),
      },
      reasoning: overrideReason,
      timestamp: DateTime.now(),
      sessionId: sessionId,
      ipAddress: ipAddress,
      userAgent: userAgent,
      severity: AuditSeverity.medium,
      tags: ['user_override', 'manual_intervention'],
    );

    await _addToAuditTrail(entry);
  }

  /// Log system errors and exceptions
  Future<void> logSystemError({
    required String businessId,
    required String userId,
    required String errorType,
    required String errorMessage,
    required String stackTrace,
    Map<String, dynamic>? context,
    String? sessionId,
    String? ipAddress,
    String? userAgent,
  }) async {
    final entry = AuditTrailEntry(
      id: _uuid.v4(),
      businessId: businessId,
      userId: userId,
      eventType: AuditEventType.systemError,
      entityId: _uuid.v4(),
      entityType: 'SystemError',
      action: 'error_occurred',
      beforeState: context ?? {},
      afterState: {
        'error_type': errorType,
        'error_message': errorMessage,
        'stack_trace': stackTrace,
      },
      metadata: {
        'error_type': errorType,
        'error_timestamp': DateTime.now().toIso8601String(),
      },
      reasoning: errorMessage,
      timestamp: DateTime.now(),
      sessionId: sessionId,
      ipAddress: ipAddress,
      userAgent: userAgent,
      severity: AuditSeverity.high,
      tags: ['system_error', errorType.toLowerCase()],
    );

    await _addToAuditTrail(entry);
  }

  /// Search audit trail with comprehensive filtering
  Future<AuditSearchResult> searchAuditTrail(
    AuditSearchCriteria criteria,
  ) async {
    try {
      final response = await _aiClient.post('/audit/search', {
        'criteria': criteria.toJson(),
      });

      return AuditSearchResult.fromJson(response);
    } catch (e) {
      throw Exception('Failed to search audit trail: $e');
    }
  }

  /// Get detailed explanation for a specific decision
  Future<DecisionExplanation> getDecisionExplanation(String decisionId) async {
    try {
      final response = await _aiClient.get(
        '/audit/decisions/$decisionId/explanation',
      );
      return DecisionExplanation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get decision explanation: $e');
    }
  }

  /// Generate decision explanation using AI
  Future<DecisionExplanation> generateDecisionExplanation({
    required String decisionId,
    required String businessId,
    required AutoPilotDecision decision,
    required Map<String, dynamic> inputContext,
    required Map<String, dynamic> businessContext,
  }) async {
    try {
      final prompt = _buildExplanationPrompt(
        decision: decision,
        inputContext: inputContext,
        businessContext: businessContext,
      );

      final response = await _aiClient.post('/ai/explain-decision', {
        'decision_id': decisionId,
        'business_id': businessId,
        'prompt': prompt,
        'decision_data': decision.toJson(),
        'context': inputContext,
      });

      final explanationData = response['explanation'];

      return DecisionExplanation(
        decisionId: decisionId,
        reasoning: explanationData['summary'] ?? 'AI decision explanation',
        factors:
            (explanationData['reasoning_steps'] as List? ?? [])
                .map((step) => step['description']?.toString() ?? '')
                .toList(),
        weights: (explanationData['alternatives'] as Map<String, dynamic>? ??
                {})
            .map(
              (key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 0.0),
            ),
        confidence: decision.confidenceScore,
      );
    } catch (e) {
      // Fallback to basic explanation if AI fails
      return _generateBasicExplanation(
        decisionId: decisionId,
        businessId: businessId,
        decision: decision,
        inputContext: inputContext,
      );
    }
  }

  /// Get audit trail for specific entity
  Future<List<AuditTrailEntry>> getEntityAuditTrail({
    required String entityId,
    required String entityType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final criteria = AuditSearchCriteria(
      entityTypes: [entityType],
      startDate: startDate,
      endDate: endDate,
      searchText: entityId,
      sortBy: 'timestamp',
      sortOrder: SortOrder.descending,
    );

    final result = await searchAuditTrail(criteria);
    return result.entries.where((entry) => entry.entityId == entityId).toList();
  }

  /// Generate compliance report
  Future<ComplianceReport> generateComplianceReport(
    ComplianceReportConfig config,
  ) async {
    try {
      final response = await _aiClient.post('/audit/compliance-report', {
        'config': config.toJson(),
      });

      return ComplianceReport.fromJson(response);
    } catch (e) {
      throw Exception('Failed to generate compliance report: $e');
    }
  }

  /// Analyze audit patterns for insights
  Future<Map<String, dynamic>> analyzeAuditPatterns({
    required String businessId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _aiClient.post('/audit/analyze-patterns', {
        'business_id': businessId,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      });

      return response;
    } catch (e) {
      throw Exception('Failed to analyze audit patterns: $e');
    }
  }

  /// Export audit data in various formats
  Future<String> exportAuditData({
    required AuditSearchCriteria criteria,
    required ReportFormat format,
  }) async {
    try {
      final response = await _aiClient.post('/audit/export', {
        'criteria': criteria.toJson(),
        'format': format.toString().split('.').last,
      });

      return response['file_path'];
    } catch (e) {
      throw Exception('Failed to export audit data: $e');
    }
  }

  /// Get audit statistics and metrics
  Future<Map<String, dynamic>> getAuditStatistics({
    required String businessId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String url = '/audit/statistics?business_id=$businessId';
      if (startDate != null)
        url += '&start_date=${startDate.toIso8601String()}';
      if (endDate != null) url += '&end_date=${endDate.toIso8601String()}';

      final response = await _aiClient.get(url);

      return response;
    } catch (e) {
      throw Exception('Failed to get audit statistics: $e');
    }
  }

  /// Private helper methods

  Future<void> _addToAuditTrail(AuditTrailEntry entry) async {
    _auditBuffer.add(entry);

    if (_auditBuffer.length >= _bufferSize) {
      await _flushAuditBuffer();
    }
  }

  Future<void> _flushAuditBuffer() async {
    if (_auditBuffer.isEmpty) return;

    try {
      final entries = List<AuditTrailEntry>.from(_auditBuffer);
      _auditBuffer.clear();

      await _aiClient.post('/audit/batch-log', {
        'entries': entries.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      // Re-add entries to buffer if flush fails
      _auditBuffer.addAll(_auditBuffer);
      throw Exception('Failed to flush audit buffer: $e');
    }
  }

  void _startPeriodicFlush() {
    _flushTimer = Timer.periodic(_flushInterval, (_) {
      _flushAuditBuffer();
    });
  }

  AuditSeverity _determineSeverity(
    double confidenceScore,
    List<RiskFactor> risks,
  ) {
    final highRisks =
        risks
            .where(
              (r) => r.level == RiskLevel.high || r.level == RiskLevel.critical,
            )
            .length;

    if (highRisks > 0 || confidenceScore < 0.5) {
      return AuditSeverity.high;
    } else if (confidenceScore < 0.7) {
      return AuditSeverity.medium;
    } else {
      return AuditSeverity.low;
    }
  }

  String _getConfidenceLevel(double score) {
    if (score >= 0.8) return 'high';
    if (score >= 0.6) return 'medium';
    return 'low';
  }

  String _buildExplanationPrompt({
    required AutoPilotDecision decision,
    required Map<String, dynamic> inputContext,
    required Map<String, dynamic> businessContext,
  }) {
    return '''
Explain the following AI business decision in detail:

Decision Type: ${decision.type}
Description: ${decision.description}
Confidence Score: ${decision.confidenceScore}

Input Context:
${jsonEncode(inputContext)}

Business Context:
${jsonEncode(businessContext)}

Please provide:
1. A clear summary of why this decision was made
2. Step-by-step reasoning process
3. Alternative options that were considered
4. Potential risks and mitigation strategies
5. Key assumptions made in the decision process

Format the response as structured JSON with the following fields:
- summary: Brief explanation
- reasoning_steps: Array of step objects with stepNumber, description, rationale, data, weight
- alternatives: Array of alternative options with id, description, score, whyNotChosen, pros, cons
- risks: Array of risk factors with id, description, level, probability, mitigation, impact
- assumptions: Array of key assumptions
''';
  }

  DecisionExplanation _generateBasicExplanation({
    required String decisionId,
    required String businessId,
    required AutoPilotDecision decision,
    required Map<String, dynamic> inputContext,
  }) {
    return DecisionExplanation(
      decisionId: decisionId,
      reasoning: 'AI decision based on business context and configured rules',
      factors: [
        'Analyzed business context',
        'Applied decision logic',
        'Used configured business rules and AI reasoning',
      ],
      weights: {
        'business_context': 1.0,
        'decision_logic': 1.0,
        'confidence': decision.confidenceScore,
      },
      confidence: decision.confidenceScore,
    );
  }

  void dispose() {
    _flushTimer?.cancel();
    _flushAuditBuffer();
  }
}
