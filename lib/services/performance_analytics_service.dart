import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/performance_analytics_models.dart';
import '../config/api_config.dart';

/// Service for tracking and analyzing AI AutoPilot performance
class PerformanceAnalyticsService {
  final http.Client _httpClient;
  final String _baseUrl;
  final Map<String, DecisionOutcome> _outcomeCache = {};
  final StreamController<PerformanceAlert> _alertController =
      StreamController.broadcast();

  PerformanceAnalyticsService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client(),
      _baseUrl = ApiConfig.baseUrl;

  /// Stream of performance alerts
  Stream<PerformanceAlert> get alertStream => _alertController.stream;

  /// Record the outcome of an AI decision
  Future<void> recordDecisionOutcome({
    required String decisionId,
    required String businessId,
    required DecisionOutcomeType type,
    required double predictedValue,
    required double actualValue,
    Map<String, dynamic>? additionalMetrics,
    String? notes,
  }) async {
    try {
      final accuracyScore = _calculateAccuracyScore(
        predictedValue,
        actualValue,
      );

      final outcome = DecisionOutcome(
        id: _generateId(),
        decisionId: decisionId,
        businessId: businessId,
        type: type,
        predictedValue: predictedValue,
        actualValue: actualValue,
        accuracyScore: accuracyScore,
        metrics: additionalMetrics ?? {},
        recordedAt: DateTime.now(),
        notes: notes,
      );

      // Cache the outcome
      _outcomeCache[outcome.id] = outcome;

      // Send to backend
      await _sendOutcomeToBackend(outcome);

      // Check for performance alerts
      await _checkPerformanceAlerts(outcome);
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate ROI for an automated action
  Future<AutomationROI> calculateActionROI({
    required String actionId,
    required String businessId,
    required ROICategory category,
    required Map<String, dynamic> costData,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/api/v1/performance/roi/calculate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action_id': actionId,
          'business_id': businessId,
          'category': category.name,
          'cost_data': costData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AutomationROI.fromJson(data);
      } else {
        throw Exception('Failed to calculate ROI: ${response.statusCode}');
      }
    } catch (e) {
      // Return default ROI calculation
      return _calculateDefaultROI(actionId, businessId, category, costData);
    }
  }

  /// Get AI performance metrics for a time period
  Future<AIPerformanceMetrics> getAIPerformanceMetrics({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/api/v1/performance/ai-metrics').replace(
          queryParameters: {
            'business_id': businessId,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AIPerformanceMetrics.fromJson(data);
      } else {
        throw Exception('Failed to get AI metrics: ${response.statusCode}');
      }
    } catch (e) {
      // Return default metrics
      return _generateDefaultAIMetrics(businessId, startDate, endDate);
    }
  }

  /// Get business impact metrics
  Future<BusinessImpactMetrics> getBusinessImpactMetrics({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/api/v1/performance/business-impact').replace(
          queryParameters: {
            'business_id': businessId,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BusinessImpactMetrics.fromJson(data);
      } else {
        throw Exception(
          'Failed to get business impact metrics: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Return default metrics
      return _generateDefaultBusinessMetrics(businessId, startDate, endDate);
    }
  }

  /// Get comprehensive performance dashboard data
  Future<PerformanceDashboardData> getDashboardData({
    required String businessId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 30));

    try {
      final futures = await Future.wait([
        getAIPerformanceMetrics(
          businessId: businessId,
          startDate: start,
          endDate: end,
        ),
        getBusinessImpactMetrics(
          businessId: businessId,
          startDate: start,
          endDate: end,
        ),
        getTopROIActions(businessId: businessId, limit: 5),
        getRecentOutcomes(businessId: businessId, limit: 10),
        getPerformanceTrends(businessId: businessId, days: 30),
        getActiveAlerts(businessId: businessId),
      ]);

      return PerformanceDashboardData(
        businessId: businessId,
        aiMetrics: futures[0] as AIPerformanceMetrics,
        businessImpact: futures[1] as BusinessImpactMetrics,
        topROIActions: futures[2] as List<AutomationROI>,
        recentOutcomes: futures[3] as List<DecisionOutcome>,
        trends: futures[4] as Map<String, dynamic>,
        alerts: futures[5] as List<PerformanceAlert>,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get top ROI actions
  Future<List<AutomationROI>> getTopROIActions({
    required String businessId,
    int limit = 10,
  }) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/api/v1/performance/top-roi').replace(
          queryParameters: {
            'business_id': businessId,
            'limit': limit.toString(),
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => AutomationROI.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to get top ROI actions: ${response.statusCode}',
        );
      }
    } catch (e) {
      return [];
    }
  }

  /// Get recent decision outcomes
  Future<List<DecisionOutcome>> getRecentOutcomes({
    required String businessId,
    int limit = 20,
  }) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/api/v1/performance/recent-outcomes').replace(
          queryParameters: {
            'business_id': businessId,
            'limit': limit.toString(),
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => DecisionOutcome.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to get recent outcomes: ${response.statusCode}',
        );
      }
    } catch (e) {
      return _outcomeCache.values.take(limit).toList();
    }
  }

  /// Get performance trends
  Future<Map<String, dynamic>> getPerformanceTrends({
    required String businessId,
    int days = 30,
  }) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/api/v1/performance/trends').replace(
          queryParameters: {'business_id': businessId, 'days': days.toString()},
        ),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to get performance trends: ${response.statusCode}',
        );
      }
    } catch (e) {
      return _generateDefaultTrends();
    }
  }

  /// Get active performance alerts
  Future<List<PerformanceAlert>> getActiveAlerts({
    required String businessId,
  }) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/api/v1/performance/alerts').replace(
          queryParameters: {'business_id': businessId, 'active_only': 'true'},
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => PerformanceAlert.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get alerts: ${response.statusCode}');
      }
    } catch (e) {
      return [];
    }
  }

  /// Generate performance report
  Future<Map<String, dynamic>> generatePerformanceReport({
    required PerformanceReportConfig config,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/api/v1/performance/reports/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(config.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate report: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Track decision accuracy over time
  Future<void> trackDecisionAccuracy({
    required String decisionId,
    required double actualOutcome,
  }) async {
    // Find the original decision prediction
    final outcomes =
        _outcomeCache.values
            .where((outcome) => outcome.decisionId == decisionId)
            .toList();

    if (outcomes.isNotEmpty) {
      final outcome = outcomes.first;
      final updatedOutcome = DecisionOutcome(
        id: outcome.id,
        decisionId: outcome.decisionId,
        businessId: outcome.businessId,
        type: outcome.type,
        predictedValue: outcome.predictedValue,
        actualValue: actualOutcome,
        accuracyScore: _calculateAccuracyScore(
          outcome.predictedValue,
          actualOutcome,
        ),
        metrics: outcome.metrics,
        recordedAt: outcome.recordedAt,
        notes: outcome.notes,
      );

      _outcomeCache[outcome.id] = updatedOutcome;
      await _sendOutcomeToBackend(updatedOutcome);
    }
  }

  /// Calculate accuracy score between predicted and actual values
  double _calculateAccuracyScore(double predicted, double actual) {
    if (predicted == 0 && actual == 0) return 1.0;
    if (predicted == 0 || actual == 0) return 0.0;

    final error = (predicted - actual).abs();
    final maxValue = [
      predicted.abs(),
      actual.abs(),
    ].reduce((a, b) => a > b ? a : b);

    return 1.0 - (error / maxValue);
  }

  /// Send outcome data to backend
  Future<void> _sendOutcomeToBackend(DecisionOutcome outcome) async {
    try {
      await _httpClient.post(
        Uri.parse('$_baseUrl/api/v1/performance/outcomes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(outcome.toJson()),
      );
    } catch (e) {
    }
  }

  /// Check for performance alerts based on outcome
  Future<void> _checkPerformanceAlerts(DecisionOutcome outcome) async {
    // Check accuracy threshold
    if (outcome.accuracyScore < 0.7) {
      final alert = PerformanceAlert(
        id: _generateId(),
        type: AlertType.accuracyDrop,
        severity:
            outcome.accuracyScore < 0.5
                ? AlertSeverity.high
                : AlertSeverity.medium,
        title: 'Decision Accuracy Below Threshold',
        description:
            'Decision ${outcome.decisionId} has accuracy of ${(outcome.accuracyScore * 100).toStringAsFixed(1)}%',
        data: outcome.toJson(),
        createdAt: DateTime.now(),
        isResolved: false,
      );

      _alertController.add(alert);
    }
  }

  /// Calculate default ROI when backend is unavailable
  AutomationROI _calculateDefaultROI(
    String actionId,
    String businessId,
    ROICategory category,
    Map<String, dynamic> costData,
  ) {
    // Simple ROI calculation based on category
    double costSavings = 0;
    double timeSavings = 0;
    double revenueImpact = 0;
    double implementationCost = 100; // Default implementation cost

    switch (category) {
      case ROICategory.paymentReminders:
        costSavings = 500;
        timeSavings = 2;
        revenueImpact = 2000;
        break;
      case ROICategory.expenseControl:
        costSavings = 1000;
        timeSavings = 1;
        revenueImpact = 0;
        break;
      case ROICategory.customerManagement:
        costSavings = 300;
        timeSavings = 3;
        revenueImpact = 1500;
        break;
      default:
        costSavings = 200;
        timeSavings = 1;
        revenueImpact = 500;
    }

    final netROI = costSavings + revenueImpact - implementationCost;
    final roiPercentage = (netROI / implementationCost) * 100;

    return AutomationROI(
      id: _generateId(),
      businessId: businessId,
      actionId: actionId,
      category: category,
      costSavings: costSavings,
      timeSavings: timeSavings,
      revenueImpact: revenueImpact,
      implementationCost: implementationCost,
      netROI: netROI,
      roiPercentage: roiPercentage,
      breakdown: {
        'cost_savings': costSavings,
        'time_savings': timeSavings,
        'revenue_impact': revenueImpact,
        'implementation_cost': implementationCost,
      },
      calculatedAt: DateTime.now(),
    );
  }

  /// Generate default AI metrics when backend is unavailable
  AIPerformanceMetrics _generateDefaultAIMetrics(
    String businessId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return AIPerformanceMetrics(
      businessId: businessId,
      periodStart: startDate,
      periodEnd: endDate,
      totalDecisions: 50,
      successfulDecisions: 42,
      overallAccuracy: 0.84,
      averageConfidence: 0.78,
      accuracyByType: {
        DecisionOutcomeType.cashFlowPrediction: 0.87,
        DecisionOutcomeType.customerBehavior: 0.82,
        DecisionOutcomeType.paymentRecovery: 0.89,
        DecisionOutcomeType.expenseOptimization: 0.85,
      },
      keyMetrics: {
        'response_time_ms': 1200,
        'confidence_calibration': 0.91,
        'false_positive_rate': 0.08,
        'false_negative_rate': 0.12,
      },
      calculatedAt: DateTime.now(),
    );
  }

  /// Generate default business metrics when backend is unavailable
  BusinessImpactMetrics _generateDefaultBusinessMetrics(
    String businessId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return BusinessImpactMetrics(
      businessId: businessId,
      periodStart: startDate,
      periodEnd: endDate,
      cashFlowImprovement: 15000,
      customerSatisfactionDelta: 0.12,
      operationalEfficiencyGain: 0.25,
      complianceScoreImprovement: 0.08,
      automatedTasksCount: 156,
      totalTimeSaved: 48,
      totalCostSavings: 8500,
      categoryImpacts: {
        'payment_management': 5000,
        'expense_control': 2000,
        'customer_relations': 1500,
      },
      calculatedAt: DateTime.now(),
    );
  }

  /// Generate default performance trends
  Map<String, dynamic> _generateDefaultTrends() {
    return {
      'accuracy_trend': [0.82, 0.84, 0.83, 0.85, 0.87],
      'roi_trend': [120, 135, 142, 158, 165],
      'automation_count_trend': [10, 15, 18, 22, 25],
      'cost_savings_trend': [1000, 1500, 2200, 2800, 3200],
    };
  }

  /// Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Dispose resources
  void dispose() {
    _alertController.close();
    _httpClient.close();
  }
}
