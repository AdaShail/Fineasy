import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IOSUpiLinkService {
  /// Generate clickable UPI payment link for iOS
  static String generateClickableUpiLink({
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
    String? transactionRef,
  }) {
    final Map<String, String> params = {
      'pa': upiId, // Payee Address (UPI ID)
      'pn': payeeName, // Payee Name
      'am': amount.toStringAsFixed(2), // Amount
      'cu': 'INR', // Currency
    };

    if (transactionNote != null && transactionNote.isNotEmpty) {
      params['tn'] = transactionNote; // Transaction Note
    }

    if (transactionRef != null && transactionRef.isNotEmpty) {
      params['tr'] = transactionRef; // Transaction Reference
    }

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    if (Platform.isIOS) {
      // Method 1: Use UPI Intent URL (works better on iOS)
      return 'https://upi.link/?$queryString';

      // Alternative methods (uncomment to try):
      // Method 2: Use PhonePe's universal link
      // return 'https://phon.pe/ru_${base64Encode(utf8.encode('upi://pay?$queryString'))}';

      // Method 3: Use GPay's universal link
      // return 'https://pay.google.com/gp/p/ui/pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR';
    }

    // For Android, use standard UPI scheme
    return 'upi://pay?$queryString';
  }

  /// Generate multiple clickable UPI links for iOS
  static List<Map<String, String>> generateMultipleClickableLinks({
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
  }) {
    final encodedPayeeName = Uri.encodeComponent(payeeName);
    final encodedNote =
        transactionNote != null ? Uri.encodeComponent(transactionNote) : '';

    return [
      {
        'name': 'UPI Link (Universal)',
        'url':
            'https://upi.link/?pa=$upiId&pn=$encodedPayeeName&am=${amount.toStringAsFixed(2)}&cu=INR${transactionNote != null ? '&tn=$encodedNote' : ''}',
        'description': 'Works with most UPI apps',
      },
      {
        'name': 'Google Pay',
        'url':
            'https://pay.google.com/gp/p/ui/pay?pa=$upiId&pn=$encodedPayeeName&am=${amount.toStringAsFixed(2)}&cu=INR',
        'description': 'Direct Google Pay link',
      },
      {
        'name': 'PhonePe',
        'url':
            'phonepe://pay?pa=$upiId&pn=$encodedPayeeName&am=${amount.toStringAsFixed(2)}&cu=INR',
        'description': 'Direct PhonePe app link',
      },
      {
        'name': 'Paytm',
        'url':
            'paytmmp://pay?pa=$upiId&pn=$encodedPayeeName&am=${amount.toStringAsFixed(2)}&cu=INR',
        'description': 'Direct Paytm app link',
      },
      {
        'name': 'BHIM UPI',
        'url':
            'bhim://pay?pa=$upiId&pn=$encodedPayeeName&am=${amount.toStringAsFixed(2)}&cu=INR',
        'description': 'Direct BHIM app link',
      },
    ];
  }

  /// Create iOS-optimized WhatsApp message with clickable links
  static String createIOSOptimizedWhatsAppMessage({
    required String customerName,
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
    String? businessName,
  }) {
    final business = businessName ?? 'Our Business';
    final note = transactionNote ?? 'Payment Request';

    // Generate clickable UPI link
    final clickableLink = generateClickableUpiLink(
      upiId: upiId,
      payeeName: payeeName,
      amount: amount,
      transactionNote: transactionNote,
    );

    // Generate Google Pay direct link
    final gPayLink =
        'https://pay.google.com/gp/p/ui/pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR';

    return '''
Hello $customerName!

Payment Request from $business

Amount: ₹${amount.toStringAsFixed(2)}
Note: $note

CLICK TO PAY (Choose any option):

1. Universal UPI Link:
$clickableLink

2️⃣ Google Pay Direct:
$gPayLink

3️⃣ Manual Payment:
UPI ID: $upiId
(Copy and paste in any UPI app)

Instructions:
• Tap any link above to pay instantly
• Or copy the UPI ID and use any UPI app
• Amount will be auto-filled

Thank you for choosing $business!

---
Powered by $business
''';
  }

  /// Test if UPI link is clickable
  static Future<bool> testUpiLinkClickability(String upiLink) async {
    try {
      final uri = Uri.parse(upiLink);
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Launch UPI payment with fallback options
  static Future<bool> launchUpiPayment({
    required BuildContext context,
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
  }) async {
    if (Platform.isIOS) {
      // Try multiple methods for iOS
      final links = generateMultipleClickableLinks(
        upiId: upiId,
        payeeName: payeeName,
        amount: amount,
        transactionNote: transactionNote,
      );

      // Try each link until one works
      for (final linkData in links) {
        try {
          final uri = Uri.parse(linkData['url']!);
          if (await canLaunchUrl(uri)) {
            final success = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            if (success && context.mounted) {
              _showSuccessMessage(context, 'Opened ${linkData['name']}!');
              return true;
            }
          }
        } catch (e) {
          continue;
        }
      }

      // If no links work, show options dialog
      if (context.mounted) {
        _showPaymentOptionsDialog(context, links);
      }
      return false;
    } else {
      // For Android, use standard UPI link
      final standardLink =
          'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR${transactionNote != null ? '&tn=${Uri.encodeComponent(transactionNote)}' : ''}';

      try {
        final uri = Uri.parse(standardLink);
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorMessage(context, 'No UPI apps found');
        }
      }
      return false;
    }
  }

  /// Show payment options dialog for iOS
  static void _showPaymentOptionsDialog(
    BuildContext context,
    List<Map<String, String>> links,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Payment Method'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: links.length,
                itemBuilder: (context, index) {
                  final link = links[index];
                  return ListTile(
                    title: Text(link['name']!),
                    subtitle: Text(link['description']!),
                    trailing: const Icon(Icons.launch),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        final uri = Uri.parse(link['url']!);
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          _showErrorMessage(
                            context,
                            'Could not open ${link['name']}',
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  /// Show success message
  static void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Show error message
  static void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Generate QR code friendly UPI string
  static String generateQRCodeUpiString({
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
  }) {
    return 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR${transactionNote != null ? '&tn=${Uri.encodeComponent(transactionNote)}' : ''}';
  }

  /// Create a shortened URL for UPI payment (requires backend service)
  static Future<String?> createShortenedUpiLink({
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
  }) async {
    // This would require a backend service to create shortened URLs
    // For now, return the universal UPI link
    return generateClickableUpiLink(
      upiId: upiId,
      payeeName: payeeName,
      amount: amount,
      transactionNote: transactionNote,
    );
  }
}
