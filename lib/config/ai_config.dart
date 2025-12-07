/// AI service configuration
class AIConfig {
  // Backend URL configuration
  static const String baseUrl = String.fromEnvironment(
    'AI_BACKEND_URL',
    defaultValue: 'https://api.fineasy.tech/',
  );

  static const String apiVersion = 'v1';
  static const int timeoutSeconds = 30;

  // Feature flags
  static const bool enableFraudAlerts = bool.fromEnvironment(
    'ENABLE_FRAUD_ALERTS',
    defaultValue: true,
  );

  static const bool enablePredictiveInsights = bool.fromEnvironment(
    'ENABLE_PREDICTIVE_INSIGHTS',
    defaultValue: true,
  );

  static const bool enableComplianceChecking = bool.fromEnvironment(
    'ENABLE_COMPLIANCE_CHECKING',
    defaultValue: true,
  );

  static const bool enableNLPInvoice = bool.fromEnvironment(
    'ENABLE_NLP_INVOICE',
    defaultValue: true,
  );

  // Cache configuration
  static const Duration cacheExpiry = Duration(hours: 1);
  static const Duration insightsCacheExpiry = Duration(hours: 6);
  static const Duration fraudCacheExpiry = Duration(minutes: 30);

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const bool enableOfflineMode = true;
  static const Duration offlineCacheExpiry = Duration(days: 1);
  static bool get isAIEnabled {
    return enableFraudAlerts ||
        enablePredictiveInsights ||
        enableComplianceChecking ||
        enableNLPInvoice;
  }

  static String get fullApiUrl => '$baseUrl/api/$apiVersion';
}
