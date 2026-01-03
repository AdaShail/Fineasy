import 'package:flutter/foundation.dart';
import 'dart:async';

/// Comprehensive error handler for web-specific errors
class WebErrorHandler {
  static final WebErrorHandler _instance = WebErrorHandler._internal();
  factory WebErrorHandler() => _instance;
  WebErrorHandler._internal();

  final StreamController<WebError> _errorController = StreamController<WebError>.broadcast();
  Stream<WebError> get errorStream => _errorController.stream;

  /// Handle and categorize web errors
  void handleError(dynamic error, StackTrace? stackTrace, {String? context}) {
    final webError = _categorizeError(error, stackTrace, context);
    _errorController.add(webError);
    
    // Log error for debugging
    if (kDebugMode) {
      if (stackTrace != null) {
      }
    }
  }

  /// Categorize error into specific web error types
  WebError _categorizeError(dynamic error, StackTrace? stackTrace, String? context) {
    final errorString = error.toString().toLowerCase();
    
    // Network errors
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('failed to fetch')) {
      return WebError(
        type: WebErrorType.network,
        message: 'Network connection issue. Please check your internet connection.',
        originalError: error,
        stackTrace: stackTrace,
        context: context,
        isRecoverable: true,
      );
    }
    
    // CORS errors
    if (errorString.contains('cors') || 
        errorString.contains('cross-origin')) {
      return WebError(
        type: WebErrorType.cors,
        message: 'Cross-origin request blocked. Please contact support.',
        originalError: error,
        stackTrace: stackTrace,
        context: context,
        isRecoverable: false,
      );
    }
    
    // Authentication errors
    if (errorString.contains('auth') || 
        errorString.contains('unauthorized') ||
        errorString.contains('token')) {
      return WebError(
        type: WebErrorType.authentication,
        message: 'Session expired. Please log in again.',
        originalError: error,
        stackTrace: stackTrace,
        context: context,
        isRecoverable: true,
      );
    }
    
    // Browser compatibility errors
    if (errorString.contains('unsupported') || 
        errorString.contains('not supported')) {
      return WebError(
        type: WebErrorType.browserCompatibility,
        message: 'This feature is not supported in your browser.',
        originalError: error,
        stackTrace: stackTrace,
        context: context,
        isRecoverable: false,
      );
    }
    
    // Storage errors
    if (errorString.contains('storage') || 
        errorString.contains('quota')) {
      return WebError(
        type: WebErrorType.storage,
        message: 'Storage limit reached. Please clear some data.',
        originalError: error,
        stackTrace: stackTrace,
        context: context,
        isRecoverable: true,
      );
    }
    
    // Default to general error
    return WebError(
      type: WebErrorType.general,
      message: 'An unexpected error occurred. Please try again.',
      originalError: error,
      stackTrace: stackTrace,
      context: context,
      isRecoverable: true,
    );
  }

  /// Get user-friendly error message
  String getUserFriendlyMessage(WebErrorType type) {
    switch (type) {
      case WebErrorType.network:
        return 'Unable to connect. Please check your internet connection and try again.';
      case WebErrorType.cors:
        return 'Security restriction encountered. Please contact support if this persists.';
      case WebErrorType.authentication:
        return 'Your session has expired. Please log in again to continue.';
      case WebErrorType.browserCompatibility:
        return 'Your browser doesn\'t support this feature. Please try using Chrome, Firefox, or Safari.';
      case WebErrorType.storage:
        return 'Storage space is full. Please clear some data or use a different browser.';
      case WebErrorType.general:
        return 'Something went wrong. Please try again or contact support if the issue persists.';
    }
  }

  /// Dispose resources
  void dispose() {
    _errorController.close();
  }
}

/// Web-specific error model
class WebError {
  final WebErrorType type;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final String? context;
  final bool isRecoverable;
  final DateTime timestamp;

  WebError({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
    this.context,
    this.isRecoverable = true,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'WebError(type: $type, message: $message, context: $context, timestamp: $timestamp)';
  }
}

/// Types of web-specific errors
enum WebErrorType {
  network,
  cors,
  authentication,
  browserCompatibility,
  storage,
  general,
}
