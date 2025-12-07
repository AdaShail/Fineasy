import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feature_flag_provider.dart';

/// Debug widget for viewing feature flag states (development only)
class FeatureFlagDebugWidget extends StatefulWidget {
  const FeatureFlagDebugWidget({Key? key}) : super(key: key);

  @override
  State<FeatureFlagDebugWidget> createState() => _FeatureFlagDebugWidgetState();
}

class _FeatureFlagDebugWidgetState extends State<FeatureFlagDebugWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    assert(() {
      return true;
    }());

    return Consumer<FeatureFlagProvider>(
      builder: (context, provider, child) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(
                  Icons.flag,
                  color: provider.isLoading ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                const Text('Feature Flags'),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              '${provider.enabledFeatures.length} features enabled',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            children: [
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              _buildFeatureFlagsList(provider),
              _buildActionButtons(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureFlagsList(FeatureFlagProvider provider) {
    final features = [
      'fraud_detection',
      'predictive_insights',
      'compliance_checking',
      'nlp_invoice_generation',
      'smart_notifications',
      'ml_analytics_engine',
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature States',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => _buildFeatureRow(feature, provider)),
          const SizedBox(height: 16),
          if (provider.featuresWithVariants.isNotEmpty) ...[
            Text(
              'A/B Test Variants',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...provider.featuresWithVariants.entries.map(
              (entry) => _buildVariantRow(entry.key, entry.value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, FeatureFlagProvider provider) {
    final isEnabled = provider.isFeatureEnabled(feature);
    final variant = provider.getFeatureVariant(feature);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEnabled ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _formatFeatureName(feature),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (variant != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getVariantColor(variant).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getVariantColor(variant)),
              ),
              child: Text(
                variant,
                style: TextStyle(
                  fontSize: 12,
                  color: _getVariantColor(variant),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isEnabled ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildVariantRow(String feature, String variant) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Icon(Icons.science, size: 16, color: _getVariantColor(variant)),
          const SizedBox(width: 8),
          Text(
            _formatFeatureName(feature),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: _getVariantColor(variant).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              variant,
              style: TextStyle(
                fontSize: 11,
                color: _getVariantColor(variant),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(FeatureFlagProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: provider.isLoading ? null : () => provider.refresh(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: provider.isLoading ? null : () => provider.clearCache(),
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Clear Cache'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _showDebugInfo(provider),
            child: const Text('Debug Info'),
          ),
        ],
      ),
    );
  }

  String _formatFeatureName(String feature) {
    return feature
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Color _getVariantColor(String variant) {
    switch (variant.toLowerCase()) {
      case 'control':
        return Colors.blue;
      case 'variant_a':
        return Colors.orange;
      case 'variant_b':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showDebugInfo(FeatureFlagProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Feature Flag Debug Info'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Debug Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...provider.debugInfo.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              '${entry.key}:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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

/// Simplified feature flag indicator for production use
class FeatureFlagIndicator extends StatelessWidget {
  final String featureName;
  final Widget child;
  final Widget? fallback;

  const FeatureFlagIndicator({
    Key? key,
    required this.featureName,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FeatureFlagProvider>(
      builder: (context, provider, _) {
        final isEnabled = provider.isFeatureEnabled(featureName);

        if (isEnabled) {
          // Track view automatically
          provider.trackInteraction(featureName, interactionType: 'view');
          return child;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// A/B test variant widget
class ABTestVariantWidget extends StatelessWidget {
  final String featureName;
  final Widget controlWidget;
  final Widget? variantAWidget;
  final Widget? variantBWidget;
  final Widget? fallback;

  const ABTestVariantWidget({
    Key? key,
    required this.featureName,
    required this.controlWidget,
    this.variantAWidget,
    this.variantBWidget,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FeatureFlagProvider>(
      builder: (context, provider, _) {
        final isEnabled = provider.isFeatureEnabled(featureName);

        if (!isEnabled) {
          return fallback ?? const SizedBox.shrink();
        }

        final variant = provider.getFeatureVariant(featureName);

        // Track view automatically
        provider.trackInteraction(featureName, interactionType: 'ab_test_view');

        switch (variant) {
          case 'variant_a':
            return variantAWidget ?? controlWidget;
          case 'variant_b':
            return variantBWidget ?? controlWidget;
          default:
            return controlWidget;
        }
      },
    );
  }
}
