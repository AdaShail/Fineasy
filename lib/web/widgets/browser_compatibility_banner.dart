import 'package:flutter/material.dart';
import '../services/browser_compatibility_service.dart';

/// Banner that displays browser compatibility warnings
class BrowserCompatibilityBanner extends StatefulWidget {
  final Widget child;
  final bool showWarning;

  const BrowserCompatibilityBanner({
    super.key,
    required this.child,
    this.showWarning = true,
  });

  @override
  State<BrowserCompatibilityBanner> createState() => _BrowserCompatibilityBannerState();
}

class _BrowserCompatibilityBannerState extends State<BrowserCompatibilityBanner> {
  final _compatibilityService = BrowserCompatibilityService();
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.showWarning || _dismissed) {
      return widget.child;
    }

    final browserInfo = _compatibilityService.browserInfo;
    final unsupportedFeatures = _compatibilityService.unsupportedFeatures;

    if (browserInfo == null || unsupportedFeatures.isEmpty) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildWarningBanner(context, browserInfo, unsupportedFeatures),
        ),
      ],
    );
  }

  Widget _buildWarningBanner(
    BuildContext context,
    BrowserInfo browserInfo,
    List<String> unsupportedFeatures,
  ) {
    return Material(
      color: Colors.orange.shade700,
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Browser Compatibility Warning',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _dismissed = true;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your browser ($browserInfo) may not support all features:',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...unsupportedFeatures.map((feature) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Colors.white,
                      size: 6,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  _showRecommendedBrowsersDialog(context);
                },
                icon: const Icon(Icons.info_outline, color: Colors.white),
                label: const Text(
                  'View Recommended Browsers',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecommendedBrowsersDialog(BuildContext context) {
    final recommendedBrowsers = _compatibilityService.getRecommendedBrowsers();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recommended Browsers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'For the best experience, please use one of these browsers:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ...recommendedBrowsers.map((browser) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      browser,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Compact browser compatibility indicator
class BrowserCompatibilityIndicator extends StatelessWidget {
  final BrowserCompatibilityService _compatibilityService = BrowserCompatibilityService();

  BrowserCompatibilityIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final unsupportedFeatures = _compatibilityService.unsupportedFeatures;

    if (unsupportedFeatures.isEmpty) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: 'Some features may not work in your browser',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              'Limited Support',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
