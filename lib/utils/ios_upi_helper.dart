import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IOSUpiHelper {
  /// Test different UPI link formats for iOS compatibility
  static Future<void> testUpiLinkFormats({
    required BuildContext context,
    required String upiId,
    required String payeeName,
    required double amount,
    String? note,
  }) async {
    if (!Platform.isIOS) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This test is only for iOS devices')),
      );
      return;
    }

    final formats = [
      // Standard UPI format
      'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR${note != null ? '&tn=${Uri.encodeComponent(note)}' : ''}',

      // GPay specific format
      'gpay://upi/pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR',

      // PhonePe specific format
      'phonepe://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR',

      // Paytm specific format
      'paytmmp://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR',

      // BHIM specific format
      'bhim://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR',
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Test UPI Link Formats'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: formats.length,
                itemBuilder: (context, index) {
                  final format = formats[index];
                  final appName = _getAppNameFromFormat(format);

                  return ListTile(
                    title: Text(appName),
                    subtitle: Text(
                      format,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _testLaunchUrl(context, format),
                      child: const Text('Test'),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  static String _getAppNameFromFormat(String format) {
    if (format.startsWith('gpay://')) return 'Google Pay';
    if (format.startsWith('phonepe://')) return 'PhonePe';
    if (format.startsWith('paytmmp://')) return 'Paytm';
    if (format.startsWith('bhim://')) return 'BHIM';
    return 'Standard UPI';
  }

  static Future<void> _testLaunchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          _showResult(context, 'Failed to launch: $url', false);
        } else {
          _showResult(context, 'Successfully launched!', true);
        }
      } else {
        _showResult(
          context,
          'Cannot launch: App not installed or URL not supported',
          false,
        );
      }
    } catch (e) {
      _showResult(context, 'Error: $e', false);
    }
  }

  static void _showResult(BuildContext context, String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Generate iOS-optimized UPI message for WhatsApp
  static String generateIOSOptimizedMessage({
    required String customerName,
    required String upiId,
    required String payeeName,
    required double amount,
    String? note,
    String? businessName,
  }) {
    final business = businessName ?? 'Our Business';
    final transactionNote = note ?? 'Payment Request';

    return '''
Hello $customerName,

💳 Payment Request from $business

Amount: ₹${amount.toStringAsFixed(2)}
Note: $transactionNote

📱 Easy Payment Options:

Option 1 - UPI ID:
Copy this → $upiId
Open any UPI app and send money

Option 2 - UPI Apps:
• Google Pay: gpay://upi/pay?pa=$upiId&am=${amount.toStringAsFixed(2)}&pn=${Uri.encodeComponent(payeeName)}
• PhonePe: phonepe://pay?pa=$upiId&am=${amount.toStringAsFixed(2)}&pn=${Uri.encodeComponent(payeeName)}
• Paytm: paytmmp://pay?pa=$upiId&am=${amount.toStringAsFixed(2)}&pn=${Uri.encodeComponent(payeeName)}

Option 3 - Standard UPI:
upi://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR

Thank you! 🙏
- $business Team''';
  }

  /// Check which UPI apps are available on iOS
  static Future<List<String>> getAvailableUpiApps() async {
    if (!Platform.isIOS) return [];

    final apps = {
      'Google Pay': 'gpay://',
      'PhonePe': 'phonepe://',
      'Paytm': 'paytmmp://',
      'BHIM': 'bhim://',
      'Amazon Pay': 'amazonpay://',
    };

    final availableApps = <String>[];

    for (final entry in apps.entries) {
      try {
        final uri = Uri.parse(entry.value);
        if (await canLaunchUrl(uri)) {
          availableApps.add(entry.key);
        }
      } catch (e) {
        // App not available
      }
    }

    return availableApps;
  }
}
