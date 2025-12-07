import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class UpiService {
  /// Generate UPI payment link (iOS and Android compatible)
  static String generateUpiLink({
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

    // For iOS, use HTTPS wrapper for better compatibility
    if (Platform.isIOS) {
      return 'https://upi.link/?$queryString';
    }

    // For Android, use standard UPI scheme
    return 'upi://pay?$queryString';
  }

  /// Generate iOS-compatible UPI payment link for WhatsApp
  static String generateIOSCompatibleUpiLink({
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
    String? transactionRef,
  }) {
    // For iOS WhatsApp sharing, create a more descriptive message
    final note = transactionNote ?? 'Payment Request';

    return '''
💳 UPI Payment Request

Pay to: $payeeName
UPI ID: $upiId
Amount: ₹${amount.toStringAsFixed(2)}
Note: $note

To pay:
1. Copy this UPI ID: $upiId
2. Open any UPI app (GPay, PhonePe, Paytm, etc.)
3. Send ₹${amount.toStringAsFixed(2)} to the above UPI ID

Or use this UPI link:
upi://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR${transactionNote != null ? '&tn=${Uri.encodeComponent(transactionNote)}' : ''}''';
  }

  /// Launch UPI payment
  static Future<bool> makePayment({
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
    String? transactionRef,
  }) async {
    try {
      final upiLink = generateUpiLink(
        upiId: upiId,
        payeeName: payeeName,
        amount: amount,
        transactionNote: transactionNote,
        transactionRef: transactionRef,
      );

      final uri = Uri.parse(upiLink);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Launch payment with specific UPI app
  static Future<bool> makePaymentWithApp({
    required String upiId,
    required String payeeName,
    required double amount,
    required UpiApp app,
    String? transactionNote,
    String? transactionRef,
  }) async {
    try {
      final upiLink = generateUpiLink(
        upiId: upiId,
        payeeName: payeeName,
        amount: amount,
        transactionNote: transactionNote,
        transactionRef: transactionRef,
      );

      // Replace upi:// with app-specific scheme
      final appLink = upiLink.replaceFirst('upi://', '${app.scheme}://');
      final uri = Uri.parse(appLink);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get available UPI apps
  static Future<List<UpiApp>> getAvailableUpiApps() async {
    final List<UpiApp> availableApps = [];

    for (final app in UpiApp.values) {
      try {
        final testUri = Uri.parse('${app.scheme}://');
        if (await canLaunchUrl(testUri)) {
          availableApps.add(app);
        }
      } catch (e) {
        // App not available
      }
    }

    return availableApps;
  }

  /// Validate UPI ID format
  static bool isValidUpiId(String upiId) {
    // Basic UPI ID validation: should contain @ and have valid format
    final upiRegex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
    return upiRegex.hasMatch(upiId);
  }

  /// Extract UPI ID from text (useful for parsing from messages)
  static String? extractUpiId(String text) {
    final upiRegex = RegExp(r'[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}');
    final match = upiRegex.firstMatch(text);
    return match?.group(0);
  }

  /// Generate QR code data for UPI payment
  static String generateQrCodeData({
    required String upiId,
    required String payeeName,
    required double amount,
    String? transactionNote,
  }) {
    return generateUpiLink(
      upiId: upiId,
      payeeName: payeeName,
      amount: amount,
      transactionNote: transactionNote,
    );
  }
}

/// Enum for popular UPI apps
enum UpiApp {
  googlePay('gpay', 'Google Pay'),
  phonePe('phonepe', 'PhonePe'),
  paytm('paytmmp', 'Paytm'),
  amazonPay('amazonpay', 'Amazon Pay'),
  bhim('bhim', 'BHIM'),
  mobikwik('mobikwik', 'MobiKwik'),
  freecharge('freecharge', 'FreeCharge'),
  sbi('sbi', 'SBI Pay'),
  icici('icici', 'iMobile Pay'),
  hdfc('hdfc', 'HDFC PayZapp');

  const UpiApp(this.scheme, this.displayName);

  final String scheme;
  final String displayName;
}

/// UPI transaction status
enum UpiTransactionStatus { success, failure, pending, cancelled, unknown }

/// UPI payment result
class UpiPaymentResult {
  final UpiTransactionStatus status;
  final String? transactionId;
  final String? responseCode;
  final String? approvalRefNo;
  final String? transactionRefId;
  final String? message;

  UpiPaymentResult({
    required this.status,
    this.transactionId,
    this.responseCode,
    this.approvalRefNo,
    this.transactionRefId,
    this.message,
  });

  bool get isSuccess => status == UpiTransactionStatus.success;
  bool get isFailure => status == UpiTransactionStatus.failure;
  bool get isPending => status == UpiTransactionStatus.pending;
  bool get isCancelled => status == UpiTransactionStatus.cancelled;
}
