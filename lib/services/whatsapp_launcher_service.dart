import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class WhatsAppLauncherService {
  /// Launch WhatsApp with a pre-filled message
  static Future<bool> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final formattedNumber = _formatPhoneNumber(phoneNumber);
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = 'https://wa.me/$formattedNumber?text=$encodedMessage';

      final uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch WhatsApp URL: $whatsappUrl');
        return false;
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
      return false;
    }
  }

  /// Send invoice via WhatsApp
  static Future<bool> sendInvoice({
    required String phoneNumber,
    required String customerName,
    required String invoiceNumber,
    required double amount,
    String? businessName,
  }) async {
    final message = _buildInvoiceMessage(
      customerName: customerName,
      invoiceNumber: invoiceNumber,
      amount: amount,
      businessName: businessName,
    );

    return await sendMessage(phoneNumber: phoneNumber, message: message);
  }

  /// Send invoice with payment link and reminder (consolidated message)
  static Future<bool> sendInvoiceWithPaymentLink({
    required String phoneNumber,
    required String customerName,
    required String invoiceNumber,
    required double amount,
    DateTime? dueDate,
    String? paymentLink,
    String? businessName,
  }) async {
    final message = _buildConsolidatedInvoiceMessage(
      customerName: customerName,
      invoiceNumber: invoiceNumber,
      amount: amount,
      dueDate: dueDate,
      paymentLink: paymentLink,
      businessName: businessName,
    );

    return await sendMessage(phoneNumber: phoneNumber, message: message);
  }

  /// Send payment reminder via WhatsApp
  static Future<bool> sendPaymentReminder({
    required String phoneNumber,
    required String customerName,
    required String invoiceNumber,
    required double amount,
    DateTime? dueDate,
    String? businessName,
  }) async {
    final message = _buildPaymentReminderMessage(
      customerName: customerName,
      invoiceNumber: invoiceNumber,
      amount: amount,
      dueDate: dueDate,
      businessName: businessName,
    );

    return await sendMessage(phoneNumber: phoneNumber, message: message);
  }

  /// Send payment confirmation via WhatsApp
  static Future<bool> sendPaymentConfirmation({
    required String phoneNumber,
    required String customerName,
    required double amount,
    required String transactionId,
    String? businessName,
  }) async {
    final message = _buildPaymentConfirmationMessage(
      customerName: customerName,
      amount: amount,
      transactionId: transactionId,
      businessName: businessName,
    );

    return await sendMessage(phoneNumber: phoneNumber, message: message);
  }

  /// Send custom message via WhatsApp
  static Future<bool> sendCustomMessage({
    required String phoneNumber,
    required String message,
  }) async {
    return await sendMessage(phoneNumber: phoneNumber, message: message);
  }

  /// Check if WhatsApp is installed
  static Future<bool> isWhatsAppInstalled() async {
    try {
      // Try to launch WhatsApp with a minimal URL
      final uri = Uri.parse('https://wa.me/');
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Show WhatsApp not installed dialog
  static void showWhatsAppNotInstalledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('WhatsApp Not Found'),
              ],
            ),
            content: const Text(
              'WhatsApp is not installed on this device. Please install WhatsApp to send messages.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openWhatsAppStore();
                },
                child: const Text('Install WhatsApp'),
              ),
            ],
          ),
    );
  }

  /// Open WhatsApp in app store
  static Future<void> _openWhatsAppStore() async {
    try {
      // Try Play Store first (Android)
      const playStoreUrl =
          'https://play.google.com/store/apps/details?id=com.whatsapp';
      final playStoreUri = Uri.parse(playStoreUrl);

      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Try App Store (iOS)
      const appStoreUrl =
          'https://apps.apple.com/app/whatsapp-messenger/id310633997';
      final appStoreUri = Uri.parse(appStoreUrl);

      if (await canLaunchUrl(appStoreUri)) {
        await launchUrl(appStoreUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to web
      const webUrl = 'https://www.whatsapp.com/download';
      final webUri = Uri.parse(webUrl);
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error opening WhatsApp store: $e');
    }
  }

  /// Format phone number for WhatsApp
  static String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Add country code if not present (assuming India +91)
    if (cleaned.length == 10) {
      cleaned = '91$cleaned';
    } else if (cleaned.startsWith('0')) {
      cleaned = '91${cleaned.substring(1)}';
    } else if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    return cleaned;
  }

  /// Build invoice message
  static String _buildInvoiceMessage({
    required String customerName,
    required String invoiceNumber,
    required double amount,
    String? businessName,
  }) {
    final business = businessName ?? 'Our Business';

    return '''
Hello $customerName,

Your invoice from $business is ready:

Invoice: $invoiceNumber
Amount: ₹${amount.toStringAsFixed(2)}

Please review and make payment as per the terms mentioned.

Thank you for your business!

- $business Team''';
  }

  /// Build payment reminder message
  static String _buildPaymentReminderMessage({
    required String customerName,
    required String invoiceNumber,
    required double amount,
    DateTime? dueDate,
    String? businessName,
  }) {
    final business = businessName ?? 'Our Business';
    final dueDateStr =
        dueDate != null
            ? 'due on ${dueDate.day}/${dueDate.month}/${dueDate.year}'
            : 'overdue';

    return '''
Hello $customerName,

This is a friendly reminder regarding your pending payment:

Invoice: $invoiceNumber
Amount: ₹${amount.toStringAsFixed(2)}
Status: $dueDateStr

Please make the payment at your earliest convenience. If you have already made the payment, please ignore this message.

For any queries, feel free to contact us.

Thank you!

- $business Team''';
  }

  /// Build payment confirmation message
  static String _buildPaymentConfirmationMessage({
    required String customerName,
    required double amount,
    required String transactionId,
    String? businessName,
  }) {
    final business = businessName ?? 'Our Business';

    return '''
Hello $customerName,

Thank you for your payment!

Amount: ₹${amount.toStringAsFixed(2)}
Transaction ID: $transactionId
Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

Your payment has been successfully processed and recorded in our system.

Thank you for your business!

- $business Team''';
  }

  /// Build consolidated invoice message with payment link and reminder
  static String _buildConsolidatedInvoiceMessage({
    required String customerName,
    required String invoiceNumber,
    required double amount,
    DateTime? dueDate,
    String? paymentLink,
    String? businessName,
  }) {
    final business = businessName ?? 'Our Business';
    final dueDateStr =
        dueDate != null
            ? '${dueDate.day}/${dueDate.month}/${dueDate.year}'
            : 'upon receipt';

    return '''
Hello $customerName,

📄 INVOICE DETAILS
━━━━━━━━━━━━━━━━
Invoice: $invoiceNumber
Amount: ₹${amount.toStringAsFixed(2)}
Due Date: $dueDateStr

${paymentLink != null ? '💳 PAY NOW:\n$paymentLink\n\n' : ''}📱 PAYMENT OPTIONS:
• UPI/GPay/PhonePe
• Bank Transfer
• Cash

⚠️ REMINDER:
Please make payment by the due date to avoid late fees.

For any queries, contact us.

Thank you!
- $business Team''';
  }

  /// Send message with error handling and user feedback
  static Future<bool> sendMessageWithFeedback({
    required BuildContext context,
    required String phoneNumber,
    required String message,
    String? successMessage,
  }) async {
    try {
      // Check if WhatsApp is available
      if (!await isWhatsAppInstalled()) {
        showWhatsAppNotInstalledDialog(context);
        return false;
      }

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Opening WhatsApp...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Send message
      final success = await sendMessage(
        phoneNumber: phoneNumber,
        message: message,
      );

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(successMessage ?? 'WhatsApp opened successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to open WhatsApp'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }

      return success;
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Error: $e'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
