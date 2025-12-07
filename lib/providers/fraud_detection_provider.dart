import 'package:flutter/foundation.dart';
import '../models/ai_models.dart';
import '../services/fraud_detection_service.dart';

class FraudDetectionProvider extends ChangeNotifier {
  final FraudDetectionService _fraudService = FraudDetectionService();

  // Getters that delegate to the service
  List<FraudAlert> get alerts => _fraudService.alerts;
  bool get isAnalyzing => _fraudService.isAnalyzing;
  bool get isEnabled => _fraudService.isEnabled;
  double get confidenceThreshold => _fraudService.confidenceThreshold;
  bool get realTimeCheckingEnabled => _fraudService.realTimeCheckingEnabled;

  FraudDetectionProvider() {
    // Listen to changes in the fraud service
    _fraudService.addListener(_onFraudServiceChanged);
  }

  @override
  void dispose() {
    _fraudService.removeListener(_onFraudServiceChanged);
    super.dispose();
  }

  void _onFraudServiceChanged() {
    notifyListeners();
  }

  // Delegate methods to the service
  Future<void> initialize() async {
    await _fraudService.initialize();
  }

  Future<void> analyzeFraud(String businessId) async {
    await _fraudService.analyzeFraud(businessId);
  }

  void setEnabled(bool enabled) {
    _fraudService.setEnabled(enabled);
  }

  void setConfidenceThreshold(double threshold) {
    _fraudService.setConfidenceThreshold(threshold);
  }

  void setRealTimeCheckingEnabled(bool enabled) {
    _fraudService.setRealTimeCheckingEnabled(enabled);
  }

  void dismissAlert(String alertId) {
    _fraudService.dismissAlert(alertId);
  }

  void clearAllAlerts() {
    _fraudService.clearAllAlerts();
  }

  List<FraudAlert> getAlertsByType(FraudType type) {
    return _fraudService.getAlertsByType(type);
  }

  List<FraudAlert> getHighPriorityAlerts() {
    return _fraudService.getHighPriorityAlerts();
  }

  Future<bool> isServiceAvailable() async {
    return await _fraudService.isServiceAvailable();
  }

  // Access to the underlying service for direct operations
  FraudDetectionService get service => _fraudService;
}
