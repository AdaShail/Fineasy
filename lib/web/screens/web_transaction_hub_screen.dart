import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../utils/constants.dart';
import '../../screens/transactions/quick_transaction_screen.dart';
import '../widgets/web_data_table.dart';
import '../../core/responsive/responsive_layout.dart';

/// Web-optimized transaction hub with multi-tab interface and advanced features
/// Requirements: 3.4, 6.3
class WebTransactionHubScreen extends StatefulWidget {
  const WebTransactionHubScreen({super.key});

  @override
  State<WebTransactionHubScreen> createState() =>
      _WebTransactionHubScreenState();
}

class _WebTransactionHubScreenState extends State<WebTransactionHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<TransactionModel> _selectedTransactions = {};
  String _searchQuery = '';
  bool _showFilters = false;
  bool _showQuickEntry = true;

  // Filter state
  TransactionType? _filterType;
  PaymentMode? _filterPaymentMode;
  TransactionStatus? _filterStatus;
  String? _filterCustomerId;
  String? _filterSupplierId;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  double? _filterMinAmount;
  double? _filterMaxAmount;

  // Quick entry state
  final _quickAmountController = TextEditingController();
  final _quickDescriptionController = TextEditingController();
  TransactionType _quickType = TransactionType.income;
  PaymentMode _quickPaymentMode = PaymentMode.cash;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quickAmountController.dispose();
    _quickDescriptionController.dispose();
    super.dispose();
  }

  void _loadTransactions() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      transactionProvider.loadTransactions(businessProvider.business!.id);
    }
  }

  List<TransactionModel> _getFilteredTransactions(
    List<TransactionModel> transactions,
  ) {
    var filtered = transactions;

    // Type filter
    if (_filterType != null) {
      filtered = filtered.where((t) => t.type == _filterType).toList();
    }

    // Payment mode filter
    if (_filterPaymentMode != null) {
      filtered = filtered.where((t) => t.paymentMode == _filterPaymentMode).toList();
    }

    // Status filter
    if (_filterStatus != null) {
      filtered = filtered.where((t) => t.status == _filterStatus).toList();
    }

    // Customer filter
    if (_filterCustomerId != null && _filterCustomerId!.isNotEmpty) {
      filtered = filtered.where((t) => t.customerId == _filterCustomerId).toList();
    }

    // Supplier filter
    if (_filterSupplierId != null && _filterSupplierId!.isNotEmpty) {
      filtered = filtered.where((t) => t.supplierId == _filterSupplierId).toList();
    }

    // Date range filter
    if (_filterStartDate != null) {
      filtered = filtered.where((t) {
        return t.date.isAfter(_filterStartDate!) ||
            t.date.isAtSameMomentAs(_filterStartDate!);
      }).toList();
    }
    if (_filterEndDate != null) {
      filtered = filtered.where((t) {
        final endOfDay = DateTime(
          _filterEndDate!.year,
          _filterEndDate!.month,
          _filterEndDate!.day,
          23,
          59,
          59,
        );
        return t.date.isBefore(endOfDay) || t.date.isAtSameMomentAs(endOfDay);
      }).toList();
    }

    // Amount range filter
    if (_filterMinAmount != null) {
      filtered = filtered.where((t) => t.amount >= _filterMinAmount!).toList();
    }
    if (_filterMaxAmount != null) {
      filtered = filtered.where((t) => t.amount <= _filterMaxAmount!).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final supplierProvider = Provider.of<SupplierProvider>(
        context,
        listen: false,
      );

      filtered = filtered.where((transaction) {
        final query = _searchQuery.toLowerCase();

        // Search by description
        if (transaction.description.toLowerCase().contains(query)) {
          return true;
        }

        // Search by amount
        if (transaction.amount.toString().contains(query)) {
          return true;
        }

        // Search by customer name
        if (transaction.customerId != null) {
          final customer = customerProvider.getCustomerById(
            transaction.customerId!,
          );
          if (customer != null && customer.name.toLowerCase().contains(query)) {
            return true;
          }
        }

        // Search by supplier name
        if (transaction.supplierId != null) {
          final supplier = supplierProvider.getSupplierById(
            transaction.supplierId!,
          );
          if (supplier != null && supplier.name.toLowerCase().contains(query)) {
            return true;
          }
        }

        // Search by reference
        if (transaction.reference != null &&
            transaction.reference!.toLowerCase().contains(query)) {
          return true;
        }

        return false;
      }).toList();
    }

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
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewTransaction,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.isLoading && transactionProvider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredTransactions = _getFilteredTransactions(transactionProvider.transactions);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              // Type filter chips
              if (_showFilters)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterType == null,
                        onSelected: (_) => setState(() => _filterType = null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Income'),
                        selected: _filterType == TransactionType.income,
                        onSelected: (_) => setState(() => _filterType = TransactionType.income),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Expense'),
                        selected: _filterType == TransactionType.expense,
                        onSelected: (_) => setState(() => _filterType = TransactionType.expense),
                      ),
                    ],
                  ),
                ),
              if (_showFilters) const SizedBox(height: 8),
              // Transaction list
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.swap_horiz_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No transactions found', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return _buildMobileTransactionCard(transaction);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileTransactionCard(TransactionModel transaction) {
    final isIncome = transaction.type == TransactionType.income ||
        transaction.type == TransactionType.paymentIn ||
        transaction.type == TransactionType.sale;
    final color = isIncome ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${DateFormat('dd MMM yyyy').format(transaction.date)} • ${_getPaymentModeDisplayName(transaction.paymentMode)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        onTap: () => _viewTransaction(transaction),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Main content area with tabs
          Expanded(
            flex: _showQuickEntry ? 3 : 1,
            child: _buildMainContent(),
          ),

          // Quick entry sidebar
          if (_showQuickEntry)
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: _buildQuickEntrySidebar(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildHeader(),
        if (_selectedTransactions.isNotEmpty) _buildBatchProcessingToolbar(),
        if (_showFilters) _buildAdvancedFilters(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAllTransactionsTab(),
              _buildIncomeTab(),
              _buildExpenseTab(),
              _buildAnalyticsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
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
                'Transaction Hub',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              IconButton(
                icon: Icon(
                  _showQuickEntry
                      ? Icons.chevron_right
                      : Icons.chevron_left,
                ),
                onPressed: () {
                  setState(() {
                    _showQuickEntry = !_showQuickEntry;
                  });
                },
                tooltip: 'Toggle Quick Entry',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _createNewTransaction,
                icon: const Icon(Icons.add),
                label: const Text('New Transaction'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search transactions by description, amount, customer, or supplier...',
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

  Widget _buildBatchProcessingToolbar() {
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
            '${_selectedTransactions.length} selected',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: _batchMarkAsCompleted,
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Mark as Completed'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _batchCategorize,
            icon: const Icon(Icons.category, size: 18),
            label: const Text('Categorize'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _batchExport,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _batchDelete,
            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTransactions.clear();
              });
            },
            child: const Text('Clear Selection'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final supplierProvider = Provider.of<SupplierProvider>(context);

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
              // Type filter
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<TransactionType>(
                  initialValue: _filterType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<TransactionType>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...TransactionType.values.map((type) {
                      return DropdownMenuItem<TransactionType>(
                        value: type,
                        child: Text(_getTypeDisplayName(type)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterType = value;
                    });
                  },
                ),
              ),

              // Payment mode filter
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<PaymentMode>(
                  initialValue: _filterPaymentMode,
                  decoration: const InputDecoration(
                    labelText: 'Payment Mode',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<PaymentMode>(
                      value: null,
                      child: Text('All Modes'),
                    ),
                    ...PaymentMode.values.map((mode) {
                      return DropdownMenuItem<PaymentMode>(
                        value: mode,
                        child: Text(_getPaymentModeDisplayName(mode)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterPaymentMode = value;
                    });
                  },
                ),
              ),

              // Status filter
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<TransactionStatus>(
                  initialValue: _filterStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<TransactionStatus>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...TransactionStatus.values.map((status) {
                      return DropdownMenuItem<TransactionStatus>(
                        value: status,
                        child: Text(_getStatusDisplayName(status)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                  },
                ),
              ),

              // Customer filter
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: _filterCustomerId,
                  decoration: const InputDecoration(
                    labelText: 'Customer',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Customers'),
                    ),
                    ...customerProvider.customers.map((customer) {
                      return DropdownMenuItem<String>(
                        value: customer.id,
                        child: Text(customer.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterCustomerId = value;
                    });
                  },
                ),
              ),

              // Supplier filter
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: _filterSupplierId,
                  decoration: const InputDecoration(
                    labelText: 'Supplier',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Suppliers'),
                    ),
                    ...supplierProvider.suppliers.map((supplier) {
                      return DropdownMenuItem<String>(
                        value: supplier.id,
                        child: Text(supplier.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterSupplierId = value;
                    });
                  },
                ),
              ),

              // Date range
              SizedBox(
                width: 150,
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _filterStartDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _filterStartDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'From Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      _filterStartDate != null
                          ? DateFormat('dd/MM/yyyy').format(_filterStartDate!)
                          : 'Select',
                      style: TextStyle(
                        color: _filterStartDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: 150,
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _filterEndDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _filterEndDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'To Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      _filterEndDate != null
                          ? DateFormat('dd/MM/yyyy').format(_filterEndDate!)
                          : 'Select',
                      style: TextStyle(
                        color: _filterEndDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              // Amount range
              SizedBox(
                width: 150,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Min Amount',
                    border: const OutlineInputBorder(),
                    prefixText: AppConstants.defaultCurrency,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _filterMinAmount = double.tryParse(value);
                    });
                  },
                ),
              ),

              SizedBox(
                width: 150,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Max Amount',
                    border: const OutlineInputBorder(),
                    prefixText: AppConstants.defaultCurrency,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _filterMaxAmount = double.tryParse(value);
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

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(text: 'All Transactions'),
          Tab(text: 'Income'),
          Tab(text: 'Expenses'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildAllTransactionsTab() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        if (transactionProvider.isLoading &&
            transactionProvider.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (transactionProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${transactionProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadTransactions,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filteredTransactions = _getFilteredTransactions(
          transactionProvider.transactions,
        );

        return _buildTransactionTable(filteredTransactions);
      },
    );
  }

  Widget _buildIncomeTab() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final incomeTransactions = _getFilteredTransactions(
          transactionProvider.transactions,
        ).where((t) =>
            t.type == TransactionType.income ||
            t.type == TransactionType.paymentIn ||
            t.type == TransactionType.sale).toList();

        return _buildTransactionTable(incomeTransactions);
      },
    );
  }

  Widget _buildExpenseTab() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final expenseTransactions = _getFilteredTransactions(
          transactionProvider.transactions,
        ).where((t) =>
            t.type == TransactionType.expense ||
            t.type == TransactionType.paymentOut ||
            t.type == TransactionType.purchase).toList();

        return _buildTransactionTable(expenseTransactions);
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnalyticsSummary(transactionProvider),
              const SizedBox(height: 24),
              _buildPaymentModeBreakdown(transactionProvider),
              const SizedBox(height: 24),
              _buildMonthlyTrend(transactionProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionTable(List<TransactionModel> transactions) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final supplierProvider = Provider.of<SupplierProvider>(context);

    return WebDataTable<TransactionModel>(
      data: transactions,
      selectable: true,
      onSelectionChanged: (selected) {
        setState(() {
          _selectedTransactions.clear();
          _selectedTransactions.addAll(selected);
        });
      },
      columns: [
        WebDataColumn<TransactionModel>(
          label: 'Date',
          field: 'date',
          width: 120,
          valueGetter: (transaction) =>
              DateFormat('dd MMM yyyy').format(transaction.date),
        ),
        WebDataColumn<TransactionModel>(
          label: 'Description',
          field: 'description',
          width: 250,
          valueGetter: (transaction) => transaction.description,
          cellBuilder: (transaction) => Text(
            transaction.description,
            style: const TextStyle(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        WebDataColumn<TransactionModel>(
          label: 'Type',
          field: 'type',
          width: 120,
          valueGetter: (transaction) => _getTypeDisplayName(transaction.type),
          cellBuilder: (transaction) => _buildTypeChip(transaction.type),
        ),
        WebDataColumn<TransactionModel>(
          label: 'Party',
          field: 'party',
          width: 180,
          valueGetter: (transaction) {
            if (transaction.customerId != null) {
              final customer = customerProvider.getCustomerById(
                transaction.customerId!,
              );
              return customer?.name ?? 'Unknown Customer';
            } else if (transaction.supplierId != null) {
              final supplier = supplierProvider.getSupplierById(
                transaction.supplierId!,
              );
              return supplier?.name ?? 'Unknown Supplier';
            }
            return 'N/A';
          },
        ),
        WebDataColumn<TransactionModel>(
          label: 'Amount',
          field: 'amount',
          width: 150,
          valueGetter: (transaction) => transaction.amount.toStringAsFixed(2),
          cellBuilder: (transaction) {
            final isIncome = transaction.type == TransactionType.income ||
                transaction.type == TransactionType.paymentIn ||
                transaction.type == TransactionType.sale;
            return Text(
              '${isIncome ? '+' : '-'}${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            );
          },
        ),
        WebDataColumn<TransactionModel>(
          label: 'Payment Mode',
          field: 'paymentMode',
          width: 130,
          valueGetter: (transaction) =>
              _getPaymentModeDisplayName(transaction.paymentMode),
          cellBuilder: (transaction) =>
              _buildPaymentModeChip(transaction.paymentMode),
        ),
        WebDataColumn<TransactionModel>(
          label: 'Status',
          field: 'status',
          width: 120,
          valueGetter: (transaction) =>
              _getStatusDisplayName(transaction.status),
          cellBuilder: (transaction) => _buildStatusChip(transaction.status),
        ),
        WebDataColumn<TransactionModel>(
          label: 'Actions',
          field: 'actions',
          width: 100,
          sortable: false,
          cellBuilder: (transaction) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18),
                onPressed: () => _viewTransaction(transaction),
                tooltip: 'View',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => _deleteTransaction(transaction),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickEntrySidebar() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Quick Entry',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showQuickEntry = false;
                  });
                },
                tooltip: 'Close',
              ),
            ],
          ),
        ),

        // Quick entry form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type selector
                const Text(
                  'Transaction Type',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                      icon: Icon(Icons.add_circle, size: 16),
                    ),
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.remove_circle, size: 16),
                    ),
                  ],
                  selected: {_quickType},
                  onSelectionChanged: (Set<TransactionType> newSelection) {
                    setState(() {
                      _quickType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                TextField(
                  controller: _quickAmountController,
                  decoration: InputDecoration(
                    labelText: 'Amount *',
                    prefixText: AppConstants.defaultCurrency,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: _quickDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Payment mode
                DropdownButtonFormField<PaymentMode>(
                  initialValue: _quickPaymentMode,
                  decoration: InputDecoration(
                    labelText: 'Payment Mode',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: PaymentMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Row(
                        children: [
                          Icon(_getPaymentModeIcon(mode), size: 18),
                          const SizedBox(width: 8),
                          Text(_getPaymentModeDisplayName(mode)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _quickPaymentMode = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Save button
                ElevatedButton.icon(
                  onPressed: _saveQuickTransaction,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Transaction'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 8),

                // Clear button
                OutlinedButton.icon(
                  onPressed: _clearQuickEntry,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSummary(TransactionProvider provider) {
    final filteredTransactions = _getFilteredTransactions(provider.transactions);
    final totalIncome = filteredTransactions
        .where((t) =>
            t.type == TransactionType.income ||
            t.type == TransactionType.paymentIn ||
            t.type == TransactionType.sale)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = filteredTransactions
        .where((t) =>
            t.type == TransactionType.expense ||
            t.type == TransactionType.paymentOut ||
            t.type == TransactionType.purchase)
        .fold(0.0, (sum, t) => sum + t.amount);
    final netBalance = totalIncome - totalExpense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Income',
                    totalIncome,
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Expenses',
                    totalExpense,
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Net Balance',
                    netBalance,
                    Icons.account_balance_wallet,
                    netBalance >= 0 ? Colors.blue : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Icon(Icons.arrow_forward, color: color.withValues(alpha: 0.5), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${AppConstants.defaultCurrency}${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModeBreakdown(TransactionProvider provider) {
    final filteredTransactions = _getFilteredTransactions(provider.transactions);
    final modeBreakdown = <PaymentMode, double>{};

    for (final transaction in filteredTransactions) {
      modeBreakdown[transaction.paymentMode] =
          (modeBreakdown[transaction.paymentMode] ?? 0) + transaction.amount;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Mode Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...modeBreakdown.entries.map((entry) {
              final percentage = filteredTransactions.isEmpty
                  ? 0.0
                  : (entry.value /
                          filteredTransactions.fold(
                              0.0, (sum, t) => sum + t.amount)) *
                      100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_getPaymentModeIcon(entry.key), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _getPaymentModeDisplayName(entry.key),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          '${AppConstants.defaultCurrency}${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrend(TransactionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Trend',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Chart visualization will be implemented with a charting library',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets
  Widget _buildTypeChip(TransactionType type) {
    Color color;
    IconData icon;

    switch (type) {
      case TransactionType.income:
      case TransactionType.paymentIn:
      case TransactionType.sale:
        color = Colors.green;
        icon = Icons.add_circle;
        break;
      case TransactionType.expense:
      case TransactionType.paymentOut:
      case TransactionType.purchase:
        color = Colors.red;
        icon = Icons.remove_circle;
        break;
      case TransactionType.credit:
        color = Colors.blue;
        icon = Icons.arrow_upward;
        break;
      case TransactionType.debit:
        color = Colors.orange;
        icon = Icons.arrow_downward;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _getTypeDisplayName(type),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModeChip(PaymentMode mode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPaymentModeIcon(mode), size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            _getPaymentModeDisplayName(mode),
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TransactionStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case TransactionStatus.pending:
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case TransactionStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case TransactionStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _getStatusDisplayName(status),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getTypeDisplayName(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.credit:
        return 'Credit';
      case TransactionType.debit:
        return 'Debit';
      case TransactionType.paymentIn:
        return 'Payment In';
      case TransactionType.paymentOut:
        return 'Payment Out';
      case TransactionType.sale:
        return 'Sale';
      case TransactionType.purchase:
        return 'Purchase';
    }
  }

  String _getPaymentModeDisplayName(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.card:
        return 'Card';
      case PaymentMode.upi:
        return 'UPI';
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

  String _getStatusDisplayName(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _getPaymentModeIcon(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return Icons.money;
      case PaymentMode.card:
        return Icons.credit_card;
      case PaymentMode.upi:
        return Icons.qr_code;
      case PaymentMode.netBanking:
        return Icons.account_balance;
      case PaymentMode.cheque:
        return Icons.receipt;
      case PaymentMode.bankTransfer:
        return Icons.swap_horiz;
      case PaymentMode.other:
        return Icons.more_horiz;
    }
  }

  void _clearFilters() {
    setState(() {
      _filterType = null;
      _filterPaymentMode = null;
      _filterStatus = null;
      _filterCustomerId = null;
      _filterSupplierId = null;
      _filterStartDate = null;
      _filterEndDate = null;
      _filterMinAmount = null;
      _filterMaxAmount = null;
    });
  }

  void _createNewTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const QuickTransactionScreen(
          transactionType: QuickTransactionType.paymentReceived,
        ),
      ),
    ).then((_) => _loadTransactions());
  }

  Future<void> _saveQuickTransaction() async {
    if (_quickAmountController.text.isEmpty ||
        _quickDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_quickAmountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No business selected'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final transaction = TransactionModel(
      id: '',
      businessId: businessProvider.business!.id,
      userId: businessProvider.business!.userId,
      type: _quickType,
      amount: amount,
      description: _quickDescriptionController.text.trim(),
      paymentMode: _quickPaymentMode,
      date: DateTime.now(),
      status: TransactionStatus.completed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await transactionProvider.addTransaction(transaction);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _clearQuickEntry();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              transactionProvider.error ?? 'Failed to save transaction',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearQuickEntry() {
    _quickAmountController.clear();
    _quickDescriptionController.clear();
    setState(() {
      _quickType = TransactionType.income;
      _quickPaymentMode = PaymentMode.cash;
    });
  }

  void _viewTransaction(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Date', DateFormat('dd MMM yyyy').format(transaction.date)),
              _buildDetailRow('Description', transaction.description),
              _buildDetailRow('Type', _getTypeDisplayName(transaction.type)),
              _buildDetailRow(
                'Amount',
                '${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Payment Mode',
                _getPaymentModeDisplayName(transaction.paymentMode),
              ),
              _buildDetailRow('Status', _getStatusDisplayName(transaction.status)),
              if (transaction.reference != null)
                _buildDetailRow('Reference', transaction.reference!),
              if (transaction.notes != null)
                _buildDetailRow('Notes', transaction.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(TransactionModel transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
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

    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    final success = await transactionProvider.deleteTransaction(transaction.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Transaction deleted successfully'
                : 'Failed to delete transaction',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _batchMarkAsCompleted() async {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    int successCount = 0;
    for (final transaction in _selectedTransactions) {
      final updatedTransaction = transaction.copyWith(
        status: TransactionStatus.completed,
      );
      final success = await transactionProvider.updateTransaction(
        updatedTransaction,
      );
      if (success) successCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successCount transactions marked as completed'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedTransactions.clear();
      });
    }
  }

  Future<void> _batchCategorize() async {
    // Show categorization dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Batch categorization feature coming soon'),
      ),
    );
  }

  Future<void> _batchExport() async {
    // Export selected transactions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting ${_selectedTransactions.length} transactions...'),
      ),
    );
    // TODO: Implement CSV export
  }

  Future<void> _batchDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transactions'),
        content: Text(
          'Are you sure you want to delete ${_selectedTransactions.length} transactions?',
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

    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    int successCount = 0;
    for (final transaction in _selectedTransactions) {
      final success = await transactionProvider.deleteTransaction(
        transaction.id,
      );
      if (success) successCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successCount transactions deleted'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedTransactions.clear();
      });
    }
  }
}
