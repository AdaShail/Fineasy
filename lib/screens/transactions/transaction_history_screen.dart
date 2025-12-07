import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'add_edit_transaction_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String title;
  final String? customerId;
  final String? supplierId;

  const TransactionHistoryScreen({
    super.key,
    required this.title,
    this.customerId,
    this.supplierId,
  });

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  List<TransactionModel> _filteredTransactions = [];
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTransactions() {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    List<TransactionModel> transactions = transactionProvider.transactions;

    // Filter by customer or supplier
    if (widget.customerId != null) {
      transactions =
          transactions.where((t) => t.customerId == widget.customerId).toList();
    } else if (widget.supplierId != null) {
      transactions =
          transactions.where((t) => t.supplierId == widget.supplierId).toList();
    }

    setState(() {
      _filteredTransactions = transactions;
    });
  }

  void _filterTransactions(String query) {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    List<TransactionModel> transactions = transactionProvider.transactions;

    // Filter by customer or supplier
    if (widget.customerId != null) {
      transactions =
          transactions.where((t) => t.customerId == widget.customerId).toList();
    } else if (widget.supplierId != null) {
      transactions =
          transactions.where((t) => t.supplierId == widget.supplierId).toList();
    }

    if (query.isNotEmpty) {
      transactions =
          transactions
              .where(
                (transaction) =>
                    transaction.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    transaction.amount.toString().contains(query) ||
                    transaction.reference?.toLowerCase().contains(
                          query.toLowerCase(),
                        ) ==
                        true,
              )
              .toList();
    }

    // Apply date filter
    if (_selectedDateRange != null) {
      transactions =
          transactions
              .where(
                (transaction) =>
                    transaction.date.isAfter(
                      _selectedDateRange!.start.subtract(
                        const Duration(days: 1),
                      ),
                    ) &&
                    transaction.date.isBefore(
                      _selectedDateRange!.end.add(const Duration(days: 1)),
                    ),
              )
              .toList();
    }

    setState(() {
      _filteredTransactions = transactions;
    });
  }

  void _selectDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );

    if (dateRange != null) {
      setState(() {
        _selectedDateRange = dateRange;
      });
      _filterTransactions(_searchController.text);
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateRange = null;
    });
    _filterTransactions(_searchController.text);
  }

  void _addTransaction() async {
    final result = await Navigator.of(context).push<TransactionModel>(
      MaterialPageRoute(
        builder:
            (_) => AddEditTransactionScreen(
              customerId: widget.customerId,
              supplierId: widget.supplierId,
            ),
      ),
    );

    if (result != null) {
      _loadTransactions();
    }
  }

  void _editTransaction(TransactionModel transaction) async {
    final result = await Navigator.of(context).push<TransactionModel>(
      MaterialPageRoute(
        builder:
            (_) => AddEditTransactionScreen(
              transaction: transaction,
              customerId: widget.customerId,
              supplierId: widget.supplierId,
            ),
      ),
    );

    if (result != null) {
      _loadTransactions();
    }
  }

  void _deleteTransaction(TransactionModel transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: Text(
              'Are you sure you want to delete this transaction of ${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );
      final success = await transactionProvider.deleteTransaction(
        transaction.id,
      );

      if (success && mounted) {
        _loadTransactions();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              transactionProvider.error ?? 'Failed to delete transaction',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
            tooltip: 'Filter by Date',
          ),
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDateFilter,
              tooltip: 'Clear Date Filter',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: _filterTransactions,
                ),
                if (_selectedDateRange != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.date_range,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _clearDateFilter,
                          child: const Icon(
                            Icons.close,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Summary Card
          if (_filteredTransactions.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          'Total Income',
                          _filteredTransactions
                              .where((t) => t.type == TransactionType.income)
                              .fold(0.0, (sum, t) => sum + t.amount),
                          AppTheme.successColor,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      Expanded(
                        child: _buildSummaryItem(
                          'Total Expense',
                          _filteredTransactions
                              .where((t) => t.type == TransactionType.expense)
                              .fold(0.0, (sum, t) => sum + t.amount),
                          AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Transactions List
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                if (transactionProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_filteredTransactions.isEmpty) {
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
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
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

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _filteredTransactions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              transaction.type == TransactionType.income
                                  ? AppTheme.successColor.withValues(alpha: 0.1)
                                  : AppTheme.errorColor.withValues(alpha: 0.1),
                          child: Icon(
                            transaction.type == TransactionType.income
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color:
                                transaction.type == TransactionType.income
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                          ),
                        ),
                        title: Text(
                          transaction.description,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${transaction.paymentMode.toString().split('.').last.toUpperCase()} • ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.date)}',
                            ),
                            if (transaction.reference != null)
                              Text(
                                'Ref: ${transaction.reference}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${transaction.type == TransactionType.income ? '+' : '-'}${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    transaction.type == TransactionType.income
                                        ? AppTheme.successColor
                                        : AppTheme.errorColor,
                              ),
                            ),
                            if (!transaction.isSynced)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Pending',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.warningColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () => _editTransaction(transaction),
                        onLongPress: () => _deleteTransaction(transaction),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${AppConstants.defaultCurrency}${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
