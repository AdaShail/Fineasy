import 'package:flutter/material.dart';
import 'web_error_handler.dart';
import 'network_connectivity_service.dart';
import 'browser_compatibility_service.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/browser_compatibility_banner.dart';
import '../widgets/user_friendly_error_dialog.dart';
import '../../widgets/error_boundary_widget.dart';

/// Example demonstrating web error handling integration
class WebErrorHandlingExample extends StatefulWidget {
  const WebErrorHandlingExample({super.key});

  @override
  State<WebErrorHandlingExample> createState() => _WebErrorHandlingExampleState();
}

class _WebErrorHandlingExampleState extends State<WebErrorHandlingExample> {
  final _errorHandler = WebErrorHandler();
  final _connectivityService = NetworkConnectivityService();
  final _compatibilityService = BrowserCompatibilityService();

  @override
  void initState() {
    super.initState();
    _setupErrorHandling();
    _checkBrowserCompatibility();
  }

  void _setupErrorHandling() {
    // Listen to all errors
    _errorHandler.errorStream.listen((error) {
      if (mounted) {
        _handleError(error);
      }
    });

    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((isOnline) {
      if (mounted) {
        _handleConnectivityChange(isOnline);
      }
    });
  }

  void _checkBrowserCompatibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_compatibilityService.isSupported) {
        _showBrowserWarning();
      }
    });
  }

  void _handleError(WebError error) {
    // Show appropriate error UI based on error type
    if (error.type == WebErrorType.authentication) {
      // Redirect to login
      _showAuthenticationError(error);
    } else if (error.isRecoverable) {
      // Show snackbar with retry option
      ErrorSnackBar.show(context, error, onRetry: () {
        _retryOperation(error);
      });
    } else {
      // Show dialog for non-recoverable errors
      UserFriendlyErrorDialog.show(context, error);
    }
  }

  void _handleConnectivityChange(bool isOnline) {
    if (isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.cloud_done, color: Colors.white),
              SizedBox(width: 12),
              Text('Connection restored'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      _syncOfflineData();
    }
  }

  void _showAuthenticationError(WebError error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.orange),
            SizedBox(width: 12),
            Text('Session Expired'),
          ],
        ),
        content: const Text(
          'Your session has expired. Please log in again to continue.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLogin();
            },
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }

  void _showBrowserWarning() {
    final unsupportedFeatures = _compatibilityService.unsupportedFeatures;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Browser Compatibility'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your browser (${_compatibilityService.browserInfo}) may not support all features:',
            ),
            const SizedBox(height: 12),
            ...unsupportedFeatures.map((feature) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text('• $feature'),
            )),
            const SizedBox(height: 12),
            const Text(
              'For the best experience, please use Chrome 90+, Firefox 88+, or Safari 14+.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Anyway'),
          ),
        ],
      ),
    );
  }

  void _retryOperation(WebError error) {
    // Implement retry logic based on error context
  }

  void _syncOfflineData() {
    // Sync any queued offline operations
  }

  void _navigateToLogin() {
    // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    return BrowserCompatibilityBanner(
      child: OfflineIndicator(
        child: ErrorBoundaryWidget(
          onError: (error, stackTrace) {
            _errorHandler.handleError(
              error,
              stackTrace,
              context: 'WebErrorHandlingExample',
            );
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Web Error Handling Demo'),
              actions: [
                CompactOfflineIndicator(),
                const SizedBox(width: 8),
                BrowserCompatibilityIndicator(),
                const SizedBox(width: 16),
              ],
            ),
            body: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connection Status
          ConnectionStatusWidget(),
          const SizedBox(height: 16),

          // Browser Info
          _buildBrowserInfoCard(),
          const SizedBox(height: 16),

          // Error Testing Buttons
          _buildErrorTestingSection(),
          const SizedBox(height: 16),

          // Error Log
          _buildErrorLogSection(),
        ],
      ),
    );
  }

  Widget _buildBrowserInfoCard() {
    final browserInfo = _compatibilityService.browserInfo;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browser Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (browserInfo != null) ...[
              _buildInfoRow('Browser', browserInfo.displayName),
              _buildInfoRow('Version', browserInfo.version),
              _buildInfoRow('Supported', _compatibilityService.isSupported ? 'Yes' : 'No'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTestingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Error Handling',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _testError(WebErrorType.network),
                  child: const Text('Network Error'),
                ),
                ElevatedButton(
                  onPressed: () => _testError(WebErrorType.authentication),
                  child: const Text('Auth Error'),
                ),
                ElevatedButton(
                  onPressed: () => _testError(WebErrorType.storage),
                  child: const Text('Storage Error'),
                ),
                ElevatedButton(
                  onPressed: () => _testError(WebErrorType.cors),
                  child: const Text('CORS Error'),
                ),
                ElevatedButton(
                  onPressed: () => _testError(WebErrorType.browserCompatibility),
                  child: const Text('Browser Error'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _testError(WebErrorType type) {
    final error = WebError(
      type: type,
      message: _errorHandler.getUserFriendlyMessage(type),
      context: 'Test error',
      isRecoverable: type != WebErrorType.cors && type != WebErrorType.browserCompatibility,
    );

    _errorHandler.handleError(error.originalError ?? error.message, null, context: error.context);
  }

  Widget _buildErrorLogSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error Log',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<WebError>(
              stream: _errorHandler.errorStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('No errors logged yet');
                }

                final error = snapshot.data!;
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
                        'Type: ${error.type.name}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text('Message: ${error.message}'),
                      const SizedBox(height: 4),
                      Text('Time: ${error.timestamp}'),
                      if (error.context != null) ...[
                        const SizedBox(height: 4),
                        Text('Context: ${error.context}'),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _errorHandler.dispose();
    _connectivityService.dispose();
    super.dispose();
  }
}
