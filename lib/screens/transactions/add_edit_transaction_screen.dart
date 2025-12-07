import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../models/ai_models.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/business_provider.dart';
import '../../services/fraud_detection_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/fraud_alert_widget.dart';
import 'package:uuid/uuid.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  final String? customerId;
  final String? supplierId;

  const AddEditTransactionScreen({
    super.key,
    this.transaction,
    this.customerId,
    this.supplierId,
  });

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isEditing = false;
  TransactionType _selectedType = TransactionType.income;
  PaymentMode _selectedPaymentMode = PaymentMode.cash;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCustomerId;
  String? _selectedSupplierId;

  // Fraud detection
  final FraudDetectionService _fraudService = FraudDetectionService();
  List<FraudAlert> _fraudAlerts = [];
  bool _isCheckingFraud = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transaction != null;
    _selectedCustomerId = widget.customerId;
    _selectedSupplierId = widget.supplierId;

    if (_isEditing) {
      final transaction = widget.transaction!;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description;
      _referenceController.text = transaction.reference ?? '';
      _notesController.text = transaction.notes ?? '';
      _selectedType = transaction.type;
      _selectedPaymentMode = transaction.paymentMode;
      _selectedDate = transaction.date;
      _selectedCustomerId = transaction.customerId;
      _selectedSupplierId = transaction.supplierId;
    }

    // Initialize fraud detection service
    _fraudService.initialize();

    // Add listeners for real-time fraud checking
    _amountController.addListener(_onTransactionDataChanged);
    _descriptionController.addListener(_onTransactionDataChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onTransactionDataChanged);
    _descriptionController.removeListener(_onTransactionDataChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _onTransactionDataChanged() {
    // Debounce fraud checking to avoid too many API calls
    if (_isCheckingFraud) return;

    // Only check if we have sufficient data
    if (_amountController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      _checkFraudRealTime();
    }
  }

  Future<void> _checkFraudRealTime() async {
    if (!_fraudService.realTimeCheckingEnabled || _isEditing) return;

    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business == null) return;

    setState(() {
      _isCheckingFraud = true;
    });

    try {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) return;

      final tempTransaction = TransactionModel(
        id: const Uuid().v4(),
        businessId: businessProvider.business!.id,
        userId: businessProvider.business!.userId,
        customerId: _selectedCustomerId,
        supplierId: _selectedSupplierId,
        type: _selectedType,
        amount: amount,
        description: _descriptionController.text.trim(),
        paymentMode: _selectedPaymentMode,
        date: _selectedDate,
        reference:
            _referenceController.text.trim().isEmpty
                ? null
                : _referenceController.text.trim(),
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        isSynced: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final alerts = await _fraudService.checkTransactionFraud(tempTransaction);

      if (mounted) {
        setState(() {
          _fraudAlerts = alerts;
        });
      }
    } catch (e) {
      // Silently handle fraud checking errors
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingFraud = false;
        });
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final transactionProvider = Provider.of<TransactionProvider>(
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

    // Get current user ID from business
    final userId = businessProvider.business!.userId;

    final transaction = TransactionModel(
      id: _isEditing ? widget.transaction!.id : const Uuid().v4(),
      businessId: businessProvider.business!.id,
      userId: userId, // REQUIRED: Added missing userId
      customerId: _selectedCustomerId,
      supplierId: _selectedSupplierId,
      type: _selectedType,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.trim(),
      paymentMode: _selectedPaymentMode,
      date: _selectedDate,
      reference:
          _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim(),
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
      isSynced: false,
      createdAt: _isEditing ? widget.transaction!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Check for fraud before saving (for new transactions)
    if (!_isEditing && _fraudService.isEnabled) {
      try {
        final fraudAlerts = await _fraudService.checkTransactionFraud(
          transaction,
        );
        if (fraudAlerts.isNotEmpty && mounted) {
          final shouldContinue =
              await FraudCheckingExtension.showFraudAlertDialog(
                context,
                fraudAlerts,
              );
          if (!shouldContinue) return;
        }
      } catch (e) {
        // Continue with save if fraud checking fails
      }
    }

    bool success;
    if (_isEditing) {
      success = await transactionProvider.updateTransaction(transaction);
    } else {
      success = await transactionProvider.addTransaction(transaction);
    }

    if (success && mounted) {
      Navigator.of(context).pop(transaction);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Transaction updated successfully'
                : 'Transaction added successfully',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            transactionProvider.error ?? 'Failed to save transaction',
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
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fraud alerts
              if (_fraudAlerts.isNotEmpty) ...[
                ...(_fraudAlerts.map(
                  (alert) => FraudAlertWidget(
                    alert: alert,
                    onDismiss: () {
                      setState(() {
                        _fraudAlerts.removeWhere((a) => a.id == alert.id);
                      });
                    },
                    onViewDetails: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => FraudAlertDetailsDialog(alert: alert),
                      );
                    },
                  ),
                )),
                const SizedBox(height: 16),
              ],

              // Real-time fraud checking indicator
              if (_isCheckingFraud)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Checking for potential fraud...',
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              // Transaction Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<TransactionType>(
                              title: const Text('Income'),
                              subtitle: const Text('Money received'),
                              value: TransactionType.income,
                              groupValue: _selectedType,
                              onChanged:
                                  (value) =>
                                      setState(() => _selectedType = value!),
                              activeColor: AppTheme.successColor,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<TransactionType>(
                              title: const Text('Expense'),
                              subtitle: const Text('Money paid'),
                              value: TransactionType.expense,
                              groupValue: _selectedType,
                              onChanged:
                                  (value) =>
                                      setState(() => _selectedType = value!),
                              activeColor: AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount *',
                  prefixText: AppConstants.defaultCurrency,
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                    color:
                        _selectedType == TransactionType.income
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
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

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Customer/Supplier Selection
              if (widget.customerId == null && widget.supplierId == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Consumer<CustomerProvider>(
                        builder: (context, customerProvider, child) {
                          return DropdownButtonFormField<String>(
                            initialValue: _selectedCustomerId,
                            decoration: const InputDecoration(
                              labelText: 'Customer (Optional)',
                              prefixIcon: Icon(Icons.person),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('No Customer'),
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
                                _selectedCustomerId = value;
                                if (value != null) _selectedSupplierId = null;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer<SupplierProvider>(
                        builder: (context, supplierProvider, child) {
                          return DropdownButtonFormField<String>(
                            initialValue: _selectedSupplierId,
                            decoration: const InputDecoration(
                              labelText: 'Supplier (Optional)',
                              prefixIcon: Icon(Icons.business),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('No Supplier'),
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
                                _selectedSupplierId = value;
                                if (value != null) _selectedCustomerId = null;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Payment Mode
              DropdownButtonFormField<PaymentMode>(
                initialValue: _selectedPaymentMode,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode *',
                  prefixIcon: Icon(Icons.payment),
                ),
                items:
                    PaymentMode.values.map((mode) {
                      return DropdownMenuItem<PaymentMode>(
                        value: mode,
                        child: Text(_getPaymentModeDisplayName(mode)),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() => _selectedPaymentMode = value!),
              ),

              const SizedBox(height: 16),

              // Date and Time
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date & Time *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Reference
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference (Optional)',
                  prefixIcon: Icon(Icons.receipt),
                  hintText: 'Invoice number, cheque number, etc.',
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              Consumer<TransactionProvider>(
                builder: (context, transactionProvider, child) {
                  return ElevatedButton(
                    onPressed:
                        transactionProvider.isLoading ? null : _saveTransaction,
                    child:
                        transactionProvider.isLoading
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
                              _isEditing
                                  ? 'Update Transaction'
                                  : 'Add Transaction',
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
}
