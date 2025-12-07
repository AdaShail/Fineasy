import 'package:flutter/material.dart';
import '../../models/social_models.dart';
import '../../services/social_service.dart';
import '../../services/timeline_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final ExpenseGroup? group;

  const AddExpenseScreen({super.key, this.group});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final SocialService _socialService = SocialService();
  final TimelineService _timelineService = TimelineService();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Food';
  String _transactionType = 'expense';
  ExpenseGroup? _selectedGroup;
  List<ExpenseGroup> _userGroups = [];
  DateTime _selectedDate = DateTime.now();
  final List<String> _tags = [];
  bool _shareToTimeline = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Bills',
    'Healthcare',
    'Education',
    'Travel',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedGroup = widget.group;
    _loadUserGroups();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserGroups() async {
    final groups = await _socialService.getUserGroups();
    setState(() {
      _userGroups = groups;
    });
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await _socialService.addExpense(
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      transactionType: _transactionType,
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      groupId: _selectedGroup?.id,
      date: _selectedDate,
      tags: _tags.isEmpty ? null : _tags,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Create timeline post if enabled
      if (_shareToTimeline) {
        String content;
        if (_selectedGroup != null) {
          content =
              'Added ${_transactionType == 'income' ? 'income' : 'expense'} to ${_selectedGroup!.name}: ${_titleController.text} - \$${_amountController.text}';
        } else {
          content =
              '${_transactionType == 'income' ? 'Earned' : 'Spent'} \$${_amountController.text} on ${_selectedCategory}';
        }

        await _timelineService.createPost(
          content: content,
          postType: 'expense',
          groupId: _selectedGroup?.id,
          visibility: _selectedGroup != null ? 'group' : 'friends',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add expense')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedGroup != null ? 'Add Group Expense' : 'Add Expense',
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(onPressed: _saveExpense, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type Toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'expense',
                            label: Text('Expense'),
                            icon: Icon(Icons.remove),
                          ),
                          ButtonSegment(
                            value: 'income',
                            label: Text('Income'),
                            icon: Icon(Icons.add),
                          ),
                        ],
                        selected: {_transactionType},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            _transactionType = selection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Basic Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'e.g., Lunch at restaurant',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          hintText: '0.00',
                          prefixText: '\$',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Additional details...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Group Selection
              if (_userGroups.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Group (Optional)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<ExpenseGroup?>(
                          initialValue: _selectedGroup,
                          decoration: const InputDecoration(
                            labelText: 'Select Group',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<ExpenseGroup?>(
                              value: null,
                              child: Text('Personal Expense'),
                            ),
                            ..._userGroups.map((group) {
                              return DropdownMenuItem<ExpenseGroup?>(
                                value: group,
                                child: Text(group.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGroup = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Date Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(_formatDate(_selectedDate)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Social Options
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Social Options',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Share to Timeline'),
                        subtitle: Text(
                          _selectedGroup != null
                              ? 'Share with group members'
                              : 'Share with friends',
                        ),
                        value: _shareToTimeline,
                        onChanged: (value) {
                          setState(() {
                            _shareToTimeline = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
