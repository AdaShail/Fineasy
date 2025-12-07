import 'package:flutter/material.dart';
import 'dart:io';
import '../services/ios_upi_link_service.dart';
import '../services/upi_service.dart';

class UpiLinkTestWidget extends StatefulWidget {
  const UpiLinkTestWidget({super.key});

  @override
  State<UpiLinkTestWidget> createState() => _UpiLinkTestWidgetState();
}

class _UpiLinkTestWidgetState extends State<UpiLinkTestWidget> {
  final _upiIdController = TextEditingController(text: 'test@paytm');
  final _payeeNameController = TextEditingController(text: 'Test Merchant');
  final _amountController = TextEditingController(text: '100');
  final _noteController = TextEditingController(text: 'Test Payment');

  @override
  void dispose() {
    _upiIdController.dispose();
    _payeeNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UPI Link Test - ${Platform.operatingSystem}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input fields
            TextField(
              controller: _upiIdController,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _payeeNameController,
              decoration: const InputDecoration(
                labelText: 'Payee Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Test buttons
            Expanded(
              child: ListView(
                children: [
                  _buildTestCard(
                    'Standard UPI Link',
                    'Test standard upi:// scheme',
                    () => _testStandardUpiLink(),
                  ),

                  if (Platform.isIOS) ...[
                    _buildTestCard(
                      'iOS Optimized Link',
                      'Test https://upi.link wrapper',
                      () => _testIOSOptimizedLink(),
                    ),

                    _buildTestCard(
                      'Google Pay Direct',
                      'Test Google Pay universal link',
                      () => _testGooglePayLink(),
                    ),

                    _buildTestCard(
                      'Multiple Options',
                      'Show all available payment options',
                      () => _testMultipleOptions(),
                    ),
                  ],

                  _buildTestCard(
                    'Generate WhatsApp Message',
                    'See optimized WhatsApp message',
                    () => _showWhatsAppMessage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }

  void _testStandardUpiLink() async {
    final link = UpiService.generateUpiLink(
      upiId: _upiIdController.text,
      payeeName: _payeeNameController.text,
      amount: double.tryParse(_amountController.text) ?? 100,
      transactionNote: _noteController.text,
    );

    _showLinkDialog('Standard UPI Link', link);
  }

  void _testIOSOptimizedLink() async {
    final link = IOSUpiLinkService.generateClickableUpiLink(
      upiId: _upiIdController.text,
      payeeName: _payeeNameController.text,
      amount: double.tryParse(_amountController.text) ?? 100,
      transactionNote: _noteController.text,
    );

    _showLinkDialog('iOS Optimized Link', link);
  }

  void _testGooglePayLink() async {
    final amount = double.tryParse(_amountController.text) ?? 100;
    final link =
        'https://pay.google.com/gp/p/ui/pay?pa=${_upiIdController.text}&pn=${Uri.encodeComponent(_payeeNameController.text)}&am=${amount.toStringAsFixed(2)}&cu=INR';

    _showLinkDialog('Google Pay Link', link);
  }

  void _testMultipleOptions() async {
    await IOSUpiLinkService.launchUpiPayment(
      context: context,
      upiId: _upiIdController.text,
      payeeName: _payeeNameController.text,
      amount: double.tryParse(_amountController.text) ?? 100,
      transactionNote: _noteController.text,
    );
  }

  void _showWhatsAppMessage() {
    final message =
        Platform.isIOS
            ? IOSUpiLinkService.createIOSOptimizedWhatsAppMessage(
              customerName: 'Test Customer',
              upiId: _upiIdController.text,
              payeeName: _payeeNameController.text,
              amount: double.tryParse(_amountController.text) ?? 100,
              transactionNote: _noteController.text,
              businessName: 'Test Business',
            )
            : 'Standard Android message would be generated here';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('WhatsApp Message Preview'),
            content: SingleChildScrollView(child: Text(message)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showLinkDialog(String title, String link) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Generated Link:'),
                const SizedBox(height: 8),
                SelectableText(
                  link,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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
                  Navigator.pop(context);
                  await IOSUpiLinkService.launchUpiPayment(
                    context: context,
                    upiId: _upiIdController.text,
                    payeeName: _payeeNameController.text,
                    amount: double.tryParse(_amountController.text) ?? 100,
                    transactionNote: _noteController.text,
                  );
                },
                child: const Text('Test Launch'),
              ),
            ],
          ),
    );
  }
}
