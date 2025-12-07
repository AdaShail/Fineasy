import 'package:flutter/foundation.dart';
import 'ai_exceptions.dart';

/// Comprehensive error handler for AI services
class AIErrorHandler {
  static final AIErrorHandler _instance = AIErrorHandler._internal();
  factory AIErrorHandler() => _instance;
  AIErrorHandler._internal();

  /// Convert AI service exceptions to user-friendly messages
  String getUserFriendlyMessage(AIServiceException exception) {
    switch (exception.type) {
      case AIErrorType.networkError:
        return _getNetworkErrorMessage(exception);
      case AIErrorType.serviceUnavailable:
        return _getServiceUnavailableMessage(exception);
      case AIErrorType.authenticationError:
        return _getAuthErrorMessage(exception);
      case AIErrorType.processingError:
        return _getProcessingErrorMessage(exception);
      case AIErrorType.notFound:
        return 'The requested resource was not found. Please try again.';
      case AIErrorType.initializationError:
        return _getInitializationErrorMessage(exception);
      case AIErrorType.insufficientData:
        return _getInsufficientDataMessage(exception);
      case AIErrorType.rateLimitExceeded:
        return _getRateLimitMessage(exception);
      case AIErrorType.invalidRequest:
        return _getInvalidRequestMessage(exception);
      case AIErrorType.serverError:
        return _getServerErrorMessage(exception);
      case AIErrorType.timeoutError:
        return _getTimeoutErrorMessage(exception);
      case AIErrorType.offlineError:
        return _getOfflineErrorMessage(exception);
      case AIErrorType.expired:
        return 'Session expired. Please log in again.';
    }
  }

  /// Get recovery actions for the error
  List<String> getRecoveryActions(AIServiceException exception) {
    final actions = <String>[];

    if (exception.recoveryAction != null) {
      actions.add(exception.recoveryAction!);
    }

    switch (exception.type) {
      case AIErrorType.networkError:
        actions.addAll([
          'Check your internet connection',
          'Try switching between WiFi and mobile data',
          'Restart the app if the problem persists',
        ]);
        break;
      case AIErrorType.serviceUnavailable:
        actions.addAll([
          'Wait a few minutes and try again',
          'Check if other features are working',
          'Contact support if the issue continues',
        ]);
        break;
      case AIErrorType.authenticationError:
        actions.addAll([
          'Log out and log back in',
          'Check your account status',
          'Contact support if needed',
        ]);
        break;
      case AIErrorType.processingError:
        actions.addAll([
          'Try again with different data',
          'Check if your input is valid',
          'Contact support if the error persists',
        ]);
        break;
      case AIErrorType.insufficientData:
        actions.addAll([
          'Add more transaction data',
          'Wait for more business activity',
          'Try again after a few days',
        ]);
        break;
      case AIErrorType.timeoutError:
        actions.addAll([
          'Try again in a moment',
          'Check your internet speed',
          'Use a more stable connection',
        ]);
        break;
      case AIErrorType.offlineError:
        actions.addAll([
          'Connect to the internet',
          'Enable mobile data or WiFi',
          'Some features work offline with cached data',
        ]);
        break;
      case AIErrorType.rateLimitExceeded:
        actions.addAll([
          'Wait before making more requests',
          'Try again in a few minutes',
          'Reduce the frequency of requests',
        ]);
        break;
      case AIErrorType.invalidRequest:
        actions.addAll([
          'Check your input data',
          'Try with different parameters',
          'Contact support if the issue continues',
        ]);
        break;
      case AIErrorType.serverError:
        actions.addAll([
          'Try again in a few minutes',
          'Check service status',
          'Contact support if needed',
        ]);
        break;
      case AIErrorType.initializationError:
        actions.addAll([
          'Restart the application',
          'Clear app cache and data',
          'Reinstall the app if needed',
        ]);
        break;
      case AIErrorType.notFound:
        actions.addAll([
          'Check if the resource exists',
          'Try refreshing the data',
          'Contact support if needed',
        ]);
        break;
      case AIErrorType.expired:
        actions.addAll([
          'Log in again',
          'Refresh your session',
          'Try the operation again',
        ]);
        break;
    }

    return actions.take(3).toList(); // Limit to 3 actions for UI
  }

  /// Get appropriate icon for the error type
  String getErrorIcon(AIServiceException exception) {
    switch (exception.type) {
      case AIErrorType.networkError:
      case AIErrorType.offlineError:
        return 'NET';
      case AIErrorType.serviceUnavailable:
      case AIErrorType.serverError:
        return 'TECH';
      case AIErrorType.authenticationError:
        return 'AUTH';
      case AIErrorType.processingError:
        return 'WARN';
      case AIErrorType.insufficientData:
        return 'DATA';
      case AIErrorType.timeoutError:
        return 'TIME';
      case AIErrorType.rateLimitExceeded:
        return 'LIMIT';
      case AIErrorType.invalidRequest:
        return 'ERR';
      case AIErrorType.initializationError:
        return 'INIT';
      case AIErrorType.notFound:
        return 'NOT_FOUND';
      case AIErrorType.expired:
        return 'EXPIRED';
    }
  }

  /// Check if error allows fallback to cached data
  bool canUseCachedData(AIServiceException exception) {
    return [
      AIErrorType.networkError,
      AIErrorType.serviceUnavailable,
      AIErrorType.timeoutError,
      AIErrorType.offlineError,
      AIErrorType.serverError,
    ].contains(exception.type);
  }

  /// Check if error should trigger retry
  bool shouldRetry(AIServiceException exception) {
    return [
      AIErrorType.networkError,
      AIErrorType.timeoutError,
      AIErrorType.serverError,
    ].contains(exception.type);
  }

  /// Get retry delay based on error type
  Duration getRetryDelay(AIServiceException exception, int retryCount) {
    final baseDelay = Duration(seconds: 2);
    final multiplier = retryCount + 1;

    switch (exception.type) {
      case AIErrorType.networkError:
        return baseDelay * multiplier;
      case AIErrorType.timeoutError:
        return baseDelay * (multiplier * 2);
      case AIErrorType.serverError:
        return baseDelay * (multiplier * 3);
      case AIErrorType.rateLimitExceeded:
        return Duration(minutes: 1 * multiplier);
      default:
        return baseDelay * multiplier;
    }
  }

  /// Log error for debugging (only in debug mode)
  void logError(AIServiceException exception, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('AI Service Error: ${exception.message}');
      debugPrint('Type: ${exception.type}');
      debugPrint('Status Code: ${exception.statusCode}');
      debugPrint('Details: ${exception.details}');
      if (stackTrace != null) {
        debugPrint('Stack Trace: $stackTrace');
      }
    }
  }

  // Private helper methods for specific error messages

  String _getNetworkErrorMessage(AIServiceException exception) {
    return 'Unable to connect to AI services. Please check your internet connection and try again.';
  }

  String _getServiceUnavailableMessage(AIServiceException exception) {
    return 'AI services are temporarily unavailable. We\'re working to restore them quickly.';
  }

  String _getAuthErrorMessage(AIServiceException exception) {
    return 'Authentication failed. Please log in again to access AI features.';
  }

  String _getProcessingErrorMessage(AIServiceException exception) {
    if (exception.details != null &&
        exception.details!['validation_errors'] != null) {
      return 'There was an issue with your data. Please check the highlighted fields and try again.';
    }
    return 'Unable to process your request. Please try again or contact support if the issue persists.';
  }

  String _getInsufficientDataMessage(AIServiceException exception) {
    return 'Not enough data available for accurate analysis. Add more transactions and try again.';
  }

  String _getTimeoutErrorMessage(AIServiceException exception) {
    return 'The request took too long to complete. Please try again with a better connection.';
  }

  String _getOfflineErrorMessage(AIServiceException exception) {
    return 'AI features require an internet connection. Connect to WiFi or mobile data to continue.';
  }

  String _getRateLimitMessage(AIServiceException exception) {
    return 'You\'ve made too many requests. Please wait a moment before trying again.';
  }

  String _getInvalidRequestMessage(AIServiceException exception) {
    if (exception.details != null && exception.details!['field'] != null) {
      return 'Invalid ${exception.details!['field']}: ${exception.message}';
    }
    return 'Invalid request data. Please check your input and try again.';
  }

  String _getServerErrorMessage(AIServiceException exception) {
    return 'A server error occurred. Our team has been notified and is working on a fix.';
  }

  String _getInitializationErrorMessage(AIServiceException exception) {
    return 'Failed to initialize AI services. Please restart the app and try again.';
  }
}

/// Error recovery strategies
enum ErrorRecoveryStrategy {
  retry,
  useCachedData,
  showFallback,
  requireUserAction,
  gracefulDegradation,
}

/// Error context for better handling
class AIErrorContext {
  final String operation;
  final Map<String, dynamic>? requestData;
  final DateTime timestamp;
  final String? businessId;

  AIErrorContext({
    required this.operation,
    this.requestData,
    required this.timestamp,
    this.businessId,
  });
}

/// Enhanced error with context
class AIServiceErrorWithContext {
  final AIServiceException exception;
  final AIErrorContext context;
  final ErrorRecoveryStrategy recommendedStrategy;

  AIServiceErrorWithContext({
    required this.exception,
    required this.context,
    required this.recommendedStrategy,
  });

  String get userFriendlyMessage =>
      AIErrorHandler().getUserFriendlyMessage(exception);
  List<String> get recoveryActions =>
      AIErrorHandler().getRecoveryActions(exception);
  String get errorIcon => AIErrorHandler().getErrorIcon(exception);
}
