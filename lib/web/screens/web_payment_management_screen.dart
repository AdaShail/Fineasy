import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/payment_model.dart';
import '../../models/customer_model.dart';
import '../../models/supplier_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/payment_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/business_provider.dart';
import '../../services/upi_service.dart';
import '../widgets/web_data_table.dart';
import '../widgets/web_card.dart';
import '../widgets/web_form_field.dart';
import '../widgets/web_date_picker.dart';
import '../widgets/web_dropdown.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../utils/app_theme.dart';

/// Web-optimized payment management screen
/// Requirements: 3.5
class WebPaymentManagementScreen extends StatefulWidget {
  const WebPaymentManagementScreen({super.key});

  @override
  State<WebPaymentManagementScreen> createState() =>
      _WebPaymentManagementScreenState();
}

class _WebPaymentManagementScreenState
    extends State<WebPaymentManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PaymentModel? _selectedPayment;
  String _searchQuery = '';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  PaymentMode? _filterPaymentMode;
  PaymentStatus? _filterStatus;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPayments() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      paymentProvider.loadPayments(
        businessId: businessProvider.business!.id,
        fromDate: _filterStartDate,
        toDate: _filterEndDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showRecordPaymentDialog,
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final payments = _getFilteredPayments(paymentProvider.payments);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search payments...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              // Payment list
              Expanded(
                child: payments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No payments found', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          final payment = payments[index];
                          return _buildMobilePaymentCard(payment);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobilePaymentCard(PaymentModel payment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(payment.status),
          child: Icon(
            payment.status == PaymentStatus.completed ? Icons.check : Icons.pending,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          '₹${payment.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${DateFormat('dd MMM yyyy').format(payment.paymentDate)} • ${payment.paymentMode.toString().split('.').last}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Chip(
          label: Text(
            payment.status.toString().split('.').last,
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: _getStatusColor(payment.status),
        ),
        onTap: () => setState(() => _selectedPayment = payment),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: _selectedPayment == null ? 1 : 2,
                  child: _buildPaymentList(),
                ),
                if (_selectedPayment != null)
                  Expanded(
                    flex: 3,
                    child: _buildPaymentDetail(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.payment, size: 32, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          const Text(
            'Payment Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildStatsCards(),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _showRecordPaymentDialog,
            icon: const Icon(Icons.add),
            label: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        final totalPayments = paymentProvider.totalPaymentsAmount;
        final pendingPayments = paymentProvider.totalPendingPayments;

        return Row(
          children: [
            _buildStatCard(
              'Total Payments',
              '₹${totalPayments.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              AppTheme.successColor,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Pending',
              '₹${pendingPayments.toStringAsFixed(2)}',
              Icons.pending,
              AppTheme.warningColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryColor,
        tabs: const [
          Tab(text: 'Payment History', icon: Icon(Icons.history)),
          Tab(text: 'Receivables', icon: Icon(Icons.account_balance_wallet)),
          Tab(text: 'Payables', icon: Icon(Icons.payment)),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPaymentHistoryTab(),
                _buildReceivablesTab(),
                _buildPayablesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search payments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                tooltip: 'Toggle Filters',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadPayments,
                tooltip: 'Refresh',
              ),
            ],
          ),
          if (_showFilters) ...[
            const SizedBox(height: 16),
            _buildFilterRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: WebDatePicker(
            label: 'Start Date',
            initialDate: _filterStartDate,
            onChanged: (date) {
              setState(() {
                _filterStartDate = date;
              });
              _loadPayments();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: WebDatePicker(
            label: 'End Date',
            initialDate: _filterEndDate,
            onChanged: (date) {
              setState(() {
                _filterEndDate = date;
              });
              _loadPayments();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: WebDropdown<PaymentMode>(
            label: 'Payment Mode',
            value: _filterPaymentMode,
            options: PaymentMode.values
                .map((mode) => WebDropdownOption(
                      value: mode,
                      label: mode.toString().split('.').last,
                    ))
                .toList(),
            onChanged: (mode) {
              setState(() {
                _filterPaymentMode = mode;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: WebDropdown<PaymentStatus>(
            label: 'Status',
            value: _filterStatus,
            options: PaymentStatus.values
                .map((status) => WebDropdownOption(
                      value: status,
                      label: status.toString().split('.').last,
                    ))
                .toList(),
            onChanged: (status) {
              setState(() {
                _filterStatus = status;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryTab() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, child) {
        if (paymentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final payments = _getFilteredPayments(paymentProvider.payments);

        if (payments.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No payments found'),
              ],
            ),
          );
        }

        return WebDataTable<PaymentModel>(
          data: payments,
          columns: [
            WebDataColumn<PaymentModel>(
              label: 'Date',
              field: 'date',
              valueGetter: (payment) =>
                  DateFormat('dd MMM yyyy').format(payment.paymentDate),
              cellBuilder: (payment) => Text(
                DateFormat('dd MMM yyyy').format(payment.paymentDate),
              ),
            ),
            WebDataColumn<PaymentModel>(
              label: 'Reference',
              field: 'reference',
              valueGetter: (payment) => payment.reference ?? '-',
              cellBuilder: (payment) => Text(payment.reference ?? '-'),
            ),
            WebDataColumn<PaymentModel>(
              label: 'Customer/Supplier',
              field: 'party',
              valueGetter: (payment) => payment.id,
              cellBuilder: (payment) => FutureBuilder<String>(
                future: _getPaymentPartyName(payment),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? 'Loading...');
                },
              ),
            ),
            WebDataColumn<PaymentModel>(
              label: 'Amount',
              field: 'amount',
              valueGetter: (payment) => payment.amount.toString(),
              cellBuilder: (payment) => Text(
                '₹${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            WebDataColumn<PaymentModel>(
              label: 'Mode',
              field: 'mode',
              valueGetter: (payment) =>
                  payment.paymentMode.toString().split('.').last,
              cellBuilder: (payment) => Chip(
                label: Text(
                  payment.paymentMode.toString().split('.').last,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: _getPaymentModeColor(payment.paymentMode),
              ),
            ),
            WebDataColumn<PaymentModel>(
              label: 'Status',
              field: 'status',
              valueGetter: (payment) =>
                  payment.status.toString().split('.').last,
              cellBuilder: (payment) => Chip(
                label: Text(
                  payment.status.toString().split('.').last,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: _getStatusColor(payment.status),
              ),
            ),
            WebDataColumn<PaymentModel>(
              label: 'Actions',
              field: 'actions',
              sortable: false,
              valueGetter: (payment) => '',
              cellBuilder: (payment) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedPayment = payment;
                        });
                      },
                      tooltip: 'View Details',
                    ),
                    if (payment.status != PaymentStatus.cancelled)
                      IconButton(
                        icon: const Icon(Icons.undo, size: 20),
                        onPressed: () => _reversePayment(payment),
                        tooltip: 'Reverse Payment',
                      ),
                  ],
                );
              },
            ),
          ],
          onRowTap: (payment) {
            setState(() {
              _selectedPayment = payment;
            });
          },
        );
      },
    );
  }

  Widget _buildReceivablesTab() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        final customers = customerProvider.customers
            .where((c) => c.balance > 0)
            .toList();

        if (customers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No receivables found'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            return WebCard(
              content: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    customer.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(customer.name),
                subtitle: Text(customer.phone ?? 'No phone'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${customer.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showUpiPaymentDialog(
                        customer: customer,
                        amount: customer.balance,
                      ),
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Request Payment'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPayablesTab() {
    return Consumer<SupplierProvider>(
      builder: (context, supplierProvider, child) {
        final suppliers = supplierProvider.suppliers
            .where((s) => s.balance > 0)
            .toList();

        if (suppliers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No payables found'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final supplier = suppliers[index];
            return WebCard(
              content: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.errorColor,
                  child: Text(
                    supplier.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(supplier.name),
                subtitle: Text(supplier.phone ?? 'No phone'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${supplier.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showPaySupplierDialog(supplier),
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Pay Now'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentDetail() {
    if (_selectedPayment == null) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedPayment = null;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Payment ID', _selectedPayment!.id),
                  _buildDetailRow(
                    'Date',
                    DateFormat('dd MMM yyyy, hh:mm a')
                        .format(_selectedPayment!.paymentDate),
                  ),
                  _buildDetailRow(
                    'Amount',
                    '₹${_selectedPayment!.amount.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    'Payment Mode',
                    _selectedPayment!.paymentMode.toString().split('.').last,
                  ),
                  _buildDetailRow(
                    'Status',
                    _selectedPayment!.status.toString().split('.').last,
                  ),
                  if (_selectedPayment!.reference != null)
                    _buildDetailRow('Reference', _selectedPayment!.reference!),
                  if (_selectedPayment!.notes != null)
                    _buildDetailRow('Notes', _selectedPayment!.notes!),
                  const SizedBox(height: 24),
                  if (_selectedPayment!.status != PaymentStatus.cancelled)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _reversePayment(_selectedPayment!),
                        icon: const Icon(Icons.undo),
                        label: const Text('Reverse Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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
            width: 150,
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PaymentModel> _getFilteredPayments(List<PaymentModel> payments) {
    var filtered = payments;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((payment) {
        final query = _searchQuery.toLowerCase();
        return (payment.reference?.toLowerCase().contains(query) ?? false) ||
            (payment.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_filterPaymentMode != null) {
      filtered = filtered
          .where((payment) => payment.paymentMode == _filterPaymentMode)
          .toList();
    }

    if (_filterStatus != null) {
      filtered = filtered
          .where((payment) => payment.status == _filterStatus)
          .toList();
    }

    return filtered;
  }

  Future<String> _getPaymentPartyName(PaymentModel payment) async {
    if (payment.customerId != null) {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final customer = customerProvider.customers
          .where((c) => c.id == payment.customerId)
          .firstOrNull;
      return customer?.name ?? 'Unknown Customer';
    } else if (payment.supplierId != null) {
      final supplierProvider = Provider.of<SupplierProvider>(
        context,
        listen: false,
      );
      final supplier = supplierProvider.suppliers
          .where((s) => s.id == payment.supplierId)
          .firstOrNull;
      return supplier?.name ?? 'Unknown Supplier';
    }
    return 'N/A';
  }

  Color _getPaymentModeColor(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return Colors.green.shade100;
      case PaymentMode.upi:
        return Colors.blue.shade100;
      case PaymentMode.card:
        return Colors.purple.shade100;
      case PaymentMode.bankTransfer:
        return Colors.orange.shade100;
      case PaymentMode.cheque:
        return Colors.teal.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Colors.green.shade100;
      case PaymentStatus.pending:
        return Colors.orange.shade100;
      case PaymentStatus.failed:
        return Colors.red.shade100;
      case PaymentStatus.cancelled:
        return Colors.grey.shade100;
    }
  }

  void _showRecordPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => const RecordPaymentDialog(),
    );
  }

  void _showUpiPaymentDialog({
    required CustomerModel customer,
    required double amount,
  }) {
    showDialog(
      context: context,
      builder: (context) => UpiPaymentRequestDialog(
        customer: customer,
        amount: amount,
      ),
    );
  }

  void _showPaySupplierDialog(SupplierModel supplier) {
    showDialog(
      context: context,
      builder: (context) => PaySupplierDialog(supplier: supplier),
    );
  }

  Future<void> _reversePayment(PaymentModel payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reverse Payment'),
        content: Text(
          'Are you sure you want to reverse this payment of ₹${payment.amount.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Reverse'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final paymentProvider = Provider.of<PaymentProvider>(
        context,
        listen: false,
      );

      final result = await paymentProvider.reversePayment(payment.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Payment reversed'),
            backgroundColor:
                result.success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );

        if (result.success) {
          setState(() {
            _selectedPayment = null;
          });
          _loadPayments();
        }
      }
    }
  }
}

// Record Payment Dialog
class RecordPaymentDialog extends StatefulWidget {
  const RecordPaymentDialog({super.key});

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMode _selectedMode = PaymentMode.cash;
  DateTime _paymentDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Payment'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WebFormField(
                  controller: _amountController,
                  label: 'Amount',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                WebDropdown<PaymentMode>(
                  label: 'Payment Mode',
                  value: _selectedMode,
                  options: PaymentMode.values
                      .map((mode) => WebDropdownOption(
                            value: mode,
                            label: mode.toString().split('.').last,
                          ))
                      .toList(),
                  onChanged: (mode) {
                    if (mode != null) {
                      setState(() {
                        _selectedMode = mode;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                WebDatePicker(
                  label: 'Payment Date',
                  initialDate: _paymentDate,
                  onChanged: (date) {
                    if (date != null) {
                      setState(() {
                        _paymentDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                WebFormField(
                  controller: _referenceController,
                  label: 'Reference (Optional)',
                ),
                const SizedBox(height: 16),
                WebFormField(
                  controller: _notesController,
                  label: 'Notes (Optional)',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _recordPayment,
          child: const Text('Record Payment'),
        ),
      ],
    );
  }

  Future<void> _recordPayment() async {
    if (!_formKey.currentState!.validate()) return;

    // For now, we'll show a message that invoice selection is needed
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please record payment from invoice detail screen'),
          backgroundColor: AppTheme.warningColor,
        ),
      );

      Navigator.pop(context);
    }
  }
}

// UPI Payment Request Dialog
class UpiPaymentRequestDialog extends StatefulWidget {
  final CustomerModel customer;
  final double amount;

  const UpiPaymentRequestDialog({
    super.key,
    required this.customer,
    required this.amount,
  });

  @override
  State<UpiPaymentRequestDialog> createState() =>
      _UpiPaymentRequestDialogState();
}

class _UpiPaymentRequestDialogState extends State<UpiPaymentRequestDialog> {
  final _upiIdController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = 'Payment from ${widget.customer.name}';
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate Payment Request'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Request ₹${widget.amount.toStringAsFixed(2)} from ${widget.customer.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            WebFormField(
              controller: _upiIdController,
              label: 'Your Business UPI ID',
              hint: 'yourbusiness@upi',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your UPI ID';
                }
                if (!UpiService.isValidUpiId(value)) {
                  return 'Please enter a valid UPI ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            WebFormField(
              controller: _noteController,
              label: 'Payment Note',
              maxLines: 2,
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
          onPressed: _generatePaymentUrl,
          icon: const Icon(Icons.link),
          label: const Text('Generate URL'),
        ),
      ],
    );
  }

  Future<void> _generatePaymentUrl() async {
    if (_upiIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your business UPI ID'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (!UpiService.isValidUpiId(_upiIdController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid UPI ID'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      final upiLink = UpiService.generateUpiLink(
        upiId: _upiIdController.text,
        payeeName: 'Your Business',
        amount: widget.amount,
        transactionNote: _noteController.text,
      );

      await Clipboard.setData(ClipboardData(text: upiLink));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment URL copied to clipboard!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}

// Pay Supplier Dialog
class PaySupplierDialog extends StatefulWidget {
  final SupplierModel supplier;

  const PaySupplierDialog({super.key, required this.supplier});

  @override
  State<PaySupplierDialog> createState() => _PaySupplierDialogState();
}

class _PaySupplierDialogState extends State<PaySupplierDialog> {
  final _upiIdController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.supplier.upiId != null) {
      _upiIdController.text = widget.supplier.upiId!;
    }
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pay Supplier'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pay ₹${widget.supplier.balance.toStringAsFixed(2)} to ${widget.supplier.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            WebFormField(
              controller: _upiIdController,
              label: 'Supplier UPI ID',
              hint: 'supplier@upi',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter UPI ID';
                }
                if (!UpiService.isValidUpiId(value)) {
                  return 'Please enter a valid UPI ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            WebFormField(
              controller: _noteController,
              label: 'Payment Note (Optional)',
              maxLines: 2,
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
          onPressed: _initiatePayment,
          icon: const Icon(Icons.payment),
          label: const Text('Pay Now'),
        ),
      ],
    );
  }

  Future<void> _initiatePayment() async {
    if (_upiIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter supplier UPI ID'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (!UpiService.isValidUpiId(_upiIdController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid UPI ID'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      final success = await UpiService.makePayment(
        upiId: _upiIdController.text,
        payeeName: widget.supplier.name,
        amount: widget.supplier.balance,
        transactionNote: _noteController.text.isEmpty
            ? null
            : _noteController.text,
      );

      if (mounted) {
        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment initiated successfully!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initiate payment'),
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
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
