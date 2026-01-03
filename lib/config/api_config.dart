/// API Configuration for different environments
class ApiConfig {
  // Production API URL (update this with your actual deployed URL)
  static const String productionBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.fineasy.tech',
  );

  // Development API URL (Local AI Backend)
  static const String developmentBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // Get the appropriate base URL based on build mode with HTTPS enforcement
  static String get baseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    final url = isProduction ? productionBaseUrl : developmentBaseUrl;

    // Enforce HTTPS in production builds
    if (isProduction && !url.startsWith('https://')) {
      throw StateError(
        'SECURITY ERROR: Production builds must use HTTPS. '
        'Current URL: $url. Please update API_BASE_URL environment variable.',
      );
    }

    return url;
  }

  // API endpoints
  static String get healthEndpoint => '$baseUrl/health';
  static String get nlpProcessInvoiceEndpoint =>
      '$baseUrl/api/nlp/process-invoice';
  static String get nlpCreateInvoiceEndpoint =>
      '$baseUrl/api/nlp/create-invoice';
  static String get fraudDetectionEndpoint => '$baseUrl/api/fraud/analyze';
  static String get insightsEndpoint => '$baseUrl/api/insights/generate';
  static String get complianceEndpoint => '$baseUrl/api/compliance/check';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Validate URL uses HTTPS (for production)
  static bool isSecureUrl(String url) {
    return url.startsWith('https://');
  }

  // Validate all endpoints use HTTPS in production
  static void validateSecureConnection() {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');

    if (isProduction) {
      if (!isSecureUrl(baseUrl)) {
        throw StateError(
          'SECURITY ERROR: All API endpoints must use HTTPS in production. '
          'Current base URL: $baseUrl',
        );
      }
    }
  }

  // Debug information (no-op in production)
  static void printConfig() {
    // Run security validation
    validateSecureConnection();
  }
}
