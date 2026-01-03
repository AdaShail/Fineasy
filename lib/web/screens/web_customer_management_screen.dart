import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/customer_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';
import '../../screens/customers/add_edit_customer_screen.dart';
import '../widgets/web_data_table.dart';
import '../../core/responsive/responsive_layout.dart';

/// Web-optimized customer management screen with master-detail layout
/// Requirements: 3.3, 6.3
class WebCustomerManagementScreen extends StatefulWidget {
  const WebCustomerManagementScreen({super.key});

  @override
  State<WebCustomerManagementScreen> createState() =>
      _WebCustomerManagementScreenState();
}

class _WebCustomerManagementScreenState
    extends State<WebCustomerManagementScreen> {
  CustomerModel? _selectedCustomer;
  final Set<CustomerModel> _selectedCustomers = {};
  String _searchQuery = '';
  bool _showFilters = false;
  double? _filterMinBalance;
  double? _filterMaxBalance;
  String _sortField = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
    });
  }

  void _loadCustomers() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      customerProvider.loadCustomers(businessProvider.business!.id);
    }
  }

  List<CustomerModel> _getFilteredCustomers(List<CustomerModel> customers) {
    var filtered = customers;

    // Balance range filter
    if (_filterMinBalance != null) {
      filtered = filtered
          .where((customer) => customer.balance >= _filterMinBalance!)
          .toList();
    }
    if (_filterMaxBalance != null) {
      filtered = filtered
          .where((customer) => customer.balance <= _filterMaxBalance!)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((customer) {
        final query = _searchQuery.toLowerCase();
        return customer.name.toLowerCase().contains(query) ||
            (customer.phone?.contains(query) ?? false) ||
            (customer.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort
    filtered.sort((a, b) {
      int comparison;
      switch (_sortField) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'balance':
          comparison = a.balance.compareTo(b.balance);
          break;
        case 'lastTransaction':
          final aDate = a.lastTransactionDate ?? DateTime(1970);
          final bDate = b.lastTransactionDate ?? DateTime(1970);
          comparison = aDate.compareTo(bDate);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
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
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewCustomer,
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          if (customerProvider.isLoading && customerProvider.customers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredCustomers = _getFilteredCustomers(customerProvider.customers);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              // Customer list
              Expanded(
                child: filteredCustomers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No customers found', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return _buildMobileCustomerCard(customer);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileCustomerCard(CustomerModel customer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: customer.balance > 0
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          child: Text(
            customer.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: customer.balance > 0 ? Colors.green : Colors.grey,
            ),
          ),
        ),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(customer.phone ?? customer.email ?? 'No contact'),
        trailing: Text(
          '${AppConstants.defaultCurrency}${customer.balance.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: customer.balance > 0 ? Colors.green : Colors.grey,
          ),
        ),
        onTap: () => _editCustomer(customer),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Left side: Customer list with filters
          Expanded(
            flex: _selectedCustomer == null ? 1 : 2,
            child: _buildCustomerList(),
          ),

          // Right side: Customer detail
          if (_selectedCustomer != null)
            Expanded(
              flex: 3,
              child: _buildCustomerDetail(),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        if (customerProvider.isLoading && customerProvider.customers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (customerProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${customerProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadCustomers,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filteredCustomers = _getFilteredCustomers(
          customerProvider.customers,
        );

        return Column(
          children: [
            _buildListHeader(filteredCustomers.length),
            if (_selectedCustomers.isNotEmpty) _buildBulkOperationsToolbar(),
            if (_showFilters) _buildAdvancedFilters(),
            Expanded(
              child: _buildCustomerTable(filteredCustomers),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListHeader(int totalCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Customers',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Chip(
                label: Text('$totalCount'),
                backgroundColor: Colors.blue.shade100,
              ),
              const Spacer(),
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
                onPressed: _createNewCustomer,
                icon: const Icon(Icons.add),
                label: const Text('New Customer'),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'export') {
                    _exportCustomers();
                  } else if (value == 'import') {
                    _importCustomers();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Export CSV'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'import',
                    child: Row(
                      children: [
                        Icon(Icons.upload),
                        SizedBox(width: 8),
                        Text('Import CSV'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search customers by name, phone, or email...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBulkOperationsToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedCustomers.length} selected',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: _bulkExport,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export Selected'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _bulkDelete,
            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCustomers.clear();
              });
            },
            child: const Text('Clear Selection'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Advanced Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 150,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Min Balance',
                    border: const OutlineInputBorder(),
                    prefixText: AppConstants.defaultCurrency,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _filterMinBalance = double.tryParse(value);
                    });
                  },
                ),
              ),
              SizedBox(
                width: 150,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Max Balance',
                    border: const OutlineInputBorder(),
                    prefixText: AppConstants.defaultCurrency,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _filterMaxBalance = double.tryParse(value);
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTable(List<CustomerModel> customers) {
    return WebDataTable<CustomerModel>(
      data: customers,
      selectable: true,
      onSelectionChanged: (selected) {
        setState(() {
          _selectedCustomers.clear();
          _selectedCustomers.addAll(selected);
        });
      },
      onRowTap: (customer) {
        setState(() {
          _selectedCustomer = customer;
        });
      },
      columns: [
        WebDataColumn<CustomerModel>(
          label: 'Name',
          field: 'name',
          width: 200,
          valueGetter: (customer) => customer.name,
          cellBuilder: (customer) => Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: customer.balance > 0
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                child: Text(
                  customer.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: customer.balance > 0 ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customer.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        WebDataColumn<CustomerModel>(
          label: 'Phone',
          field: 'phone',
          width: 150,
          valueGetter: (customer) => customer.phone ?? 'N/A',
        ),
        WebDataColumn<CustomerModel>(
          label: 'Email',
          field: 'email',
          width: 200,
          valueGetter: (customer) => customer.email ?? 'N/A',
        ),
        WebDataColumn<CustomerModel>(
          label: 'Balance',
          field: 'balance',
          width: 150,
          valueGetter: (customer) => customer.balance.toStringAsFixed(2),
          cellBuilder: (customer) => Text(
            '${AppConstants.defaultCurrency}${customer.balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: customer.balance > 0 ? Colors.green : Colors.grey,
            ),
          ),
        ),
        WebDataColumn<CustomerModel>(
          label: 'Last Transaction',
          field: 'lastTransaction',
          width: 150,
          valueGetter: (customer) => customer.lastTransactionDate != null
              ? DateFormat('dd MMM yyyy').format(customer.lastTransactionDate!)
              : 'Never',
        ),
        WebDataColumn<CustomerModel>(
          label: 'Actions',
          field: 'actions',
          width: 100,
          sortable: false,
          cellBuilder: (customer) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _editCustomer(customer),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => _deleteCustomer(customer),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerDetail() {
    if (_selectedCustomer == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          _buildDetailHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerInfo(),
                  const SizedBox(height: 24),
                  _buildContactInfo(),
                  const SizedBox(height: 24),
                  _buildRelationshipVisualization(),
                  const SizedBox(height: 24),
                  _buildActivityTimeline(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _selectedCustomer!.balance > 0
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            child: Text(
              _selectedCustomer!.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _selectedCustomer!.balance > 0
                    ? Colors.green
                    : Colors.grey,
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
                  ),
                ),
                Text(
                  _selectedCustomer!.phone ?? 'No phone',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editCustomer(_selectedCustomer!),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedCustomer = null;
              });
            },
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Balance',
                    '${AppConstants.defaultCurrency}${_selectedCustomer!.balance.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    _selectedCustomer!.balance > 0
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Customer Since',
                    DateFormat('dd MMM yyyy').format(
                      _selectedCustomer!.createdAt,
                    ),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Last Transaction',
                    _selectedCustomer!.lastTransactionDate != null
                        ? DateFormat('dd MMM yyyy').format(
                          _selectedCustomer!.lastTransactionDate!,
                        )
                        : 'Never',
                    Icons.history,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'GST Number',
                    _selectedCustomer!.gstNumber ?? 'Not provided',
                    Icons.receipt_long,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_selectedCustomer!.phone != null)
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(_selectedCustomer!.phone!),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    // TODO: Implement phone call
                  },
                ),
              ),
            if (_selectedCustomer!.email != null)
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(_selectedCustomer!.email!),
                trailing: IconButton(
                  icon: const Icon(Icons.mail),
                  onPressed: () {
                    // TODO: Implement email
                  },
                ),
              ),
            if (_selectedCustomer!.address != null)
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Address'),
                subtitle: Text(_selectedCustomer!.address!),
                trailing: IconButton(
                  icon: const Icon(Icons.directions),
                  onPressed: () {
                    // TODO: Implement directions
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipVisualization() {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final totalReceivables = customerProvider.totalReceivables;
    final customerPercentage = totalReceivables > 0
        ? (_selectedCustomer!.balance / totalReceivables * 100)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Relationship Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share of Total Receivables',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: customerPercentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${customerPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatChip(
                  'Total Receivables',
                  '${AppConstants.defaultCurrency}${totalReceivables.toStringAsFixed(2)}',
                  Colors.blue,
                ),
                _buildStatChip(
                  'Customer Balance',
                  '${AppConstants.defaultCurrency}${_selectedCustomer!.balance.toStringAsFixed(2)}',
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
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
    );
  }

  Widget _buildActivityTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _viewFullHistory,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                final transactions = transactionProvider.transactions
                    .where((t) => t.customerId == _selectedCustomer!.id)
                    .take(5)
                    .toList();

                if (transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recent activity',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTimelineItem(transaction);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TransactionModel transaction) {
    IconData icon;
    Color color;
    String title;

    switch (transaction.type) {
      case TransactionType.paymentIn:
      case TransactionType.income:
        icon = Icons.arrow_downward;
        color = Colors.green;
        title = 'Payment Received';
        break;
      case TransactionType.sale:
      case TransactionType.credit:
        icon = Icons.shopping_cart;
        color = Colors.blue;
        title = 'Sale/Credit';
        break;
      case TransactionType.paymentOut:
      case TransactionType.expense:
        icon = Icons.arrow_upward;
        color = Colors.red;
        title = 'Payment Made';
        break;
      case TransactionType.purchase:
      case TransactionType.debit:
        icon = Icons.shopping_bag;
        color = Colors.orange;
        title = 'Purchase/Debit';
        break;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        DateFormat('dd MMM yyyy, hh:mm a').format(transaction.date),
      ),
      trailing: Text(
        '${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _filterMinBalance = null;
      _filterMaxBalance = null;
    });
  }

  void _createNewCustomer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddEditCustomerScreen(),
      ),
    ).then((_) => _loadCustomers());
  }

  void _editCustomer(CustomerModel customer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditCustomerScreen(customer: customer),
      ),
    ).then((_) {
      _loadCustomers();
      if (_selectedCustomer?.id == customer.id) {
        final customerProvider = Provider.of<CustomerProvider>(
          context,
          listen: false,
        );
        setState(() {
          _selectedCustomer = customerProvider.getCustomerById(customer.id);
        });
      }
    });
  }

  Future<void> _deleteCustomer(CustomerModel customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete "${customer.name}"?',
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

    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    final success = await customerProvider.deleteCustomer(customer.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Customer deleted successfully'
                : 'Failed to delete customer',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success && _selectedCustomer?.id == customer.id) {
        setState(() {
          _selectedCustomer = null;
        });
      }
    }
  }

  Future<void> _bulkDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customers'),
        content: Text(
          'Are you sure you want to delete ${_selectedCustomers.length} customers?',
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

    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    int successCount = 0;
    for (final customer in _selectedCustomers) {
      final success = await customerProvider.deleteCustomer(customer.id);
      if (success) successCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successCount customers deleted'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedCustomers.clear();
        if (_selectedCustomer != null &&
            _selectedCustomers.contains(_selectedCustomer)) {
          _selectedCustomer = null;
        }
      });
    }
  }

  void _exportCustomers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon'),
      ),
    );
  }

  void _importCustomers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import functionality coming soon'),
      ),
    );
  }

  void _bulkExport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${_selectedCustomers.length} customers...'),
      ),
    );
  }

  void _viewFullHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full history view coming soon'),
      ),
    );
  }
}
