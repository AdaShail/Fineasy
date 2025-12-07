import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/transaction_model.dart';
import '../../models/customer_model.dart';
import '../../models/supplier_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

enum QuickTransactionType {
  paymentReceived,
  saleCredit,
  paymentMade,
  purchaseDebit,
}

class QuickTransactionScreen extends StatefulWidget {
  final QuickTransactionType transactionType;
  final CustomerModel? customer;
  final SupplierModel? supplier;

  const QuickTransactionScreen({
    super.key,
    required this.transactionType,
    this.customer,
    this.supplier,
  });

  @override
  State<QuickTransactionScreen> createState() => _QuickTransactionScreenState();
}

class _QuickTransactionScreenState extends State<QuickTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();

  PaymentMode _selectedPaymentMode = PaymentMode.cash;
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedDueDate;
  bool _showDueDateField = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setDefaultDescription();
  }

  void _setDefaultDescription() {
    String description = '';
    switch (widget.transactionType) {
      case QuickTransactionType.paymentReceived:
        description =
            'Payment received from ${widget.customer?.name ?? 'customer'}';
        break;
      case QuickTransactionType.saleCredit:
        description = 'Sale/Credit to ${widget.customer?.name ?? 'customer'}';
        break;
      case QuickTransactionType.paymentMade:
        description = 'Payment made to ${widget.supplier?.name ?? 'supplier'}';
        break;
      case QuickTransactionType.purchaseDebit:
        description =
            'Purchase/Debit from ${widget.supplier?.name ?? 'supplier'}';
        break;
    }
    _descriptionController.text = description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        backgroundColor: _getThemeColor(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildPaymentModeField(),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildReferenceField(),
              const SizedBox(height: 16),
              _buildDueDateSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    if (widget.customer != null) {
      final customer = widget.customer!;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getThemeColor(),
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Current Balance: ${AppConstants.defaultCurrency}${customer.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                            customer.balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (widget.supplier != null) {
      final supplier = widget.supplier!;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getThemeColor(),
                child: Text(
                  supplier.name.isNotEmpty
                      ? supplier.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Current Balance: ${AppConstants.defaultCurrency}${supplier.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                            supplier.balance >= 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Amount *',
        prefixText: AppConstants.defaultCurrency,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description *',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      maxLines: 2,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter description';
        }
        return null;
      },
    );
  }

  Widget _buildPaymentModeField() {
    return DropdownButtonFormField<PaymentMode>(
      initialValue: _selectedPaymentMode,
      decoration: InputDecoration(
        labelText: 'Payment Mode',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items:
          PaymentMode.values.map((mode) {
            return DropdownMenuItem(
              value: mode,
              child: Row(
                children: [
                  Icon(_getPaymentModeIcon(mode)),
                  const SizedBox(width: 8),
                  Text(_getPaymentModeText(mode)),
                ],
              ),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPaymentMode = value!;
        });
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Transaction Date',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceField() {
    return TextFormField(
      controller: _referenceController,
      decoration: InputDecoration(
        labelText: 'Reference Number (Optional)',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
        hintText: 'Cheque number, transaction ID, etc.',
      ),
    );
  }

  Widget _buildDueDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('Add Due Date'),
          subtitle:
              _selectedDueDate != null
                  ? Text(
                    'Due: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                    style: const TextStyle(color: Colors.blue),
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
        if (_showDueDateField)
          InkWell(
            onTap: _selectDueDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: _getThemeColor()),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDueDate != null
                        ? 'Due: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                        : 'Select Due Date',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          _selectedDueDate != null
                              ? Colors.black87
                              : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getThemeColor(),
          foregroundColor: Colors.white,
        ),
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                  'Save ${_getTransactionTypeText()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (businessProvider.business == null) {
        throw Exception('No business selected');
      }

      if (authProvider.user == null) {
        throw Exception('User not authenticated');
      }

      final amount = double.parse(_amountController.text);
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        businessId: businessProvider.business!.id,
        userId: authProvider.user!.id,
        customerId: widget.customer?.id,
        supplierId: widget.supplier?.id,
        type: _getTransactionType(),
        amount: amount,
        description: _descriptionController.text.trim(),
        paymentMode: _selectedPaymentMode,
        date: _selectedDate,
        dueDate: _selectedDueDate,
        reference:
            _referenceController.text.trim().isEmpty
                ? null
                : _referenceController.text.trim(),
        status: _selectedDueDate != null ? TransactionStatus.pending : TransactionStatus.completed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await transactionProvider.addTransaction(transaction);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getTransactionTypeText()} saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        throw Exception(
          transactionProvider.error ?? 'Failed to save transaction',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getScreenTitle() {
    switch (widget.transactionType) {
      case QuickTransactionType.paymentReceived:
        return 'Payment Received';
      case QuickTransactionType.saleCredit:
        return 'Sale/Credit';
      case QuickTransactionType.paymentMade:
        return 'Payment Made';
      case QuickTransactionType.purchaseDebit:
        return 'Purchase/Debit';
    }
  }

  String _getTransactionTypeText() {
    switch (widget.transactionType) {
      case QuickTransactionType.paymentReceived:
        return 'Payment';
      case QuickTransactionType.saleCredit:
        return 'Sale/Credit';
      case QuickTransactionType.paymentMade:
        return 'Payment';
      case QuickTransactionType.purchaseDebit:
        return 'Purchase/Debit';
    }
  }

  TransactionType _getTransactionType() {
    switch (widget.transactionType) {
      case QuickTransactionType.paymentReceived:
        return TransactionType.income;
      case QuickTransactionType.saleCredit:
        return TransactionType.credit;
      case QuickTransactionType.paymentMade:
        return TransactionType.expense;
      case QuickTransactionType.purchaseDebit:
        return TransactionType.debit;
    }
  }

  Color _getThemeColor() {
    switch (widget.transactionType) {
      case QuickTransactionType.paymentReceived:
      case QuickTransactionType.saleCredit:
        return Colors.green;
      case QuickTransactionType.paymentMade:
      case QuickTransactionType.purchaseDebit:
        return Colors.red;
    }
  }

  IconData _getPaymentModeIcon(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash:
        return Icons.money;
      //option and proper widget to load only when cash is selected
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

  String _getPaymentModeText(PaymentMode mode) {
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

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}
