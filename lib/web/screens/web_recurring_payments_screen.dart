import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/recurring_payment_model.dart';
import '../../providers/recurring_payment_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/business_provider.dart';
import '../widgets/web_data_table.dart';
import '../widgets/web_form_field.dart';
import '../widgets/web_date_picker.dart';
import '../widgets/web_dropdown.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../utils/app_theme.dart';

/// Web-optimized recurring payments management screen
/// Requirements: 3.7
class WebRecurringPaymentsScreen extends StatefulWidget {
  const WebRecurringPaymentsScreen({super.key});

  @override
  State<WebRecurringPaymentsScreen> createState() =>
      _WebRecurringPaymentsScreenState();
}

class _WebRecurringPaymentsScreenState
    extends State<WebRecurringPaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RecurringPaymentModel? _selectedPayment;
  String _searchQuery = '';
  RecurringPaymentStatus? _filterStatus;
  RecurringFrequency? _filterFrequency;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final recurringProvider = Provider.of<RecurringPaymentProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      recurringProvider.loadRecurringPayments(
        businessId: businessProvider.business!.id,
        status: _filterStatus,
      );
      recurringProvider.loadOccurrences(
        businessId: businessProvider.business!.id,
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
        title: const Text('Recurring Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePaymentDialog,
          ),
        ],
      ),
      body: Consumer<RecurringPaymentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final payments = _getFilteredPayments(provider.recurringPayments);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search recurring payments...',
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
                            Icon(Icons.repeat_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No recurring payments found', style: TextStyle(color: Colors.grey[600])),
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

  Widget _buildMobilePaymentCard(RecurringPaymentModel payment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(payment.status),
          child: Icon(
            payment.status == RecurringPaymentStatus.active ? Icons.repeat : Icons.pause,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(payment.description, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${payment.frequencyDescription} • ₹${payment.amount.toStringAsFixed(2)}'),
        trailing: Chip(
          label: Text(
            payment.status.name.toUpperCase(),
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: _getStatusColor(payment.status),
        ),
        onTap: () => _showEditPaymentDialog(payment),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.repeat, size: 32, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          const Text(
            'Recurring Payments',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildStatsCards(),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _showCreatePaymentDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Recurring Payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<RecurringPaymentProvider>(
      builder: (context, provider, child) {
        final activeCount = provider.activeRecurringPayments.length;
        final unpaidCount = provider.unpaidOccurrences.length;

        return Row(
          children: [
            _buildStatCard(
              'Active',
              activeCount.toString(),
              Icons.repeat,
              AppTheme.successColor,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Unpaid Occurrences',
              unpaidCount.toString(),
              Icons.pending_actions,
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
        color: color.withValues(alpha: 0.1),
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
          Tab(text: 'All', icon: Icon(Icons.list)),
          Tab(text: 'Active', icon: Icon(Icons.check_circle)),
          Tab(text: 'Paused', icon: Icon(Icons.pause_circle)),
          Tab(text: 'Occurrences', icon: Icon(Icons.event)),
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
                _buildAllPaymentsTab(),
                _buildActivePaymentsTab(),
                _buildPausedPaymentsTab(),
                _buildOccurrencesTab(),
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
                    hintText: 'Search recurring payments...',
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
                onPressed: _loadData,
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
          child: WebDropdown<RecurringPaymentStatus>(
            label: 'Status',
            value: _filterStatus,
            options: RecurringPaymentStatus.values
                .map((status) => WebDropdownOption(
                      value: status,
                      label: status.name,
                    ))
                .toList(),
            onChanged: (status) {
              setState(() {
                _filterStatus = status;
              });
              _loadData();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: WebDropdown<RecurringFrequency>(
            label: 'Frequency',
            value: _filterFrequency,
            options: RecurringFrequency.values
                .map((freq) => WebDropdownOption(
                      value: freq,
                      label: freq.name,
                    ))
                .toList(),
            onChanged: (freq) {
              setState(() {
                _filterFrequency = freq;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllPaymentsTab() {
    return Consumer<RecurringPaymentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final payments = _getFilteredPayments(provider.recurringPayments);

        if (payments.isEmpty) {
          return _buildEmptyState();
        }

        return _buildPaymentsTable(payments);
      },
    );
  }

  Widget _buildActivePaymentsTab() {
    return Consumer<RecurringPaymentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final payments = _getFilteredPayments(provider.activeRecurringPayments);

        if (payments.isEmpty) {
          return _buildEmptyState();
        }

        return _buildPaymentsTable(payments);
      },
    );
  }

  Widget _buildPausedPaymentsTab() {
    return Consumer<RecurringPaymentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final payments = _getFilteredPayments(provider.pausedRecurringPayments);

        if (payments.isEmpty) {
          return _buildEmptyState();
        }

        return _buildPaymentsTable(payments);
      },
    );
  }

  Widget _buildOccurrencesTab() {
    return Consumer<RecurringPaymentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final occurrences = provider.occurrences;

        if (occurrences.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No occurrences found'),
              ],
            ),
          );
        }

        return _buildOccurrencesTable(occurrences);
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.repeat_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No recurring payments found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first recurring payment to get started',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsTable(List<RecurringPaymentModel> payments) {
    return WebDataTable<RecurringPaymentModel>(
      data: payments,
      columns: [
        WebDataColumn<RecurringPaymentModel>(
          label: 'Description',
          field: 'description',
          valueGetter: (payment) => payment.description,
          cellBuilder: (payment) => Text(
            payment.description,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        WebDataColumn<RecurringPaymentModel>(
          label: 'Customer',
          field: 'customer',
          valueGetter: (payment) => payment.customerId,
          cellBuilder: (payment) => FutureBuilder<String>(
            future: _getCustomerName(payment.customerId),
            builder: (context, snapshot) {
              return Text(snapshot.data ?? 'Loading...');
            },
          ),
        ),
        WebDataColumn<RecurringPaymentModel>(
          label: 'Amount',
          field: 'amount',
          valueGetter: (payment) => payment.amount.toString(),
          cellBuilder: (payment) => Text(
            '₹${payment.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        WebDataColumn<RecurringPaymentModel>(
          label: 'Frequency',
          field: 'frequency',
          valueGetter: (payment) => payment.frequencyDescription,
          cellBuilder: (payment) => Chip(
            label: Text(
              payment.frequencyDescription,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: _getFrequencyColor(payment.frequency),
          ),
        ),
        WebDataColumn<RecurringPaymentModel>(
          label: 'Status',
          field: 'status',
          valueGetter: (payment) => payment.status.name,
          cellBuilder: (payment) => Chip(
            label: Text(
              payment.status.name.toUpperCase(),
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: _getStatusColor(payment.status),
          ),
        ),
        WebDataColumn<RecurringPaymentModel>(
          label: 'Occurrences',
          field: 'occurrences',
          valueGetter: (payment) => payment.occurrencesGenerated.toString(),
          cellBuilder: (payment) => Text(
            payment.occurrencesGenerated.toString(),
          ),
        ),
        WebDataColumn<RecurringPaymentModel>(
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
                if (payment.status == RecurringPaymentStatus.active)
                  IconButton(
                    icon: const Icon(Icons.pause, size: 20),
                    onPressed: () => _pausePayment(payment),
                    tooltip: 'Pause',
                  ),
                if (payment.status == RecurringPaymentStatus.paused)
                  IconButton(
                    icon: const Icon(Icons.play_arrow, size: 20),
                    onPressed: () => _resumePayment(payment),
                    tooltip: 'Resume',
                  ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditPaymentDialog(payment),
                  tooltip: 'Edit',
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
  }

  Widget _buildOccurrencesTable(List<RecurringPaymentOccurrence> occurrences) {
    return WebDataTable<RecurringPaymentOccurrence>(
      data: occurrences,
      columns: [
        WebDataColumn<RecurringPaymentOccurrence>(
          label: 'Due Date',
          field: 'dueDate',
          valueGetter: (occ) => DateFormat('dd MMM yyyy').format(occ.dueDate),
          cellBuilder: (occ) => Text(
            DateFormat('dd MMM yyyy').format(occ.dueDate),
          ),
        ),
        WebDataColumn<RecurringPaymentOccurrence>(
          label: 'Amount',
          field: 'amount',
          valueGetter: (occ) => occ.amount.toString(),
          cellBuilder: (occ) => Text(
            '₹${occ.amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        WebDataColumn<RecurringPaymentOccurrence>(
          label: 'Invoice Generated',
          field: 'invoiceGenerated',
          valueGetter: (occ) => occ.invoiceGenerated.toString(),
          cellBuilder: (occ) => Icon(
            occ.invoiceGenerated ? Icons.check_circle : Icons.cancel,
            color: occ.invoiceGenerated ? AppTheme.successColor : Colors.grey,
            size: 20,
          ),
        ),
        WebDataColumn<RecurringPaymentOccurrence>(
          label: 'Paid',
          field: 'paid',
          valueGetter: (occ) => occ.paid.toString(),
          cellBuilder: (occ) => Chip(
            label: Text(
              occ.paid ? 'PAID' : 'UNPAID',
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: occ.paid ? AppTheme.successColor : AppTheme.warningColor,
          ),
        ),
        WebDataColumn<RecurringPaymentOccurrence>(
          label: 'Actions',
          field: 'actions',
          sortable: false,
          valueGetter: (occ) => '',
          cellBuilder: (occ) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!occ.paid)
                  ElevatedButton(
                    onPressed: () => _markOccurrencePaid(occ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Mark Paid', style: TextStyle(fontSize: 12)),
                  ),
              ],
            );
          },
        ),
      ],
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
                  _buildDetailRow('Description', _selectedPayment!.description),
                  _buildDetailRow(
                    'Amount',
                    '₹${_selectedPayment!.amount.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow(
                    'Frequency',
                    _selectedPayment!.frequencyDescription,
                  ),
                  _buildDetailRow(
                    'Status',
                    _selectedPayment!.status.name,
                  ),
                  _buildDetailRow(
                    'Start Date',
                    DateFormat('dd MMM yyyy').format(_selectedPayment!.startDate),
                  ),
                  if (_selectedPayment!.endDate != null)
                    _buildDetailRow(
                      'End Date',
                      DateFormat('dd MMM yyyy').format(_selectedPayment!.endDate!),
                    ),
                  _buildDetailRow(
                    'Occurrences Generated',
                    _selectedPayment!.occurrencesGenerated.toString(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingRow(
                    'Auto Generate Invoice',
                    _selectedPayment!.autoGenerateInvoice,
                  ),
                  _buildSettingRow(
                    'Auto Send Reminder',
                    _selectedPayment!.autoSendReminder,
                  ),
                  if (_selectedPayment!.autoSendReminder)
                    _buildDetailRow(
                      'Reminder Days Before',
                      _selectedPayment!.reminderDaysBefore.toString(),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (_selectedPayment!.status == RecurringPaymentStatus.active)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pausePayment(_selectedPayment!),
                            icon: const Icon(Icons.pause),
                            label: const Text('Pause'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      if (_selectedPayment!.status == RecurringPaymentStatus.paused)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _resumePayment(_selectedPayment!),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Resume'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditPaymentDialog(_selectedPayment!),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _cancelPayment(_selectedPayment!),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel Recurring Payment'),
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
            width: 180,
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

  Widget _buildSettingRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? AppTheme.successColor : Colors.grey,
          ),
        ],
      ),
    );
  }

  List<RecurringPaymentModel> _getFilteredPayments(
    List<RecurringPaymentModel> payments,
  ) {
    var filtered = payments;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((payment) {
        final query = _searchQuery.toLowerCase();
        return payment.description.toLowerCase().contains(query) ||
            payment.amount.toString().contains(query);
      }).toList();
    }

    if (_filterFrequency != null) {
      filtered = filtered
          .where((payment) => payment.frequency == _filterFrequency)
          .toList();
    }

    return filtered;
  }

  Future<String> _getCustomerName(String customerId) async {
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final customer = customerProvider.customers
        .where((c) => c.id == customerId)
        .firstOrNull;
    return customer?.name ?? 'Unknown Customer';
  }

  Color _getFrequencyColor(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return Colors.blue.shade100;
      case RecurringFrequency.weekly:
        return Colors.green.shade100;
      case RecurringFrequency.monthly:
        return Colors.orange.shade100;
      case RecurringFrequency.yearly:
        return Colors.purple.shade100;
    }
  }

  Color _getStatusColor(RecurringPaymentStatus status) {
    switch (status) {
      case RecurringPaymentStatus.active:
        return Colors.green.shade100;
      case RecurringPaymentStatus.paused:
        return Colors.orange.shade100;
      case RecurringPaymentStatus.cancelled:
        return Colors.red.shade100;
      case RecurringPaymentStatus.completed:
        return Colors.blue.shade100;
    }
  }

  void _showCreatePaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => const RecurringPaymentDialog(),
    ).then((_) => _loadData());
  }

  void _showEditPaymentDialog(RecurringPaymentModel payment) {
    showDialog(
      context: context,
      builder: (context) => RecurringPaymentDialog(payment: payment),
    ).then((_) => _loadData());
  }

  Future<void> _pausePayment(RecurringPaymentModel payment) async {
    final provider = Provider.of<RecurringPaymentProvider>(
      context,
      listen: false,
    );

    final success = await provider.pauseRecurringPayment(payment.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Recurring payment paused'
                : 'Failed to pause recurring payment',
          ),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );

      if (success) {
        setState(() {
          _selectedPayment = null;
        });
        _loadData();
      }
    }
  }

  Future<void> _resumePayment(RecurringPaymentModel payment) async {
    final provider = Provider.of<RecurringPaymentProvider>(
      context,
      listen: false,
    );

    final success = await provider.resumeRecurringPayment(payment.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Recurring payment resumed'
                : 'Failed to resume recurring payment',
          ),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );

      if (success) {
        setState(() {
          _selectedPayment = null;
        });
        _loadData();
      }
    }
  }

  Future<void> _cancelPayment(RecurringPaymentModel payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Recurring Payment'),
        content: Text(
          'Are you sure you want to cancel "${payment.description}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = Provider.of<RecurringPaymentProvider>(
        context,
        listen: false,
      );

      final success = await provider.cancelRecurringPayment(payment.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Recurring payment cancelled'
                  : 'Failed to cancel recurring payment',
            ),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );

        if (success) {
          setState(() {
            _selectedPayment = null;
          });
          _loadData();
        }
      }
    }
  }

  Future<void> _markOccurrencePaid(RecurringPaymentOccurrence occurrence) async {
    final provider = Provider.of<RecurringPaymentProvider>(
      context,
      listen: false,
    );

    final success = await provider.markOccurrencePaid(occurrence.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Occurrence marked as paid'
                : 'Failed to mark occurrence as paid',
          ),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );

      if (success) {
        _loadData();
      }
    }
  }
}


// Recurring Payment Dialog
class RecurringPaymentDialog extends StatefulWidget {
  final RecurringPaymentModel? payment;

  const RecurringPaymentDialog({super.key, this.payment});

  @override
  State<RecurringPaymentDialog> createState() => _RecurringPaymentDialogState();
}

class _RecurringPaymentDialogState extends State<RecurringPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reminderDaysController = TextEditingController();

  String? _selectedCustomerId;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  RecurringPaymentStatus _status = RecurringPaymentStatus.active;
  bool _autoGenerateInvoice = true;
  bool _autoSendReminder = true;
  int? _dayOfMonth;
  int? _dayOfWeek;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _amountController.text = widget.payment!.amount.toString();
      _descriptionController.text = widget.payment!.description;
      _reminderDaysController.text = widget.payment!.reminderDaysBefore.toString();
      _selectedCustomerId = widget.payment!.customerId;
      _frequency = widget.payment!.frequency;
      _startDate = widget.payment!.startDate;
      _endDate = widget.payment!.endDate;
      _status = widget.payment!.status;
      _autoGenerateInvoice = widget.payment!.autoGenerateInvoice;
      _autoSendReminder = widget.payment!.autoSendReminder;
      _dayOfMonth = widget.payment!.dayOfMonth;
      _dayOfWeek = widget.payment!.dayOfWeek;
    } else {
      _updateFrequencyDefaults();
      _reminderDaysController.text = '3';
    }
  }

  void _updateFrequencyDefaults() {
    if (_frequency == RecurringFrequency.monthly) {
      _dayOfMonth = _startDate.day;
      _dayOfWeek = null;
    } else if (_frequency == RecurringFrequency.weekly) {
      _dayOfWeek = _startDate.weekday;
      _dayOfMonth = null;
    } else {
      _dayOfMonth = null;
      _dayOfWeek = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _reminderDaysController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomerId == null || _selectedCustomerId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final businessProvider = context.read<BusinessProvider>();
    if (businessProvider.business == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<RecurringPaymentProvider>();
      final payment = RecurringPaymentModel(
        id: widget.payment?.id ?? '',
        businessId: widget.payment?.businessId ?? businessProvider.business!.id,
        customerId: _selectedCustomerId!.trim(),
        amount: double.parse(_amountController.text),
        frequency: _frequency,
        dayOfMonth: _dayOfMonth,
        dayOfWeek: _dayOfWeek,
        startDate: _startDate,
        endDate: _endDate,
        description: _descriptionController.text,
        status: _status,
        occurrencesGenerated: widget.payment?.occurrencesGenerated ?? 0,
        autoGenerateInvoice: _autoGenerateInvoice,
        autoSendReminder: _autoSendReminder,
        reminderDaysBefore: int.parse(_reminderDaysController.text),
        createdAt: widget.payment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.payment == null) {
        await provider.createRecurringPayment(payment);
      } else {
        await provider.updateRecurringPayment(payment);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.payment == null
            ? 'Create Recurring Payment'
            : 'Edit Recurring Payment',
      ),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<CustomerProvider>(
                  builder: (context, customerProvider, _) {
                    final customers = customerProvider.customers;

                    if (customers.isEmpty) {
                      return const Text(
                        'No customers available. Please add customers first.',
                        style: TextStyle(color: Colors.red),
                      );
                    }

                    return WebDropdown<String>(
                      label: 'Customer *',
                      value: _selectedCustomerId,
                      options: customers
                          .map((customer) => WebDropdownOption(
                                value: customer.id,
                                label: customer.name,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCustomerId = value);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                WebFormField(
                  controller: _amountController,
                  label: 'Amount *',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.currency_rupee),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                WebFormField(
                  controller: _descriptionController,
                  label: 'Description *',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                WebDropdown<RecurringFrequency>(
                  label: 'Frequency *',
                  value: _frequency,
                  options: RecurringFrequency.values
                      .map((freq) => WebDropdownOption(
                            value: freq,
                            label: freq.name,
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _frequency = value;
                        _updateFrequencyDefaults();
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (_frequency == RecurringFrequency.monthly)
                  WebDropdown<int>(
                    label: 'Day of Month *',
                    value: _dayOfMonth,
                    options: List.generate(31, (index) => index + 1)
                        .map((day) => WebDropdownOption(
                              value: day,
                              label: 'Day $day',
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _dayOfMonth = value),
                  ),
                if (_frequency == RecurringFrequency.weekly)
                  WebDropdown<int>(
                    label: 'Day of Week *',
                    value: _dayOfWeek,
                    options: const [
                      WebDropdownOption(value: 1, label: 'Monday'),
                      WebDropdownOption(value: 2, label: 'Tuesday'),
                      WebDropdownOption(value: 3, label: 'Wednesday'),
                      WebDropdownOption(value: 4, label: 'Thursday'),
                      WebDropdownOption(value: 5, label: 'Friday'),
                      WebDropdownOption(value: 6, label: 'Saturday'),
                      WebDropdownOption(value: 7, label: 'Sunday'),
                    ],
                    onChanged: (value) => setState(() => _dayOfWeek = value),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: WebDatePicker(
                        label: 'Start Date *',
                        initialDate: _startDate,
                        onChanged: (date) {
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                              _updateFrequencyDefaults();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: WebDatePicker(
                        label: 'End Date (Optional)',
                        initialDate: _endDate,
                        firstDate: _startDate,
                        onChanged: (date) {
                          setState(() => _endDate = date);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                WebDropdown<RecurringPaymentStatus>(
                  label: 'Status *',
                  value: _status,
                  options: RecurringPaymentStatus.values
                      .map((status) => WebDropdownOption(
                            value: status,
                            label: status.name,
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Automation Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Auto Generate Invoice'),
                  subtitle: const Text('Automatically create invoices for occurrences'),
                  value: _autoGenerateInvoice,
                  onChanged: (value) => setState(() => _autoGenerateInvoice = value),
                ),
                SwitchListTile(
                  title: const Text('Auto Send Reminder'),
                  subtitle: const Text('Send reminders before due date'),
                  value: _autoSendReminder,
                  onChanged: (value) => setState(() => _autoSendReminder = value),
                ),
                if (_autoSendReminder) ...[
                  const SizedBox(height: 16),
                  WebFormField(
                    controller: _reminderDaysController,
                    label: 'Reminder Days Before',
                    keyboardType: TextInputType.number,
                    helperText: 'Number of days before due date to send reminder',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter reminder days';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter valid number';
                      }
                      return null;
                    },
                  ),
                ],
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
          onPressed: _isLoading ? null : _savePayment,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.payment == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
