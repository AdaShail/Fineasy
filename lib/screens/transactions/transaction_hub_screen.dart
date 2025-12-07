import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/transaction_widgets/transaction_summary_widget.dart';
import '../../widgets/transaction_widgets/quick_transaction_widget.dart';

class TransactionHubScreen extends StatefulWidget {
  const TransactionHubScreen({super.key});

  @override
  State<TransactionHubScreen> createState() => _TransactionHubScreenState();
}

class _TransactionHubScreenState extends State<TransactionHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                title: const Text('Transactions'),
                floating: true,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _showSearchDialog(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterDialog(),
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'History'),
                    Tab(text: 'Analytics'),
                  ],
                ),
              ),
            ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildHistoryTab(),
            _buildAnalyticsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAddTransaction(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const TransactionSummaryWidget(),
          const SizedBox(height: 16),
          const QuickTransactionWidget(),
          const SizedBox(height: 16),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final transactions = _getFilteredTransactions(
          transactionProvider.transactions,
        );

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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionCard(transaction);
          },
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildAnalyticsCard(
                'Monthly Trend',
                Icons.trending_up,
                Colors.blue,
                _buildMonthlyChart(transactionProvider),
              ),
              const SizedBox(height: 16),
              _buildAnalyticsCard(
                'Payment Methods',
                Icons.payment,
                Colors.green,
                _buildPaymentMethodChart(transactionProvider),
              ),
              const SizedBox(height: 16),
              _buildAnalyticsCard(
                'Category Breakdown',
                Icons.pie_chart,
                Colors.orange,
                _buildCategoryChart(transactionProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final recentTransactions =
            transactionProvider.transactions.take(5).toList();

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _tabController.animateTo(1),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...recentTransactions.map(
                  (transaction) => _buildTransactionListItem(transaction),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isIncome ? Icons.add_circle : Icons.remove_circle,
            color: color,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(_formatPaymentMode(transaction.paymentMode)),
            Text(_formatDateTime(transaction.date)),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Widget _buildTransactionListItem(TransactionModel transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.add : Icons.remove,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDate(transaction.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    IconData icon,
    Color color,
    Widget content,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(TransactionProvider provider) {
    return Container(
      height: 200,
      child: const Center(
        child: Text('Monthly trend chart will be implemented here'),
      ),
    );
  }

  Widget _buildPaymentMethodChart(TransactionProvider provider) {
    return Container(
      height: 150,
      child: const Center(
        child: Text(
          'Payment method distribution chart will be implemented here',
        ),
      ),
    );
  }

  Widget _buildCategoryChart(TransactionProvider provider) {
    return Container(
      height: 150,
      child: const Center(
        child: Text('Category breakdown chart will be implemented here'),
      ),
    );
  }

  List<TransactionModel> _getFilteredTransactions(
    List<TransactionModel> transactions,
  ) {
    switch (_selectedFilter) {
      case 'income':
        return transactions
            .where((t) => t.type == TransactionType.income)
            .toList();
      case 'expense':
        return transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();
      case 'today':
        final today = DateTime.now();
        return transactions
            .where(
              (t) =>
                  t.date.year == today.year &&
                  t.date.month == today.month &&
                  t.date.day == today.day,
            )
            .toList();
      case 'week':
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        return transactions.where((t) => t.date.isAfter(weekAgo)).toList();
      default:
        return transactions;
    }
  }

  void _showQuickAddTransaction() {
    Navigator.pushNamed(context, '/add-transaction');
  }

  void _showSearchDialog() {
    // Implement search functionality
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                ...['all', 'income', 'expense', 'today', 'week'].map(
                  (filter) => RadioListTile<String>(
                    title: Text(_getFilterLabel(filter)),
                    value: filter,
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showTransactionDetails(TransactionModel transaction) {
    Navigator.pushNamed(
      context,
      '/transaction-details',
      arguments: transaction.id,
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'All Transactions';
      case 'income':
        return 'Income Only';
      case 'expense':
        return 'Expenses Only';
      case 'today':
        return 'Today';
      case 'week':
        return 'This Week';
      default:
        return filter;
    }
  }

  String _formatPaymentMode(PaymentMode mode) {
    return mode.toString().split('.').last.toUpperCase();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
