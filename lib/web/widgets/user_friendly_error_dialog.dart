import 'package:flutter/material.dart';
import '../services/web_error_handler.dart';

/// User-friendly error dialog for web-specific errors
class UserFriendlyErrorDialog extends StatelessWidget {
  final WebError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const UserFriendlyErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getErrorIcon(),
            color: _getErrorColor(),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getErrorTitle(),
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error.message,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 16),
          _buildErrorDetails(context),
          if (error.isRecoverable) ...[
            const SizedBox(height: 16),
            _buildRecoverySuggestions(context),
          ],
        ],
      ),
      actions: [
        if (onDismiss != null)
          TextButton(
            onPressed: onDismiss,
            child: const Text('Dismiss'),
          ),
        if (error.isRecoverable && onRetry != null)
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        if (!error.isRecoverable)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
      ],
    );
  }

  IconData _getErrorIcon() {
    switch (error.type) {
      case WebErrorType.network:
        return Icons.wifi_off;
      case WebErrorType.cors:
        return Icons.security;
      case WebErrorType.authentication:
        return Icons.lock_outline;
      case WebErrorType.browserCompatibility:
        return Icons.browser_not_supported;
      case WebErrorType.storage:
        return Icons.storage;
      case WebErrorType.general:
        return Icons.error_outline;
    }
  }

  Color _getErrorColor() {
    if (!error.isRecoverable) {
      return Colors.red;
    }
    return Colors.orange;
  }

  String _getErrorTitle() {
    switch (error.type) {
      case WebErrorType.network:
        return 'Connection Issue';
      case WebErrorType.cors:
        return 'Security Restriction';
      case WebErrorType.authentication:
        return 'Session Expired';
      case WebErrorType.browserCompatibility:
        return 'Browser Compatibility';
      case WebErrorType.storage:
        return 'Storage Issue';
      case WebErrorType.general:
        return 'Error Occurred';
    }
  }

  Widget _buildErrorDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Error Type: ${error.type.name}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontFamily: 'monospace',
            ),
          ),
          if (error.context != null) ...[
            const SizedBox(height: 4),
            Text(
              'Context: ${error.context}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecoverySuggestions(BuildContext context) {
    final suggestions = _getRecoverySuggestions();
    
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you can do:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        ...suggestions.map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  List<String> _getRecoverySuggestions() {
    switch (error.type) {
      case WebErrorType.network:
        return [
          'Check your internet connection',
          'Try refreshing the page',
          'Wait a moment and try again',
        ];
      case WebErrorType.authentication:
        return [
          'Log in again to continue',
          'Clear your browser cache',
          'Check if your session has expired',
        ];
      case WebErrorType.storage:
        return [
          'Clear browser data to free up space',
          'Try using a different browser',
          'Close other tabs to free up memory',
        ];
      case WebErrorType.browserCompatibility:
        return [
          'Update your browser to the latest version',
          'Try using Chrome, Firefox, or Safari',
          'Enable JavaScript in your browser',
        ];
      case WebErrorType.cors:
      case WebErrorType.general:
        return [
          'Refresh the page and try again',
          'Contact support if the issue persists',
        ];
    }
  }

  /// Show error dialog
  static Future<void> show(
    BuildContext context,
    WebError error, {
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: error.isRecoverable,
      builder: (context) => UserFriendlyErrorDialog(
        error: error,
        onRetry: onRetry,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Snackbar for quick error notifications
class ErrorSnackBar {
  static void show(
    BuildContext context,
    WebError error, {
    VoidCallback? onRetry,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getErrorIcon(error.type),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: error.isRecoverable ? Colors.orange.shade700 : Colors.red.shade700,
      duration: const Duration(seconds: 4),
      action: error.isRecoverable && onRetry != null
          ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static IconData _getErrorIcon(WebErrorType type) {
    switch (type) {
      case WebErrorType.network:
        return Icons.wifi_off;
      case WebErrorType.cors:
        return Icons.security;
      case WebErrorType.authentication:
        return Icons.lock_outline;
      case WebErrorType.browserCompatibility:
        return Icons.browser_not_supported;
      case WebErrorType.storage:
        return Icons.storage;
      case WebErrorType.general:
        return Icons.error_outline;
    }
  }
}
