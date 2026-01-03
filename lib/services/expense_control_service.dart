import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../models/payment_models.dart';
import '../services/expense_service.dart';
import '../services/ai_client_service.dart';
import '../services/notification_service.dart';

/// Service for automatic expense control and fund reservation
class ExpenseControlService {
  final ExpenseService _expenseService;
  final AIClientService _aiService;
  final NotificationService _notificationService;

  ExpenseControlService({
    required ExpenseService expenseService,
    required AIClientService aiService,
    required NotificationService notificationService,
  }) : _expenseService = expenseService,
       _aiService = aiService,
       _notificationService = notificationService;

  /// Monitors expenses and triggers controls when thresholds are exceeded
  Future<List<ExpenseControlRule>> monitorExpenseThresholds({
    required String businessId,
  }) async {
    try {
      // Get active expense control rules
      final activeRules = await _getActiveExpenseRules(businessId);

      final triggeredRules = <ExpenseControlRule>[];

      for (final rule in activeRules) {
        final isTriggered = await _checkRuleThreshold(rule);
        if (isTriggered) {
          await _executeControlAction(rule);
          triggeredRules.add(rule);
        }
      }

      return triggeredRules;
    } catch (e) {
      return [];
    }
  }

  /// Pauses non-essential expenses automatically
  Future<List<String>> pauseNonEssentialExpenses({
    required String businessId,
    String? reason,
  }) async {
    try {
      // Get current expenses and categorize by priority
      final expenses = await _expenseService.getExpenses(businessId);
      final nonEssentialCategories = await _identifyNonEssentialCategories(
        expenses,
      );

      final pausedCategories = <String>[];

      for (final category in nonEssentialCategories) {
        // Create expense control rule to pause this category
        final controlRule = ExpenseControlRule(
          id: _generateId(),
          businessId: businessId,
          name: 'Auto-pause: $category',
          description:
              reason ?? 'Automatically paused due to cash flow constraints',
          category: category,
          threshold: 0.0, // Zero threshold means pause all
          thresholdType: 'absolute',
          action: 'pause',
          isActive: true,
          priorityLevel: '1',
          createdAt: DateTime.now(),
        );

        await _saveExpenseRule(controlRule);
        pausedCategories.add(category);
      }

      // Notify business owner
      await _notificationService.sendNotification(
        title: 'Expense Controls Activated',
        message:
            'Non-essential expenses have been paused: ${pausedCategories.join(', ')}',
        type: NotificationType.warning,
      );

      return pausedCategories;
    } catch (e) {
      return [];
    }
  }

  /// Reserves funds for upcoming obligations
  Future<List<FundReservation>> reserveFundsForObligations({
    required String businessId,
    required List<Map<String, dynamic>> obligations,
  }) async {
    try {
      final reservations = <FundReservation>[];

      for (final obligation in obligations) {
        final reservation = FundReservation(
          id: _generateId(),
          businessId: businessId,
          purpose: obligation['purpose'] ?? 'Upcoming obligation',
          amount: obligation['amount']?.toDouble() ?? 0.0,
          reservedAt: DateTime.now(),
          releaseDate:
              obligation['dueDate'] ??
              DateTime.now().add(const Duration(days: 30)),
          status: 'active',
          obligationType: obligation['type'] ?? 'general',
          obligationId: obligation['id'],
          createdAt: DateTime.now(),
        );

        await _saveFundReservation(reservation);
        reservations.add(reservation);
      }

      // Calculate total reserved amount
      final totalReserved = reservations.fold(0.0, (sum, r) => sum + r.amount);

      // Notify business owner
      await _notificationService.sendNotification(
        title: 'Funds Reserved',
        message:
            '₹${totalReserved.toStringAsFixed(2)} reserved for upcoming obligations',
        type: NotificationType.info,
      );

      return reservations;
    } catch (e) {
      return [];
    }
  }

  /// Categorizes expenses by priority and necessity
  Future<Map<String, List<String>>> categorizeExpensesByPriority({
    required String businessId,
  }) async {
    try {
      final expenses = await _expenseService.getExpenses(businessId);

      // Group expenses by category
      final categoryGroups = <String, List<ExpenseModel>>{};
      for (final expense in expenses) {
        categoryGroups[expense.category] =
            (categoryGroups[expense.category] ?? [])..add(expense);
      }

      // Analyze each category using AI
      final categorization = <String, List<String>>{
        'essential': [],
        'important': [],
        'discretionary': [],
        'non_essential': [],
      };

      for (final entry in categoryGroups.entries) {
        final category = entry.key;
        final categoryExpenses = entry.value;

        final priority = await _analyzeCategoryPriority(
          category,
          categoryExpenses,
        );
        categorization[priority]!.add(category);
      }

      return categorization;
    } catch (e) {
      return {
        'essential': [],
        'important': [],
        'discretionary': [],
        'non_essential': [],
      };
    }
  }

  /// Creates expense control rules based on business patterns
  Future<List<ExpenseControlRule>> createSmartExpenseRules({
    required String businessId,
  }) async {
    try {
      // Analyze historical expense patterns
      final expensePatterns = await _analyzeExpensePatterns(businessId);

      final smartRules = <ExpenseControlRule>[];

      // Create rules based on patterns
      for (final pattern in expensePatterns) {
        if (pattern['volatility'] > 0.3) {
          // High volatility category - create threshold rule
          smartRules.add(
            ExpenseControlRule(
              id: _generateId(),
              businessId: businessId,
              name: 'Smart Control: ${pattern['category']}',
              description: 'Auto-generated rule for volatile expense category',
              category: pattern['category'],
              threshold: pattern['averageMonthly'] * 1.5, // 50% above average
              thresholdType: 'monthly',
              action: 'alert',
              isActive: true,
              priorityLevel: '2',
              createdAt: DateTime.now(),
            ),
          );
        }

        if (pattern['trend'] > 0.2) {
          // Rising trend - create growth control rule
          smartRules.add(
            ExpenseControlRule(
              id: _generateId(),
              businessId: businessId,
              name: 'Growth Control: ${pattern['category']}',
              description: 'Control for rapidly growing expense category',
              category: pattern['category'],
              threshold: pattern['averageMonthly'] * 1.3, // 30% above average
              thresholdType: 'monthly',
              action: 'require_approval',
              isActive: true,
              priorityLevel: '1',
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      // Save rules
      for (final rule in smartRules) {
        await _saveExpenseRule(rule);
      }

      return smartRules;
    } catch (e) {
      return [];
    }
  }

  /// Gets current fund reservations
  Future<List<FundReservation>> getCurrentReservations({
    required String businessId,
  }) async {
    try {
      // This would typically query a database
      // For now, return empty list as placeholder
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Releases expired fund reservations
  Future<List<FundReservation>> releaseExpiredReservations({
    required String businessId,
  }) async {
    try {
      final currentReservations = await getCurrentReservations(
        businessId: businessId,
      );
      final expiredReservations =
          currentReservations
              .where(
                (r) =>
                    r.releaseDate != null &&
                    r.releaseDate!.isBefore(DateTime.now()) &&
                    r.status == 'active',
              )
              .toList();

      for (final reservation in expiredReservations) {
        await _updateReservationStatus(reservation.id, 'released');
      }

      return expiredReservations;
    } catch (e) {
      return [];
    }
  }

  /// Private helper methods

  Future<List<ExpenseControlRule>> _getActiveExpenseRules(
    String businessId,
  ) async {
    try {
      // This would typically query a database
      // For now, return some default rules
      return [
        ExpenseControlRule(
          id: 'default_1',
          businessId: businessId,
          name: 'Marketing Spend Control',
          description: 'Control marketing expenses',
          category: 'marketing',
          threshold: 25000.0,
          thresholdType: 'monthly',
          action: 'alert',
          isActive: true,
          priorityLevel: '2',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        ExpenseControlRule(
          id: 'default_2',
          businessId: businessId,
          name: 'Travel Expense Control',
          description: 'Control travel expenses',
          category: 'travel',
          threshold: 15000.0,
          thresholdType: 'monthly',
          action: 'require_approval',
          isActive: true,
          priorityLevel: '1',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];
    } catch (e) {
      return [];
    }
  }

  Future<bool> _checkRuleThreshold(ExpenseControlRule rule) async {
    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (rule.thresholdType) {
        case 'daily':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'weekly':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'monthly':
          startDate = DateTime(now.year, now.month, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      // Get expenses for the period and category
      final expenses = await _expenseService.getExpensesByDateRange(
        rule.businessId,
        startDate,
        now,
      );

      final ruleCategory = rule.category;
      final categoryExpenses =
          expenses
              .where(
                (e) =>
                    e.category.toLowerCase() == ruleCategory.toLowerCase(),
              )
              .toList();

      final totalAmount = categoryExpenses.fold(
        0.0,
        (sum, e) => sum + e.amount,
      );

      final threshold = rule.threshold;
      return totalAmount >= threshold;
    } catch (e) {
      return false;
    }
  }

  Future<void> _executeControlAction(ExpenseControlRule rule) async {
    try {
      final action = rule.action;
      switch (action) {
        case 'alert':
          await _sendThresholdAlert(rule);
          break;
        case 'pause':
          await _pauseCategoryExpenses(rule);
          break;
        case 'require_approval':
          await _enableApprovalRequirement(rule);
          break;
        case 'block':
          await _blockCategoryExpenses(rule);
          break;
      }
    } catch (e) {
    }
  }

  Future<void> _sendThresholdAlert(ExpenseControlRule rule) async {
    final category = rule.category;
    final threshold = rule.threshold;
    await _notificationService.sendNotification(
      title: 'Expense Threshold Exceeded',
      message:
          '$category expenses have exceeded ₹${threshold.toStringAsFixed(2)} threshold',
      type: NotificationType.warning,
    );
  }

  Future<void> _pauseCategoryExpenses(ExpenseControlRule rule) async {
    // Implementation would pause new expenses in this category
    final category = rule.category;
    await _notificationService.sendNotification(
      title: 'Expenses Paused',
      message: '$category expenses have been automatically paused',
      type: NotificationType.warning,
    );
  }

  Future<void> _enableApprovalRequirement(ExpenseControlRule rule) async {
    // Implementation would require approval for new expenses in this category
    final category = rule.category;
    await _notificationService.sendNotification(
      title: 'Approval Required',
      message: '$category expenses now require approval',
      type: NotificationType.info,
    );
  }

  Future<void> _blockCategoryExpenses(ExpenseControlRule rule) async {
    // Implementation would block new expenses in this category
    final category = rule.category;
    await _notificationService.sendNotification(
      title: 'Expenses Blocked',
      message: '$category expenses have been blocked',
      type: NotificationType.error,
    );
  }

  Future<List<String>> _identifyNonEssentialCategories(
    List<ExpenseModel> expenses,
  ) async {
    // Categorize expenses by necessity
    final nonEssentialCategories = <String>[
      'entertainment',
      'marketing',
      'travel',
      'training',
      'subscriptions',
      'office_supplies',
      'miscellaneous',
    ];

    // Get unique categories from expenses
    final expenseCategories =
        expenses.map((e) => e.category.toLowerCase()).toSet();

    // Return intersection of non-essential and actual categories
    return nonEssentialCategories
        .where((category) => expenseCategories.contains(category))
        .toList();
  }

  Future<String> _analyzeCategoryPriority(
    String category,
    List<ExpenseModel> expenses,
  ) async {
    try {
      // Use AI to analyze category priority
      final prompt = '''
Analyze the expense category "$category" and classify its priority level.

Category: $category
Number of expenses: ${expenses.length}
Total amount: ₹${expenses.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(2)}
Average amount: ₹${expenses.isNotEmpty ? (expenses.fold(0.0, (sum, e) => sum + e.amount) / expenses.length).toStringAsFixed(2) : '0'}

Classify as one of:
- essential (critical for business operations)
- important (necessary but can be delayed)
- discretionary (nice to have)
- non_essential (can be eliminated)

Return only the classification word.
''';

      final response = await _aiService.generateText(prompt);
      final priority = response.toLowerCase().trim();

      // Validate response
      const validPriorities = [
        'essential',
        'important',
        'discretionary',
        'non_essential',
      ];
      return validPriorities.contains(priority) ? priority : 'discretionary';
    } catch (e) {
      return _getDefaultPriority(category);
    }
  }

  String _getDefaultPriority(String category) {
    // Default priority mapping
    const essentialCategories = [
      'rent',
      'utilities',
      'salaries',
      'insurance',
      'loan_payments',
    ];
    const importantCategories = [
      'inventory',
      'equipment',
      'maintenance',
      'professional_services',
    ];
    const nonEssentialCategories = [
      'entertainment',
      'marketing',
      'travel',
      'training',
    ];

    final lowerCategory = category.toLowerCase();

    if (essentialCategories.contains(lowerCategory)) return 'essential';
    if (importantCategories.contains(lowerCategory)) return 'important';
    if (nonEssentialCategories.contains(lowerCategory)) return 'non_essential';

    return 'discretionary';
  }

  Future<List<Map<String, dynamic>>> _analyzeExpensePatterns(
    String businessId,
  ) async {
    try {
      final expenses = await _expenseService.getExpenses(businessId);

      // Group by category and month
      final categoryMonthlyData = <String, Map<String, double>>{};

      for (final expense in expenses) {
        final category = expense.category;
        final monthKey =
            '${expense.expenseDate.year}-${expense.expenseDate.month.toString().padLeft(2, '0')}';

        categoryMonthlyData[category] ??= {};
        categoryMonthlyData[category]![monthKey] =
            (categoryMonthlyData[category]![monthKey] ?? 0.0) + expense.amount;
      }

      final patterns = <Map<String, dynamic>>[];

      for (final entry in categoryMonthlyData.entries) {
        final category = entry.key;
        final monthlyData = entry.value;

        if (monthlyData.length >= 3) {
          final values = monthlyData.values.toList();
          final averageMonthly = values.reduce((a, b) => a + b) / values.length;

          // Calculate volatility (coefficient of variation)
          final variance =
              values
                  .map((v) => pow(v - averageMonthly, 2))
                  .reduce((a, b) => a + b) /
              values.length;
          final volatility = sqrt(variance) / averageMonthly;

          // Calculate trend
          final trend = _calculateTrend(values);

          patterns.add({
            'category': category,
            'averageMonthly': averageMonthly,
            'volatility': volatility,
            'trend': trend,
          });
        }
      }

      return patterns;
    } catch (e) {
      return [];
    }
  }

  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;

    // Simple linear regression to calculate trend
    final n = values.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = values;

    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumXX = x.map((xi) => xi * xi).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final avgY = sumY / n;

    // Normalize slope by average value to get relative trend
    return avgY != 0 ? slope / avgY : 0.0;
  }

  Future<void> _saveExpenseRule(ExpenseControlRule rule) async {
    // Implementation would save to database
  }

  Future<void> _saveFundReservation(FundReservation reservation) async {
    // Implementation would save to database
  }

  Future<void> _updateReservationStatus(
    String reservationId,
    String status,
  ) async {
    // Implementation would update database
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}
