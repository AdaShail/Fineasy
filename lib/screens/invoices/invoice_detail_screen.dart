import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice_model.dart';
import '../../models/payment_model.dart';
import '../../models/transaction_model.dart';
import '../../models/customer_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/payment_service.dart';
import '../../services/invoice_service.dart';
import '../../utils/constants.dart';
import '../../widgets/payments/payment_recording_dialog.dart';
import 'add_edit_invoice_screen.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  List<PaymentModel> _payments = [];
  TransactionModel? _linkedTransaction;
  bool _isLoadingPayments = false;
  bool _isLoadingTransaction = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentHistory();
    _loadLinkedTransaction();
  }

  Future<void> _loadPaymentHistory() async {
    setState(() {
      _isLoadingPayments = true;
    });

    try {
      final payments = await PaymentService.getInvoicePayments(
        widget.invoice.id,
      );
      setState(() {
        _payments = payments;
        _isLoadingPayments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPayments = false;
      });
    }
  }

  Future<void> _loadLinkedTransaction() async {
    if (widget.invoice.transactionId == null) return;

    setState(() {
      _isLoadingTransaction = true;
    });

    try {
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      // Try to find transaction in provider's list
      final transaction = transactionProvider.transactions.firstWhere(
        (t) => t.id == widget.invoice.transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      setState(() {
        _linkedTransaction = transaction;
        _isLoadingTransaction = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTransaction = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final customer =
        widget.invoice.customerId != null
            ? customerProvider.getCustomerById(widget.invoice.customerId!)
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice ${widget.invoice.invoiceNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditInvoiceScreen(invoice: widget.invoice),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteInvoice,
            tooltip: 'Delete Invoice',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            _buildStatusBanner(),

            // Invoice Information
            _buildSection(
              title: 'Invoice Information',
              child: _buildInvoiceInfo(),
            ),

            // Customer Information
            if (customer != null)
              _buildSection(
                title: 'Customer Information',
                child: _buildCustomerInfo(customer),
              ),

            // Line Items
            _buildSection(title: 'Line Items', child: _buildLineItems()),

            // Payment Summary
            _buildSection(
              title: 'Payment Summary',
              child: _buildPaymentSummary(),
            ),

            // Payment History
            _buildSection(
              title: 'Payment History',
              child: _buildPaymentHistory(),
            ),

            // Linked Transaction
            if (widget.invoice.transactionId != null)
              _buildSection(
                title: 'Linked Transaction',
                child: _buildLinkedTransactionInfo(),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton:
          widget.invoice.status != InvoiceStatus.paid &&
                  widget.invoice.status != InvoiceStatus.cancelled
              ? FloatingActionButton.extended(
                onPressed: _recordPayment,
                icon: const Icon(Icons.payment),
                label: const Text('Record Payment'),
              )
              : null,
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: _getStatusColor(widget.invoice.status),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(widget.invoice.status),
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusDisplayName(widget.invoice.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.invoice.isOverdue)
                  const Text(
                    'This invoice is overdue',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        child,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildInvoiceInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildInfoRow('Invoice Number', widget.invoice.invoiceNumber),
          _buildInfoRow(
            'Invoice Date',
            '${widget.invoice.createdAt.day}/${widget.invoice.createdAt.month}/${widget.invoice.createdAt.year}',
          ),
          if (widget.invoice.dueDate != null)
            _buildInfoRow(
              'Due Date',
              '${widget.invoice.dueDate!.day}/${widget.invoice.dueDate!.month}/${widget.invoice.dueDate!.year}',
            ),
          if (widget.invoice.notes != null && widget.invoice.notes!.isNotEmpty)
            _buildInfoRow('Notes', widget.invoice.notes ?? ''),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(CustomerModel customer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildInfoRow('Name', customer.name),
          if (customer.phone != null) _buildInfoRow('Phone', customer.phone!),
          if (customer.email != null) _buildInfoRow('Email', customer.email!),
          if (customer.address != null)
            _buildInfoRow('Address', customer.address!),
          if (customer.gstNumber != null)
            _buildInfoRow('GST Number', customer.gstNumber!),
        ],
      ),
    );
  }

  Widget _buildLineItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ...widget.invoice.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (item.description != null &&
                            item.description!.isNotEmpty)
                          Text(
                            item.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${AppConstants.defaultCurrency}${item.unitPrice.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${AppConstants.defaultCurrency}${item.totalAmount.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(),
          _buildAmountRow('Subtotal', widget.invoice.subtotal),
          if (widget.invoice.taxAmount > 0)
            _buildAmountRow('Tax', widget.invoice.taxAmount),
          if (widget.invoice.discountAmount > 0)
            _buildAmountRow('Discount', -widget.invoice.discountAmount),
          const Divider(thickness: 2),
          _buildAmountRow('Total', widget.invoice.totalAmount, isBold: true),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildAmountRow('Total Amount', widget.invoice.totalAmount),
          _buildAmountRow(
            'Paid Amount',
            widget.invoice.paidAmount,
            color: Colors.green,
          ),
          const Divider(thickness: 2),
          _buildAmountRow(
            'Outstanding',
            widget.invoice.outstandingAmount,
            isBold: true,
            color:
                widget.invoice.outstandingAmount > 0
                    ? Colors.red
                    : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    if (_isLoadingPayments) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_payments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No payments recorded yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children:
            _payments.map((payment) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        payment.status == PaymentStatus.completed
                            ? Colors.green
                            : Colors.grey,
                    child: const Icon(
                      Icons.payment,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${AppConstants.defaultCurrency}${payment.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}',
                      ),
                      Text(
                        _getPaymentModeDisplayName(payment.paymentMode),
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (payment.reference != null &&
                          payment.reference!.isNotEmpty)
                        Text(
                          'Ref: ${payment.reference}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing:
                      payment.status == PaymentStatus.cancelled
                          ? const Chip(
                            label: Text(
                              'Cancelled',
                              style: TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.red,
                            labelStyle: TextStyle(color: Colors.white),
                          )
                          : null,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildLinkedTransactionInfo() {
    if (_isLoadingTransaction) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_linkedTransaction == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Transaction not found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                _linkedTransaction!.type == TransactionType.income
                    ? Colors.green
                    : Colors.red,
            child: Icon(
              _linkedTransaction!.type == TransactionType.income
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            _linkedTransaction!.description,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_linkedTransaction!.date.day}/${_linkedTransaction!.date.month}/${_linkedTransaction!.date.year}',
              ),
              Text(
                _linkedTransaction!.type.toString().split('.').last,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: Text(
            '${AppConstants.defaultCurrency}${_linkedTransaction!.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            '${AppConstants.defaultCurrency}${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.partiallyPaid:
        return Colors.orange;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.brown;
    }
  }

  IconData _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icons.edit_note;
      case InvoiceStatus.sent:
        return Icons.send;
      case InvoiceStatus.partiallyPaid:
        return Icons.pending;
      case InvoiceStatus.paid:
        return Icons.check_circle;
      case InvoiceStatus.overdue:
        return Icons.warning;
      case InvoiceStatus.cancelled:
        return Icons.cancel;
    }
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

  String _getPaymentModeDisplayName(PaymentMode mode) {
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

  Future<void> _recordPayment() async {
    // Get customer invoices for multi-invoice payment option
    List<InvoiceModel>? customerInvoices;
    if (widget.invoice.customerId != null) {
      try {
        customerInvoices = await InvoiceService.getInvoices(
          businessId: widget.invoice.businessId,
          customerId: widget.invoice.customerId,
        );
        // Filter to only unpaid and partially paid invoices
        customerInvoices =
            customerInvoices
                .where(
                  (inv) =>
                      inv.outstandingAmount > 0 &&
                      inv.status != InvoiceStatus.cancelled,
                )
                .toList();
      } catch (e) {
        // If we can't load customer invoices, just proceed with single invoice
        customerInvoices = null;
      }
    }

    // Show payment recording dialog
    final result = await showDialog<PaymentResult>(
      context: context,
      builder:
          (context) => PaymentRecordingDialog(
            invoice: widget.invoice,
            customerInvoices: customerInvoices,
            onPaymentRecorded: (result) async {
              if (result.success) {
                // Reload invoice provider
                final invoiceProvider = Provider.of<InvoiceProvider>(
                  context,
                  listen: false,
                );
                await invoiceProvider.loadInvoices(widget.invoice.businessId);

                // Reload payment history
                await _loadPaymentHistory();
              }
            },
          ),
    );

    // If payment was successful and invoice is fully paid, pop back
    if (result != null &&
        result.success &&
        result.updatedInvoice?.status == InvoiceStatus.paid) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _deleteInvoice() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text(
          'Are you sure you want to delete invoice "${widget.invoice.invoiceNumber}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final invoiceProvider = Provider.of<InvoiceProvider>(
        context,
        listen: false,
      );

      final success = await invoiceProvider.deleteInvoice(widget.invoice.id);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back
        Navigator.pop(context);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete invoice'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
