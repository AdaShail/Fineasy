import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../services/whatsapp_service.dart';
import '../../services/whatsapp_launcher_service.dart';
import '../../services/payment_url_service.dart';
import '../../services/upi_service.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/invoice_model.dart';
import '../../models/customer_model.dart';
import '../../models/transaction_model.dart';

class ReceivablesManagementScreen extends StatefulWidget {
  const ReceivablesManagementScreen({super.key});

  @override
  State<ReceivablesManagementScreen> createState() =>
      _ReceivablesManagementScreenState();
}

class _ReceivablesManagementScreenState
    extends State<ReceivablesManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGroupedView = true; // Toggle between grouped and list view

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receivables Management'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // View toggle button (only show on Pending Payments tab)
          if (_tabController.index == 1)
            IconButton(
              icon: Icon(_isGroupedView ? Icons.view_list : Icons.view_module),
              tooltip: _isGroupedView ? 'List View' : 'Grouped View',
              onPressed: () {
                setState(() {
                  _isGroupedView = !_isGroupedView;
                });
              },
            ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: _showSearchDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            // Use post-frame callback to avoid setState during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {});
              }
            });
          },
          tabs: const [
            Tab(text: 'Invoices Sent', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Pending Payments', icon: Icon(Icons.pending_actions)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildInvoicesSentTab(), _buildPendingPaymentsTab()],
      ),
    );
  }

  Widget _buildInvoicesSentTab() {
    return Consumer3<InvoiceProvider, CustomerProvider, BusinessProvider>(
      builder: (
        context,
        invoiceProvider,
        customerProvider,
        businessProvider,
        child,
      ) {
        final invoices =
            invoiceProvider.invoices
                .where(
                  (inv) =>
                      inv.status == InvoiceStatus.sent ||
                      inv.status == InvoiceStatus.overdue,
                )
                .toList()
              ..sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));

        if (invoiceProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (invoices.isEmpty) {
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
                  'No invoices sent yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create and send invoices to track receivables',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (businessProvider.business != null) {
              await invoiceProvider.loadInvoices(businessProvider.business!.id);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              final customer = customerProvider.getCustomerById(
                invoice.customerId ?? '',
              );
              return _buildInvoiceCard(invoice, customer);
            },
          ),
        );
      },
    );
  }

  Widget _buildPendingPaymentsTab() {
    return Consumer4<
      InvoiceProvider,
      CustomerProvider,
      TransactionProvider,
      BusinessProvider
    >(
      builder: (
        context,
        invoiceProvider,
        customerProvider,
        transactionProvider,
        businessProvider,
        child,
      ) {
        // Get pending invoices
        final pendingInvoices =
            invoiceProvider.invoices
                .where(
                  (inv) =>
                      inv.outstandingAmount > 0 &&
                      inv.status != InvoiceStatus.cancelled,
                )
                .toList();

        // Get pending transactions (with due dates, not yet paid, NOT linked to invoices)
        // This prevents double-counting when a transaction has both due date and invoice
        final pendingTransactions =
            transactionProvider.transactions
                .where(
                  (txn) =>
                      txn.customerId != null &&
                      txn.dueDate != null &&
                      txn.status == TransactionStatus.pending &&
                      txn.type == TransactionType.income &&
                      (txn.invoiceId == null || txn.invoiceId!.isEmpty), // Exclude transactions with invoices
                )
                .toList();

        // Combine all pending payments
        final allPendingPayments = <Map<String, dynamic>>[];

        // Add invoice-based payments
        for (var invoice in pendingInvoices) {
          final customer = customerProvider.getCustomerById(
            invoice.customerId ?? '',
          );
          allPendingPayments.add({
            'type': 'invoice',
            'invoice': invoice,
            'customer': customer,
            'amount': invoice.outstandingAmount,
            'dueDate':
                invoice.dueDate ?? DateTime.now().add(const Duration(days: 7)),
            'isOverdue': invoice.isOverdue,
            'description': 'Invoice #${invoice.invoiceNumber}',
          });
        }

        // Add transaction-based pending payments
        for (var transaction in pendingTransactions) {
          final customer = customerProvider.getCustomerById(
            transaction.customerId!,
          );
          if (customer != null) {
            final isOverdue = transaction.dueDate!.isBefore(DateTime.now());
            allPendingPayments.add({
              'type': 'transaction',
              'transaction': transaction,
              'customer': customer,
              'amount': transaction.amount,
              'dueDate': transaction.dueDate!,
              'isOverdue': isOverdue,
              'description': transaction.description,
            });
          }
        }

        // Add customer balance-based payments (not covered by invoices or transactions)
        final customersWithBalance =
            customerProvider.customers
                .where((customer) => customer.balance > 0)
                .toList();

        for (var customer in customersWithBalance) {
          // Check if this customer already has invoices or transactions listed
          final hasInvoice = pendingInvoices.any(
            (inv) => inv.customerId == customer.id,
          );
          final hasTransaction = pendingTransactions.any(
            (txn) => txn.customerId == customer.id,
          );

          if (!hasInvoice && !hasTransaction) {
            // Calculate due date: last transaction + 30 days, or 7 days from now
            final dueDate =
                customer.lastTransactionDate?.add(const Duration(days: 30)) ??
                DateTime.now().add(const Duration(days: 7));
            final isOverdue = dueDate.isBefore(DateTime.now());

            allPendingPayments.add({
              'type': 'balance',
              'customer': customer,
              'amount': customer.balance,
              'dueDate': dueDate,
              'isOverdue': isOverdue,
              'description': 'Outstanding Balance',
            });
          }
        }

        // Group by customer
        final Map<String, List<Map<String, dynamic>>> customerGroups = {};
        for (var payment in allPendingPayments) {
          final customer = payment['customer'] as CustomerModel?;
          if (customer != null) {
            if (!customerGroups.containsKey(customer.id)) {
              customerGroups[customer.id] = [];
            }
            customerGroups[customer.id]!.add(payment);
          }
        }

        // Sort each customer's transactions by due date
        for (var transactions in customerGroups.values) {
          transactions.sort((a, b) {
            if (a['isOverdue'] && !b['isOverdue']) return -1;
            if (!a['isOverdue'] && b['isOverdue']) return 1;
            return (a['dueDate'] as DateTime).compareTo(
              b['dueDate'] as DateTime,
            );
          });
        }

        // Create list of customers sorted by earliest due date
        final sortedCustomers =
            customerGroups.keys.map((customerId) {
                final transactions = customerGroups[customerId]!;
                final customer =
                    transactions.first['customer'] as CustomerModel;
                final earliestDueDate =
                    transactions.first['dueDate'] as DateTime;
                final hasOverdue = transactions.any(
                  (t) => t['isOverdue'] as bool,
                );
                final totalAmount = transactions.fold<double>(
                  0,
                  (sum, t) => sum + (t['amount'] as double),
                );
                return {
                  'customer': customer,
                  'transactions': transactions,
                  'earliestDueDate': earliestDueDate,
                  'hasOverdue': hasOverdue,
                  'totalAmount': totalAmount,
                };
              }).toList()
              ..sort((a, b) {
                final aOverdue = a['hasOverdue'] as bool;
                final bOverdue = b['hasOverdue'] as bool;
                if (aOverdue && !bOverdue) return -1;
                if (!aOverdue && bOverdue) return 1;
                return (a['earliestDueDate'] as DateTime).compareTo(
                  b['earliestDueDate'] as DateTime,
                );
              });

        if (invoiceProvider.isLoading || transactionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (sortedCustomers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No pending payments!',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'All payments are up to date',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (businessProvider.business != null) {
              await Future.wait([
                invoiceProvider.loadInvoices(businessProvider.business!.id),
                customerProvider.loadCustomers(businessProvider.business!.id),
                transactionProvider.refreshTransactions(
                  businessProvider.business!.id,
                ),
              ]);
            }
          },
          child:
              _isGroupedView
                  ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedCustomers.length,
                    itemBuilder: (context, index) {
                      final customerGroup = sortedCustomers[index];
                      return _buildCustomerGroupCard(
                        customerGroup['customer'] as CustomerModel,
                        customerGroup['transactions']
                            as List<Map<String, dynamic>>,
                        customerGroup['totalAmount'] as double,
                        customerGroup['hasOverdue'] as bool,
                        businessProvider.business,
                      );
                    },
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allPendingPayments.length,
                    itemBuilder: (context, index) {
                      final payment = allPendingPayments[index];
                      if (payment['type'] == 'invoice') {
                        return _buildPaymentCard(
                          payment['invoice'],
                          payment['customer'],
                          businessProvider.business,
                        );
                      } else if (payment['type'] == 'transaction') {
                        return _buildTransactionPaymentCard(
                          payment['transaction'],
                          payment['customer'],
                          payment['amount'],
                          payment['dueDate'],
                          payment['isOverdue'],
                          businessProvider.business,
                        );
                      } else {
                        return _buildCustomerBalanceCard(
                          payment['customer'],
                          payment['amount'],
                          payment['dueDate'],
                          payment['isOverdue'],
                          businessProvider.business,
                        );
                      }
                    },
                  ),
        );
      },
    );
  }

  Widget _buildCustomerGroupCard(
    CustomerModel customer,
    List<Map<String, dynamic>> transactions,
    double totalAmount,
    bool hasOverdue,
    dynamic business,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: hasOverdue ? Colors.red : AppTheme.primaryColor,
          child: Text(
            customer.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: InkWell(
          onTap: () => _showCustomerTransactionHistory(customer, business),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phone != null)
              Text(
                customer.phone!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            const SizedBox(height: 4),
            Text(
              '${transactions.length} pending transaction(s)',
              style: TextStyle(
                fontSize: 12,
                color: hasOverdue ? Colors.red : Colors.grey[600],
                fontWeight: hasOverdue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: hasOverdue ? Colors.red : AppTheme.primaryColor,
              ),
            ),
            if (hasOverdue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'OVERDUE',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // List all transactions
                ...transactions.map((payment) {
                  if (payment['type'] == 'invoice') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCompactTransactionCard(
                        payment['description'] as String,
                        payment['amount'] as double,
                        payment['dueDate'] as DateTime,
                        payment['isOverdue'] as bool,
                        () => _sendCompletePaymentReminder(
                          payment['invoice'] as InvoiceModel,
                          customer,
                          business,
                        ),
                      ),
                    );
                  } else if (payment['type'] == 'transaction') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCompactTransactionCard(
                        payment['description'] as String,
                        payment['amount'] as double,
                        payment['dueDate'] as DateTime,
                        payment['isOverdue'] as bool,
                        () => _sendTransactionPaymentReminder(
                          payment['transaction'] as TransactionModel,
                          customer,
                          payment['amount'] as double,
                          payment['dueDate'] as DateTime,
                          business,
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCompactTransactionCard(
                        payment['description'] as String,
                        payment['amount'] as double,
                        payment['dueDate'] as DateTime,
                        payment['isOverdue'] as bool,
                        () => _sendCustomerBalanceReminder(
                          customer,
                          payment['amount'] as double,
                          payment['dueDate'] as DateTime,
                          business,
                        ),
                      ),
                    );
                  }
                }).toList(),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            () => _showCustomerTransactionHistory(
                              customer,
                              business,
                            ),
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text('View History'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _showConsolidatedReminderDialog(
                              customer,
                              business,
                            ),
                        icon: const Icon(Icons.send, size: 18),
                        label: const Text('Send All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTransactionCard(
    String description,
    double amount,
    DateTime dueDate,
    bool isOverdue,
    VoidCallback onSendIndividual,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverdue ? Colors.red[200]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: isOverdue ? Colors.red[700] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('dd MMM yyyy').format(dueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red[700] : Colors.grey[600],
                        fontWeight:
                            isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOverdue ? Colors.red[700] : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: onSendIndividual,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice, CustomerModel? customer) {
    final customerName = customer?.name ?? 'Unknown Customer';
    final statusStr = invoice.isOverdue ? 'overdue' : invoice.status.name;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Invoice #${invoice.invoiceNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(statusStr),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              customerName,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${invoice.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Due Date',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      invoice.dueDate != null
                          ? DateFormat('dd MMM yyyy').format(invoice.dueDate!)
                          : 'No due date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: invoice.isOverdue ? Colors.red : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (invoice.status == InvoiceStatus.sent || invoice.isOverdue)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton.icon(
                  onPressed:
                      customer != null
                          ? () => _sendPaymentReminder(invoice, customer)
                          : null,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Send Payment Reminder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionPaymentCard(
    TransactionModel transaction,
    CustomerModel customer,
    double amount,
    DateTime dueDate,
    bool isOverdue,
    dynamic business,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      if (customer.phone != null)
                        Text(
                          customer.phone!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                _buildPaymentTypeChip('transaction'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount Due',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Due Date',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(dueDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isOverdue ? Colors.red : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ], // <-- This closing bracket was here
            ),
            if (isOverdue)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Overdue by ${DateTime.now().difference(dueDate).inDays} days',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        business != null
                            ? () => _sendTransactionPaymentReminder(
                              transaction,
                              customer,
                              amount,
                              dueDate,
                              business,
                            )
                            : null,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Send This'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        business != null
                            ? () => _showConsolidatedReminderDialog(
                              customer,
                              business,
                            )
                            : null,
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: const Text('Send All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerBalanceCard(
    CustomerModel customer,
    double amount,
    DateTime dueDate,
    bool isOverdue,
    dynamic business,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Outstanding Balance',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (customer.phone != null)
                        Text(
                          customer.phone!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                _buildPaymentTypeChip('balance'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount Due',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Due Date',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(dueDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isOverdue ? Colors.red : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isOverdue)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Overdue by ${DateTime.now().difference(dueDate).inDays} days',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        business != null
                            ? () => _sendCustomerBalanceReminder(
                              customer,
                              amount,
                              dueDate,
                              business,
                            )
                            : null,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Send This'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        business != null
                            ? () => _showConsolidatedReminderDialog(
                              customer,
                              business,
                            )
                            : null,
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: const Text('Send All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
    InvoiceModel invoice,
    CustomerModel? customer,
    dynamic business,
  ) {
    final customerName = customer?.name ?? 'Unknown Customer';
    final description = 'Invoice #${invoice.invoiceNumber}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                _buildPaymentTypeChip('invoice'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outstanding',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '₹${invoice.outstandingAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Due Date',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      invoice.dueDate != null
                          ? DateFormat('dd MMM yyyy').format(invoice.dueDate!)
                          : 'No due date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: invoice.isOverdue ? Colors.red : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (invoice.isOverdue)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Overdue by ${invoice.daysOverdue} days',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed:
                  customer != null && business != null
                      ? () => _sendCompletePaymentReminder(
                        invoice,
                        customer,
                        business,
                      )
                      : null,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Send Payment Link (WhatsApp + GPay)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'paid':
        color = Colors.green;
        label = 'Paid';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'overdue':
        color = Colors.red;
        label = 'Overdue';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _sendTransactionPaymentReminder(
    TransactionModel transaction,
    CustomerModel customer,
    double amount,
    DateTime dueDate,
    dynamic business,
  ) async {
    if (customer.phone == null || customer.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer phone number not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show UPI ID input dialog if not configured
    final upiId = await _showUpiIdDialog();
    if (upiId == null || upiId.isEmpty) {
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Send payment link via WhatsApp with UPI/GPay integration
      await PaymentUrlService.sharePaymentViaWhatsApp(
        context: context,
        phoneNumber: customer.phone!,
        customerName: customer.name,
        upiId: upiId,
        payeeName: business.name,
        amount: amount,
        transactionNote: transaction.description,
        businessName: business.name,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending payment link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendCustomerBalanceReminder(
    CustomerModel customer,
    double amount,
    DateTime dueDate,
    dynamic business,
  ) async {
    if (customer.phone == null || customer.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer phone number not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show UPI ID input dialog if not configured
    final upiId = await _showUpiIdDialog();
    if (upiId == null || upiId.isEmpty) {
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Send payment link via WhatsApp with UPI/GPay integration
      await PaymentUrlService.sharePaymentViaWhatsApp(
        context: context,
        phoneNumber: customer.phone!,
        customerName: customer.name,
        upiId: upiId,
        payeeName: business.name,
        amount: amount,
        transactionNote: 'Payment for outstanding balance',
        businessName: business.name,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending payment link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPaymentTypeChip(String type) {
    Color color;
    IconData icon;

    switch (type) {
      case 'invoice':
        color = Colors.blue;
        icon = Icons.receipt_long;
        break;
      case 'transaction':
        color = Colors.purple;
        icon = Icons.swap_horiz;
        break;
      case 'balance':
        color = Colors.orange;
        icon = Icons.account_balance_wallet;
        break;
      case 'sales':
        color = Colors.green;
        icon = Icons.shopping_cart;
        break;
      case 'credit':
        color = Colors.purple;
        icon = Icons.credit_card;
        break;
      default:
        color = Colors.grey;
        icon = Icons.payment;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            type.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPaymentReminder(
    InvoiceModel invoice,
    CustomerModel customer,
  ) async {
    if (customer.phone == null || customer.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer phone number not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Send WhatsApp payment reminder
      final success = await WhatsAppService.sendPaymentReminderWithDetails(
        phoneNumber: customer.phone!,
        customerName: customer.name,
        amount: invoice.outstandingAmount,
        invoiceNumber: invoice.invoiceNumber,
        dueDate: invoice.dueDate,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Payment reminder sent successfully!'
                  : 'Failed to send reminder. Please try again.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendCompletePaymentReminder(
    InvoiceModel invoice,
    CustomerModel customer,
    dynamic business,
  ) async {
    if (customer.phone == null || customer.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer phone number not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show UPI ID input dialog if not configured
    final upiId = await _showUpiIdDialog();
    if (upiId == null || upiId.isEmpty) {
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Send payment link via WhatsApp with UPI/GPay integration
      final success = await PaymentUrlService.sharePaymentViaWhatsApp(
        context: context,
        phoneNumber: customer.phone!,
        customerName: customer.name,
        upiId: upiId,
        payeeName: business.name,
        amount: invoice.outstandingAmount,
        transactionNote: 'Payment for Invoice #${invoice.invoiceNumber}',
        businessName: business.name,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          // Update invoice to mark WhatsApp sent
          final updatedInvoice = invoice.copyWith(
            whatsappSent: true,
            whatsappSentAt: DateTime.now(),
          );

          final invoiceProvider = Provider.of<InvoiceProvider>(
            context,
            listen: false,
          );
          await invoiceProvider.updateInvoice(updatedInvoice);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending payment link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showUpiIdDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enter UPI ID'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please enter your UPI ID to generate payment link',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'UPI ID',
                    hintText: 'yourname@upi',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Navigator.pop(context, controller.text);
                  }
                },
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  void _showSearchDialog() {
    // TODO: Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search functionality coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showCustomerTransactionHistory(
    CustomerModel customer,
    dynamic business,
  ) async {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    // Get all transactions for this customer (both income and expense)
    final customerTransactions =
        transactionProvider.transactions
            .where((txn) => txn.customerId == customer.id)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    // Separate into receivables (income) and payables (expense)
    final receivables =
        customerTransactions
            .where((txn) => txn.type == TransactionType.income)
            .toList();
    final payables =
        customerTransactions
            .where((txn) => txn.type == TransactionType.expense)
            .toList();

    // Calculate totals (only pending amounts)
    final totalReceivablePending = receivables.fold<double>(
      0,
      (sum, txn) =>
          sum + (txn.status == TransactionStatus.pending ? txn.amount : 0),
    );
    final totalPayablePending = payables.fold<double>(
      0,
      (sum, txn) =>
          sum + (txn.status == TransactionStatus.pending ? txn.amount : 0),
    );

    // Calculate all-time totals for display
    final totalReceivableAll = receivables.fold<double>(
      0,
      (sum, txn) => sum + txn.amount,
    );
    final totalPayableAll = payables.fold<double>(
      0,
      (sum, txn) => sum + txn.amount,
    );

    await showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(
                            customer.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (customer.phone != null)
                                Text(
                                  customer.phone!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Summary Cards
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDetailedSummaryCard(
                            'They Owe You',
                            totalReceivablePending,
                            totalReceivableAll,
                            Colors.green,
                            Icons.arrow_downward,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDetailedSummaryCard(
                            'You Owe Them',
                            totalPayablePending,
                            totalPayableAll,
                            Colors.red,
                            Icons.arrow_upward,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabs for Receivables and Payables
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: AppTheme.primaryColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: AppTheme.primaryColor,
                            tabs: [
                              Tab(text: 'Receivables (${receivables.length})'),
                              Tab(text: 'Payables (${payables.length})'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildTransactionList(receivables, true),
                                _buildTransactionList(payables, false),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailedSummaryCard(
    String title,
    double pendingAmount,
    double totalAmount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${pendingAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (totalAmount != pendingAmount)
            Column(
              children: [
                const SizedBox(height: 4),
                Text(
                  'Pending',
                  style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ₹${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    List<TransactionModel> transactions,
    bool isReceivable,
  ) {
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
              'No ${isReceivable ? 'receivables' : 'payables'} found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final txn = transactions[index];
        final isPending = txn.status == TransactionStatus.pending;
        final isOverdue =
            txn.dueDate != null &&
            txn.dueDate!.isBefore(DateTime.now()) &&
            isPending;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isPending
                      ? (isOverdue ? Colors.red : Colors.orange)
                      : Colors.green,
              child: Icon(
                isPending ? Icons.pending : Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              txn.description,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(txn.date),
                  style: const TextStyle(fontSize: 12),
                ),
                if (txn.dueDate != null)
                  Text(
                    'Due: ${DateFormat('dd MMM yyyy').format(txn.dueDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontWeight:
                          isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                Text(
                  txn.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: isPending ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${txn.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isReceivable ? Colors.green : Colors.red,
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'OVERDUE',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showConsolidatedReminderDialog(
    CustomerModel customer,
    dynamic business,
  ) async {
    // Get all pending transactions for this customer
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    final pendingTransactions =
        transactionProvider.transactions
            .where(
              (txn) =>
                  txn.customerId == customer.id &&
                  txn.status == TransactionStatus.pending &&
                  txn.type == TransactionType.income,
            )
            .toList()
          ..sort(
            (a, b) => (a.dueDate ?? a.date).compareTo(b.dueDate ?? b.date),
          );

    if (pendingTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pending transactions found for this customer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show dialog with selectable transaction list
    final result = await showDialog<List<TransactionModel>>(
      context: context,
      builder:
          (context) => _SelectableTransactionsDialog(
            customer: customer,
            transactions: pendingTransactions,
          ),
    );

    if (result != null && result.isNotEmpty) {
      final totalAmount = result.fold<double>(
        0,
        (sum, txn) => sum + txn.amount,
      );
      await _sendConsolidatedReminder(customer, result, totalAmount, business);
    }
  }

  Future<void> _sendConsolidatedReminder(
    CustomerModel customer,
    List<TransactionModel> transactions,
    double totalAmount,
    dynamic business,
  ) async {
    if (customer.phone == null || customer.phone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer phone number not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show UPI ID input dialog
    final upiId = await _showUpiIdDialog();
    if (upiId == null || upiId.isEmpty) {
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Build consolidated message
      final buffer = StringBuffer();
      buffer.writeln('Hello ${customer.name},');
      buffer.writeln();
      buffer.writeln('Payment Reminder from ${business.name}');
      buffer.writeln();
      buffer.writeln('You have ${transactions.length} pending payment(s):');
      buffer.writeln();

      for (var i = 0; i < transactions.length; i++) {
        final txn = transactions[i];
        final dueDate = txn.dueDate ?? txn.date;
        buffer.writeln('${i + 1}. ${txn.description}');
        buffer.writeln('   Amount: ₹${txn.amount.toStringAsFixed(2)}');
        buffer.writeln('   Due: ${DateFormat('dd MMM yyyy').format(dueDate)}');
        buffer.writeln();
      }

      buffer.writeln('Total Amount Due: ₹${totalAmount.toStringAsFixed(2)}');
      buffer.writeln();
      buffer.writeln('Pay now using UPI:');

      // Generate UPI link
      final upiLink = UpiService.generateUpiLink(
        upiId: upiId,
        payeeName: business.name,
        amount: totalAmount,
        transactionNote: 'Payment for ${transactions.length} transactions',
      );

      buffer.writeln(upiLink);
      buffer.writeln();
      buffer.writeln('Thank you!');
      buffer.writeln(business.name);

      // Send via WhatsApp
      await WhatsAppLauncherService.sendMessageWithFeedback(
        context: context,
        phoneNumber: customer.phone!,
        message: buffer.toString(),
        successMessage: 'Consolidated reminder sent successfully!',
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending reminder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Selectable Transactions Dialog
class _SelectableTransactionsDialog extends StatefulWidget {
  final CustomerModel customer;
  final List<TransactionModel> transactions;

  const _SelectableTransactionsDialog({
    required this.customer,
    required this.transactions,
  });

  @override
  State<_SelectableTransactionsDialog> createState() =>
      _SelectableTransactionsDialogState();
}

class _SelectableTransactionsDialogState
    extends State<_SelectableTransactionsDialog> {
  late List<bool> _selectedTransactions;
  bool _selectAll = true;

  @override
  void initState() {
    super.initState();
    // All selected by default
    _selectedTransactions = List.filled(widget.transactions.length, true);
  }

  double get _selectedTotal {
    double total = 0;
    for (int i = 0; i < widget.transactions.length; i++) {
      if (_selectedTransactions[i]) {
        total += widget.transactions[i].amount;
      }
    }
    return total;
  }

  int get _selectedCount {
    return _selectedTransactions.where((selected) => selected).length;
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedTransactions = List.filled(
        widget.transactions.length,
        _selectAll,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Send Reminder to ${widget.customer.name}'),
          const SizedBox(height: 4),
          Text(
            'Select transactions to include',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Select All checkbox
            CheckboxListTile(
              title: const Text(
                'Select All',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: _selectAll,
              onChanged: (value) => _toggleSelectAll(),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const Divider(),

            // Transaction list
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.transactions.length,
                itemBuilder: (context, index) {
                  final txn = widget.transactions[index];
                  final dueDate = txn.dueDate ?? txn.date;
                  final isOverdue = dueDate.isBefore(DateTime.now());

                  return CheckboxListTile(
                    value: _selectedTransactions[index],
                    onChanged: (value) {
                      setState(() {
                        _selectedTransactions[index] = value ?? false;
                        _selectAll = _selectedTransactions.every((s) => s);
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      txn.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Due: ${DateFormat('dd MMM yyyy').format(dueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : Colors.grey[600],
                      ),
                    ),
                    secondary: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${txn.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (isOverdue)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'OVERDUE',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$_selectedCount transaction(s)',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₹${_selectedTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed:
              _selectedCount > 0
                  ? () {
                    final selected = <TransactionModel>[];
                    for (int i = 0; i < widget.transactions.length; i++) {
                      if (_selectedTransactions[i]) {
                        selected.add(widget.transactions[i]);
                      }
                    }
                    Navigator.pop(context, selected);
                  }
                  : null,
          icon: const Icon(Icons.send),
          label: Text('Send ${_selectedCount > 0 ? '($_selectedCount)' : ''}'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
