import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/invoice_model.dart';
import '../../models/transaction_model.dart';
import '../../services/payment_service.dart';

/// Dialog for recording a payment against an invoice
///
/// Supports:
/// - Single invoice payment
/// - Multi-invoice payment allocation
/// - Payment validation
/// - Payment confirmation
///
/// Requirements: 6.1, 6.2, 6.3
class PaymentRecordingDialog extends StatefulWidget {
  final InvoiceModel invoice;
  final List<InvoiceModel>? customerInvoices; // For multi-invoice payment
  final Function(PaymentResult)? onPaymentRecorded;

  const PaymentRecordingDialog({
    Key? key,
    required this.invoice,
    this.customerInvoices,
    this.onPaymentRecorded,
  }) : super(key: key);

  @override
  State<PaymentRecordingDialog> createState() => _PaymentRecordingDialogState();
}

class _PaymentRecordingDialogState extends State<PaymentRecordingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  PaymentMode _selectedPaymentMode = PaymentMode.cash;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _showMultiInvoiceAllocation = false;

  // Multi-invoice allocation
  final Map<String, double> _invoiceAllocations = {};
  double _totalAllocated = 0.0;

  @override
  void initState() {
    super.initState();
    // Pre-fill with outstanding amount
    _amountController.text = widget.invoice.outstandingAmount.toStringAsFixed(
      2,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _enteredAmount {
    final text = _amountController.text.trim();
    return double.tryParse(text) ?? 0.0;
  }

  double get _remainingAmount {
    if (_showMultiInvoiceAllocation) {
      return _enteredAmount - _totalAllocated;
    }
    return widget.invoice.outstandingAmount - _enteredAmount;
  }

  bool get _isOverpayment {
    if (_showMultiInvoiceAllocation) {
      return _totalAllocated > _enteredAmount;
    }
    return _enteredAmount > widget.invoice.outstandingAmount;
  }

  bool get _canShowMultiInvoice {
    return widget.customerInvoices != null &&
        widget.customerInvoices!.length > 1 &&
        widget.customerInvoices!.any((inv) => inv.outstandingAmount > 0);
  }

  void _updateTotalAllocated() {
    setState(() {
      _totalAllocated = _invoiceAllocations.values.fold(
        0.0,
        (sum, amount) => sum + amount,
      );
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _recordPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      PaymentResult result;

      if (_showMultiInvoiceAllocation && _invoiceAllocations.isNotEmpty) {
        // Multi-invoice payment
        final allocations =
            _invoiceAllocations.entries
                .map(
                  (entry) => InvoicePaymentAllocation(
                    invoiceId: entry.key,
                    amount: entry.value,
                  ),
                )
                .toList();

        result = await PaymentService.recordDistributedPayment(
          allocations: allocations,
          paymentMode: _selectedPaymentMode,
          reference:
              _referenceController.text.trim().isEmpty
                  ? null
                  : _referenceController.text.trim(),
          notes:
              _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
          paymentDate: _selectedDate,
        );
      } else {
        // Single invoice payment
        result = await PaymentService.recordPayment(
          invoiceId: widget.invoice.id,
          amount: _enteredAmount,
          paymentMode: _selectedPaymentMode,
          reference:
              _referenceController.text.trim().isEmpty
                  ? null
                  : _referenceController.text.trim(),
          notes:
              _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
          paymentDate: _selectedDate,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        // Show success message
        if (mounted) {
          _showSuccessDialog(result);
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Failed to record payment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirm Payment'),
                content: _buildConfirmationContent(),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Confirm'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Widget _buildConfirmationContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount: ₹${_enteredAmount.toStringAsFixed(2)}'),
        Text('Payment Mode: ${_getPaymentModeLabel(_selectedPaymentMode)}'),
        Text('Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
        if (_referenceController.text.trim().isNotEmpty)
          Text('Reference: ${_referenceController.text.trim()}'),
        if (_showMultiInvoiceAllocation && _invoiceAllocations.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Allocation:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._invoiceAllocations.entries.map((entry) {
            final invoice = widget.customerInvoices!.firstWhere(
              (inv) => inv.id == entry.key,
            );
            return Text(
              '  ${invoice.invoiceNumber}: ₹${entry.value.toStringAsFixed(2)}',
            );
          }),
        ],
      ],
    );
  }

  Future<void> _showSuccessDialog(PaymentResult result) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 8),
                Text('Payment Recorded'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.message ?? 'Payment recorded successfully'),
                const SizedBox(height: 16),
                if (result.updatedInvoice != null) ...[
                  Text(
                    'Invoice Status: ${_getStatusLabel(result.updatedInvoice!.status)}',
                  ),
                  Text(
                    'Remaining: ₹${result.updatedInvoice!.outstandingAmount.toStringAsFixed(2)}',
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close success dialog
                  Navigator.of(
                    context,
                  ).pop(result); // Close payment dialog with result
                  widget.onPaymentRecorded?.call(result);
                },
                child: const Text('OK'),
              ),
              if (result.updatedInvoice != null &&
                  result.updatedInvoice!.status == InvoiceStatus.paid)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close success dialog
                    Navigator.of(context).pop(result); // Close payment dialog
                    widget.onPaymentRecorded?.call(result);
                    // TODO: Generate receipt
                  },
                  child: const Text('Generate Receipt'),
                ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payment, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Record Payment',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice Info
                      _buildInvoiceInfo(),
                      const SizedBox(height: 24),

                      // Payment Amount
                      _buildAmountField(),
                      const SizedBox(height: 16),

                      // Payment Mode
                      _buildPaymentModeSelector(),
                      const SizedBox(height: 16),

                      // Payment Date
                      _buildDatePicker(),
                      const SizedBox(height: 16),

                      // Reference Number
                      _buildReferenceField(),
                      const SizedBox(height: 16),

                      // Notes
                      _buildNotesField(),
                      const SizedBox(height: 16),

                      // Multi-invoice allocation toggle
                      if (_canShowMultiInvoice) ...[
                        _buildMultiInvoiceToggle(),
                        const SizedBox(height: 16),
                      ],

                      // Multi-invoice allocation UI
                      if (_showMultiInvoiceAllocation) ...[
                        _buildMultiInvoiceAllocation(),
                        const SizedBox(height: 16),
                      ],

                      // Validation warnings
                      _buildValidationWarnings(),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _recordPayment,
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Record Payment'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invoice: ${widget.invoice.invoiceNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.invoice.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getStatusLabel(widget.invoice.status),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount:'),
              Text(
                '₹${widget.invoice.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Paid Amount:'),
              Text(
                '₹${widget.invoice.paidAmount.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.green[700]),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Outstanding:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${widget.invoice.outstandingAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Payment Amount *',
        prefixText: '₹ ',
        border: const OutlineInputBorder(),
        helperText:
            'Outstanding: ₹${widget.invoice.outstandingAmount.toStringAsFixed(2)}',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter payment amount';
        }
        final amount = double.tryParse(value.trim());
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        if (!_showMultiInvoiceAllocation &&
            amount > widget.invoice.outstandingAmount + 0.01) {
          return 'Amount exceeds outstanding (₹${widget.invoice.outstandingAmount.toStringAsFixed(2)})';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {}); // Rebuild to update remaining amount
      },
    );
  }

  Widget _buildPaymentModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Mode *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              PaymentMode.values.map((mode) {
                final isSelected = _selectedPaymentMode == mode;
                return ChoiceChip(
                  label: Text(_getPaymentModeLabel(mode)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPaymentMode = mode;
                      });
                    }
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Payment Date *',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
      ),
    );
  }

  Widget _buildReferenceField() {
    return TextFormField(
      controller: _referenceController,
      decoration: const InputDecoration(
        labelText: 'Reference Number',
        hintText: 'e.g., Transaction ID, Cheque Number',
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.characters,
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes',
        hintText: 'Additional payment details',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildMultiInvoiceToggle() {
    return SwitchListTile(
      title: const Text('Distribute across multiple invoices'),
      subtitle: Text(
        '${widget.customerInvoices!.length} unpaid invoices available',
      ),
      value: _showMultiInvoiceAllocation,
      onChanged: (value) {
        setState(() {
          _showMultiInvoiceAllocation = value;
          if (!value) {
            _invoiceAllocations.clear();
            _totalAllocated = 0.0;
          }
        });
      },
    );
  }

  Widget _buildMultiInvoiceAllocation() {
    final unpaidInvoices =
        widget.customerInvoices!
            .where((inv) => inv.outstandingAmount > 0)
            .toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Allocate Payment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Remaining: ₹${_remainingAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: _remainingAmount < 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...unpaidInvoices.map(
            (invoice) => _buildInvoiceAllocationItem(invoice),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceAllocationItem(InvoiceModel invoice) {
    final allocated = _invoiceAllocations[invoice.id] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Outstanding: ₹${invoice.outstandingAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: allocated > 0 ? allocated.toStringAsFixed(2) : '',
              decoration: const InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                final amount = double.tryParse(value.trim()) ?? 0.0;
                setState(() {
                  if (amount > 0) {
                    _invoiceAllocations[invoice.id] = amount;
                  } else {
                    _invoiceAllocations.remove(invoice.id);
                  }
                  _updateTotalAllocated();
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.auto_fix_high, size: 20),
            tooltip: 'Auto-fill outstanding',
            onPressed: () {
              setState(() {
                final remaining = _enteredAmount - _totalAllocated;
                final amountToAllocate =
                    remaining > invoice.outstandingAmount
                        ? invoice.outstandingAmount
                        : remaining;
                if (amountToAllocate > 0) {
                  _invoiceAllocations[invoice.id] = amountToAllocate;
                  _updateTotalAllocated();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValidationWarnings() {
    if (_enteredAmount <= 0) {
      return const SizedBox.shrink();
    }

    if (_showMultiInvoiceAllocation) {
      if (_totalAllocated > _enteredAmount) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Total allocation (₹${_totalAllocated.toStringAsFixed(2)}) exceeds payment amount',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],
          ),
        );
      } else if (_totalAllocated < _enteredAmount) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unallocated amount: ₹${_remainingAmount.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.orange[700]),
                ),
              ),
            ],
          ),
        );
      }
    } else if (_isOverpayment) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Payment amount exceeds outstanding by ₹${(_enteredAmount - widget.invoice.outstandingAmount).toStringAsFixed(2)}',
                style: TextStyle(color: Colors.orange[700]),
              ),
            ),
          ],
        ),
      );
    } else if (_remainingAmount > 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Remaining after payment: ₹${_remainingAmount.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.blue[700]),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getPaymentModeLabel(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.card:
        return 'Card';
      case PaymentMode.netBanking:
        return 'Net Banking';
      case PaymentMode.cheque:
        return 'Cheque';
      case PaymentMode.bankTransfer:
        return 'Bank Transfer';
      case PaymentMode.other:
        return 'Other';
    }
  }

  String _getStatusLabel(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.partiallyPaid:
        return Colors.orange;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.black54;
    }
  }
}
