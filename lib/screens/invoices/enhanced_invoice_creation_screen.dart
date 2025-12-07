import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/invoice_model.dart';
import '../../models/customer_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/customer_provider.dart';

class EnhancedInvoiceCreationScreen extends StatefulWidget {
  final String? transactionId;
  final CustomerModel? customer;

  const EnhancedInvoiceCreationScreen({
    super.key,
    this.transactionId,
    this.customer,
  });

  @override
  State<EnhancedInvoiceCreationScreen> createState() =>
      _EnhancedInvoiceCreationScreenState();
}

class _EnhancedInvoiceCreationScreenState
    extends State<EnhancedInvoiceCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<InvoiceLineItem> _lineItems = [];
  
  String? _selectedCustomerId;
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  final _notesController = TextEditingController();
  final _termsController = TextEditingController();
  
  double _discountPercentage = 0.0;
  double _taxPercentage = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _selectedCustomerId = widget.customer!.id;
    }
    
    // Add one empty line item to start
    _addLineItem();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _termsController.dispose();
    for (var item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addLineItem() {
    setState(() {
      _lineItems.add(InvoiceLineItem());
    });
  }

  void _removeLineItem(int index) {
    if (_lineItems.length > 1) {
      setState(() {
        _lineItems[index].dispose();
        _lineItems.removeAt(index);
      });
    }
  }

  double _calculateSubtotal() {
    return _lineItems.fold(0.0, (sum, item) => sum + item.total);
  }

  double _calculateDiscount() {
    final subtotal = _calculateSubtotal();
    return (subtotal * _discountPercentage) / 100;
  }

  double _calculateTax() {
    final subtotal = _calculateSubtotal();
    final discount = _calculateDiscount();
    return ((subtotal - discount) * _taxPercentage) / 100;
  }

  double _calculateTotal() {
    final subtotal = _calculateSubtotal();
    final discount = _calculateDiscount();
    final tax = _calculateTax();
    return subtotal - discount + tax;
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_lineItems.isEmpty || !_lineItems.any((item) => item.isValid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final invoiceProvider = context.read<InvoiceProvider>();
      
      // Generate invoice number
      final invoiceNumber = await invoiceProvider.generateInvoiceNumber(
        'business_id', // Replace with actual business ID
      );

      // Create invoice items
      final items = _lineItems
          .where((item) => item.isValid)
          .map((item) => InvoiceItemModel(
                id: '',
                invoiceId: '',
                name: item.nameController.text,
                description: item.descriptionController.text,
                quantity: double.parse(item.quantityController.text),
                unitPrice: double.parse(item.priceController.text),
                taxRate: _taxPercentage,
                discountRate: _discountPercentage,
                totalAmount: item.total,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ))
          .toList();

      // Create invoice
      final invoice = InvoiceModel(
        id: '',
        businessId: 'business_id', // Replace with actual business ID
        customerId: _selectedCustomerId,
        invoiceNumber: invoiceNumber,
        invoiceType: InvoiceType.customer,
        invoiceDate: _invoiceDate,
        dueDate: _dueDate,
        status: InvoiceStatus.draft,
        subtotal: _calculateSubtotal(),
        taxAmount: _calculateTax(),
        discountAmount: _calculateDiscount(),
        totalAmount: _calculateTotal(),
        paidAmount: 0.0,
        notes: _notesController.text,
        items: items,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await invoiceProvider.addInvoice(invoice);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create invoice'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveInvoice,
              tooltip: 'Save Invoice',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Consumer<CustomerProvider>(
                      builder: (context, customerProvider, _) {
                        final customers = customerProvider.customers;
                        return DropdownButtonFormField<String>(
                          value: _selectedCustomerId,
                          decoration: const InputDecoration(
                            labelText: 'Customer *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: customers.map((customer) {
                            return DropdownMenuItem(
                              value: customer.id,
                              child: Text(customer.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedCustomerId = value);
                          },
                          validator: (value) =>
                              value == null ? 'Please select a customer' : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Invoice Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _invoiceDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setState(() => _invoiceDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Invoice Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat('dd MMM yyyy').format(_invoiceDate),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _dueDate,
                                firstDate: _invoiceDate,
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                setState(() => _dueDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Due Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event),
                              ),
                              child: Text(
                                DateFormat('dd MMM yyyy').format(_dueDate),
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

            // Line Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Products/Services',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton.icon(
                          onPressed: _addLineItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._lineItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildLineItem(item, index);
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Calculations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calculations',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _discountPercentage.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Discount %',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.discount),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _discountPercentage =
                                    double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _taxPercentage.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Tax %',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.percent),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _taxPercentage = double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow('Subtotal', _calculateSubtotal()),
                    _buildSummaryRow('Discount', -_calculateDiscount()),
                    _buildSummaryRow('Tax', _calculateTax()),
                    const Divider(thickness: 2),
                    _buildSummaryRow(
                      'Total',
                      _calculateTotal(),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes and Terms
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _termsController,
                      decoration: const InputDecoration(
                        labelText: 'Terms & Conditions',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveInvoice,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Saving...' : 'Save Invoice'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(InvoiceLineItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_lineItems.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeLineItem(index),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: item.nameController,
              decoration: const InputDecoration(
                labelText: 'Product/Service Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: item.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: item.quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Qty *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: item.priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price *',
                      border: OutlineInputBorder(),
                      prefixText: '₹ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Total',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      '₹${item.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: amount < 0 ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceLineItem {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController(text: '0');

  double get quantity => double.tryParse(quantityController.text) ?? 0;
  double get price => double.tryParse(priceController.text) ?? 0;
  double get total => quantity * price;
  
  bool get isValid =>
      nameController.text.isNotEmpty &&
      quantityController.text.isNotEmpty &&
      priceController.text.isNotEmpty;

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }
}
