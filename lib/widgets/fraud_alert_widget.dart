import 'package:flutter/material.dart';
import '../models/ai_models.dart';
import '../utils/app_theme.dart';

class FraudAlertWidget extends StatelessWidget {
  final FraudAlert alert;
  final VoidCallback? onDismiss;
  final VoidCallback? onViewDetails;

  const FraudAlertWidget({
    super.key,
    required this.alert,
    this.onDismiss,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getAlertColor().withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getAlertIcon(), color: _getAlertColor(), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getAlertTitle(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onDismiss,
                    color: Colors.grey[600],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getAlertColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Confidence: ${(alert.confidenceScore * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _getAlertColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                if (onViewDetails != null)
                  TextButton(
                    onPressed: onViewDetails,
                    child: const Text('View Details'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor() {
    switch (alert.type) {
      case FraudType.duplicateInvoice:
      case FraudType.duplicateSupplierBill:
        return AppTheme.warningColor;
      case FraudType.paymentMismatch:
      case FraudType.suspiciousPattern:
        return AppTheme.errorColor;
    }
  }

  IconData _getAlertIcon() {
    switch (alert.type) {
      case FraudType.duplicateInvoice:
      case FraudType.duplicateSupplierBill:
        return Icons.content_copy;
      case FraudType.paymentMismatch:
        return Icons.error_outline;
      case FraudType.suspiciousPattern:
        return Icons.warning;
    }
  }

  String _getAlertTitle() {
    switch (alert.type) {
      case FraudType.duplicateInvoice:
        return 'Duplicate Invoice Detected';
      case FraudType.duplicateSupplierBill:
        return 'Duplicate Supplier Bill';
      case FraudType.paymentMismatch:
        return 'Payment Mismatch';
      case FraudType.suspiciousPattern:
        return 'Suspicious Pattern';
    }
  }
}

class FraudAlertBanner extends StatelessWidget {
  final List<FraudAlert> alerts;
  final VoidCallback? onViewAll;

  const FraudAlertBanner({super.key, required this.alerts, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final highPriorityAlerts =
        alerts.where((alert) => alert.confidenceScore >= 0.8).toList();

    if (highPriorityAlerts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: AppTheme.errorColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${highPriorityAlerts.length} Fraud Alert${highPriorityAlerts.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Potential fraud or errors detected in your transactions',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),
          if (onViewAll != null)
            TextButton(onPressed: onViewAll, child: const Text('View All')),
        ],
      ),
    );
  }
}

class FraudAlertDetailsDialog extends StatelessWidget {
  final FraudAlert alert;

  const FraudAlertDetailsDialog({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_getAlertIcon(), color: _getAlertColor()),
          const SizedBox(width: 8),
          Expanded(child: Text(_getAlertTitle())),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(alert.message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              'Confidence Score: ${(alert.confidenceScore * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            if (alert.evidence.isNotEmpty) ...[
              const Text(
                'Evidence:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...alert.evidence.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${entry.key}: ${entry.value}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),
            Text(
              'Detected: ${_formatDateTime(alert.detectedAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
    );
  }

  Color _getAlertColor() {
    switch (alert.type) {
      case FraudType.duplicateInvoice:
      case FraudType.duplicateSupplierBill:
        return AppTheme.warningColor;
      case FraudType.paymentMismatch:
      case FraudType.suspiciousPattern:
        return AppTheme.errorColor;
    }
  }

  IconData _getAlertIcon() {
    switch (alert.type) {
      case FraudType.duplicateInvoice:
      case FraudType.duplicateSupplierBill:
        return Icons.content_copy;
      case FraudType.paymentMismatch:
        return Icons.error_outline;
      case FraudType.suspiciousPattern:
        return Icons.warning;
    }
  }

  String _getAlertTitle() {
    switch (alert.type) {
      case FraudType.duplicateInvoice:
        return 'Duplicate Invoice Detected';
      case FraudType.duplicateSupplierBill:
        return 'Duplicate Supplier Bill';
      case FraudType.paymentMismatch:
        return 'Payment Mismatch';
      case FraudType.suspiciousPattern:
        return 'Suspicious Pattern';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
