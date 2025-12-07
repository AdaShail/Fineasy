import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/invoice_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../services/pdf_service.dart';

class TransactionInvoiceHistoryScreen extends StatefulWidget {
  const TransactionInvoiceHistoryScreen({super.key});

  @override
  State<TransactionInvoiceHistoryScreen> createState() =>
      _TransactionInvoiceHistoryScreenState();
}

class _TransactionInvoiceHistoryScreenState
    extends State<TransactionInvoiceHistoryScreen> {
  String _filterType = 'all'; // all, income, expense
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer2<TransactionProvider, BusinessProvider>(
        builder: (context, transactionProvider, businessProvider, child) {
          var transactions = transactionProvider.transactions;

          // Apply filters
          if (_filterType != 'all') {
            transactions =
                transactions.where((t) {
                  if (_filterType == 'income') {
                    return t.type == TransactionType.income;
                  } else {
                    return t.type == TransactionType.expense;
                  }
                }).toList();
          }

          if (_startDate != null && _endDate != null) {
            transactions =
                transactions.where((t) {
                  return t.date.isAfter(_startDate!) &&
                      t.date.isBefore(_endDate!.add(const Duration(days: 1)));
                }).toList();
          }

          // Sort by date (newest first)
          transactions.sort((a, b) => b.date.compareTo(a.date));

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first transaction to get started',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Group transactions by date
          final groupedTransactions = <String, List<TransactionModel>>{};
          for (var transaction in transactions) {
            final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
            if (!groupedTransactions.containsKey(dateKey)) {
              groupedTransactions[dateKey] = [];
            }
            groupedTransactions[dateKey]!.add(transaction);
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (businessProvider.business != null) {
                await transactionProvider.refreshTransactions(
                  businessProvider.business!.id,
                );
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedTransactions.length,
              itemBuilder: (context, index) {
                final dateKey = groupedTransactions.keys.elementAt(index);
                final dayTransactions = groupedTransactions[dateKey]!;
                final date = DateTime.parse(dateKey);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _formatDateHeader(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    ...dayTransactions.map(
                      (transaction) =>
                          _buildTransactionCard(transaction, businessProvider),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today - ${DateFormat('MMM dd, yyyy').format(date)}';
    } else if (transactionDate == yesterday) {
      return 'Yesterday - ${DateFormat('MMM dd, yyyy').format(date)}';
    } else {
      return DateFormat('EEEE, MMM dd, yyyy').format(date);
    }
  }

  Widget _buildTransactionCard(
    TransactionModel transaction,
    BusinessProvider businessProvider,
  ) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppTheme.successColor : AppTheme.errorColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction, businessProvider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isIncome ? Icons.trending_up : Icons.trending_down,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('hh:mm a').format(transaction.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                transaction.paymentMode
                                    .toString()
                                    .split('.')
                                    .last
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'}${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isIncome ? 'Income' : 'Expense',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed:
                        () =>
                            _createFormalInvoice(transaction, businessProvider),
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Create Invoice'),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed:
                        () => _generateInvoice(transaction, businessProvider),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF Receipt'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed:
                        () => _shareInvoice(transaction, businessProvider),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(
    TransactionModel transaction,
    BusinessProvider businessProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (context, scrollController) => SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Transaction Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDetailRow('Description', transaction.description),
                      _buildDetailRow(
                        'Amount',
                        '${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}',
                      ),
                      _buildDetailRow(
                        'Type',
                        transaction.type == TransactionType.income
                            ? 'Income'
                            : 'Expense',
                      ),
                      _buildDetailRow(
                        'Payment Mode',
                        transaction.paymentMode
                            .toString()
                            .split('.')
                            .last
                            .toUpperCase(),
                      ),
                      _buildDetailRow(
                        'Date',
                        DateFormat(
                          'MMM dd, yyyy hh:mm a',
                        ).format(transaction.date),
                      ),
                      _buildDetailRow('Transaction ID', transaction.id),
                      const SizedBox(height: 24),
                      if (transaction.invoiceNumber != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Invoice ${transaction.invoiceNumber} created',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/invoices');
                                },
                                child: const Text('View'),
                              ),
                            ],
                          ),
                        ),
                      if (transaction.invoiceNumber != null)
                        const SizedBox(height: 16),
                      Row(
                        children: [
                          if (transaction.invoiceNumber == null)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _createFormalInvoice(
                                    transaction,
                                    businessProvider,
                                  );
                                },
                                icon: const Icon(Icons.receipt_long),
                                label: const Text('Create Invoice'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          if (transaction.invoiceNumber == null)
                            const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _generateInvoice(transaction, businessProvider);
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('PDF Receipt'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _shareInvoice(transaction, businessProvider);
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createFormalInvoice(
    TransactionModel transaction,
    BusinessProvider businessProvider,
  ) async {
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    // Check if transaction has a customer
    if (transaction.customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign a customer to this transaction first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final customer = customerProvider.getCustomerById(transaction.customerId!);
    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Generate invoice number
      final invoiceNumber = await invoiceProvider.generateInvoiceNumber(
        businessProvider.business!.id,
      );

      // Create invoice from transaction
      final invoice = InvoiceModel(
        id: const Uuid().v4(),
        businessId: businessProvider.business!.id,
        userId:
            businessProvider
                .business!
                .userId, // Already present - this is correct
        customerId: transaction.customerId,
        invoiceNumber: invoiceNumber,
        invoiceType: InvoiceType.customer,
        invoiceDate: transaction.date,
        dueDate:
            transaction.dueDate ??
            transaction.date.add(const Duration(days: 30)),
        subtotal: transaction.amount,
        taxAmount: 0.0,
        discountAmount: 0.0,
        totalAmount: transaction.amount,
        paidAmount:
            transaction.status == TransactionStatus.completed
                ? transaction.amount
                : 0.0,
        status:
            transaction.status == TransactionStatus.completed
                ? InvoiceStatus.paid
                : InvoiceStatus.sent,
        notes: transaction.notes ?? transaction.description,
        items: [
          InvoiceItemModel(
            id: const Uuid().v4(),
            invoiceId: '', // Will be set after invoice creation
            name: transaction.description,
            description: transaction.notes,
            quantity: 1.0,
            unitPrice: transaction.amount,
            taxRate: 0.0,
            discountRate: 0.0,
            totalAmount: transaction.amount,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save invoice
      final success = await invoiceProvider.addInvoice(invoice);

      if (mounted) {
        Navigator.pop(context);

        if (success) {
          // Update transaction with invoice number
          final updatedTransaction = transaction.copyWith(
            invoiceNumber: invoiceNumber,
          );
          final transactionProvider = Provider.of<TransactionProvider>(
            context,
            listen: false,
          );
          await transactionProvider.updateTransaction(updatedTransaction);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invoice $invoiceNumber created successfully!'),
              backgroundColor: AppTheme.successColor,
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/invoices');
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create invoice'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating invoice: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _generateInvoice(
    TransactionModel transaction,
    BusinessProvider businessProvider,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Generate PDF for single transaction
      final pdfData = await PdfService.generateTransactionReport(
        business: businessProvider.business!,
        transactions: [transaction],
        startDate: transaction.date,
        endDate: transaction.date,
        title: 'Transaction Receipt',
      );

      // Save PDF
      final fileName =
          'transaction_${transaction.id}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      await PdfService.savePdf(pdfData, fileName);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice generated and saved successfully!'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating invoice: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _shareInvoice(
    TransactionModel transaction,
    BusinessProvider businessProvider,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Generate PDF for single transaction
      final pdfData = await PdfService.generateTransactionReport(
        business: businessProvider.business!,
        transactions: [transaction],
        startDate: transaction.date,
        endDate: transaction.date,
        title: 'Transaction Receipt',
      );

      // Save and share PDF
      final fileName =
          'transaction_${transaction.id}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      await PdfService.sharePdf(pdfData, fileName);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice shared successfully!'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing invoice: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Transactions'),
            content: StatefulBuilder(
              builder:
                  (context, setState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Type',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      ListTile(
                        title: const Text('All'),
                        leading: Radio<String>(
                          value: 'all',
                          groupValue: _filterType,
                          onChanged:
                              (value) => setState(() => _filterType = value!),
                        ),
                        onTap: () => setState(() => _filterType = 'all'),
                      ),
                      ListTile(
                        title: const Text('Income'),
                        leading: Radio<String>(
                          value: 'income',
                          groupValue: _filterType,
                          onChanged:
                              (value) => setState(() => _filterType = value!),
                        ),
                        onTap: () => setState(() => _filterType = 'income'),
                      ),
                      ListTile(
                        title: const Text('Expense'),
                        leading: Radio<String>(
                          value: 'expense',
                          groupValue: _filterType,
                          onChanged:
                              (value) => setState(() => _filterType = value!),
                        ),
                        onTap: () => setState(() => _filterType = 'expense'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Date Range',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _startDate = date);
                                }
                              },
                              child: Text(
                                _startDate != null
                                    ? DateFormat('MMM dd').format(_startDate!)
                                    : 'Start Date',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate ?? DateTime.now(),
                                  firstDate: _startDate ?? DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _endDate = date);
                                }
                              },
                              child: Text(
                                _endDate != null
                                    ? DateFormat('MMM dd').format(_endDate!)
                                    : 'End Date',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_startDate != null || _endDate != null)
                        TextButton(
                          onPressed:
                              () => setState(() {
                                _startDate = null;
                                _endDate = null;
                              }),
                          child: const Text('Clear Dates'),
                        ),
                    ],
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {}); // Refresh the main screen
                },
                child: const Text('Apply'),
              ),
            ],
          ),
    );
  }
}
