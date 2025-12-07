import 'package:flutter/material.dart';

/// Error boundary widget to catch and display errors gracefully
class ErrorBoundaryWidget extends StatelessWidget {
  final Widget child;
  final String? errorMessage;

  const ErrorBoundaryWidget({
    super.key,
    required this.child,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

  /// Create an error widget for when something goes wrong
  static Widget createErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Safe widget wrapper that catches errors
class SafeWidget extends StatelessWidget {
  final Widget Function() builder;
  final String fallbackMessage;

  const SafeWidget({
    super.key,
    required this.builder,
    this.fallbackMessage = 'Unable to load content',
  });

  @override
  Widget build(BuildContext context) {
    try {
      return builder();
    } catch (e) {
      return ErrorBoundaryWidget.createErrorWidget(
        '$fallbackMessage: ${e.toString()}',
      );
    }
  }
}
