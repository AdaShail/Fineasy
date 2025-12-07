import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isEditing = false;
  String _selectedCategory = 'Office Supplies';
  DateTime _expenseDate = DateTime.now();
  bool _isRecurring = false;
  RecurrenceType _recurrenceType = RecurrenceType.monthly;

  final List<String> _categories = [
    'Office Supplies',
    'Travel',
    'Marketing',
    'Utilities',
    'Rent',
    'Insurance',
    'Professional Services',
    'Equipment',
    'Meals & Entertainment',
    'Software & Subscriptions',
    'Training & Education',
    'Maintenance & Repairs',
    'Fuel & Transportation',
    'Communication',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.expense != null;

    if (_isEditing) {
      final expense = widget.expense!;
      _descriptionController.text = expense.description;
      _amountController.text = expense.amount.toString();
      _selectedCategory = expense.category;
      _expenseDate = expense.expenseDate;
      _isRecurring = expense.isRecurring;
      _recurrenceType = expense.recurrenceType ?? RecurrenceType.monthly;
      _notesController.text = expense.notes ?? '';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business information not found'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    final expense = ExpenseModel(
      id: _isEditing ? widget.expense!.id : const Uuid().v4(),
      businessId: businessProvider.business!.id,
      userId: businessProvider.business!.userId,
      description: _descriptionController.text.trim(),
      amount: double.tryParse(_amountController.text) ?? 0.0,
      category: _selectedCategory,
      expenseDate: _expenseDate,
      isRecurring: _isRecurring,
      recurrenceType: _isRecurring ? _recurrenceType : null,
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
      createdAt: _isEditing ? widget.expense!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await expenseProvider.updateExpense(expense);
    } else {
      success = await expenseProvider.addExpense(expense);
    }

    if (success && mounted) {
      Navigator.of(context).pop(expense);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Expense updated successfully'
                : 'Expense added successfully',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(expenseProvider.error ?? 'Failed to save expense'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Expense' : 'Add Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expense Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          prefixIcon: Icon(Icons.description),
                          hintText: 'Enter expense description',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter expense description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount *',
                          prefixText: AppConstants.defaultCurrency,
                          prefixIcon: const Icon(Icons.money),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          prefixIcon: Icon(Icons.category),
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
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _expenseDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _expenseDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expense Date *',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_expenseDate.day}/${_expenseDate.month}/${_expenseDate.year}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Recurring Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recurring Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Recurring Expense'),
                        subtitle: const Text('This expense repeats regularly'),
                        value: _isRecurring,
                        onChanged: (value) {
                          setState(() {
                            _isRecurring = value;
                          });
                        },
                      ),
                      if (_isRecurring) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<RecurrenceType>(
                          initialValue: _recurrenceType,
                          decoration: const InputDecoration(
                            labelText: 'Recurrence Type',
                            prefixIcon: Icon(Icons.repeat),
                          ),
                          items:
                              RecurrenceType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    _getRecurrenceTypeDisplayName(type),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _recurrenceType = value!;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Additional Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: Icon(Icons.note),
                          alignLabelWithHint: true,
                          hintText: 'Additional notes about this expense',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Consumer<ExpenseProvider>(
                builder: (context, expenseProvider, child) {
                  return ElevatedButton(
                    onPressed: expenseProvider.isLoading ? null : _saveExpense,
                    child:
                        expenseProvider.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              _isEditing ? 'Update Expense' : 'Add Expense',
                            ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRecurrenceTypeDisplayName(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.quarterly:
        return 'Quarterly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }
}
