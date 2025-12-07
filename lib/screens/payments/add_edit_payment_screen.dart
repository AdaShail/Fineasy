import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/payment_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/payment_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';
import '../../utils/app_theme.dart';

class AddEditPaymentScreen extends StatefulWidget {
  final PaymentModel? payment;

  const AddEditPaymentScreen({super.key, this.payment});

  @override
  State<AddEditPaymentScreen> createState() => _AddEditPaymentScreenState();
}

class _AddEditPaymentScreenState extends State<AddEditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isEditing = false;
  String? _selectedCustomerId;
  String? _selectedSupplierId;
  PaymentMode _paymentMode = PaymentMode.cash;
  PaymentStatus _status = PaymentStatus.pending;
  DateTime _paymentDate = DateTime.now();
  DateTime? _dueDate;
  String _paymentType = 'customer'; // 'customer' or 'supplier'

  @override
  void initState() {
    super.initState();
    _isEditing = widget.payment != null;
    _loadData();

    if (_isEditing) {
      final payment = widget.payment!;
      _amountController.text = payment.amount.toString();
      _selectedCustomerId = payment.customerId;
      _selectedSupplierId = payment.supplierId;
      _paymentMode = payment.paymentMode;
      _status = payment.status;
      _paymentDate = payment.paymentDate;
      _referenceController.text = payment.reference ?? '';
      _notesController.text = payment.notes ?? '';
      _paymentType = payment.customerId != null ? 'customer' : 'supplier';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadData() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final supplierProvider = Provider.of<SupplierProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      customerProvider.loadCustomers(businessProvider.business!.id);
      supplierProvider.loadSuppliers(businessProvider.business!.id);
    }
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final paymentProvider = Provider.of<PaymentProvider>(
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

    // If due date is set and it's a customer payment, create a transaction instead
    if (_dueDate != null &&
        _paymentType == 'customer' &&
        _selectedCustomerId != null) {
      await _createTransactionWithDueDate(businessProvider);
      return;
    }

    final payment = PaymentModel(
      id: _isEditing ? widget.payment!.id : const Uuid().v4(),
      businessId: businessProvider.business!.id,
      userId: businessProvider.business!.userId,
      customerId: _paymentType == 'customer' ? _selectedCustomerId : null,
      supplierId: _paymentType == 'supplier' ? _selectedSupplierId : null,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      paymentMode: _paymentMode,
      status: _status,
      paymentDate: _paymentDate,
      reference:
          _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim(),
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
      createdAt: _isEditing ? widget.payment!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await paymentProvider.updatePayment(payment);
    } else {
      success = await paymentProvider.addPayment(payment);
    }

    if (success && mounted) {
      Navigator.of(context).pop(payment);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Payment updated successfully'
                : 'Payment recorded successfully',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentProvider.error ?? 'Failed to save payment'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _createTransactionWithDueDate(
    BusinessProvider businessProvider,
  ) async {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      businessId: businessProvider.business!.id,
      userId: businessProvider.business!.userId,
      customerId: _selectedCustomerId,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      type: TransactionType.income,
      paymentMode: _paymentMode,
      status:
          _status == PaymentStatus.completed
              ? TransactionStatus.completed
              : TransactionStatus.pending,
      date: _paymentDate,
      dueDate: _dueDate,
      description:
          _descriptionController.text.trim().isEmpty
              ? 'Payment from customer'
              : _descriptionController.text.trim(),
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await transactionProvider.addTransaction(transaction);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction with due date created successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            transactionProvider.error ?? 'Failed to create transaction',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Payment' : 'Record Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Payment Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  _isEditing
                                      ? null
                                      : () {
                                        setState(() {
                                          _paymentType = 'customer';
                                          _selectedCustomerId = null;
                                          _selectedSupplierId = null;
                                        });
                                      },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        _paymentType == 'customer'
                                            ? AppTheme.primaryColor
                                            : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      _paymentType == 'customer'
                                          ? AppTheme.primaryColor.withValues(
                                            alpha: 0.1,
                                          )
                                          : Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _paymentType == 'customer'
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color:
                                          _paymentType == 'customer'
                                              ? AppTheme.primaryColor
                                              : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('From Customer'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  _isEditing
                                      ? null
                                      : () {
                                        setState(() {
                                          _paymentType = 'supplier';
                                          _selectedCustomerId = null;
                                          _selectedSupplierId = null;
                                        });
                                      },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        _paymentType == 'supplier'
                                            ? AppTheme.primaryColor
                                            : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      _paymentType == 'supplier'
                                          ? AppTheme.primaryColor.withValues(
                                            alpha: 0.1,
                                          )
                                          : Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _paymentType == 'supplier'
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color:
                                          _paymentType == 'supplier'
                                              ? AppTheme.primaryColor
                                              : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('To Supplier'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Payment Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_paymentType == 'customer')
                        Consumer<CustomerProvider>(
                          builder: (context, customerProvider, child) {
                            return DropdownButtonFormField<String>(
                              initialValue: _selectedCustomerId,
                              decoration: const InputDecoration(
                                labelText: 'Customer *',
                                prefixIcon: Icon(Icons.person),
                              ),
                              items:
                                  customerProvider.customers.map((customer) {
                                    return DropdownMenuItem(
                                      value: customer.id,
                                      child: Text(customer.name),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCustomerId = value;
                                });
                              },
                              validator: (value) {
                                if (_paymentType == 'customer' &&
                                    value == null) {
                                  return 'Please select a customer';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      if (_paymentType == 'supplier')
                        Consumer<SupplierProvider>(
                          builder: (context, supplierProvider, child) {
                            return DropdownButtonFormField<String>(
                              initialValue: _selectedSupplierId,
                              decoration: const InputDecoration(
                                labelText: 'Supplier *',
                                prefixIcon: Icon(Icons.business),
                              ),
                              items:
                                  supplierProvider.suppliers.map((supplier) {
                                    return DropdownMenuItem(
                                      value: supplier.id,
                                      child: Text(supplier.name),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSupplierId = value;
                                });
                              },
                              validator: (value) {
                                if (_paymentType == 'supplier' &&
                                    value == null) {
                                  return 'Please select a supplier';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'e.g., TV Purchase, Monthly Payment',
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
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
                      DropdownButtonFormField<PaymentMode>(
                        initialValue: _paymentMode,
                        decoration: const InputDecoration(
                          labelText: 'Payment Mode *',
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items:
                            PaymentMode.values.map((mode) {
                              return DropdownMenuItem(
                                value: mode,
                                child: Text(_getPaymentModeDisplayName(mode)),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _paymentMode = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _paymentDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _paymentDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Payment Date *',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                _dueDate ??
                                DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _dueDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText:
                                _paymentType == 'customer'
                                    ? 'Due Date (Optional)'
                                    : 'Due Date',
                            prefixIcon: const Icon(Icons.event),
                            helperText:
                                _paymentType == 'customer'
                                    ? 'When payment is expected from customer'
                                    : 'When payment is due to supplier',
                          ),
                          child: Text(
                            _dueDate != null
                                ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                : 'Select due date',
                            style: TextStyle(
                              color:
                                  _dueDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PaymentStatus>(
                        initialValue: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items:
                            PaymentStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(_getStatusDisplayName(status)),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
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
                        controller: _referenceController,
                        decoration: const InputDecoration(
                          labelText: 'Reference Number',
                          prefixIcon: Icon(Icons.confirmation_number),
                          hintText: 'Transaction ID, Check number, etc.',
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Consumer<PaymentProvider>(
                builder: (context, paymentProvider, child) {
                  return ElevatedButton(
                    onPressed: paymentProvider.isLoading ? null : _savePayment,
                    child:
                        paymentProvider.isLoading
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
                              _isEditing ? 'Update Payment' : 'Record Payment',
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

  String _getStatusDisplayName(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
