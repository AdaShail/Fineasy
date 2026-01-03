import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice_model.dart';
import '../../providers/invoice_provider.dart';
import '../../utils/constants.dart';

/// Inline editor for quick invoice updates
/// Requirements: 3.2, 6.3
class InvoiceInlineEditor extends StatefulWidget {
  final InvoiceModel invoice;
  final VoidCallback? onSaved;
  final VoidCallback? onCancelled;

  const InvoiceInlineEditor({
    super.key,
    required this.invoice,
    this.onSaved,
    this.onCancelled,
  });

  @override
  State<InvoiceInlineEditor> createState() => _InvoiceInlineEditorState();
}

class _InvoiceInlineEditorState extends State<InvoiceInlineEditor> {
  late TextEditingController _invoiceNumberController;
  late TextEditingController _subtotalController;
  late TextEditingController _taxAmountController;
  late TextEditingController _discountAmountController;
  late TextEditingController _totalAmountController;
  late TextEditingController _notesController;

  late DateTime _invoiceDate;
  late DateTime? _dueDate;
  late InvoiceStatus _status;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _invoiceNumberController =
        TextEditingController(text: widget.invoice.invoiceNumber);
    _subtotalController =
        TextEditingController(text: widget.invoice.subtotal.toStringAsFixed(2));
    _taxAmountController = TextEditingController(
        text: widget.invoice.taxAmount.toStringAsFixed(2));
    _discountAmountController = TextEditingController(
        text: widget.invoice.discountAmount.toStringAsFixed(2));
    _totalAmountController = TextEditingController(
        text: widget.invoice.totalAmount.toStringAsFixed(2));
    _notesController = TextEditingController(text: widget.invoice.notes ?? '');

    _invoiceDate = widget.invoice.invoiceDate;
    _dueDate = widget.invoice.dueDate;
    _status = widget.invoice.status;
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _subtotalController.dispose();
    _taxAmountController.dispose();
    _discountAmountController.dispose();
    _totalAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final subtotal = double.tryParse(_subtotalController.text) ?? 0.0;
    final taxAmount = double.tryParse(_taxAmountController.text) ?? 0.0;
    final discountAmount =
        double.tryParse(_discountAmountController.text) ?? 0.0;

    final total = subtotal + taxAmount - discountAmount;
    _totalAmountController.text = total.toStringAsFixed(2);
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    final updatedInvoice = widget.invoice.copyWith(
      invoiceNumber: _invoiceNumberController.text.trim(),
      invoiceDate: _invoiceDate,
      dueDate: _dueDate,
      subtotal: double.tryParse(_subtotalController.text) ?? 0.0,
      taxAmount: double.tryParse(_taxAmountController.text) ?? 0.0,
      discountAmount: double.tryParse(_discountAmountController.text) ?? 0.0,
      totalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
      status: _status,
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final success = await invoiceProvider.updateInvoice(updatedInvoice);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSaved?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              invoiceProvider.error ?? 'Failed to update invoice',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Quick Edit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isSaving)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  TextButton(
                    onPressed: widget.onCancelled,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text('Save'),
                  ),
                ],
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Form fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _invoiceNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Invoice Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<InvoiceStatus>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: InvoiceStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusDisplayName(status)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _invoiceDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          _invoiceDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Invoice Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_invoiceDate.day}/${_invoiceDate.month}/${_invoiceDate.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            _dueDate ??
                            DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          _dueDate = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _dueDate != null
                            ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtotalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Subtotal',
                      prefixText: AppConstants.defaultCurrency,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _calculateTotal(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _taxAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tax',
                      prefixText: AppConstants.defaultCurrency,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _calculateTotal(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _discountAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Discount',
                      prefixText: AppConstants.defaultCurrency,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _calculateTotal(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _totalAmountController,
              keyboardType: TextInputType.number,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Total Amount',
                prefixText: AppConstants.defaultCurrency,
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDisplayName(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }
}
