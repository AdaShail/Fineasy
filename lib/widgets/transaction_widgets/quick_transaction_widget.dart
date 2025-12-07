import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_theme.dart';

class QuickTransactionWidget extends StatelessWidget {
  const QuickTransactionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.add_circle,
                    label: 'Add Income',
                    color: Colors.green,
                    onTap: () => _showQuickTransaction(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.remove_circle,
                    label: 'Add Expense',
                    color: Colors.red,
                    onTap: () => _showQuickTransaction(context, false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickTransaction(BuildContext context, bool isIncome) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: QuickTransactionForm(isIncome: isIncome),
            ),
          ),
    );
  }
}

class QuickTransactionForm extends StatefulWidget {
  final bool isIncome;

  const QuickTransactionForm({super.key, required this.isIncome});

  @override
  State<QuickTransactionForm> createState() => _QuickTransactionFormState();
}

class _QuickTransactionFormState extends State<QuickTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _paymentMode = 'cash';
  DateTime? _selectedDueDate;
  bool _showDueDateField = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isIncome ? Colors.green : Colors.red;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Icon(
                widget.isIncome ? Icons.add_circle : Icons.remove_circle,
                color: color,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Add ${widget.isIncome ? 'Income' : 'Expense'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Amount
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '₹ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter description';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Payment Mode
          DropdownButtonFormField<String>(
            initialValue: _paymentMode,
            decoration: InputDecoration(
              labelText: 'Payment Mode',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Cash')),
              DropdownMenuItem(value: 'card', child: Text('Card')),
              DropdownMenuItem(value: 'upi', child: Text('UPI')),
              DropdownMenuItem(value: 'netBanking', child: Text('Net Banking')),
              DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
              DropdownMenuItem(
                value: 'bankTransfer',
                child: Text('Bank Transfer'),
              ),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) => setState(() => _paymentMode = value!),
          ),

          const SizedBox(height: 16),

          // Add Due Date Option
          CheckboxListTile(
            title: const Text('Add Due Date'),
            subtitle: _selectedDueDate != null
                ? Text(
                    'Due: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                  )
                : null,
            value: _showDueDateField,
            onChanged: (value) {
              setState(() {
                _showDueDateField = value ?? false;
                if (_showDueDateField && _selectedDueDate == null) {
                  _selectedDueDate = DateTime.now().add(const Duration(days: 30));
                } else if (!_showDueDateField) {
                  _selectedDueDate = null;
                }
              });
            },
            contentPadding: EdgeInsets.zero,
          ),

          // Due Date Picker
          if (_showDueDateField)
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: color,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _selectedDueDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: color),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDueDate != null
                          ? 'Due: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                          : 'Select Due Date',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDueDate != null ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PaymentMode _getPaymentModeEnum(String paymentMode) {
    switch (paymentMode) {
      case 'cash':
        return PaymentMode.cash;
      case 'card':
        return PaymentMode.card;
      case 'upi':
        return PaymentMode.upi;
      case 'netBanking':
        return PaymentMode.netBanking;
      case 'cheque':
        return PaymentMode.cheque;
      case 'bankTransfer':
        return PaymentMode.bankTransfer;
      case 'other':
        return PaymentMode.other;
      default:
        return PaymentMode.other;
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      if (authProvider.user == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated. Please login again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      if (businessProvider.business == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Business not found. Please setup your business first.',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final transaction = TransactionModel(
        id: const Uuid().v4(),
        businessId: businessProvider.business!.id,
        userId: authProvider.user!.id,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.trim(),
        type:
            widget.isIncome ? TransactionType.income : TransactionType.expense,
        paymentMode: _getPaymentModeEnum(_paymentMode),
        date: DateTime.now(),
        dueDate: _selectedDueDate,
        status: _selectedDueDate != null ? TransactionStatus.pending : TransactionStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await transactionProvider.addTransaction(transaction);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        Navigator.of(context).pop(); // Close form

        if (success) {
          // Force refresh
          await transactionProvider.refreshTransactions(
            businessProvider.business!.id,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '${widget.isIncome ? 'Income' : 'Expense'} added successfully!'
                  : 'Failed to add transaction',
            ),
            backgroundColor:
                success
                    ? (widget.isIncome ? Colors.green : Colors.red)
                    : AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
