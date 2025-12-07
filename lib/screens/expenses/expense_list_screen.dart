import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'add_edit_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Office Supplies',
    'Travel',
    'Marketing',
    'Utilities',
    'Rent',
    'Insurance',
    'Professional Services',
    'Equipment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExpenses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadExpenses() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      expenseProvider.loadExpenses(businessProvider.business!.id);
    }
  }

  List<ExpenseModel> _getFilteredExpenses(List<ExpenseModel> expenses) {
    var filtered = expenses;

    // Category filter
    if (_selectedCategory != 'All') {
      filtered =
          filtered
              .where((expense) => expense.category == _selectedCategory)
              .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (expense) =>
                    expense.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    expense.category.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    expense.amount.toString().contains(_searchQuery),
              )
              .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Recurring'),
            Tab(text: 'Categories'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadExpenses),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.isLoading && expenseProvider.expenses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (expenseProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading expenses',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    expenseProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadExpenses,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllExpensesTab(expenseProvider),
              _buildRecurringExpensesTab(expenseProvider),
              _buildCategoriesTab(expenseProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAllExpensesTab(ExpenseProvider expenseProvider) {
    final filteredExpenses = _getFilteredExpenses(expenseProvider.expenses);

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search expenses...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items:
                    _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ],
          ),
        ),

        // Summary Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${filteredExpenses.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Total Expenses'),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.money_off,
                        color: AppTheme.errorColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppConstants.defaultCurrency}${filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      const Text('Total Amount'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Expense List
        Expanded(
          child:
              filteredExpenses.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No expenses found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add your first expense to get started',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return ExpenseListTile(
                        expense: expense,
                        onTap: () => _editExpense(expense),
                        onDelete: () => _deleteExpense(expense),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildRecurringExpensesTab(ExpenseProvider expenseProvider) {
    final recurringExpenses = expenseProvider.recurringExpenses;

    return recurringExpenses.isEmpty
        ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.repeat, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No recurring expenses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'Set up recurring expenses to track regular payments',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        )
        : ListView.builder(
          itemCount: recurringExpenses.length,
          itemBuilder: (context, index) {
            final expense = recurringExpenses[index];
            return ExpenseListTile(
              expense: expense,
              onTap: () => _editExpense(expense),
              onDelete: () => _deleteExpense(expense),
              showRecurringBadge: true,
            );
          },
        );
  }

  Widget _buildCategoriesTab(ExpenseProvider expenseProvider) {
    final categoryTotals = expenseProvider.getExpensesByCategories();
    final sortedCategories =
        categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCategories.isEmpty
        ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No expense categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'Add expenses to see category breakdown',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        )
        : ListView.builder(
          itemCount: sortedCategories.length,
          itemBuilder: (context, index) {
            final category = sortedCategories[index];
            final percentage =
                (category.value / expenseProvider.totalExpenses * 100);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(category.key),
                  child: const Icon(
                    Icons.category,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  category.key,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppConstants.defaultCurrency}${category.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCategoryColor(category.key),
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  setState(() {
                    _selectedCategory = category.key;
                    _tabController.animateTo(0);
                  });
                },
              ),
            );
          },
        );
  }

  Color _getCategoryColor(String category) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[category.hashCode % colors.length];
  }

  void _addExpense() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()));
  }

  void _editExpense(ExpenseModel expense) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditExpenseScreen(expense: expense)),
    );
  }

  void _deleteExpense(ExpenseModel expense) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Expense'),
            content: Text(
              'Are you sure you want to delete this expense "${expense.description}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final expenseProvider = Provider.of<ExpenseProvider>(
                    context,
                    listen: false,
                  );
                  final success = await expenseProvider.deleteExpense(
                    expense.id,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Expense deleted successfully'
                              : 'Failed to delete expense',
                        ),
                        backgroundColor:
                            success
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            ],
          ),
    );
  }
}

class ExpenseListTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool showRecurringBadge;

  const ExpenseListTile({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
    this.showRecurringBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(expense.category),
          child: const Icon(Icons.receipt, color: Colors.white, size: 20),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${expense.category}'),
            Text(
              'Date: ${expense.expenseDate.day}/${expense.expenseDate.month}/${expense.expenseDate.year}',
            ),
            if (showRecurringBadge || expense.isRecurring)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'RECURRING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${AppConstants.defaultCurrency}${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.errorColor,
              ),
            ),
            PopupMenuButton(
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppTheme.errorColor),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onTap();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[category.hashCode % colors.length];
  }
}
