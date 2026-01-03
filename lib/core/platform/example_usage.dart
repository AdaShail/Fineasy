import 'package:flutter/material.dart';
import 'platform.dart';

/// Example screen demonstrating platform service usage
/// 
/// This is a reference implementation showing how to use the
/// platform abstraction layer in your application.
class PlatformServiceExample extends StatefulWidget {
  const PlatformServiceExample({super.key});

  @override
  State<PlatformServiceExample> createState() => _PlatformServiceExampleState();
}

class _PlatformServiceExampleState extends State<PlatformServiceExample> {
  final _platformService = PlatformServiceFactory.instance;
  String _statusMessage = '';

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
  }

  Future<void> _testShareContent() async {
    try {
      await _platformService.shareContent(
        'Check out FinEasy - The best financial management app!',
        subject: 'FinEasy App',
      );
      _updateStatus('Content shared successfully');
    } catch (e) {
      _updateStatus('Error sharing: $e');
    }
  }

  Future<void> _testCopyToClipboard() async {
    try {
      await _platformService.copyToClipboard('Hello from FinEasy!');
      _updateStatus('Text copied to clipboard');
    } catch (e) {
      _updateStatus('Error copying: $e');
    }
  }

  Future<void> _testOpenUrl() async {
    try {
      await _platformService.openUrl('https://flutter.dev');
      _updateStatus('URL opened');
    } catch (e) {
      _updateStatus('Error opening URL: $e');
    }
  }

  Future<void> _testConnectivity() async {
    try {
      final hasConnection = await _platformService.hasInternetConnection();
      _updateStatus('Internet connection: ${hasConnection ? "Available" : "Not available"}');
    } catch (e) {
      _updateStatus('Error checking connectivity: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = PlatformDetector.getDeviceType(screenWidth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Service Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Platform Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Is Web: ${PlatformDetector.isWeb}'),
                    Text('Is Mobile: ${PlatformDetector.isMobile}'),
                    Text('Device Type: ${deviceType.name}'),
                    Text('Screen Width: ${screenWidth.toStringAsFixed(0)}px'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Feature Availability
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feature Availability',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureRow('Native Share', PlatformFeature.nativeShare),
                    _buildFeatureRow('Clipboard', PlatformFeature.clipboard),
                    _buildFeatureRow('File System', PlatformFeature.fileSystem),
                    _buildFeatureRow('Service Worker', PlatformFeature.serviceWorker),
                    _buildFeatureRow('Local Storage', PlatformFeature.localStorage),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Test Platform Features',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _testShareContent,
                      icon: const Icon(Icons.share),
                      label: const Text('Share Content'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _testCopyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy to Clipboard'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _testOpenUrl,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open URL'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _testConnectivity,
                      icon: const Icon(Icons.wifi),
                      label: const Text('Check Connectivity'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String label, PlatformFeature feature) {
    final isAvailable = _platformService.isFeatureAvailable(feature);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
