import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'upi_service.dart';
import 'whatsapp_launcher_service.dart';
import '../utils/ios_upi_helper.dart';
import 'ios_upi_link_service.dart';

class PaymentUrlService {
  // UPI transaction limits
  static const double maxUpiAmount = 100000.0; // ₹1,00,000
  static const double warningUpiAmount = 50000.0; // ₹50,000

  /// Validate UPI payment amount
  static PaymentValidationResult validatePaymentAmount(double amount) {
    if (amount <= 0) {
      return PaymentValidationResult(
        isValid: false,
        message: 'Amount must be greater than zero',
      );
    }

    if (amount > maxUpiAmount) {
      return PaymentValidationResult(
        isValid: false,
        message: 'Amount exceeds UPI limit of ₹${maxUpiAmount.toStringAsFixed(0)}. Please use bank transfer or split into multiple payments.',
      );
    }

    if (amount > warningUpiAmount) {
      return PaymentValidationResult(
        isValid: true,
        isWarning: true,
        message: 'Large amount (₹${amount.toStringAsFixed(2)}). Some UPI apps may have lower limits.',
      );
    }

    return PaymentValidationResult(isValid: true);
  }

  /// Generate and share payment URL via WhatsApp
  static Future<bool> sharePaymentViaWhatsApp({
    required BuildContext context,
    required String phoneNumber,
    required String customerName,
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
    String? businessName,
  }) async {
    try {
      // Validate amount
      final validation = validatePaymentAmount(amount);
      if (!validation.isValid) {
        _showErrorSnackbar(context, validation.message);
        return false;
      }

      // Show warning for large amounts
      if (validation.isWarning) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Large Amount Warning'),
            content: Text(validation.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Proceed Anyway'),
              ),
            ],
          ),
        );

        if (proceed != true) return false;
      }

      // Validate and sanitize UPI ID
      if (!UpiService.isValidUpiId(upiId)) {
        _showErrorSnackbar(context, 'Invalid UPI ID format');
        return false;
      }

      // Sanitize transaction note (remove special characters that might break UPI link)
      final sanitizedNote = _sanitizeTransactionNote(transactionNote);

      // Generate UPI payment link
      final upiLink = UpiService.generateUpiLink(
        upiId: upiId,
        payeeName: payeeName,
        amount: amount,
        transactionNote: sanitizedNote,
      );

      // Create WhatsApp message with payment request
      final message =
          Platform.isIOS
              ? IOSUpiLinkService.createIOSOptimizedWhatsAppMessage(
                customerName: customerName,
                upiId: upiId,
                payeeName: payeeName,
                amount: amount,
                transactionNote: transactionNote,
                businessName: businessName,
              )
              : _buildPaymentRequestMessage(
                customerName: customerName,
                amount: amount,
                upiLink: upiLink,
                transactionNote: transactionNote,
                businessName: businessName,
              );

      // Send via WhatsApp with user feedback
      return await WhatsAppLauncherService.sendMessageWithFeedback(
        context: context,
        phoneNumber: phoneNumber,
        message: message,
        successMessage: 'Payment request sent via WhatsApp!',
      );
    } catch (e) {
      _showErrorSnackbar(context, 'Error sharing payment: $e');
      return false;
    }
  }

  /// Generate payment URL and copy to clipboard
  static Future<void> copyPaymentUrlToClipboard({
    required BuildContext context,
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
  }) async {
    try {
      final upiLink = UpiService.generateUpiLink(
        upiId: upiId,
        payeeName: payeeName,
        amount: amount,
        transactionNote: transactionNote,
      );

      await Clipboard.setData(ClipboardData(text: upiLink));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.copy, color: Colors.white),
              SizedBox(width: 8),
              Text('Payment URL copied to clipboard!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      _showErrorSnackbar(context, 'Error copying URL: $e');
    }
  }

  /// Generate QR code data for payment
  static String generatePaymentQrData({
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
  }) {
    return UpiService.generateQrCodeData(
      upiId: upiId,
      payeeName: payeeName,
      amount: amount,
      transactionNote: transactionNote,
    );
  }

  /// Share payment request with multiple options
  static Future<void> showPaymentShareOptions({
    required BuildContext context,
    required String customerName,
    required String phoneNumber,
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
    String? businessName,
  }) async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share Payment Request',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),

                // Payment details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: $customerName'),
                      Text('Amount: ₹${amount.toStringAsFixed(2)}'),
                      if (transactionNote != null)
                        Text('Note: $transactionNote'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Share options
                ListTile(
                  leading: const Icon(Icons.payment, color: Colors.blue),
                  title: const Text('Pay Now (Direct)'),
                  subtitle: const Text('Open UPI app directly'),
                  onTap: () async {
                    Navigator.pop(context);
                    await IOSUpiLinkService.launchUpiPayment(
                      context: context,
                      upiId: upiId,
                      payeeName: payeeName,
                      amount: amount,
                      transactionNote: transactionNote,
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.message, color: Colors.green),
                  title: const Text('Send via WhatsApp'),
                  subtitle: const Text('Send payment link directly'),
                  onTap: () async {
                    Navigator.pop(context);
                    await sharePaymentViaWhatsApp(
                      context: context,
                      phoneNumber: phoneNumber,
                      customerName: customerName,
                      upiId: upiId,
                      payeeName: payeeName,
                      amount: amount,
                      transactionNote: transactionNote,
                      businessName: businessName,
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.copy, color: Colors.blue),
                  title: const Text('Copy Payment URL'),
                  subtitle: const Text('Copy UPI link to clipboard'),
                  onTap: () async {
                    Navigator.pop(context);
                    await copyPaymentUrlToClipboard(
                      context: context,
                      upiId: upiId,
                      payeeName: payeeName,
                      amount: amount,
                      transactionNote: transactionNote,
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.qr_code, color: Colors.purple),
                  title: const Text('Show QR Code'),
                  subtitle: const Text('Generate QR code for payment'),
                  onTap: () {
                    Navigator.pop(context);
                    _showQrCodeDialog(
                      context: context,
                      upiId: upiId,
                      payeeName: payeeName,
                      amount: amount,
                      transactionNote: transactionNote,
                    );
                  },
                ),

                // iOS UPI Link Tester (only show on iOS)
                if (Platform.isIOS)
                  ListTile(
                    leading: const Icon(Icons.bug_report, color: Colors.orange),
                    title: const Text('Test UPI Links (iOS)'),
                    subtitle: const Text('Debug UPI link compatibility'),
                    onTap: () {
                      Navigator.pop(context);
                      IOSUpiHelper.testUpiLinkFormats(
                        context: context,
                        upiId: upiId,
                        payeeName: payeeName,
                        amount: amount,
                        note: transactionNote,
                      );
                    },
                  ),

                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  /// Build payment request message for WhatsApp
  static String _buildPaymentRequestMessage({
    required String customerName,
    required double amount,
    required String upiLink,
    String? transactionNote,
    String? businessName,
  }) {
    final business = businessName ?? 'Our Business';
    final note =
        transactionNote != null && transactionNote.isNotEmpty
            ? '\n📝 Note: $transactionNote'
            : '';

    // For iOS, create a more detailed message since UPI links might not be clickable
    if (Platform.isIOS) {
      // Extract UPI ID from the link for iOS users
      final upiIdMatch = RegExp(r'pa=([^&]+)').firstMatch(upiLink);
      final upiId = upiIdMatch?.group(1) ?? '';

      return '''
Hello $customerName,

Payment Request from $business:

💰 Amount: ₹${amount.toStringAsFixed(2)}$note

💳 UPI Payment Options:

Option 1 - Copy UPI ID:
$upiId

Option 2 - Click UPI Link:
$upiLink

Steps to pay:
1. Open any UPI app (GPay, PhonePe, Paytm)
2. Send money using UPI ID above
3. Enter amount: ₹${amount.toStringAsFixed(2)}

Thank you for your business! 🙏

- $business Team''';
    }

    // For Android, use the simpler format
    return '''
Hello $customerName,

Payment Request from $business:

💰 Amount: ₹${amount.toStringAsFixed(2)}$note

Click the link below to pay instantly:
$upiLink

Or scan the QR code when you meet us.

Thank you for your business! 🙏

- $business Team''';
  }

  /// Show QR code dialog
  static void _showQrCodeDialog({
    required BuildContext context,
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
  }) {
    final qrData = generatePaymentQrData(
      upiId: upiId,
      payeeName: payeeName,
      amount: amount,
      transactionNote: transactionNote,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment QR Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TODO: Add QR code widget here
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code, size: 64, color: Colors.grey),
                        Text('QR Code'),
                        Text(
                          '(Install QR package)',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Amount: ₹${amount.toStringAsFixed(2)}'),
                Text('Payee: $payeeName'),
                const SizedBox(height: 8),
                const Text(
                  'Customer can scan this QR code with any UPI app to pay',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: qrData));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR data copied to clipboard'),
                    ),
                  );
                },
                child: const Text('Copy Data'),
              ),
            ],
          ),
    );
  }

  /// Show error snackbar
  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Sanitize transaction note to prevent UPI link issues
  static String? _sanitizeTransactionNote(String? note) {
    if (note == null || note.isEmpty) return null;
    
    // Remove special characters that might break UPI links
    // Keep only alphanumeric, spaces, and basic punctuation
    return note
        .replaceAll(RegExp(r'[^\w\s\-.,]'), '')
        .trim()
        .substring(0, note.length > 50 ? 50 : note.length); // Limit length
  }

  /// Validate payment details
  static bool validatePaymentDetails({
    required String upiId,
    required double amount,
    required String customerName,
  }) {
    if (!UpiService.isValidUpiId(upiId)) {
      return false;
    }

    final validation = validatePaymentAmount(amount);
    if (!validation.isValid) {
      return false;
    }

    if (customerName.trim().isEmpty) {
      return false;
    }

    return true;
  }

  /// Get suggested payment methods based on amount
  static List<String> getSuggestedPaymentMethods(double amount) {
    if (amount <= maxUpiAmount) {
      return ['UPI', 'Bank Transfer', 'Cash', 'Cheque'];
    } else {
      return ['Bank Transfer', 'Cheque', 'NEFT/RTGS'];
    }
  }

  /// Show validation error
  static void showValidationError(BuildContext context, String field) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter a valid $field'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

/// Payment validation result
class PaymentValidationResult {
  final bool isValid;
  final bool isWarning;
  final String message;

  PaymentValidationResult({
    required this.isValid,
    this.isWarning = false,
    this.message = '',
  });
}
