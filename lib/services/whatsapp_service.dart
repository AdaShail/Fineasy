import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/customer_model.dart';
import 'whatsapp_launcher_service.dart';

class WhatsAppService {
  static String get _baseUrl => ApiConfig.baseUrl;

  /// Send WhatsApp message for receivables
  static Future<bool> sendReceivableReminder({
    required CustomerModel customer,
    required double amount,
    required String invoiceNumber,
    DateTime? dueDate,
  }) async {
    try {
      // Use direct WhatsApp launcher instead of API
      return await WhatsAppLauncherService.sendPaymentReminder(
        phoneNumber: customer.phone ?? '',
        customerName: customer.name,
        invoiceNumber: invoiceNumber,
        amount: amount,
        dueDate: dueDate,
      );
    } catch (e) {
      print('Error sending receivable reminder: $e');
      return false;
    }
  }

  /// Send WhatsApp message for payment confirmation
  static Future<bool> sendPaymentConfirmation({
    required CustomerModel customer,
    required double amount,
    required String transactionId,
    required DateTime paymentDate,
  }) async {
    try {
      // Use direct WhatsApp launcher instead of API
      return await WhatsAppLauncherService.sendPaymentConfirmation(
        phoneNumber: customer.phone ?? '',
        customerName: customer.name,
        amount: amount,
        transactionId: transactionId,
      );
    } catch (e) {
      print('Error sending payment confirmation: $e');
      return false;
    }
  }

  /// Send invoice via WhatsApp
  static Future<bool> sendInvoice({
    required CustomerModel customer,
    required String invoiceNumber,
    required double amount,
    String? invoiceUrl,
  }) async {
    try {
      // Use direct WhatsApp launcher instead of API
      return await WhatsAppLauncherService.sendInvoice(
        phoneNumber: customer.phone ?? '',
        customerName: customer.name,
        invoiceNumber: invoiceNumber,
        amount: amount,
      );
    } catch (e) {
      print('Error sending invoice: $e');
      return false;
    }
  }

  /// Get WhatsApp templates
  static Future<List<Map<String, dynamic>>> getTemplates() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/whatsapp/templates'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['templates'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting templates: $e');
      return [];
    }
  }

  /// Send invoice with template
  static Future<bool> sendInvoiceWithTemplate({
    required String templateId,
    required Map<String, dynamic> templateData,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/whatsapp/send-template'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'template_id': templateId,
          'phone_number': _formatPhoneNumber(phoneNumber),
          'template_data': templateData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error sending template: $e');
      return false;
    }
  }

  /// Send custom message
  static Future<bool> sendCustomMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Use direct WhatsApp launcher instead of API
      return await WhatsAppLauncherService.sendCustomMessage(
        phoneNumber: phoneNumber,
        message: message,
      );
    } catch (e) {
      print('Error sending custom message: $e');
      return false;
    }
  }

  /// Send payment reminder with template
  static Future<bool> sendPaymentReminderWithTemplate({
    required String templateId,
    required Map<String, dynamic> templateData,
    required String phoneNumber,
  }) async {
    return await sendInvoiceWithTemplate(
      templateId: templateId,
      templateData: templateData,
      phoneNumber: phoneNumber,
    );
  }

  /// Send payment reminder with details
  static Future<bool> sendPaymentReminderWithDetails({
    required String phoneNumber,
    required String customerName,
    required double amount,
    required String invoiceNumber,
    DateTime? dueDate,
  }) async {
    try {
      // Use direct WhatsApp launcher instead of API
      return await WhatsAppLauncherService.sendPaymentReminder(
        phoneNumber: phoneNumber,
        customerName: customerName,
        invoiceNumber: invoiceNumber,
        amount: amount,
        dueDate: dueDate,
      );
    } catch (e) {
      print('Error sending payment reminder: $e');
      return false;
    }
  }

  /// Send payment request
  static Future<bool> sendPaymentRequest({
    required String phoneNumber,
    required String customerName,
    required double amount,
    required String description,
  }) async {
    try {
      final message = '''
Hello $customerName,

Payment Request:
Amount: ₹${amount.toStringAsFixed(2)}
Description: $description

Please make the payment at your earliest convenience.

Thank you!
''';

      // Use direct WhatsApp launcher instead of API
      return await WhatsAppLauncherService.sendCustomMessage(
        phoneNumber: phoneNumber,
        message: message,
      );
    } catch (e) {
      print('Error sending payment request: $e');
      return false;
    }
  }

  /// Get message history
  static Future<List<Map<String, dynamic>>> getMessageHistory(
    String phoneNumber,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/api/v1/whatsapp/history/${_formatPhoneNumber(phoneNumber)}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['messages'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting message history: $e');
      return [];
    }
  }

  /// Save template
  static Future<bool> saveTemplate({
    required String name,
    required String content,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/whatsapp/templates'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'content': content, 'type': type}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error saving template: $e');
      return false;
    }
  }

  /// Delete template
  static Future<bool> deleteTemplate(String templateId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/whatsapp/templates/$templateId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting template: $e');
      return false;
    }
  }

  /// Generic WhatsApp message sender
  static Future<bool> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
    required String templateType,
    String? attachmentUrl,
  }) async {
    if (phoneNumber.isEmpty) {
      print('Phone number is empty, cannot send WhatsApp message');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/whatsapp/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': _formatPhoneNumber(phoneNumber),
          'message': message,
          'template_type': templateType,
          'attachment_url': attachmentUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        print('WhatsApp API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('WhatsApp service error: $e');
      return false;
    }
  }

  /// Format phone number for WhatsApp API
  static String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Add country code if not present (assuming India +91)
    if (cleaned.length == 10) {
      cleaned = '91$cleaned';
    } else if (cleaned.startsWith('0')) {
      cleaned = '91${cleaned.substring(1)}';
    }

    return cleaned;
  }

  /// Build receivable reminder message
  static String buildReceivableMessage({
    required String customerName,
    required double amount,
    required String invoiceNumber,
    DateTime? dueDate,
  }) {
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
''';
  }

  /// Build payment confirmation message
  static String buildPaymentConfirmationMessage({
    required String customerName,
    required double amount,
    required String transactionId,
    required DateTime paymentDate,
  }) {
    return '''
Hello $customerName,

Thank you for your payment! 

Payment Confirmed
Amount: ₹${amount.toStringAsFixed(2)}
Transaction ID: $transactionId
Date: ${paymentDate.day}/${paymentDate.month}/${paymentDate.year}

Your payment has been successfully processed and recorded in our system.

Thank you for your business!
''';
  }

  /// Build invoice delivery message
  static String buildInvoiceMessage({
    required String customerName,
    required String invoiceNumber,
    required double amount,
    String? invoiceUrl,
  }) {
    final attachmentText = invoiceUrl != null ? '\nDownload: $invoiceUrl' : '';

    return '''
Hello $customerName,

Your invoice is ready:

Invoice Number: $invoiceNumber
Amount: ₹${amount.toStringAsFixed(2)}$attachmentText

Please review the invoice and make payment as per the terms mentioned.

Thank you for your business!
''';
  }

  /// Check if WhatsApp service is available
  static Future<bool> isServiceAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/whatsapp/status'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get recent WhatsApp messages
  static Future<List<Map<String, dynamic>>> getRecentMessages() async {
    try {
      // Mock data for now - replace with actual implementation
      return [
        {
          'id': '1',
          'business_id': 'test',
          'phone_number': '+91 9876543210',
          'recipient_name': 'John Doe',
          'message': 'Your invoice INV-001 for ₹5,000 is ready.',
          'sent_at':
              DateTime.now()
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
        },
        {
          'id': '2',
          'business_id': 'test',
          'phone_number': '+91 9876543211',
          'recipient_name': 'Jane Smith',
          'message': 'Payment reminder: Invoice INV-002 is due tomorrow.',
          'sent_at':
              DateTime.now()
                  .subtract(const Duration(hours: 5))
                  .toIso8601String(),
        },
      ];
    } catch (e) {
      print('Error getting recent messages: $e');
      return [];
    }
  }
}
