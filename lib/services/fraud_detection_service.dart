import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ai_models.dart';
import '../models/transaction_model.dart';
import '../models/invoice_model.dart';
import '../utils/app_theme.dart';
import 'ai_client_service.dart';
import 'ai_exceptions.dart';

class FraudDetectionService extends ChangeNotifier {
  static final FraudDetectionService _instance =
      FraudDetectionService._internal();
  factory FraudDetectionService() => _instance;
  FraudDetectionService._internal();

  final AIClientService _aiClient = AIClientService();

  // Current fraud alerts
  List<FraudAlert> _alerts = [];
  List<FraudAlert> get alerts => List.unmodifiable(_alerts);

  // Loading state
  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  // Settings
  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;

  double _confidenceThreshold = 0.7;
  double get confidenceThreshold => _confidenceThreshold;

  bool _realTimeCheckingEnabled = true;
  bool get realTimeCheckingEnabled => _realTimeCheckingEnabled;

  // Cache for recent analyses to avoid duplicate API calls
  final Map<String, DateTime> _recentAnalyses = {};
  static const Duration _analysisCache = Duration(minutes: 5);

  /// Initialize the fraud detection service
  Future<void> initialize() async {
    await _aiClient.initialize();
    await _loadSettings();
  }

  /// Enable or disable fraud detection
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  /// Set confidence threshold for alerts
  void setConfidenceThreshold(double threshold) {
    _confidenceThreshold = threshold.clamp(0.0, 1.0);
    notifyListeners();
    _saveSettings();
  }

  /// Enable or disable real-time checking
  void setRealTimeCheckingEnabled(bool enabled) {
    _realTimeCheckingEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  /// Analyze fraud for a business
  Future<void> analyzeFraud(String businessId) async {
    if (!_isEnabled) return;

    // Validate business ID format
    if (businessId.isEmpty) {
      debugPrint('Fraud analysis skipped: Empty business ID');
      return;
    }

    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    );
    if (!uuidRegex.hasMatch(businessId)) {
      debugPrint(
        'Fraud analysis skipped: Invalid business ID format: $businessId',
      );
      return;
    }

    // Check if we've analyzed recently
    final cacheKey = 'business_$businessId';
    final lastAnalysis = _recentAnalyses[cacheKey];
    if (lastAnalysis != null &&
        DateTime.now().difference(lastAnalysis) < _analysisCache) {
      return;
    }

    _isAnalyzing = true;
    notifyListeners();

    try {
      final response = await _aiClient.analyzeFraud(businessId);

      // Filter alerts by confidence threshold
      final filteredAlerts =
          response.alerts
              .where((alert) => alert.confidenceScore >= _confidenceThreshold)
              .toList();

      _alerts = filteredAlerts;
      _recentAnalyses[cacheKey] = DateTime.now();

      notifyListeners();
    } catch (e) {
      if (e is! AIOfflineException) {
        debugPrint('Fraud analysis failed: $e');
      }
      // Don't show error to user for background fraud checking
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Check for potential fraud in a transaction before saving
  Future<List<FraudAlert>> checkTransactionFraud(
    TransactionModel transaction,
  ) async {
    if (!_isEnabled || !_realTimeCheckingEnabled) return [];

    try {
      // For real-time checking, we'll do a quick local analysis
      // and trigger a full analysis in the background
      final potentialAlerts = <FraudAlert>[];

      // Check for duplicate amounts and descriptions
      final duplicateAlert = await _checkForDuplicateTransaction(transaction);
      if (duplicateAlert != null) {
        potentialAlerts.add(duplicateAlert);
      }

      // Trigger background analysis
      unawaited(analyzeFraud(transaction.businessId));

      return potentialAlerts;
    } catch (e) {
      debugPrint('Real-time fraud check failed: $e');
      return [];
    }
  }

  /// Check for potential fraud in an invoice before saving
  Future<List<FraudAlert>> checkInvoiceFraud(InvoiceModel invoice) async {
    if (!_isEnabled || !_realTimeCheckingEnabled) return [];

    try {
      final potentialAlerts = <FraudAlert>[];

      // Check for duplicate invoice numbers
      final duplicateAlert = await _checkForDuplicateInvoice(invoice);
      if (duplicateAlert != null) {
        potentialAlerts.add(duplicateAlert);
      }

      // Trigger background analysis
      unawaited(analyzeFraud(invoice.businessId));

      return potentialAlerts;
    } catch (e) {
      debugPrint('Real-time invoice fraud check failed: $e');
      return [];
    }
  }

  /// Dismiss a fraud alert
  void dismissAlert(String alertId) {
    _alerts.removeWhere((alert) => alert.id == alertId);
    notifyListeners();
  }

  /// Clear all alerts
  void clearAllAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  /// Get alerts for a specific type
  List<FraudAlert> getAlertsByType(FraudType type) {
    return _alerts.where((alert) => alert.type == type).toList();
  }

  /// Get high priority alerts (confidence >= 0.8)
  List<FraudAlert> getHighPriorityAlerts() {
    return _alerts.where((alert) => alert.confidenceScore >= 0.8).toList();
  }

  /// Check if AI services are available
  Future<bool> isServiceAvailable() async {
    return await _aiClient.isServiceAvailable();
  }

  // Private methods

  Future<FraudAlert?> _checkForDuplicateTransaction(
    TransactionModel transaction,
  ) async {
    // This is a simplified local check
    // In a real implementation, you might check against recent transactions
    // stored locally or in cache

    // For now, we'll just create a mock alert for demonstration
    // In practice, this would query local database for similar transactions

    return null; // No local duplicate detection for now
  }

  Future<FraudAlert?> _checkForDuplicateInvoice(InvoiceModel invoice) async {
    // This is a simplified local check
    // In a real implementation, you might check against recent invoices

    return null; // No local duplicate detection for now
  }

  Future<void> _loadSettings() async {
    // In a real implementation, load from SharedPreferences
    // For now, use defaults
  }

  Future<void> _saveSettings() async {
    // In a real implementation, save to SharedPreferences
    // For now, do nothing
  }
}

/// Extension to provide fraud checking capabilities to transaction operations
extension FraudCheckingExtension on FraudDetectionService {
  /// Show fraud alert dialog
  static Future<bool> showFraudAlertDialog(
    BuildContext context,
    List<FraudAlert> alerts,
  ) async {
    if (alerts.isEmpty) return true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning, color: AppTheme.errorColor),
                const SizedBox(width: 8),
                const Text('Fraud Alert'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Potential fraud or errors detected:',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                ...alerts.map(
                  (alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '• ${alert.message}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningColor,
                ),
                child: const Text('Continue Anyway'),
              ),
            ],
          ),
    );

    return result ?? false;
  }
}
