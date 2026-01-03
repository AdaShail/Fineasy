import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ai_models.dart';
import 'ai_exceptions.dart';
import 'auth_service.dart';

class AIClientService {
  static final AIClientService _instance = AIClientService._internal();
  factory AIClientService() => _instance;
  AIClientService._internal();

  late Dio _dio;
  final AuthService _authService = AuthService();
  final Connectivity _connectivity = Connectivity();

  // Configuration
  static const String _baseUrl = String.fromEnvironment(
    'AI_BACKEND_URL',
    defaultValue: 'http://localhost:8000',
  );
  static const String _apiVersion = 'v1';
  static const int _timeoutSeconds = 30;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// Validate that the base URL uses HTTPS in production
  static void _validateSecureConnection() {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');

    if (isProduction && !_baseUrl.startsWith('https://')) {
      throw StateError(
        'SECURITY ERROR: AI Backend must use HTTPS in production builds. '
        'Current URL: $_baseUrl. Please set AI_BACKEND_URL environment variable to use HTTPS.',
      );
    }

    if (!isProduction &&
        _baseUrl.startsWith('http://') &&
        !_baseUrl.contains('localhost')) {
      // Non-localhost HTTP in development - consider using HTTPS
    }
  }

  // Cache keys
  static const String _cacheKeyPrefix = 'ai_cache_';
  static const Duration _cacheExpiry = Duration(hours: 1);

  bool _isInitialized = false;
  bool _isServiceHealthy = true;
  DateTime? _lastHealthCheck;
  static const Duration _healthCheckInterval = Duration(minutes: 5);

  // Fallback data for offline scenarios
  // ignore: unused_field
  final Map<String, dynamic> _fallbackData = {
    'fraud_alerts': <FraudAlert>[],
    'insights': <BusinessInsight>[],
    'compliance_issues': <ComplianceIssue>[],
  };

  /// Initialize the AI client service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Validate secure connection in production
    _validateSecureConnection();

    _dio = Dio(
      BaseOptions(
        baseUrl: '$_baseUrl/api/$_apiVersion',
        connectTimeout: Duration(seconds: _timeoutSeconds),
        receiveTimeout: Duration(seconds: _timeoutSeconds),
        sendTimeout: Duration(seconds: _timeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(_authService));
    _dio.interceptors.add(_RetryInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());

    // Add logging in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }

    _isInitialized = true;
  }

  /// Check if device is online
  Future<bool> _isOnline() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      // connectivity_plus returns List<ConnectivityResult>
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      // If connectivity check fails, assume offline
      return false;
    }
  }

  /// Check AI service health with caching
  Future<bool> _checkServiceHealth() async {
    // Use cached health status if recent
    if (_lastHealthCheck != null &&
        DateTime.now().difference(_lastHealthCheck!) < _healthCheckInterval) {
      return _isServiceHealthy;
    }

    try {
      if (!await _isOnline()) {
        _isServiceHealthy = false;
        return false;
      }

      await initialize();
      // Check health endpoint without API version prefix
      final healthDio = Dio(BaseOptions(baseUrl: _baseUrl));
      final response = await healthDio
          .get('/health')
          .timeout(const Duration(seconds: 10));

      _isServiceHealthy = response.statusCode == 200;
      _lastHealthCheck = DateTime.now();

      return _isServiceHealthy;
    } catch (e) {
      _isServiceHealthy = false;
      _lastHealthCheck = DateTime.now();
      return false;
    }
  }

  /// Get fallback data for offline scenarios
  Future<T?> _getFallbackData<T>(
    String key,
    T Function() fallbackGenerator,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fallbackJson = prefs.getString('${_cacheKeyPrefix}fallback_$key');

      if (fallbackJson != null) {
        // Fallback data exists, return generated fallback
        return fallbackGenerator();
      }
    } catch (e) {
      // Ignore fallback errors
    }

    // Return default fallback data
    return fallbackGenerator();
  }

  /// Store fallback data for offline use
  Future<void> _storeFallbackData(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '${_cacheKeyPrefix}fallback_$key',
        json.encode(data),
      );
    } catch (e) {
      // Ignore storage errors
    }
  }

  /// Get cached data
  Future<T?> _getCachedData<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('$_cacheKeyPrefix$key');
      final cacheTimestamp = prefs.getInt('$_cacheKeyPrefix${key}_timestamp');

      if (cachedJson != null && cacheTimestamp != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTimestamp;
        if (cacheAge < _cacheExpiry.inMilliseconds) {
          final data = json.decode(cachedJson);
          return fromJson(data);
        }
      }
    } catch (e) {
      // Ignore cache errors
    }
    return null;
  }

  /// Cache data
  Future<void> _cacheData(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cacheKeyPrefix$key', json.encode(data));
      await prefs.setInt(
        '$_cacheKeyPrefix${key}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Analyze fraud for a business with comprehensive error handling
  Future<FraudAnalysisResponse> analyzeFraud(String businessId) async {
    await initialize();

    final cacheKey = 'fraud_$businessId';

    try {
      // Check service health first
      final isHealthy = await _checkServiceHealth();

      if (!isHealthy) {
        // Try to get cached data
        final cached = await _getCachedData<FraudAnalysisResponse>(
          cacheKey,
          (json) => FraudAnalysisResponse.fromJson(json),
        );

        if (cached != null) {
          return cached;
        }

        // Return fallback data if no cache available
        return await _getFallbackData<FraudAnalysisResponse>(
              'fraud_$businessId',
              () => FraudAnalysisResponse(
                businessId: businessId,
                alerts: [],
                riskScore: 0.0,
                analysisMetadata: {
                  'fallback': true,
                  'reason': 'service_unavailable',
                },
                analyzedAt: DateTime.now(),
              ),
            ) ??
            FraudAnalysisResponse(
              businessId: businessId,
              alerts: [],
              riskScore: 0.0,
              analysisMetadata: {
                'fallback': true,
                'reason': 'service_unavailable',
              },
              analyzedAt: DateTime.now(),
            );
      }

      // Try to get fresh data
      final response = await _dio.post(
        '/fraud/analyze',
        data: {'business_id': businessId},
      );

      final fraudResponse = FraudAnalysisResponse.fromJson(response.data);

      // Cache the response for future use
      await _cacheData(cacheKey, response.data);
      await _storeFallbackData('fraud_$businessId', response.data);

      return fraudResponse;
    } on DioException catch (e) {
      // Try cached data on error
      final cached = await _getCachedData<FraudAnalysisResponse>(
        cacheKey,
        (json) => FraudAnalysisResponse.fromJson(json),
      );

      if (cached != null) {
        return cached;
      }

      throw _handleDioException(e);
    } catch (e) {
      // Handle unexpected errors
      final cached = await _getCachedData<FraudAnalysisResponse>(
        cacheKey,
        (json) => FraudAnalysisResponse.fromJson(json),
      );

      if (cached != null) {
        return cached;
      }

      throw AIServiceException(
        'Unexpected error during fraud analysis: ${e.toString()}',
        AIErrorType.processingError,
        recoveryAction: 'Please try again later',
      );
    }
  }

  /// Get predictive business insights with graceful degradation
  Future<BusinessInsightsResponse> getPredictiveInsights(
    String businessId,
  ) async {
    await initialize();

    final cacheKey = 'insights_$businessId';

    try {
      // Check service health first
      final isHealthy = await _checkServiceHealth();

      if (!isHealthy) {
        // Try to get cached data
        final cached = await _getCachedData<BusinessInsightsResponse>(
          cacheKey,
          (json) => BusinessInsightsResponse.fromJson(json),
        );

        if (cached != null) {
          return cached;
        }

        // Return fallback insights
        return await _getFallbackData<BusinessInsightsResponse>(
              'insights_$businessId',
              () => BusinessInsightsResponse(
                success: true,
                message: 'Fallback data',
                timestamp: DateTime.now(),
                businessId: businessId,
                insights: [
                  BusinessInsight(
                    id: 'fallback_1',
                    type: InsightType.general,
                    title: 'AI Services Temporarily Unavailable',
                    description:
                        'Connect to the internet to get the latest business insights.',
                    recommendations: [
                      'Check your internet connection',
                      'Try again later',
                    ],
                    impactScore: 0.0,
                    validUntil: DateTime.now().add(const Duration(hours: 1)),
                  ),
                ],
                generatedAt: DateTime.now(),
                nextUpdate: DateTime.now().add(const Duration(hours: 1)),
              ),
            ) ??
            BusinessInsightsResponse(
              success: true,
              message: 'Empty fallback',
              timestamp: DateTime.now(),
              businessId: businessId,
              insights: [],
              generatedAt: DateTime.now(),
              nextUpdate: DateTime.now().add(const Duration(hours: 1)),
            );
      }

      // Try to get fresh data
      final response = await _dio.get('/insights/$businessId');

      final insightsResponse = BusinessInsightsResponse.fromJson(response.data);

      // Cache the response
      await _cacheData(cacheKey, response.data);
      await _storeFallbackData('insights_$businessId', response.data);

      return insightsResponse;
    } on DioException catch (e) {
      // Try cached data on error
      final cached = await _getCachedData<BusinessInsightsResponse>(
        cacheKey,
        (json) => BusinessInsightsResponse.fromJson(json),
      );

      if (cached != null) {
        return cached;
      }

      throw _handleDioException(e);
    } catch (e) {
      // Handle unexpected errors
      final cached = await _getCachedData<BusinessInsightsResponse>(
        cacheKey,
        (json) => BusinessInsightsResponse.fromJson(json),
      );

      if (cached != null) {
        return cached;
      }

      throw AIServiceException(
        'Unexpected error getting insights: ${e.toString()}',
        AIErrorType.processingError,
        recoveryAction: 'Please try again later',
      );
    }
  }

  /// Check compliance for an invoice with fallback mechanisms
  Future<ComplianceResponse> checkCompliance(String invoiceId) async {
    await initialize();

    final cacheKey = 'compliance_$invoiceId';

    try {
      // Check service health first
      final isHealthy = await _checkServiceHealth();

      if (!isHealthy) {
        // Try to get cached data
        final cached = await _getCachedData<ComplianceResponse>(
          cacheKey,
          (json) => ComplianceResponse.fromJson(json),
        );

        if (cached != null) {
          return cached;
        }

        // Return basic compliance response
        return await _getFallbackData<ComplianceResponse>(
              'compliance_$invoiceId',
              () => ComplianceResponse(
                invoiceId: invoiceId,
                issues: [
                  ComplianceIssue(
                    id: 'offline_notice',
                    type: ComplianceType.warning,
                    description:
                        'Compliance checking is temporarily unavailable',
                    plainLanguageExplanation:
                        'AI compliance services are offline. Please check manually or try again when connected.',
                    suggestedFixes: [
                      'Connect to internet',
                      'Manual review recommended',
                    ],
                    severity: ComplianceSeverity.low,
                  ),
                ],
                overallStatus: ComplianceStatus.warning,
                lastChecked: DateTime.now(),
              ),
            ) ??
            ComplianceResponse(
              invoiceId: invoiceId,
              issues: [],
              overallStatus: ComplianceStatus.unknown,
              lastChecked: DateTime.now(),
            );
      }

      // Try to get fresh data
      final response = await _dio.post(
        '/compliance/check',
        data: {'invoice_id': invoiceId},
      );

      final complianceResponse = ComplianceResponse.fromJson(response.data);

      // Cache the response
      await _cacheData(cacheKey, response.data);
      await _storeFallbackData('compliance_$invoiceId', response.data);

      return complianceResponse;
    } on DioException catch (e) {
      // Try cached data on error
      final cached = await _getCachedData<ComplianceResponse>(
        cacheKey,
        (json) => ComplianceResponse.fromJson(json),
      );

      if (cached != null) {
        return cached;
      }

      throw _handleDioException(e);
    } catch (e) {
      // Handle unexpected errors
      final cached = await _getCachedData<ComplianceResponse>(
        cacheKey,
        (json) => ComplianceResponse.fromJson(json),
      );

      if (cached != null) {
        return cached;
      }

      throw AIServiceException(
        'Unexpected error during compliance check: ${e.toString()}',
        AIErrorType.processingError,
        recoveryAction: 'Please try again later',
      );
    }
  }

  /// Generate invoice from natural language text with error handling
  Future<InvoiceGenerationResponse> generateInvoiceFromText(
    String input,
    String businessId,
  ) async {
    await initialize();

    try {
      // Check service health first
      final isHealthy = await _checkServiceHealth();

      if (!isHealthy) {
        throw AIServiceUnavailableException(
          'Invoice generation requires an active internet connection',
        );
      }

      final request = InvoiceGenerationRequest(
        rawInput: input,
        businessId: businessId,
      );

      final response = await _dio.post(
        '/invoice/generate',
        data: request.toJson(),
      );

      return InvoiceGenerationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw AIServiceException(
        'Unexpected error during invoice generation: ${e.toString()}',
        AIErrorType.processingError,
        recoveryAction: 'Please check your input and try again',
      );
    }
  }

  /// Clear all cached AI data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (key) => key.startsWith(_cacheKeyPrefix),
      );
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Check if AI services are available with detailed status
  Future<bool> isServiceAvailable() async {
    return await _checkServiceHealth();
  }

  /// Get detailed service status for monitoring
  Future<AIServiceStatus> getServiceStatus() async {
    try {
      final isOnline = await _isOnline();
      final isHealthy = await _checkServiceHealth();

      if (!isOnline) {
        return AIServiceStatus(
          isAvailable: false,
          status: 'offline',
          message: 'No internet connection',
          lastChecked: DateTime.now(),
          features: _getFeatureStatus(false),
        );
      }

      if (!isHealthy) {
        return AIServiceStatus(
          isAvailable: false,
          status: 'unhealthy',
          message: 'AI services are temporarily unavailable',
          lastChecked: _lastHealthCheck ?? DateTime.now(),
          features: _getFeatureStatus(false),
        );
      }

      // Try to get detailed health info
      try {
        await initialize();
        final response = await _dio.get('/health');
        final healthData = response.data as Map<String, dynamic>;

        return AIServiceStatus(
          isAvailable: true,
          status: healthData['status'] ?? 'healthy',
          message: 'All AI services are operational',
          lastChecked: DateTime.now(),
          features: _getFeatureStatus(true, healthData['features']),
        );
      } catch (e) {
        return AIServiceStatus(
          isAvailable: false,
          status: 'error',
          message: 'Unable to get service status: ${e.toString()}',
          lastChecked: DateTime.now(),
          features: _getFeatureStatus(false),
        );
      }
    } catch (e) {
      return AIServiceStatus(
        isAvailable: false,
        status: 'error',
        message: 'Status check failed: ${e.toString()}',
        lastChecked: DateTime.now(),
        features: _getFeatureStatus(false),
      );
    }
  }

  /// Get feature availability status
  Map<String, bool> _getFeatureStatus(
    bool isAvailable, [
    Map<String, dynamic>? serverFeatures,
  ]) {
    if (!isAvailable) {
      return {
        'fraud_detection': false,
        'predictive_analytics': false,
        'compliance_checking': false,
        'nlp_invoice': false,
      };
    }

    if (serverFeatures != null) {
      return {
        'fraud_detection': serverFeatures['fraud_detection'] ?? false,
        'predictive_analytics': serverFeatures['predictive_analytics'] ?? false,
        'compliance_checking': serverFeatures['compliance_checking'] ?? false,
        'nlp_invoice': serverFeatures['nlp_invoice'] ?? false,
      };
    }

    // Default to true if service is available but no feature info
    return {
      'fraud_detection': true,
      'predictive_analytics': true,
      'compliance_checking': true,
      'nlp_invoice': true,
    };
  }

  /// Submit structured feedback
  Future<void> submitFeedback(AIFeedback feedback) async {
    await initialize();

    if (await _isOnline() == false) {
      throw AIOfflineException();
    }

    try {
      final response = await _dio.post(
        '/feedback/structured',
        data: feedback.toJson(),
      );

      if (response.statusCode != 200) {
        throw AIProcessingException('Failed to submit feedback');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get AI model performance metrics
  Future<List<AIModelPerformance>> getModelPerformance() async {
    await initialize();

    final cacheKey = 'model_performance';

    // Try to get cached data first
    final cached = await _getCachedData<List<AIModelPerformance>>(cacheKey, (
      json,
    ) {
      final List<dynamic> data = json['models'] ?? [];
      return data.map((item) => AIModelPerformance.fromJson(item)).toList();
    });

    if (cached != null && await _isOnline() == false) {
      return cached;
    }

    if (await _isOnline() == false) {
      throw AIOfflineException();
    }

    try {
      final response = await _dio.get('/models/performance');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['models'] ?? [];
        final models =
            data.map((json) => AIModelPerformance.fromJson(json)).toList();

        // Cache the response
        await _cacheData(cacheKey, response.data);

        return models;
      } else {
        throw AIProcessingException('Failed to get model performance');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get AI service health status
  Future<Map<String, dynamic>> getServiceHealth() async {
    await initialize();

    if (await _isOnline() == false) {
      throw AIOfflineException();
    }

    try {
      final response = await _dio.get('/health');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw AIProcessingException('Failed to get service health');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generic POST method for AI services
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    await initialize();

    if (await _isOnline() == false) {
      throw AIOfflineException();
    }

    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generic GET method for AI services
  Future<Map<String, dynamic>> get(String endpoint) async {
    await initialize();

    if (await _isOnline() == false) {
      throw AIOfflineException();
    }

    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generate text response using AI
  Future<String> generateText(
    String prompt, {
    Map<String, dynamic>? context,
  }) async {
    await initialize();

    if (await _isOnline() == false) {
      throw AIOfflineException();
    }

    try {
      final response = await _dio.post(
        '/generate/text',
        data: {'prompt': prompt, 'context': context ?? {}},
      );

      return response.data['text'] ?? '';
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Generate response using AI
  Future<Map<String, dynamic>> generateResponse(
    String prompt, {
    Map<String, dynamic>? context,
  }) async {
    await initialize();

    if (await _isOnline() == false) {
      throw AIOfflineException();
    }

    try {
      final response = await _dio.post(
        '/generate/response',
        data: {'prompt': prompt, 'context': context ?? {}},
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Handle Dio exceptions and convert to AI service exceptions
  AIServiceException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AITimeoutException('Request timed out. Please try again.');

      case DioExceptionType.connectionError:
        if (e.error is SocketException) {
          return AINetworkException('Network connection failed');
        }
        return AIServiceUnavailableException(
          'Unable to connect to AI services',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        switch (statusCode) {
          case 401:
            return AIAuthenticationException('Authentication failed');
          case 403:
            return AIAuthenticationException('Access denied');
          case 429:
            return AIServiceException(
              'Rate limit exceeded',
              AIErrorType.rateLimitExceeded,
              recoveryAction: 'Please wait before making more requests',
            );
          case 422:
            String message = 'Invalid request data';
            if (responseData is Map && responseData['message'] != null) {
              message = responseData['message'];
            }
            return AIServiceException(
              message,
              AIErrorType.invalidRequest,
              details:
                  responseData is Map
                      ? Map<String, dynamic>.from(responseData)
                      : null,
            );
          case 500:
          case 502:
          case 503:
          case 504:
            return AIServiceUnavailableException(
              'AI services are temporarily unavailable',
            );
          default:
            String message = 'An error occurred while processing your request';
            if (responseData is Map && responseData['message'] != null) {
              message = responseData['message'];
            }
            return AIProcessingException(
              message,
              details:
                  responseData is Map
                      ? Map<String, dynamic>.from(responseData)
                      : null,
            );
        }

      case DioExceptionType.cancel:
        return AIServiceException(
          'Request was cancelled',
          AIErrorType.processingError,
        );

      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          return AINetworkException('Network error occurred');
        }
        return AIServiceException(
          'An unexpected error occurred',
          AIErrorType.processingError,
        );
    }
  }
}

/// Authentication interceptor
class _AuthInterceptor extends Interceptor {
  final AuthService _authService;

  _AuthInterceptor(this._authService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        // Use Supabase session token
        final session = Supabase.instance.client.auth.currentSession;
        // str token = session!.accessToken;
        if (session?.accessToken != null) {
          options.headers['Authorization'] = 'Bearer ${session!.accessToken}';
        }
      }
    } catch (e) {
      // Continue without token if auth fails
    }
    handler.next(options);
  }
}

/// Retry interceptor with exponential backoff
class _RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < AIClientService._maxRetries) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        // Exponential backoff
        final delay = AIClientService._retryDelay * (retryCount + 1);
        await Future.delayed(delay);

        try {
          final response = await Dio().fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue to next retry or fail
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on network errors and 5xx server errors
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500 &&
            err.response!.statusCode! < 600);
  }
}

/// Error interceptor for additional error handling
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log errors in debug mode - no console output in production
    handler.next(err);
  }
}
