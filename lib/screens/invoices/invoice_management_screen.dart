import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'package:provider/provider.dart';
import '../../models/invoice_model.dart';
import '../../services/invoice_service.dart';
import '../../services/whatsapp_service.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/business_provider.dart';
import 'invoice_creation_screen.dart';
import 'invoice_detail_screen.dart';

class InvoiceManagementScreen extends StatefulWidget {
  const InvoiceManagementScreen({super.key});

  @override
  State<InvoiceManagementScreen> createState() =>
      _InvoiceManagementScreenState();
}

class _InvoiceManagementScreenState extends State<InvoiceManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<InvoiceModel> _customerInvoices = [];
  List<InvoiceModel> _supplierInvoices = [];
  List<InvoiceModel> _overdueInvoices = [];
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    if (businessProvider.business == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final businessId = businessProvider.business!.id;

      // Load invoices and stats in parallel
      final results = await Future.wait([
        InvoiceService.getInvoices(
          businessId: businessId,
          type: InvoiceType.customer,
        ),
        InvoiceService.getInvoices(
          businessId: businessId,
          type: InvoiceType.supplier,
        ),
        InvoiceService.getOverdueInvoices(businessId),
        InvoiceService.getInvoiceStats(businessId),
      ]);

      setState(() {
        _customerInvoices = results[0] as List<InvoiceModel>;
        _supplierInvoices = results[1] as List<InvoiceModel>;
        _overdueInvoices = results[2] as List<InvoiceModel>;
        _stats = results[3] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Customer Invoices', icon: Icon(Icons.person)),
            Tab(text: 'Supplier Invoices', icon: Icon(Icons.business)),
            Tab(text: 'Overdue', icon: Icon(Icons.warning)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  _loadData();
                  break;
                case 'stats':
                  _showStatsDialog();
                  break;
                case 'whatsapp_templates':
                  Navigator.of(context).pushNamed('/whatsapp-templates');
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Refresh'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'stats',
                    child: ListTile(
                      leading: Icon(Icons.analytics),
                      title: Text('Statistics'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'whatsapp_templates',
                    child: ListTile(
                      leading: Icon(Icons.message),
                      title: Text('WhatsApp Templates'),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildStatsCard(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildInvoicesList(
                          _customerInvoices,
                          InvoiceType.customer,
                        ),
                        _buildInvoicesList(
                          _supplierInvoices,
                          InvoiceType.supplier,
                        ),
                        _buildOverdueList(),
                      ],
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateInvoiceOptions(),
        icon: const Icon(Icons.add),
        label: const Text('Create Invoice'),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Invoices',
                    (_stats['total_count'] ?? 0).toString(),
                    Icons.receipt,
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Amount',
                    '₹${(_stats['total_amount'] ?? 0).toStringAsFixed(0)}',
                    Icons.currency_rupee,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Outstanding',
                    '₹${(_stats['outstanding_amount'] ?? 0).toStringAsFixed(0)}',
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Overdue',
                    (_stats['overdue_count'] ?? 0).toString(),
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInvoicesList(List<InvoiceModel> invoices, InvoiceType type) {
    if (invoices.isEmpty) {
      return _buildEmptyState(type);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return _buildInvoiceCard(invoice);
        },
      ),
    );
  }

  Widget _buildOverdueList() {
    if (_overdueInvoices.isEmpty) {
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
              'No Overdue Invoices',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.green[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'All invoices are up to date!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _overdueInvoices.length,
        itemBuilder: (context, index) {
          final invoice = _overdueInvoices[index];
          return _buildOverdueInvoiceCard(invoice);
        },
      ),
    );
  }

  Widget _buildEmptyState(InvoiceType type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == InvoiceType.customer
                ? Icons.person_outline
                : Icons.business_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${type.name.toUpperCase()} Invoices',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first ${type.name} invoice',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createInvoice(type),
            icon: const Icon(Icons.add),
            label: Text('Create ${type.name.toUpperCase()} Invoice'),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _viewInvoiceDetails(invoice),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice #${invoice.invoiceNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<String>(
                          future: _getPartyName(invoice),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Loading...',
                              style: TextStyle(color: Colors.grey[600]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${invoice.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(invoice.status),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (invoice.dueDate != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.event, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${invoice.dueDate!.day}/${invoice.dueDate!.month}/${invoice.dueDate!.year}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                  const Spacer(),
                  if (invoice.whatsappSent)
                    Icon(Icons.message, size: 16, color: Colors.green[600]),
                ],
              ),
              if (invoice.outstandingAmount > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Outstanding: ₹${invoice.outstandingAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverdueInvoiceCard(InvoiceModel invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.red.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () => _viewInvoiceDetails(invoice),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice #${invoice.invoiceNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<String>(
                          future: _getPartyName(invoice),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Loading...',
                              style: TextStyle(color: Colors.grey[600]),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${invoice.outstandingAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${invoice.daysOverdue} days overdue',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _sendPaymentReminder(invoice),
                      icon: const Icon(Icons.message, size: 16),
                      label: const Text('Send Reminder'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange[700],
                        side: BorderSide(color: Colors.orange[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _recordPayment(invoice),
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Record Payment'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
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

  Widget _buildStatusChip(InvoiceStatus status) {
    Color color;
    String label;

    switch (status) {
      case InvoiceStatus.draft:
        color = Colors.grey;
        label = 'Draft';
        break;
      case InvoiceStatus.sent:
        color = Colors.blue;
        label = 'Sent';
        break;
      case InvoiceStatus.paid:
        color = Colors.green;
        label = 'Paid';
        break;
      case InvoiceStatus.partiallyPaid:
        color = Colors.amber;
        label = 'Partially Paid';
        break;
      case InvoiceStatus.overdue:
        color = Colors.red;
        label = 'Overdue';
        break;
      case InvoiceStatus.cancelled:
        color = Colors.orange;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<String> _getPartyName(InvoiceModel invoice) async {
    if (invoice.customerId != null) {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final customer =
          customerProvider.customers
              .where((c) => c.id == invoice.customerId)
              .firstOrNull;
      return customer?.name ?? 'Unknown Customer';
    } else if (invoice.supplierId != null) {
      final supplierProvider = Provider.of<SupplierProvider>(
        context,
        listen: false,
      );
      final supplier =
          supplierProvider.suppliers
              .where((s) => s.id == invoice.supplierId)
              .firstOrNull;
      return supplier?.name ?? 'Unknown Supplier';
    }
    return 'Unknown';
  }

  void _showCreateInvoiceOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Invoice',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Customer Invoice'),
                  subtitle: const Text('Invoice for sales to customers'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _createInvoice(InvoiceType.customer);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business, color: Colors.orange),
                  title: const Text('Supplier Invoice'),
                  subtitle: const Text('Invoice for purchases from suppliers'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _createInvoice(InvoiceType.supplier);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _createInvoice(InvoiceType type) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => InvoiceCreationScreen(invoiceType: type),
          ),
        )
        .then((_) => _loadData());
  }

  void _viewInvoiceDetails(InvoiceModel invoice) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => InvoiceDetailScreen(invoice: invoice),
          ),
        )
        .then((_) => _loadData());
  }

  void _sendPaymentReminder(InvoiceModel invoice) async {
    if (invoice.customerId != null) {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final customer =
          customerProvider.customers
              .where((c) => c.id == invoice.customerId)
              .firstOrNull;

      if (customer != null) {
        final success = await WhatsAppService.sendInvoiceWithTemplate(
          templateId: 'payment_reminder_template',
          phoneNumber: customer.phone ?? '',
          templateData: {
            'invoice_number': invoice.invoiceNumber,
            'customer_name': customer.name,
            'total_amount': invoice.totalAmount,
            'due_date': invoice.dueDate?.toIso8601String(),
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Payment reminder sent successfully'
                    : 'Failed to send payment reminder',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    }
  }

  void _recordPayment(InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (context) => PaymentRecordDialog(invoice: invoice),
    ).then((_) => _loadData());
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Invoice Statistics'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow(
                  'Total Invoices',
                  (_stats['total_count'] ?? 0).toString(),
                ),
                _buildStatRow(
                  'Total Amount',
                  '₹${(_stats['total_amount'] ?? 0).toStringAsFixed(2)}',
                ),
                _buildStatRow(
                  'Paid Amount',
                  '₹${(_stats['paid_amount'] ?? 0).toStringAsFixed(2)}',
                ),
                _buildStatRow(
                  'Outstanding',
                  '₹${(_stats['outstanding_amount'] ?? 0).toStringAsFixed(2)}',
                ),
                _buildStatRow(
                  'Collection Rate',
                  '${(_stats['collection_rate'] ?? 0).toStringAsFixed(1)}%',
                ),
                const Divider(),
                _buildStatRow(
                  'Paid Invoices',
                  (_stats['paid_count'] ?? 0).toString(),
                ),
                _buildStatRow(
                  'Overdue Invoices',
                  (_stats['overdue_count'] ?? 0).toString(),
                ),
                _buildStatRow(
                  'Draft Invoices',
                  (_stats['draft_count'] ?? 0).toString(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class PaymentRecordDialog extends StatefulWidget {
  final InvoiceModel invoice;

  const PaymentRecordDialog({super.key, required this.invoice});

  @override
  State<PaymentRecordDialog> createState() => _PaymentRecordDialogState();
}

class _PaymentRecordDialogState extends State<PaymentRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'cash';
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.invoice.outstandingAmount.toStringAsFixed(
      2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Payment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '₹',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter valid amount';
                }
                if (amount > widget.invoice.outstandingAmount) {
                  return 'Amount cannot exceed outstanding amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Payment Method'),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'card', child: Text('Card')),
                DropdownMenuItem(value: 'upi', child: Text('UPI')),
                DropdownMenuItem(
                  value: 'netBanking',
                  child: Text('Net Banking'),
                ),
                DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _paymentDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _paymentDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Payment Date'),
                child: Text(
                  '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (Optional)'),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _recordPayment,
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Record'),
        ),
      ],
    );
  }

  Future<void> _recordPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final success = await InvoiceService.recordPayment(
        invoiceId: widget.invoice.id,
        amount: amount,
        paymentMethod: _paymentMethod,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        paymentDate: _paymentDate,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment recorded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to record payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
