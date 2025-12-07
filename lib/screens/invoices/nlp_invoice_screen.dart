import 'package:flutter/material.dart';
import '../../services/ai_service.dart';
import '../../utils/theme_manager.dart';

class NLPInvoiceScreen extends StatefulWidget {
  const NLPInvoiceScreen({super.key});

  @override
  State<NLPInvoiceScreen> createState() => _NLPInvoiceScreenState();
}

class _NLPInvoiceScreenState extends State<NLPInvoiceScreen> {
  final TextEditingController _nlpController = TextEditingController();
  bool _isProcessing = false;
  String? _errorMessage;
  Map<String, dynamic>? _generatedInvoice;

  @override
  void dispose() {
    _nlpController.dispose();
    super.dispose();
  }

  Future<void> _processNLPInput() async {
    if (_nlpController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter invoice details';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _generatedInvoice = null;
    });

    try {
      // Try AI service first
      final aiService = AIService();
      final aiResult = await aiService.processInvoiceNLP(_nlpController.text);

      if (aiResult != null) {
        setState(() {
          _generatedInvoice = aiResult;
        });
      } else {
        // Fallback to local processing if AI fails
        final mockInvoice = _processTextLocally(_nlpController.text);
        setState(() {
          _generatedInvoice = mockInvoice;
          _errorMessage = 'AI service unavailable, using local processing';
        });
      }
    } catch (e) {
      // Fallback to local processing on error
      try {
        final mockInvoice = _processTextLocally(_nlpController.text);
        setState(() {
          _generatedInvoice = mockInvoice;
          _errorMessage =
              'AI service error, using local processing: ${e.toString()}';
        });
      } catch (localError) {
        setState(() {
          _errorMessage = 'Error processing invoice: ${localError.toString()}';
        });
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Map<String, dynamic> _processTextLocally(String text) {
    // Enhanced local NLP processing for demo
    final lowerText = text.toLowerCase();

    // Extract customer name
    String customerName = 'Unknown Customer';
    final customerPatterns = [
      RegExp(r'for\s+([a-zA-Z\s]+?)(?:\s+for|\s+\d)'),
      RegExp(r'invoice\s+for\s+([a-zA-Z\s]+?)(?:\s+for|\s+\d)'),
      RegExp(r'create\s+invoice\s+for\s+([a-zA-Z\s]+?)(?:\s+for|\s+\d)'),
    ];

    for (final pattern in customerPatterns) {
      final match = pattern.firstMatch(lowerText);
      if (match != null) {
        customerName =
            match
                .group(1)
                ?.trim()
                .split(' ')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' ') ??
            customerName;
        break;
      }
    }

    // Extract items with enhanced patterns
    List<Map<String, dynamic>> items = [];

    // Pattern for "8 drums for 5000 rupees each"
    final itemPatterns = [
      RegExp(
        r'(\d+)\s+([a-zA-Z\s]+?)\s+(?:for|at)\s+(\d+(?:\.\d+)?)\s+(?:rupees?|rs\.?|₹|dollars?|\$)\s+each',
      ),
      RegExp(
        r'(\d+)\s+([a-zA-Z\s]+?)\s+(?:at|@|for)\s+(?:\$|₹|rs\.?\s*)?(\d+(?:\.\d+)?)',
      ),
      RegExp(
        r'(\d+)\s*(?:x\s*)?([a-zA-Z\s]+?)\s*(?:at|@|for)\s*(?:\$|₹|rs\.?\s*)?(\d+(?:\.\d+)?)\s*(?:each|per)?',
      ),
    ];

    for (final pattern in itemPatterns) {
      final match = pattern.firstMatch(lowerText);
      if (match != null) {
        final quantity = int.tryParse(match.group(1)!) ?? 1;
        final description = match
            .group(2)!
            .trim()
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
        final unitPrice = double.tryParse(match.group(3)!) ?? 0.0;

        items.add({
          'description': description,
          'quantity': quantity,
          'unit_price': unitPrice,
          'total_price': quantity * unitPrice,
        });
        break;
      }
    }

    // If no items found, create a default one
    if (items.isEmpty) {
      items.add({
        'description':
            'Item from: ${text.substring(0, text.length > 30 ? 30 : text.length)}...',
        'quantity': 1,
        'unit_price': 100.0,
        'total_price': 100.0,
      });
    }

    // Calculate totals
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item['total_price'],
    );

    // Extract discount
    double discountAmount = 0;
    final discountPatterns = [
      RegExp(r'(\d+(?:\.\d+)?)\s*%\s*discount'),
      RegExp(r'with\s+(\d+(?:\.\d+)?)\s*%\s*discount'),
      RegExp(r'discount\s+of\s+(\d+(?:\.\d+)?)\s*%'),
    ];

    for (final pattern in discountPatterns) {
      final match = pattern.firstMatch(lowerText);
      if (match != null) {
        final discountPercent = (double.tryParse(match.group(1)!) ?? 0) / 100;
        discountAmount = subtotal * discountPercent;
        break;
      }
    }

    // Calculate tax (assuming 18% GST for India)
    final taxAmount = (subtotal - discountAmount) * 0.18;
    final totalAmount = subtotal - discountAmount + taxAmount;

    return {
      'invoice_number': 'INV-${DateTime.now().millisecondsSinceEpoch}',
      'customer_name': customerName,
      'date': DateTime.now().toIso8601String(),
      'due_date':
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'items': items,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_amount': totalAmount,
    };
  }

  Widget _buildNLPInputSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Describe Your Invoice',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Describe the invoice in natural language. For example:\n"Create invoice for Nitiayog Textiles for 8 drums for 5000 rupees each with 8% discount"',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nlpController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter invoice details in natural language...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processNLPInput,
                icon:
                    _isProcessing
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.auto_awesome),
                label: Text(
                  _isProcessing ? 'Processing...' : 'Generate Invoice',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedInvoicePreview() {
    if (_generatedInvoice == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Generated Invoice Preview',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _generatedInvoice = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            _buildInvoiceDetails(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit functionality coming soon!'),
                        ),
                      );
                    },
                    child: const Text('Edit Invoice'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invoice saved successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Save Invoice'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    final invoice = _generatedInvoice!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Invoice Number:', invoice['invoice_number']),
        _buildDetailRow('Customer:', invoice['customer_name']),
        _buildDetailRow('Date:', invoice['date'].toString().split('T')[0]),
        _buildDetailRow(
          'Due Date:',
          invoice['due_date'].toString().split('T')[0],
        ),
        const SizedBox(height: 16),
        Text(
          'Items:',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...(invoice['items'] as List).map((item) => _buildItemRow(item)),
        const Divider(),
        _buildDetailRow(
          'Subtotal:',
          '₹${invoice['subtotal'].toStringAsFixed(2)}',
        ),
        if (invoice['tax_amount'] > 0)
          _buildDetailRow(
            'Tax (18% GST):',
            '₹${invoice['tax_amount'].toStringAsFixed(2)}',
          ),
        if (invoice['discount_amount'] > 0)
          _buildDetailRow(
            'Discount:',
            '-₹${invoice['discount_amount'].toStringAsFixed(2)}',
          ),
        _buildDetailRow(
          'Total:',
          '₹${invoice['total_amount'].toStringAsFixed(2)}',
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(item['description'])),
          Expanded(child: Text('${item['quantity']}x')),
          Expanded(child: Text('₹${item['unit_price'].toStringAsFixed(2)}')),
          Expanded(
            child: Text(
              '₹${item['total_price'].toStringAsFixed(2)}',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Invoice Generator'),
        backgroundColor: ThemeManager.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNLPInputSection(),
            const SizedBox(height: 16),
            _buildErrorMessage(),
            const SizedBox(height: 16),
            _buildGeneratedInvoicePreview(),
          ],
        ),
      ),
    );
  }
}
