import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/invoice_model.dart';
import '../../models/customer_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/business_provider.dart';
import '../../services/whatsapp_launcher_service.dart';
import '../../services/payment_url_service.dart';
import '../../services/upi_service.dart';
import '../widgets/web_card.dart';
import '../widgets/web_form_field.dart';
import '../widgets/web_dropdown.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../utils/app_theme.dart';

/// Web-optimized receivables management screen
/// Requirements: 3.6
/// Features:
/// - Grouped receivables view by customer
/// - Advanced filtering and sorting
/// - Reminder capabilities
/// - Customer-wise receivables breakdown
/// - Aging analysis visualization
class WebReceivablesManagementScreen extends StatefulWidget {
  const WebReceivablesManagementScreen({super.key});

  @override
  State<WebReceivablesManagementScreen> createState() =>
      _WebReceivablesManagementScreenState();
}

class _WebReceivablesManagementScreenState
    extends State<WebReceivablesManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CustomerModel? _selectedCustomer;
  String _searchQuery = '';
  String _sortBy = 'dueDate'; // dueDate, amount, customer
  bool _sortAscending = true;
  bool _showOverdueOnly = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    if (businessProvider.business != null) {
      final businessId = businessProvider.business!.id;
      Provider.of<InvoiceProvider>(context, listen: false)
          .loadInvoices(businessId);
      Provider.of<CustomerProvider>(context, listen: false)
          .loadCustomers(businessId);
      Provider.of<TransactionProvider>(context, listen: false)
          .refreshTransactions(businessId);
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
        title: const Text('Receivables'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer3<InvoiceProvider, CustomerProvider, TransactionProvider>(
        builder: (context, invoiceProvider, customerProvider, transactionProvider, child) {
          final customerGroups = _getCustomerGroups(invoiceProvider, customerProvider, transactionProvider);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search receivables...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              // Filter chip
              if (_showFilters)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Overdue Only'),
                        selected: _showOverdueOnly,
                        onSelected: (value) => setState(() => _showOverdueOnly = value),
                      ),
                    ],
                  ),
                ),
              if (_showFilters) const SizedBox(height: 8),
              // Receivables list
              Expanded(
                child: customerGroups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No receivables found', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: customerGroups.length,
                        itemBuilder: (context, index) {
                          final group = customerGroups[index];
                          return _buildMobileReceivableCard(group);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileReceivableCard(Map<String, dynamic> group) {
    final customer = group['customer'] as CustomerModel;
    final totalAmount = group['totalAmount'] as double;
    final hasOverdue = group['hasOverdue'] as bool;
    final transactions = group['transactions'] as List<Map<String, dynamic>>;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: hasOverdue ? Colors.red : AppTheme.primaryColor,
          child: Text(
            customer.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${transactions.length} pending • ${hasOverdue ? 'OVERDUE' : 'Due'}',
          style: TextStyle(color: hasOverdue ? Colors.red : Colors.grey[600], fontSize: 12),
        ),
        trailing: Text(
          '₹${totalAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: hasOverdue ? Colors.red : AppTheme.primaryColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ...transactions.take(3).map((txn) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(txn['description'] as String, overflow: TextOverflow.ellipsis)),
                      Text('₹${(txn['amount'] as double).toStringAsFixed(2)}'),
                    ],
                  ),
                )),
                if (transactions.length > 3)
                  Text('+ ${transactions.length - 3} more', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          if (_showFilters) _buildFilterBar(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: _selectedCustomer == null ? 1 : 2,
                  child: _buildMainContent(),
                ),
                if (_selectedCustomer != null)
                  Expanded(
                    flex: 3,
                    child: _buildCustomerDetail(),
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
          const Icon(
            Icons.account_balance_wallet,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 16),
          const Text(
            'Receivables Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildStatsCards(),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Toggle Filters',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer3<InvoiceProvider, TransactionProvider, CustomerProvider>(
      builder: (context, invoiceProvider, transactionProvider,
          customerProvider, child) {
        final pendingInvoices = invoiceProvider.invoices
            .where((inv) =>
                inv.outstandingAmount > 0 &&
                inv.status != InvoiceStatus.cancelled)
            .toList();

        final pendingTransactions = transactionProvider.transactions
            .where((txn) =>
                txn.customerId != null &&
                txn.dueDate != null &&
                txn.status == TransactionStatus.pending &&
                txn.type == TransactionType.income &&
                (txn.invoiceId == null || txn.invoiceId!.isEmpty))
            .toList();

        final totalReceivables = pendingInvoices.fold<double>(
              0,
              (sum, inv) => sum + inv.outstandingAmount,
            ) +
            pendingTransactions.fold<double>(
              0,
              (sum, txn) => sum + txn.amount,
            );

        final overdueInvoices = pendingInvoices.where((inv) => inv.isOverdue);
        final overdueTransactions = pendingTransactions.where((txn) =>
            txn.dueDate != null && txn.dueDate!.isBefore(DateTime.now()));

        final totalOverdue = overdueInvoices.fold<double>(
              0,
              (sum, inv) => sum + inv.outstandingAmount,
            ) +
            overdueTransactions.fold<double>(
              0,
              (sum, txn) => sum + txn.amount,
            );

        final customersWithBalance =
            customerProvider.customers.where((c) => c.balance > 0).length;

        return Row(
          children: [
            _buildStatCard(
              'Total Receivables',
              '₹${totalReceivables.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              AppTheme.primaryColor,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Overdue',
              '₹${totalOverdue.toStringAsFixed(2)}',
              Icons.warning,
              Colors.red,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Customers',
              customersWithBalance.toString(),
              Icons.people,
              AppTheme.successColor,
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
          Tab(text: 'Grouped by Customer', icon: Icon(Icons.group)),
          Tab(text: 'All Receivables', icon: Icon(Icons.list)),
          Tab(text: 'Aging Analysis', icon: Icon(Icons.analytics)),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: WebFormField(
              label: 'Search',
              hint: 'Search by customer name or invoice number...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 200,
            child: WebDropdown<String>(
              label: 'Sort By',
              value: _sortBy,
              options: const [
                WebDropdownOption(value: 'dueDate', label: 'Due Date'),
                WebDropdownOption(value: 'amount', label: 'Amount'),
                WebDropdownOption(value: 'customer', label: 'Customer'),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
            tooltip: _sortAscending ? 'Ascending' : 'Descending',
          ),
          const SizedBox(width: 16),
          FilterChip(
            label: const Text('Overdue Only'),
            selected: _showOverdueOnly,
            onSelected: (value) {
              setState(() {
                _showOverdueOnly = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildGroupedView(),
        _buildListView(),
        _buildAgingAnalysis(),
      ],
    );
  }

  Widget _buildGroupedView() {
    return Consumer3<InvoiceProvider, CustomerProvider, TransactionProvider>(
      builder: (context, invoiceProvider, customerProvider,
          transactionProvider, child) {
        final customerGroups = _getCustomerGroups(
          invoiceProvider,
          customerProvider,
          transactionProvider,
        );

        if (customerGroups.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: customerGroups.length,
          itemBuilder: (context, index) {
            final group = customerGroups[index];
            return _buildCustomerGroupCard(group);
          },
        );
      },
    );
  }

  Widget _buildListView() {
    return Consumer3<InvoiceProvider, CustomerProvider, TransactionProvider>(
      builder: (context, invoiceProvider, customerProvider,
          transactionProvider, child) {
        final allReceivables = _getAllReceivables(
          invoiceProvider,
          customerProvider,
          transactionProvider,
        );

        if (allReceivables.isEmpty) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Description')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Due Date')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: allReceivables.map((receivable) {
              return DataRow(
                cells: [
                  DataCell(Text(receivable['customerName'] as String)),
                  DataCell(_buildTypeChip(receivable['type'] as String)),
                  DataCell(Text(receivable['description'] as String)),
                  DataCell(
                    Text(
                      '₹${(receivable['amount'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(
                    Text(
                      DateFormat('dd MMM yyyy')
                          .format(receivable['dueDate'] as DateTime),
                      style: TextStyle(
                        color: (receivable['isOverdue'] as bool)
                            ? Colors.red
                            : null,
                      ),
                    ),
                  ),
                  DataCell(
                    _buildStatusChip(receivable['isOverdue'] as bool),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.send, size: 18),
                          onPressed: () => _sendReminder(receivable),
                          tooltip: 'Send Reminder',
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedCustomer =
                                  receivable['customer'] as CustomerModel?;
                            });
                          },
                          tooltip: 'View Details',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAgingAnalysis() {
    return Consumer3<InvoiceProvider, CustomerProvider, TransactionProvider>(
      builder: (context, invoiceProvider, customerProvider,
          transactionProvider, child) {
        final agingData = _calculateAgingData(
          invoiceProvider,
          customerProvider,
          transactionProvider,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aging Analysis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildAgingChart(agingData),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildAgingSummary(agingData),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildAgingTable(agingData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerGroupCard(Map<String, dynamic> group) {
    final customer = group['customer'] as CustomerModel;
    final transactions = group['transactions'] as List<Map<String, dynamic>>;
    final totalAmount = group['totalAmount'] as double;
    final hasOverdue = group['hasOverdue'] as bool;

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
        title: Row(
          children: [
            Expanded(
              child: Text(
                customer.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (customer.phone != null)
              Text(
                customer.phone!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        subtitle: Text(
          '${transactions.length} pending transaction(s)',
          style: TextStyle(
            fontSize: 12,
            color: hasOverdue ? Colors.red : Colors.grey[600],
            fontWeight: hasOverdue ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
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
                ...transactions.map((txn) {
                  return _buildTransactionRow(txn);
                }).toList(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCustomer = customer;
                          });
                        },
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendConsolidatedReminder(
                          customer,
                          transactions,
                        ),
                        icon: const Icon(Icons.send, size: 18),
                        label: const Text('Send All Reminders'),
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

  Widget _buildTransactionRow(Map<String, dynamic> txn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (txn['isOverdue'] as bool) ? Colors.red[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (txn['isOverdue'] as bool)
              ? Colors.red[200]!
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn['description'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: (txn['isOverdue'] as bool)
                          ? Colors.red[700]
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${DateFormat('dd MMM yyyy').format(txn['dueDate'] as DateTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: (txn['isOverdue'] as bool)
                            ? Colors.red[700]
                            : Colors.grey[600],
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
                '₹${(txn['amount'] as double).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: (txn['isOverdue'] as bool)
                      ? Colors.red[700]
                      : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () => _sendReminder(txn),
                icon: const Icon(Icons.send, size: 14),
                label: const Text('Send', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgingChart(Map<String, dynamic> agingData) {
    final data = agingData['buckets'] as List<Map<String, dynamic>>;

    return WebCard(
      padding: const EdgeInsets.all(24),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Receivables by Age',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: data.isEmpty
                    ? 100
                    : data
                        .map((e) => e['amount'] as double)
                        .reduce((a, b) => a > b ? a : b),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data[value.toInt()]['label'] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${(value / 1000).toStringAsFixed(0)}K',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item['amount'] as double,
                        color: _getAgingColor(item['label'] as String),
                        width: 40,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgingSummary(Map<String, dynamic> agingData) {
    final buckets = agingData['buckets'] as List<Map<String, dynamic>>;
    final total = agingData['total'] as double;

    return WebCard(
      padding: const EdgeInsets.all(24),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...buckets.map((bucket) {
              final amount = bucket['amount'] as double;
              final percentage = total > 0 ? (amount / total * 100) : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bucket['label'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _getAgingColor(bucket['label'] as String),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getAgingColor(bucket['label'] as String),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgingTable(Map<String, dynamic> agingData) {
    final customerAging =
        agingData['customerAging'] as List<Map<String, dynamic>>;

    return WebCard(
      padding: const EdgeInsets.all(24),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer-wise Aging',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DataTable(
            columns: const [
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Current')),
                DataColumn(label: Text('1-30 Days')),
                DataColumn(label: Text('31-60 Days')),
                DataColumn(label: Text('61-90 Days')),
                DataColumn(label: Text('90+ Days')),
                DataColumn(label: Text('Total')),
              ],
            rows: customerAging.map((customer) {
                return DataRow(
                  cells: [
                    DataCell(Text(customer['customerName'] as String)),
                    DataCell(
                      Text(
                        '₹${(customer['current'] as double).toStringAsFixed(2)}',
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(customer['days1_30'] as double).toStringAsFixed(2)}',
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(customer['days31_60'] as double).toStringAsFixed(2)}',
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(customer['days61_90'] as double).toStringAsFixed(2)}',
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(customer['days90plus'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(customer['total'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetail() {
    if (_selectedCustomer == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          _buildCustomerDetailHeader(),
          Expanded(
            child: _buildCustomerDetailContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              _selectedCustomer!.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedCustomer!.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_selectedCustomer!.phone != null)
                  Text(
                    _selectedCustomer!.phone!,
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
            onPressed: () {
              setState(() {
                _selectedCustomer = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailContent() {
    return Consumer3<InvoiceProvider, TransactionProvider, BusinessProvider>(
      builder: (context, invoiceProvider, transactionProvider,
          businessProvider, child) {
        final customerTransactions = transactionProvider.transactions
            .where((txn) => txn.customerId == _selectedCustomer!.id)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        final receivables = customerTransactions
            .where((txn) => txn.type == TransactionType.income)
            .toList();

        final totalPending = receivables.fold<double>(
          0,
          (sum, txn) =>
              sum + (txn.status == TransactionStatus.pending ? txn.amount : 0),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerStats(totalPending),
              const SizedBox(height: 24),
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...receivables.map((txn) {
                return _buildTransactionCard(txn, businessProvider.business);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerStats(double totalPending) {
    return Row(
      children: [
        Expanded(
          child: WebCard(
            padding: const EdgeInsets.all(16),
            content: Column(
              children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pending',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '₹${totalPending.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: WebCard(
            padding: const EdgeInsets.all(16),
            content: Column(
              children: [
                  const Icon(
                    Icons.account_balance,
                    color: AppTheme.successColor,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Balance',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '₹${_selectedCustomer!.balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionModel txn, dynamic business) {
    final isPending = txn.status == TransactionStatus.pending;
    final isOverdue = txn.dueDate != null &&
        txn.dueDate!.isBefore(DateTime.now()) &&
        isPending;

    return WebCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                CircleAvatar(
                  backgroundColor: isPending
                      ? (isOverdue ? Colors.red : Colors.orange)
                      : Colors.green,
                  child: Icon(
                    isPending ? Icons.pending : Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(txn.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${txn.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          if (txn.dueDate != null) ...[
            const SizedBox(height: 8),
            Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${DateFormat('dd MMM yyyy').format(txn.dueDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
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
                          fontSize: 10,
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          if (isPending) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
                onPressed: () => _sendTransactionReminder(txn, business),
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Send Reminder'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No pending receivables!',
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

  Widget _buildTypeChip(String type) {
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
      default:
        color = Colors.grey;
        icon = Icons.payment;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildStatusChip(bool isOverdue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isOverdue ? 'OVERDUE' : 'PENDING',
        style: TextStyle(
          color: isOverdue ? Colors.red[700] : Colors.orange[700],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getAgingColor(String label) {
    switch (label) {
      case 'Current':
        return Colors.green;
      case '1-30 Days':
        return Colors.blue;
      case '31-60 Days':
        return Colors.orange;
      case '61-90 Days':
        return Colors.deepOrange;
      case '90+ Days':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Data processing methods
  List<Map<String, dynamic>> _getCustomerGroups(
    InvoiceProvider invoiceProvider,
    CustomerProvider customerProvider,
    TransactionProvider transactionProvider,
  ) {
    final pendingInvoices = invoiceProvider.invoices
        .where((inv) =>
            inv.outstandingAmount > 0 &&
            inv.status != InvoiceStatus.cancelled)
        .toList();

    final pendingTransactions = transactionProvider.transactions
        .where((txn) =>
            txn.customerId != null &&
            txn.dueDate != null &&
            txn.status == TransactionStatus.pending &&
            txn.type == TransactionType.income &&
            (txn.invoiceId == null || txn.invoiceId!.isEmpty))
        .toList();

    final Map<String, List<Map<String, dynamic>>> customerGroups = {};

    // Add invoice-based payments
    for (var invoice in pendingInvoices) {
      final customer = customerProvider.getCustomerById(invoice.customerId ?? '');
      if (customer != null) {
        if (!customerGroups.containsKey(customer.id)) {
          customerGroups[customer.id] = [];
        }
        customerGroups[customer.id]!.add({
          'type': 'invoice',
          'invoice': invoice,
          'customer': customer,
          'amount': invoice.outstandingAmount,
          'dueDate': invoice.dueDate ?? DateTime.now().add(const Duration(days: 7)),
          'isOverdue': invoice.isOverdue,
          'description': 'Invoice #${invoice.invoiceNumber}',
        });
      }
    }

    // Add transaction-based payments
    for (var transaction in pendingTransactions) {
      final customer = customerProvider.getCustomerById(transaction.customerId!);
      if (customer != null) {
        if (!customerGroups.containsKey(customer.id)) {
          customerGroups[customer.id] = [];
        }
        final isOverdue = transaction.dueDate!.isBefore(DateTime.now());
        customerGroups[customer.id]!.add({
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

    // Apply filters
    if (_searchQuery.isNotEmpty) {
      customerGroups.removeWhere((customerId, transactions) {
        final customer = transactions.first['customer'] as CustomerModel;
        return !customer.name.toLowerCase().contains(_searchQuery.toLowerCase());
      });
    }

    if (_showOverdueOnly) {
      customerGroups.removeWhere((customerId, transactions) {
        return !transactions.any((t) => t['isOverdue'] as bool);
      });
    }

    // Create sorted list
    final sortedCustomers = customerGroups.keys.map((customerId) {
      final transactions = customerGroups[customerId]!;
      final customer = transactions.first['customer'] as CustomerModel;
      final earliestDueDate = transactions.first['dueDate'] as DateTime;
      final hasOverdue = transactions.any((t) => t['isOverdue'] as bool);
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
    }).toList();

    // Sort
    sortedCustomers.sort((a, b) {
      switch (_sortBy) {
        case 'amount':
          final comparison = (a['totalAmount'] as double)
              .compareTo(b['totalAmount'] as double);
          return _sortAscending ? comparison : -comparison;
        case 'customer':
          final comparison = (a['customer'] as CustomerModel)
              .name
              .compareTo((b['customer'] as CustomerModel).name);
          return _sortAscending ? comparison : -comparison;
        case 'dueDate':
        default:
          final aOverdue = a['hasOverdue'] as bool;
          final bOverdue = b['hasOverdue'] as bool;
          if (aOverdue && !bOverdue) return -1;
          if (!aOverdue && bOverdue) return 1;
          final comparison = (a['earliestDueDate'] as DateTime)
              .compareTo(b['earliestDueDate'] as DateTime);
          return _sortAscending ? comparison : -comparison;
      }
    });

    return sortedCustomers;
  }

  List<Map<String, dynamic>> _getAllReceivables(
    InvoiceProvider invoiceProvider,
    CustomerProvider customerProvider,
    TransactionProvider transactionProvider,
  ) {
    final allReceivables = <Map<String, dynamic>>[];

    final pendingInvoices = invoiceProvider.invoices
        .where((inv) =>
            inv.outstandingAmount > 0 &&
            inv.status != InvoiceStatus.cancelled)
        .toList();

    final pendingTransactions = transactionProvider.transactions
        .where((txn) =>
            txn.customerId != null &&
            txn.dueDate != null &&
            txn.status == TransactionStatus.pending &&
            txn.type == TransactionType.income &&
            (txn.invoiceId == null || txn.invoiceId!.isEmpty))
        .toList();

    // Add invoices
    for (var invoice in pendingInvoices) {
      final customer = customerProvider.getCustomerById(invoice.customerId ?? '');
      if (customer != null) {
        allReceivables.add({
          'type': 'invoice',
          'invoice': invoice,
          'customer': customer,
          'customerName': customer.name,
          'amount': invoice.outstandingAmount,
          'dueDate': invoice.dueDate ?? DateTime.now().add(const Duration(days: 7)),
          'isOverdue': invoice.isOverdue,
          'description': 'Invoice #${invoice.invoiceNumber}',
        });
      }
    }

    // Add transactions
    for (var transaction in pendingTransactions) {
      final customer = customerProvider.getCustomerById(transaction.customerId!);
      if (customer != null) {
        final isOverdue = transaction.dueDate!.isBefore(DateTime.now());
        allReceivables.add({
          'type': 'transaction',
          'transaction': transaction,
          'customer': customer,
          'customerName': customer.name,
          'amount': transaction.amount,
          'dueDate': transaction.dueDate!,
          'isOverdue': isOverdue,
          'description': transaction.description,
        });
      }
    }

    // Apply filters
    var filtered = allReceivables;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final customerName = r['customerName'] as String;
        final description = r['description'] as String;
        return customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_showOverdueOnly) {
      filtered = filtered.where((r) => r['isOverdue'] as bool).toList();
    }

    // Sort
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'amount':
          final comparison =
              (a['amount'] as double).compareTo(b['amount'] as double);
          return _sortAscending ? comparison : -comparison;
        case 'customer':
          final comparison = (a['customerName'] as String)
              .compareTo(b['customerName'] as String);
          return _sortAscending ? comparison : -comparison;
        case 'dueDate':
        default:
          final comparison = (a['dueDate'] as DateTime)
              .compareTo(b['dueDate'] as DateTime);
          return _sortAscending ? comparison : -comparison;
      }
    });

    return filtered;
  }

  Map<String, dynamic> _calculateAgingData(
    InvoiceProvider invoiceProvider,
    CustomerProvider customerProvider,
    TransactionProvider transactionProvider,
  ) {
    final allReceivables = _getAllReceivables(
      invoiceProvider,
      customerProvider,
      transactionProvider,
    );

    final now = DateTime.now();
    final buckets = {
      'Current': 0.0,
      '1-30 Days': 0.0,
      '31-60 Days': 0.0,
      '61-90 Days': 0.0,
      '90+ Days': 0.0,
    };

    final Map<String, Map<String, double>> customerAging = {};

    for (var receivable in allReceivables) {
      final dueDate = receivable['dueDate'] as DateTime;
      final amount = receivable['amount'] as double;
      final customerName = receivable['customerName'] as String;
      final daysPastDue = now.difference(dueDate).inDays;

      String bucket;
      if (daysPastDue < 0) {
        bucket = 'Current';
      } else if (daysPastDue <= 30) {
        bucket = '1-30 Days';
      } else if (daysPastDue <= 60) {
        bucket = '31-60 Days';
      } else if (daysPastDue <= 90) {
        bucket = '61-90 Days';
      } else {
        bucket = '90+ Days';
      }

      buckets[bucket] = buckets[bucket]! + amount;

      // Customer aging
      if (!customerAging.containsKey(customerName)) {
        customerAging[customerName] = {
          'current': 0.0,
          'days1_30': 0.0,
          'days31_60': 0.0,
          'days61_90': 0.0,
          'days90plus': 0.0,
          'total': 0.0,
        };
      }

      switch (bucket) {
        case 'Current':
          customerAging[customerName]!['current'] =
              customerAging[customerName]!['current']! + amount;
          break;
        case '1-30 Days':
          customerAging[customerName]!['days1_30'] =
              customerAging[customerName]!['days1_30']! + amount;
          break;
        case '31-60 Days':
          customerAging[customerName]!['days31_60'] =
              customerAging[customerName]!['days31_60']! + amount;
          break;
        case '61-90 Days':
          customerAging[customerName]!['days61_90'] =
              customerAging[customerName]!['days61_90']! + amount;
          break;
        case '90+ Days':
          customerAging[customerName]!['days90plus'] =
              customerAging[customerName]!['days90plus']! + amount;
          break;
      }
      customerAging[customerName]!['total'] =
          customerAging[customerName]!['total']! + amount;
    }

    final total = buckets.values.fold<double>(0, (sum, amount) => sum + amount);

    return {
      'buckets': buckets.entries
          .map((e) => {'label': e.key, 'amount': e.value})
          .toList(),
      'total': total,
      'customerAging': customerAging.entries
          .map((e) => {
                'customerName': e.key,
                ...e.value,
              })
          .toList()
        ..sort((a, b) =>
            (b['total'] as double).compareTo(a['total'] as double)),
    };
  }

  // Action methods
  Future<void> _sendReminder(Map<String, dynamic> receivable) async {
    final customer = receivable['customer'] as CustomerModel;
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );

    if (customer.phone == null || customer.phone!.isEmpty) {
      _showSnackBar('Customer phone number not available', Colors.orange);
      return;
    }

    if (receivable['type'] == 'invoice') {
      await _sendInvoiceReminder(
        receivable['invoice'] as InvoiceModel,
        customer,
        businessProvider.business,
      );
    } else {
      await _sendTransactionReminder(
        receivable['transaction'] as TransactionModel,
        businessProvider.business,
      );
    }
  }

  Future<void> _sendInvoiceReminder(
    InvoiceModel invoice,
    CustomerModel customer,
    dynamic business,
  ) async {
    final upiId = await _showUpiIdDialog();
    if (upiId == null || upiId.isEmpty) return;

    _showLoadingDialog();

    try {
      await PaymentUrlService.sharePaymentViaWhatsApp(
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
        Navigator.pop(context);
        _showSnackBar('Payment reminder sent successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Error sending reminder: $e', Colors.red);
      }
    }
  }

  Future<void> _sendTransactionReminder(
    TransactionModel transaction,
    dynamic business,
  ) async {
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final customer = customerProvider.getCustomerById(transaction.customerId!);

    if (customer == null || customer.phone == null || customer.phone!.isEmpty) {
      _showSnackBar('Customer phone number not available', Colors.orange);
      return;
    }

    final upiId = await _showUpiIdDialog();
    if (upiId == null || upiId.isEmpty) return;

    _showLoadingDialog();

    try {
      await PaymentUrlService.sharePaymentViaWhatsApp(
        context: context,
        phoneNumber: customer.phone!,
        customerName: customer.name,
        upiId: upiId,
        payeeName: business.name,
        amount: transaction.amount,
        transactionNote: transaction.description,
        businessName: business.name,
      );

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Payment reminder sent successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Error sending reminder: $e', Colors.red);
      }
    }
  }

  Future<void> _sendConsolidatedReminder(
    CustomerModel customer,
    List<Map<String, dynamic>> transactions,
  ) async {
    if (customer.phone == null || customer.phone!.isEmpty) {
      _showSnackBar('Customer phone number not available', Colors.orange);
      return;
    }

    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final business = businessProvider.business;
    
    if (business == null) {
      _showSnackBar('Business information not available', Colors.orange);
      return;
    }

    final upiId = await _showUpiIdDialog();
    if (upiId == null || upiId.isEmpty) return;

    _showLoadingDialog();

    try {
      final totalAmount = transactions.fold<double>(
        0,
        (sum, txn) => sum + (txn['amount'] as double),
      );

      final buffer = StringBuffer();
      buffer.writeln('Hello ${customer.name},');
      buffer.writeln();
      buffer.writeln('Payment Reminder from ${business.name}');
      buffer.writeln();
      buffer.writeln('You have ${transactions.length} pending payment(s):');
      buffer.writeln();

      for (var i = 0; i < transactions.length; i++) {
        final txn = transactions[i];
        buffer.writeln('${i + 1}. ${txn['description']}');
        buffer.writeln('   Amount: ₹${(txn['amount'] as double).toStringAsFixed(2)}');
        buffer.writeln('   Due: ${DateFormat('dd MMM yyyy').format(txn['dueDate'] as DateTime)}');
        buffer.writeln();
      }

      buffer.writeln('Total Amount Due: ₹${totalAmount.toStringAsFixed(2)}');
      buffer.writeln();
      buffer.writeln('Pay now using UPI:');

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

      await WhatsAppLauncherService.sendCustomMessage(
        phoneNumber: customer.phone!,
        message: buffer.toString(),
      );

      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Consolidated reminder sent successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Error sending reminder: $e', Colors.red);
      }
    }
  }

  Future<String?> _showUpiIdDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
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

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
