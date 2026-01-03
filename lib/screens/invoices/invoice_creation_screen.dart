import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/invoice_model.dart';
import '../../models/whatsapp_template_model.dart';
import '../../services/invoice_service.dart';
import '../../services/whatsapp_service.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/business_provider.dart';

class InvoiceCreationScreen extends StatefulWidget {
  final InvoiceModel? invoice;
  final InvoiceType invoiceType;

  const InvoiceCreationScreen({
    super.key,
    this.invoice,
    this.invoiceType = InvoiceType.customer,
  });

  @override
  State<InvoiceCreationScreen> createState() => _InvoiceCreationScreenState();
}

class _InvoiceCreationScreenState extends State<InvoiceCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _termsController = TextEditingController();

  bool _isEditing = false;
  String? _selectedCustomerId;
  String? _selectedSupplierId;
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  InvoiceStatus _status = InvoiceStatus.draft;
  List<InvoiceItemModel> _items = [];
  bool _isLoading = false;
  bool _sendWhatsAppAfterSave = false;
  String? _selectedWhatsAppTemplate;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.invoice != null;
    _loadData();

    if (_isEditing) {
      _populateFromInvoice(widget.invoice!);
    } else {
      _generateInvoiceNumber();
      _dueDate = DateTime.now().add(const Duration(days: 30));
    }
  }

  void _loadData() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    if (businessProvider.business != null) {
      if (widget.invoiceType == InvoiceType.customer) {
        Provider.of<CustomerProvider>(
          context,
          listen: false,
        ).loadCustomers(businessProvider.business!.id);
      } else {
        Provider.of<SupplierProvider>(
          context,
          listen: false,
        ).loadSuppliers(businessProvider.business!.id);
      }
    }
  }

  void _populateFromInvoice(InvoiceModel invoice) {
    _invoiceNumberController.text = invoice.invoiceNumber;
    _selectedCustomerId = invoice.customerId;
    _selectedSupplierId = invoice.supplierId;
    _invoiceDate = invoice.invoiceDate;
    _dueDate = invoice.dueDate;
    _status = invoice.status;
    _notesController.text = invoice.notes ?? '';
    _termsController.text = invoice.termsConditions ?? '';
    _items = List.from(invoice.items);
  }

  Future<void> _generateInvoiceNumber() async {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    if (businessProvider.business != null) {
      final invoiceNumber = await InvoiceService.generateInvoiceNumber(
        businessProvider.business!.id,
      );
      _invoiceNumberController.text = invoiceNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Invoice' : 'Create Invoice'),
        actions: [
          if (!_isEditing)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'add_item':
                    _addInvoiceItem();
                    break;
                  case 'whatsapp_settings':
                    _showWhatsAppSettings();
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'add_item',
                      child: ListTile(
                        leading: Icon(Icons.add_shopping_cart),
                        title: Text('Add Item'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'whatsapp_settings',
                      child: ListTile(
                        leading: Icon(Icons.message),
                        title: Text('WhatsApp Settings'),
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBasicDetails(),
                  const SizedBox(height: 16),
                  _buildPartySelection(),
                  const SizedBox(height: 16),
                  _buildItemsSection(),
                  const SizedBox(height: 16),
                  _buildAmountSummary(),
                  const SizedBox(height: 16),
                  _buildAdditionalDetails(),
                  if (!_isEditing) ...[
                    const SizedBox(height: 16),
                    _buildWhatsAppSection(),
                  ],
                ],
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _invoiceNumberController,
              decoration: const InputDecoration(
                labelText: 'Invoice Number',
                prefixIcon: Icon(Icons.receipt),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter invoice number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Invoice Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_invoiceDate.day}/${_invoiceDate.month}/${_invoiceDate.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        prefixIcon: Icon(Icons.event),
                      ),
                      child: Text(
                        _dueDate != null
                            ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<InvoiceStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag),
              ),
              items:
                  InvoiceStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
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
    );
  }

  Widget _buildPartySelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.invoiceType == InvoiceType.customer
                  ? 'Customer'
                  : 'Supplier',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (widget.invoiceType == InvoiceType.customer)
              Consumer<CustomerProvider>(
                builder: (context, customerProvider, child) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCustomerId,
                    decoration: const InputDecoration(
                      labelText: 'Select Customer',
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
                      if (value == null) {
                        return 'Please select a customer';
                      }
                      return null;
                    },
                  );
                },
              )
            else
              Consumer<SupplierProvider>(
                builder: (context, supplierProvider, child) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedSupplierId,
                    decoration: const InputDecoration(
                      labelText: 'Select Supplier',
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
                      if (value == null) {
                        return 'Please select a supplier';
                      }
                      return null;
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addInvoiceItem,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items added',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _addInvoiceItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                    ),
                  ],
                ),
              )
            else
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildItemCard(item, index);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(InvoiceItemModel item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editInvoiceItem(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _removeInvoiceItem(index),
                ),
              ],
            ),
            if (item.description != null && item.description!.isNotEmpty)
              Text(
                item.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Qty: ${item.quantity}'),
                const SizedBox(width: 16),
                Text('Rate: ₹${item.unitPrice.toStringAsFixed(2)}'),
                const Spacer(),
                Text(
                  'Total: ₹${item.calculatedTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSummary() {
    final subtotal = _items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final taxAmount = _items.fold<double>(
      0,
      (sum, item) => sum + item.taxAmount,
    );
    final discountAmount = _items.fold<double>(
      0,
      (sum, item) => sum + item.discountAmount,
    );
    final total = subtotal + taxAmount - discountAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Amount Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildAmountRow('Subtotal', subtotal),
            _buildAmountRow('Tax', taxAmount),
            _buildAmountRow('Discount', discountAmount, isNegative: true),
            const Divider(),
            _buildAmountRow('Total', total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount, {
    bool isNegative = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          const Spacer(),
          Text(
            '${isNegative ? '-' : ''}₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isNegative ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Any additional notes...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _termsController,
              decoration: const InputDecoration(
                labelText: 'Terms & Conditions',
                hintText: 'Payment terms, conditions...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WhatsApp Sharing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Send via WhatsApp after saving'),
              subtitle: const Text(
                'Automatically share invoice with customer/supplier',
              ),
              value: _sendWhatsAppAfterSave,
              onChanged: (value) {
                setState(() {
                  _sendWhatsAppAfterSave = value;
                });
              },
            ),
            if (_sendWhatsAppAfterSave) ...[
              const SizedBox(height: 16),
              FutureBuilder<List<WhatsAppTemplateModel>>(
                future: _getWhatsAppTemplates(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final templates = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedWhatsAppTemplate,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp Template',
                        prefixIcon: Icon(Icons.message),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Use Default Template'),
                        ),
                        ...templates.map(
                          (template) => DropdownMenuItem(
                            value: template.id,
                            child: Text(template.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedWhatsAppTemplate = value;
                        });
                      },
                    );
                  }
                  return const LinearProgressIndicator();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveInvoice,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(_isEditing ? 'Update' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isInvoiceDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isInvoiceDate ? _invoiceDate : (_dueDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        if (isInvoiceDate) {
          _invoiceDate = date;
        } else {
          _dueDate = date;
        }
      });
    }
  }

  void _addInvoiceItem() {
    _showItemEditor();
  }

  void _editInvoiceItem(int index) {
    _showItemEditor(item: _items[index], index: index);
  }

  void _removeInvoiceItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _showItemEditor({InvoiceItemModel? item, int? index}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => InvoiceItemEditorScreen(
              item: item,
              onSave: (newItem) {
                setState(() {
                  if (index != null) {
                    _items[index] = newItem;
                  } else {
                    _items.add(newItem);
                  }
                });
              },
            ),
      ),
    );
  }

  void _showWhatsAppSettings() {
    // Show WhatsApp template selection dialog
  }

  Future<List<WhatsAppTemplateModel>> _getWhatsAppTemplates() async {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    if (businessProvider.business != null) {
      final templates = await WhatsAppService.getTemplates();
      return templates
          .map(
            (template) => WhatsAppTemplateModel(
              id: template['id'] ?? '',
              businessId: businessProvider.business!.id,
              name: template['name'] ?? '',
              templateType: WhatsAppTemplateType.custom,
              messageTemplate: template['content'] ?? '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
          .toList();
    }
    return [];
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      if (businessProvider.business == null) {
        throw Exception('Business not found');
      }

      final subtotal = _items.fold<double>(
        0,
        (sum, item) => sum + item.subtotal,
      );
      final taxAmount = _items.fold<double>(
        0,
        (sum, item) => sum + item.taxAmount,
      );
      final discountAmount = _items.fold<double>(
        0,
        (sum, item) => sum + item.discountAmount,
      );
      final total = subtotal + taxAmount - discountAmount;

      final invoice = InvoiceModel(
        id: _isEditing ? widget.invoice!.id : const Uuid().v4(),
        businessId: businessProvider.business!.id,
        customerId: _selectedCustomerId,
        supplierId: _selectedSupplierId,
        invoiceNumber: _invoiceNumberController.text.trim(),
        invoiceType: widget.invoiceType,
        invoiceDate: _invoiceDate,
        dueDate: _dueDate,
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        totalAmount: total,
        status: _status,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        termsConditions:
            _termsController.text.trim().isEmpty
                ? null
                : _termsController.text.trim(),
        items: _items,
        createdAt: _isEditing ? widget.invoice!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      InvoiceModel? savedInvoice;
      if (_isEditing) {
        savedInvoice = await InvoiceService.updateInvoice(invoice);
      } else {
        savedInvoice = await InvoiceService.createInvoice(invoice);
      }

      if (savedInvoice != null) {
        // Send WhatsApp message if requested
        if (_sendWhatsAppAfterSave && !_isEditing) {
          await _sendWhatsAppMessage(savedInvoice);
        }

        if (mounted) {
          Navigator.of(context).pop(savedInvoice);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Invoice updated successfully'
                    : 'Invoice created successfully',
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to save invoice');
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

  Future<void> _sendWhatsAppMessage(InvoiceModel invoice) async {
    try {
      if (invoice.customerId != null) {
        final customerProvider = Provider.of<CustomerProvider>(
          context,
          listen: false,
        );
        final customer =
            customerProvider.customers
                .where((c) => c.id == invoice.customerId)
                .firstOrNull;

        if (customer != null) {
          await WhatsAppService.sendCustomMessage(
            phoneNumber: customer.phone ?? '',
            message:
                'Invoice ${invoice.invoiceNumber} has been created. Total: ₹${invoice.totalAmount}',
          );
        }
      } else if (invoice.supplierId != null) {
        final supplierProvider = Provider.of<SupplierProvider>(
          context,
          listen: false,
        );
        final supplier =
            supplierProvider.suppliers
                .where((s) => s.id == invoice.supplierId)
                .firstOrNull;

        if (supplier != null && supplier.phone != null) {
          // Send to supplier (you might want to create a specific template for this)
          await WhatsAppService.sendCustomMessage(
            phoneNumber: supplier.phone ?? '',
            message: 'Invoice ${invoice.invoiceNumber} has been created',
          );
        }
      }
    } catch (e) {
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }
}

// Invoice Item Editor Screen
class InvoiceItemEditorScreen extends StatefulWidget {
  final InvoiceItemModel? item;
  final Function(InvoiceItemModel) onSave;

  const InvoiceItemEditorScreen({super.key, this.item, required this.onSave});

  @override
  State<InvoiceItemEditorScreen> createState() =>
      _InvoiceItemEditorScreenState();
}

class _InvoiceItemEditorScreenState extends State<InvoiceItemEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _discountRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      final item = widget.item!;
      _nameController.text = item.name;
      _descriptionController.text = item.description ?? '';
      _quantityController.text = item.quantity.toString();
      _unitPriceController.text = item.unitPrice.toString();
      _taxRateController.text = item.taxRate.toString();
      _discountRateController.text = item.discountRate.toString();
    } else {
      _quantityController.text = '1';
      _taxRateController.text = '0';
      _discountRateController.text = '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item != null ? 'Edit Item' : 'Add Item'),
        actions: [TextButton(onPressed: _saveItem, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                hintText: 'e.g., Product A, Service B',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Additional details about the item',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) <= 0) {
                        return 'Invalid quantity';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      prefixText: '₹',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Invalid price';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _taxRateController,
                    decoration: const InputDecoration(
                      labelText: 'Tax Rate (%)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final rate = double.tryParse(value);
                        if (rate == null || rate < 0 || rate > 100) {
                          return 'Invalid rate';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _discountRateController,
                    decoration: const InputDecoration(
                      labelText: 'Discount (%)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final rate = double.tryParse(value);
                        if (rate == null || rate < 0 || rate > 100) {
                          return 'Invalid rate';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCalculationPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationPreview() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final taxRate = double.tryParse(_taxRateController.text) ?? 0;
    final discountRate = double.tryParse(_discountRateController.text) ?? 0;

    final subtotal = quantity * unitPrice;
    final taxAmount = subtotal * (taxRate / 100);
    final discountAmount = subtotal * (discountRate / 100);
    final total = subtotal + taxAmount - discountAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calculation Preview',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildPreviewRow('Subtotal', subtotal),
            _buildPreviewRow('Tax', taxAmount),
            _buildPreviewRow('Discount', discountAmount, isNegative: true),
            const Divider(),
            _buildPreviewRow('Total', total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(
    String label,
    double amount, {
    bool isNegative = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            '${isNegative ? '-' : ''}₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isNegative ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.parse(_quantityController.text);
    final unitPrice = double.parse(_unitPriceController.text);
    final taxRate = double.tryParse(_taxRateController.text) ?? 0;
    final discountRate = double.tryParse(_discountRateController.text) ?? 0;

    final subtotal = quantity * unitPrice;
    final taxAmount = subtotal * (taxRate / 100);
    final discountAmount = subtotal * (discountRate / 100);
    final total = subtotal + taxAmount - discountAmount;

    final item = InvoiceItemModel(
      id: widget.item?.id ?? const Uuid().v4(),
      invoiceId: widget.item?.invoiceId ?? '',
      name: _nameController.text.trim(),
      description:
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      quantity: quantity,
      unitPrice: unitPrice,
      taxRate: taxRate,
      discountRate: discountRate,
      totalAmount: total,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(item);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _taxRateController.dispose();
    _discountRateController.dispose();
    super.dispose();
  }
}
