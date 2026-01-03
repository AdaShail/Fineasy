import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Error boundary widget to catch and display errors gracefully
class ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final String? errorMessage;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final void Function(Object, StackTrace?)? onError;

  const ErrorBoundaryWidget({
    super.key,
    required this.child,
    this.errorMessage,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<ErrorBoundaryWidget> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    
    // Set up error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
      }
      
      widget.onError?.call(details.exception, details.stack);
      
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, _stackTrace);
      }
      return _createErrorWidget(
        widget.errorMessage ?? _error.toString(),
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }

    return widget.child;
  }

  /// Create an error widget for when something goes wrong
  Widget _createErrorWidget(String error, {VoidCallback? onRetry}) {
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
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
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
      return _createErrorWidget(
        '$fallbackMessage: ${e.toString()}',
      );
    }
  }

  /// Create an error widget for when something goes wrong
  Widget _createErrorWidget(String error) {
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
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
