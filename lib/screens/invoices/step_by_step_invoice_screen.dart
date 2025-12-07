import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/invoice_model.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';

class StepByStepInvoiceScreen extends StatefulWidget {
  const StepByStepInvoiceScreen({super.key});

  @override
  State<StepByStepInvoiceScreen> createState() =>
      _StepByStepInvoiceScreenState();
}

class _StepByStepInvoiceScreenState extends State<StepByStepInvoiceScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Form controllers
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  // Form data
  CustomerModel? _selectedCustomer;
  final List<InvoiceItemModel> _items = [];
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  double _taxRate = 18.0;
  final double _discountAmount = 0.0;
  String _paymentTerms = 'Net 30 days';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _customerAddressController.dispose();
    _itemNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadCustomers() async {
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    // Get business ID from provider or use a default
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final businessId = businessProvider.business?.id ?? 'default';
    await customerProvider.loadCustomers(businessId);
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCustomerStep(),
                _buildItemsStep(),
                _buildDetailsStep(),
                _buildReviewStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < _totalSteps - 1 ? 8 : 0,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              isCompleted || isCurrent
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            isCompleted || isCurrent
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color:
                                isCompleted || isCurrent
                                    ? AppTheme.primaryColor
                                    : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _getStepTitle(_currentStep),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _getStepDescription(_currentStep),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Customer Details';
      case 1:
        return 'Add Items';
      case 2:
        return 'Invoice Details';
      case 3:
        return 'Review & Confirm';
      case 4:
        return 'Invoice Created';
      default:
        return '';
    }
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Select or add customer information';
      case 1:
        return 'Add products or services to invoice';
      case 2:
        return 'Set dates, taxes, and payment terms';
      case 3:
        return 'Review all details before creating';
      case 4:
        return 'Your invoice has been created successfully';
      default:
        return '';
    }
  }

  Widget _buildCustomerStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Customer',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Existing customers
          Consumer<CustomerProvider>(
            builder: (context, customerProvider, child) {
              if (customerProvider.customers.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No customers found. Add a new customer below.',
                    ),
                  ),
                );
              }

              return Card(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Choose from existing customers:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ...customerProvider.customers.map((customer) {
                      final isSelected = _selectedCustomer == customer;
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(customer.name[0].toUpperCase()),
                        ),
                        title: Text(customer.name),
                        subtitle: Text(customer.phone ?? 'No phone'),
                        trailing: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color:
                              isSelected ? AppTheme.primaryColor : Colors.grey,
                        ),
                        onTap: () {
                          setState(() {
                            _selectedCustomer = customer;
                          });
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Add new customer
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Or add a new customer:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _selectedCustomer = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customerPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customerEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customerAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Items/Services',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Add item form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Item/Service Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Unit Price *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.currency_rupee),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Items list
          if (_items.isNotEmpty) ...[
            const Text(
              'Added Items:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children:
                    _items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          'Qty: ${item.quantity} × ₹${item.unitPrice}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${item.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${_calculateSubtotal().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No items added yet. Add at least one item to continue.',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoice Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Invoice Date
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Invoice Date'),
                    subtitle: Text(
                      '${_invoiceDate.day}/${_invoiceDate.month}/${_invoiceDate.year}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectInvoiceDate(),
                  ),
                  const Divider(),

                  // Due Date
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('Due Date'),
                    subtitle: Text(
                      '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _selectDueDate(),
                  ),
                  const Divider(),

                  // Tax Rate
                  ListTile(
                    leading: const Icon(Icons.percent),
                    title: const Text('Tax Rate (GST)'),
                    subtitle: Text('${_taxRate.toStringAsFixed(1)}%'),
                    trailing: DropdownButton<double>(
                      value: _taxRate,
                      items:
                          [0.0, 5.0, 12.0, 18.0, 28.0].map((rate) {
                            return DropdownMenuItem(
                              value: rate,
                              child: Text('${rate.toStringAsFixed(1)}%'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _taxRate = value ?? 18.0;
                        });
                      },
                    ),
                  ),
                  const Divider(),

                  // Payment Terms
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Payment Terms'),
                    subtitle: Text(_paymentTerms),
                    trailing: DropdownButton<String>(
                      value: _paymentTerms,
                      items:
                          [
                            'Due on receipt',
                            'Net 15 days',
                            'Net 30 days',
                            'Net 45 days',
                            'Net 60 days',
                          ].map((term) {
                            return DropdownMenuItem(
                              value: term,
                              child: Text(term),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _paymentTerms = value ?? 'Net 30 days';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Notes',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Add any additional notes or terms...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final subtotal = _calculateSubtotal();
    final taxAmount = subtotal * (_taxRate / 100);
    final total = subtotal + taxAmount - _discountAmount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Invoice',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Customer Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(_getCustomerName()),
                  if (_getCustomerPhone().isNotEmpty)
                    Text('Phone: ${_getCustomerPhone()}'),
                  if (_getCustomerEmail().isNotEmpty)
                    Text('Email: ${_getCustomerEmail()}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Items
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.name} (${item.quantity} × ₹${item.unitPrice})',
                            ),
                          ),
                          Text('₹${item.totalAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Totals
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text('₹${subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax (${_taxRate.toStringAsFixed(1)}%):'),
                      Text('₹${taxAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Invoice Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invoice Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${_invoiceDate.day}/${_invoiceDate.month}/${_invoiceDate.year}',
                  ),
                  Text(
                    'Due: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                  ),
                  Text('Payment Terms: $_paymentTerms'),
                  if (_notesController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Notes:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(_notesController.text),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.successColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 24),
            const Text(
              'Invoice Created Successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your invoice has been created and saved. You can now send it to your customer or make any additional changes.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement send via WhatsApp
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(' Opening WhatsApp to send invoice...'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Send via WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement share
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing invoice...')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Invoice'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('View All Invoices'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0 && _currentStep < _totalSteps - 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0 && _currentStep < _totalSteps - 1)
            const SizedBox(width: 16),
          if (_currentStep < _totalSteps - 1)
            Expanded(
              child: ElevatedButton(
                onPressed: _canProceedToNextStep() ? _nextStep : null,
                child: Text(
                  _currentStep == _totalSteps - 2 ? 'Create Invoice' : 'Next',
                ),
              ),
            ),
          if (_currentStep == _totalSteps - 1)
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
        ],
      ),
    );
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0: // Customer step
        return _selectedCustomer != null ||
            _customerNameController.text.isNotEmpty;
      case 1: // Items step
        return _items.isNotEmpty;
      case 2: // Details step
        return true;
      case 3: // Review step
        return true;
      default:
        return false;
    }
  }

  void _addItem() {
    if (_itemNameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all item fields')),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;

    if (quantity <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity and price must be greater than 0'),
        ),
      );
      return;
    }

    setState(() {
      _items.add(
        InvoiceItemModel(
          id: const Uuid().v4(),
          invoiceId: '', // Will be set when invoice is created
          name: _itemNameController.text,
          description: '',
          quantity: quantity,
          unitPrice: price,
          totalAmount: quantity * price,
          taxRate: _taxRate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    });

    // Clear form
    _itemNameController.clear();
    _quantityController.clear();
    _priceController.clear();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double _calculateSubtotal() {
    return _items.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  String _getCustomerName() {
    return _selectedCustomer?.name ?? _customerNameController.text;
  }

  String _getCustomerPhone() {
    return _selectedCustomer?.phone ?? _customerPhoneController.text;
  }

  String _getCustomerEmail() {
    return _selectedCustomer?.email ?? _customerEmailController.text;
  }

  Future<void> _selectInvoiceDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _invoiceDate = date;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }
}
