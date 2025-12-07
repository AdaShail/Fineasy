import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/customer_model.dart';
import '../../utils/app_theme.dart';

class QuickInvoiceDialog extends StatefulWidget {
  final CustomerModel? customer;

  const QuickInvoiceDialog({super.key, this.customer});

  @override
  State<QuickInvoiceDialog> createState() => _QuickInvoiceDialogState();
}

class _QuickInvoiceDialogState extends State<QuickInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _discountController = TextEditingController(text: '0');
  final _taxRateController = TextEditingController(text: '0');

  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _sendImmediately = true;
  bool _isNewCustomer = false;
  bool _showAdvancedFields = false;
  double _calculatedTotal = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone ?? '';
    } else {
      _isNewCustomer = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _productNameController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    final taxRate = double.tryParse(_taxRateController.text) ?? 0;

    double subtotal = amount;
    double discountAmount = discount;
    
    // If discount is percentage (> 0 and <= 100), calculate percentage
    if (discount > 0 && discount <= 100) {
      discountAmount = (amount * discount) / 100;
    }
    
    double afterDiscount = subtotal - discountAmount;
    double taxAmount = (afterDiscount * taxRate) / 100;
    double total = afterDiscount + taxAmount;

    setState(() {
      _calculatedTotal = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quick Invoice'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Customer selection or new customer
              if (widget.customer == null) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (_sendImmediately && (value == null || value.isEmpty)) {
                      return 'Phone required to send invoice';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Product/Service Name
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Product/Service Name',
                  prefixIcon: Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(),
                  helperText: 'What are you selling?',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product/service name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                  helperText: 'Base amount before discount and tax',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculateTotal(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Advanced fields toggle
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAdvancedFields = !_showAdvancedFields;
                  });
                },
                icon: Icon(_showAdvancedFields ? Icons.expand_less : Icons.expand_more),
                label: Text(_showAdvancedFields ? 'Hide Advanced Options' : 'Show Advanced Options (Discount, Tax)'),
              ),
              
              if (_showAdvancedFields) ...[
                const SizedBox(height: 16),
                
                // Discount
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(
                    labelText: 'Discount',
                    prefixIcon: Icon(Icons.discount),
                    border: OutlineInputBorder(),
                    helperText: 'Enter % (0-100) or fixed amount',
                    suffixText: '% or ₹',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calculateTotal(),
                ),
                const SizedBox(height: 16),

                // Tax Rate
                TextFormField(
                  controller: _taxRateController,
                  decoration: const InputDecoration(
                    labelText: 'Tax Rate',
                    prefixIcon: Icon(Icons.percent),
                    border: OutlineInputBorder(),
                    helperText: 'GST/Tax percentage',
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _calculateTotal(),
                ),
                const SizedBox(height: 16),

                // Calculated Total Display
                if (_calculatedTotal > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹${_calculatedTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Due Date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _dueDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(_dueDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Send immediately checkbox
              CheckboxListTile(
                title: const Text('Send via WhatsApp immediately'),
                value: _sendImmediately,
                onChanged: (value) {
                  setState(() {
                    _sendImmediately = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount = double.parse(_amountController.text);
              final discount = double.tryParse(_discountController.text) ?? 0;
              final taxRate = double.tryParse(_taxRateController.text) ?? 0;
              
              // Calculate final amounts
              double discountAmount = discount;
              if (discount > 0 && discount <= 100) {
                discountAmount = (amount * discount) / 100;
              }
              
              final afterDiscount = amount - discountAmount;
              final taxAmount = (afterDiscount * taxRate) / 100;
              final totalAmount = afterDiscount + taxAmount;
              
              Navigator.pop(context, {
                'name': _nameController.text,
                'phone': _phoneController.text,
                'productName': _productNameController.text,
                'amount': amount,
                'discount': discountAmount,
                'taxRate': taxRate,
                'taxAmount': taxAmount,
                'totalAmount': totalAmount,
                'description': _descriptionController.text,
                'dueDate': _dueDate,
                'sendImmediately': _sendImmediately,
                'isNewCustomer': _isNewCustomer,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Create Invoice'),
        ),
      ],
    );
  }
}
