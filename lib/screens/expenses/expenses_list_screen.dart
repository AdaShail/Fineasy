import 'package:flutter/material.dart';
import '../../models/social_models.dart';
import '../../services/social_service.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen>
    with TickerProviderStateMixin {
  final SocialService _socialService = SocialService();
  late TabController _tabController;

  List<Expense> _personalExpenses = [];
  List<Expense> _groupExpenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExpenses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);

    try {
      // Load personal expenses
      final personalExpenses = await _socialService.getExpenses();

      // Load group expenses (you'll need to implement this)
      final groupExpenses = await _loadGroupExpenses();

      setState(() {
        _personalExpenses =
            personalExpenses.where((e) => e.expenseType == 'personal').toList();
        _groupExpenses = groupExpenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load expenses: $e')));
    }
  }

  Future<List<Expense>> _loadGroupExpenses() async {
    // This is a placeholder - implement group expense loading
    final allExpenses = await _socialService.getExpenses();
    return allExpenses.where((e) => e.expenseType == 'group').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Summary cards
          _buildSummaryCards(),

          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Personal (${_personalExpenses.length})'),
              Tab(text: 'Groups (${_groupExpenses.length})'),
            ],
          ),

          // Tab content
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildExpensesList(_personalExpenses),
                        _buildExpensesList(_groupExpenses),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalIncome = _personalExpenses
        .where((e) => e.transactionType == 'income')
        .fold(0.0, (sum, e) => sum + e.amount);

    final totalExpenses = _personalExpenses
        .where((e) => e.transactionType == 'expense')
        .fold(0.0, (sum, e) => sum + e.amount);

    final balance = totalIncome - totalExpenses;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Income',
              '\$${totalIncome.toStringAsFixed(2)}',
              Colors.green,
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Expenses',
              '\$${totalExpenses.toStringAsFixed(2)}',
              Colors.red,
              Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Balance',
              '\$${balance.toStringAsFixed(2)}',
              balance >= 0 ? Colors.green : Colors.red,
              balance >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses) {
    if (expenses.isEmpty) {
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
              'No expenses yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your expenses',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExpenses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return _buildExpenseTile(expense);
        },
      ),
    );
  }

  Widget _buildExpenseTile(Expense expense) {
    final isIncome = expense.transactionType == 'income';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isIncome
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(expense.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.category),
            if (expense.description != null)
              Text(
                expense.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            Text(
              _formatDate(expense.date),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}\$${expense.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
            if (expense.group != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  expense.group!.name,
                  style: const TextStyle(fontSize: 10, color: Colors.blue),
                ),
              ),
          ],
        ),
        onTap: () {
          // Navigate to expense details
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
