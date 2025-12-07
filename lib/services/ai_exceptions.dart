/// AI Service specific exceptions
class AIServiceException implements Exception {
  final String message;
  final AIErrorType type;
  final String? recoveryAction;
  final int? statusCode;
  final Map<String, dynamic>? details;

  AIServiceException(
    this.message,
    this.type, {
    this.recoveryAction,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'AIServiceException: $message (Type: $type)';
  }
}

enum AIErrorType {
  networkError,
  processingError,
  insufficientData,
  serviceUnavailable,
  authenticationError,
  rateLimitExceeded,
  invalidRequest,
  serverError,
  timeoutError,
  offlineError,
  initializationError,
  notFound,
  expired,
}

/// Network connectivity exception
class AINetworkException extends AIServiceException {
  AINetworkException(String message, {String? recoveryAction})
    : super(
        message,
        AIErrorType.networkError,
        recoveryAction:
            recoveryAction ?? 'Check your internet connection and try again',
      );
}

/// Authentication related exception
class AIAuthenticationException extends AIServiceException {
  AIAuthenticationException(String message)
    : super(
        message,
        AIErrorType.authenticationError,
        recoveryAction: 'Please log in again',
      );
}

/// Service unavailable exception
class AIServiceUnavailableException extends AIServiceException {
  AIServiceUnavailableException(String message)
    : super(
        message,
        AIErrorType.serviceUnavailable,
        recoveryAction:
            'AI services are temporarily unavailable. Please try again later',
      );
}

/// Processing error exception
class AIProcessingException extends AIServiceException {
  AIProcessingException(String message, {Map<String, dynamic>? details})
    : super(
        message,
        AIErrorType.processingError,
        recoveryAction: 'Please check your data and try again',
        details: details,
      );
}

/// Insufficient data exception
class AIInsufficientDataException extends AIServiceException {
  AIInsufficientDataException(String message)
    : super(
        message,
        AIErrorType.insufficientData,
        recoveryAction: 'More transaction data is needed for accurate analysis',
      );
}

/// Timeout exception
class AITimeoutException extends AIServiceException {
  AITimeoutException(String message)
    : super(
        message,
        AIErrorType.timeoutError,
        recoveryAction: 'Request timed out. Please try again',
      );
}

/// Offline exception
class AIOfflineException extends AIServiceException {
  AIOfflineException()
    : super(
        'AI services are not available offline',
        AIErrorType.offlineError,
        recoveryAction: 'Connect to the internet to use AI features',
      );
}
