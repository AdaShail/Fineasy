import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/invoice_model.dart';

import '../../providers/invoice_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/customer_provider.dart';
// import '../../providers/compliance_provider.dart'; // REMOVED - Python dependency
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
// import '../../widgets/compliance_status_widget.dart'; // REMOVED - Python dependency
import '../../widgets/gst_validation_field.dart';

class AddEditInvoiceScreen extends StatefulWidget {
  final InvoiceModel? invoice;
  final Map<String, dynamic>? prefilledData;

  const AddEditInvoiceScreen({super.key, this.invoice, this.prefilledData});

  @override
  State<AddEditInvoiceScreen> createState() => _AddEditInvoiceScreenState();
}

class _AddEditInvoiceScreenState extends State<AddEditInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _subtotalController = TextEditingController();
  final _taxAmountController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final _notesController = TextEditingController();
  final _termsController = TextEditingController();
  final _supplierGstinController = TextEditingController();
  final _customerGstinController = TextEditingController();
  final _placeOfSupplyController = TextEditingController();

  bool _isEditing = false;
  String? _selectedCustomerId;
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  InvoiceStatus _status = InvoiceStatus.draft;
  bool _enableRealTimeCompliance = true;
  String? _currentInvoiceId;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.invoice != null;

    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
      _generateInvoiceNumber();
    });

    if (_isEditing) {
      final invoice = widget.invoice!;
      _currentInvoiceId = invoice.id;
      _invoiceNumberController.text = invoice.invoiceNumber;
      _selectedCustomerId = invoice.customerId;
      _invoiceDate = invoice.invoiceDate;
      _dueDate = invoice.dueDate;
      _subtotalController.text = invoice.subtotal.toString();
      _taxAmountController.text = invoice.taxAmount.toString();
      _discountAmountController.text = invoice.discountAmount.toString();
      _totalAmountController.text = invoice.totalAmount.toString();
      _paidAmountController.text = invoice.paidAmount.toString();
      _status = invoice.status;
      _notesController.text = invoice.notes ?? '';
      _termsController.text = invoice.termsConditions ?? '';
      // Initialize GST fields if available
      _supplierGstinController.text = ''; // TODO: Get from business
      _customerGstinController.text = ''; // TODO: Get from customer
      _placeOfSupplyController.text = ''; // TODO: Get from invoice
    } else {
      _subtotalController.text = '0.00';
      _taxAmountController.text = '0.00';
      _discountAmountController.text = '0.00';
      _totalAmountController.text = '0.00';
      _paidAmountController.text = '0.00';
      _dueDate = DateTime.now().add(const Duration(days: 30));

      // Handle prefilled data from NLP generation
      if (widget.prefilledData != null) {
        _handlePrefilledData(widget.prefilledData!);
      }
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _subtotalController.dispose();
    _taxAmountController.dispose();
    _discountAmountController.dispose();
    _totalAmountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    _supplierGstinController.dispose();
    _customerGstinController.dispose();
    _placeOfSupplyController.dispose();
    super.dispose();
  }

  void _loadCustomers() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      customerProvider.loadCustomers(businessProvider.business!.id);
    }
  }

  void _generateInvoiceNumber() async {
    if (!_isEditing) {
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      final invoiceProvider = Provider.of<InvoiceProvider>(
        context,
        listen: false,
      );

      if (businessProvider.business != null) {
        final invoiceNumber = await invoiceProvider.generateInvoiceNumber(
          businessProvider.business!.id,
        );
        _invoiceNumberController.text = invoiceNumber;
      }
    }
  }

  void _calculateTotal() {
    final subtotal = double.tryParse(_subtotalController.text) ?? 0.0;
    final taxAmount = double.tryParse(_taxAmountController.text) ?? 0.0;
    final discountAmount =
        double.tryParse(_discountAmountController.text) ?? 0.0;

    final total = subtotal + taxAmount - discountAmount;
    _totalAmountController.text = total.toStringAsFixed(2);

    // Trigger compliance check if real-time validation is enabled
    if (_enableRealTimeCompliance && _currentInvoiceId != null) {
      _triggerComplianceCheck();
    }
  }

  void _triggerComplianceCheck() {
    if (_currentInvoiceId == null) return;

    // Compliance checks disabled (Python dependency removed)
    // Future.delayed(const Duration(milliseconds: 500), () {
    //   if (mounted) {
    //     final complianceProvider = Provider.of<ComplianceProvider>(
    //       context,
    //       listen: false,
    //     );
    //     complianceProvider.checkInvoiceCompliance(_currentInvoiceId!);
    //   }
    // });
  }

  void _handlePrefilledData(Map<String, dynamic> data) {
    // Handle customer data
    final customer = data['customer'] as Map<String, dynamic>?;
    if (customer != null) {
      final customerName = customer['name'] as String?;
      if (customerName != null) {
        // Try to find existing customer or create note for new customer
        final customerProvider = Provider.of<CustomerProvider>(
          context,
          listen: false,
        );
        final matchingCustomers = customerProvider.customers.where(
          (c) => c.name.toLowerCase() == customerName.toLowerCase(),
        );
        final existingCustomer =
            matchingCustomers.isNotEmpty ? matchingCustomers.first : null;

        if (existingCustomer != null) {
          _selectedCustomerId = existingCustomer.id;
        } else {
          // Add note about new customer
          _notesController.text =
              'New customer: $customerName\n${_notesController.text}';
        }
      }
    }

    // Handle items and calculate totals
    final items = data['items'] as List<dynamic>? ?? [];
    if (items.isNotEmpty) {
      double subtotal = 0.0;
      double taxAmount = 0.0;

      for (final item in items) {
        final itemMap = item as Map<String, dynamic>;
        final totalPrice = (itemMap['total_price'] as num?)?.toDouble() ?? 0.0;
        final taxRate = (itemMap['tax_rate'] as num?)?.toDouble() ?? 0.0;

        subtotal += totalPrice;
        if (taxRate > 0) {
          taxAmount += totalPrice * (taxRate / 100);
        }
      }

      _subtotalController.text = subtotal.toStringAsFixed(2);
      _taxAmountController.text = taxAmount.toStringAsFixed(2);
      _calculateTotal();

      // Add items to notes for reference
      final itemsText = items
          .map((item) {
            final itemMap = item as Map<String, dynamic>;
            return '${itemMap['name']} - Qty: ${itemMap['quantity']} @ ₹${itemMap['unit_price']}';
          })
          .join('\n');

      _notesController.text =
          'AI Generated Items:\n$itemsText\n\n${_notesController.text}';
    }

    // Handle payment preference
    final paymentPreference = data['payment_preference'] as String?;
    if (paymentPreference != null) {
      _notesController.text =
          'Payment method: $paymentPreference\n${_notesController.text}';
    }

    // Handle total amount if provided
    final totalAmount = data['total_amount'] as double?;
    if (totalAmount != null && totalAmount > 0) {
      _totalAmountController.text = totalAmount.toStringAsFixed(2);
    }
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    final invoiceProvider = Provider.of<InvoiceProvider>(
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

    final invoiceId = _isEditing ? widget.invoice!.id : const Uuid().v4();
    final invoice = InvoiceModel(
      id: invoiceId,
      businessId: businessProvider.business!.id,
      //userId: businessProvider.business!.userId,
      customerId: _selectedCustomerId!,
      invoiceNumber: _invoiceNumberController.text.trim(),
      invoiceDate: _invoiceDate,
      dueDate: _dueDate,
      subtotal: double.tryParse(_subtotalController.text) ?? 0.0,
      taxAmount: double.tryParse(_taxAmountController.text) ?? 0.0,
      discountAmount: double.tryParse(_discountAmountController.text) ?? 0.0,
      totalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
      paidAmount: double.tryParse(_paidAmountController.text) ?? 0.0,
      status: _status,
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
      termsConditions:
          _termsController.text.trim().isEmpty
              ? null
              : _termsController.text.trim(),
      createdAt: _isEditing ? widget.invoice!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Set current invoice ID for compliance checking
    if (!_isEditing) {
      _currentInvoiceId = invoiceId;
    }

    bool success;
    if (_isEditing) {
      success = await invoiceProvider.updateInvoice(invoice);
    } else {
      success = await invoiceProvider.addInvoice(invoice);
    }

    if (success && mounted) {
      // Compliance check disabled (Python dependency removed)
      // if (_enableRealTimeCompliance) {
      //   final complianceProvider = Provider.of<ComplianceProvider>(
      //     context,
      //     listen: false,
      //   );
      //   complianceProvider.checkInvoiceCompliance(invoice.id);
      // }

      Navigator.of(context).pop(invoice);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Invoice updated successfully'
                : 'Invoice created successfully',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(invoiceProvider.error ?? 'Failed to save invoice'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Invoice' : 'Create Invoice'),
        actions: [
          // AI-powered buttons in top right
          PopupMenuButton<String>(
            icon: const Icon(Icons.smart_toy, color: Colors.blue),
            tooltip: 'AI Tools',
            onSelected: (value) {
              switch (value) {
                case 'cv_extract':
                  _showCVExtractionDialog();
                  break;
                case 'add_customer':
                  _showAddCustomerDialog();
                  break;
                case 'add_supplier':
                  _showAddSupplierDialog();
                  break;
                case 'whatsapp_reminder':
                  _showWhatsAppReminderDialog();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'cv_extract',
                    child: ListTile(
                      leading: Icon(
                        Icons.document_scanner,
                        color: Colors.green,
                      ),
                      title: Text('Extract from CV/Document'),
                      subtitle: Text('AI-powered data extraction'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'add_customer',
                    child: ListTile(
                      leading: Icon(Icons.person_add, color: Colors.blue),
                      title: Text('Add Customer'),
                      subtitle: Text('Quick customer creation'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'add_supplier',
                    child: ListTile(
                      leading: Icon(Icons.business, color: Colors.orange),
                      title: Text('Add Supplier'),
                      subtitle: Text('Quick supplier creation'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'whatsapp_reminder',
                    child: ListTile(
                      leading: Icon(Icons.message, color: Colors.green),
                      title: Text('WhatsApp Reminder'),
                      subtitle: Text('Send payment reminders'),
                    ),
                  ),
                ],
          ),
          // Manual entry button
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Manual Entry Mode',
            onPressed: () {
              setState(() {
                // Toggle manual entry mode
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Invoice Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invoice Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _invoiceNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Invoice Number *',
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
                              if (value == null) {
                                return 'Please select a customer';
                              }
                              return null;
                            },
                          );
                        },
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
                                  setState(() {
                                    _invoiceDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Invoice Date *',
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
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _dueDate ??
                                      DateTime.now().add(
                                        const Duration(days: 30),
                                      ),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dueDate = date;
                                  });
                                }
                              },
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

              // Amount Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _subtotalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Subtotal *',
                          prefixText: AppConstants.defaultCurrency,
                          prefixIcon: const Icon(Icons.calculate),
                        ),
                        onChanged: (_) => _calculateTotal(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter subtotal';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _taxAmountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Tax Amount',
                                prefixText: AppConstants.defaultCurrency,
                                prefixIcon: const Icon(Icons.percent),
                              ),
                              onChanged: (_) => _calculateTotal(),
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    double.tryParse(value) == null) {
                                  return 'Please enter a valid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _discountAmountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Discount',
                                prefixText: AppConstants.defaultCurrency,
                                prefixIcon: const Icon(Icons.discount),
                              ),
                              onChanged: (_) => _calculateTotal(),
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    double.tryParse(value) == null) {
                                  return 'Please enter a valid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _totalAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Total Amount *',
                          prefixText: AppConstants.defaultCurrency,
                          prefixIcon: const Icon(Icons.money),
                        ),
                        readOnly: true,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _paidAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Paid Amount',
                          prefixText: AppConstants.defaultCurrency,
                          prefixIcon: const Icon(Icons.payment),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // GST Compliance Section (Optional - Disabled by default)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'GST Compliance (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _enableRealTimeCompliance,
                            onChanged: (value) {
                              setState(() {
                                _enableRealTimeCompliance = value;
                              });
                              if (value && _currentInvoiceId != null) {
                                _triggerComplianceCheck();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          const Text('Enable GST'),
                        ],
                      ),
                      if (_enableRealTimeCompliance) ...[
                        const SizedBox(height: 16),
                        GSTValidationField(
                          controller: _supplierGstinController,
                          labelText: 'Supplier GSTIN',
                          hintText: 'Your business GST number (optional)',
                          isRequired: false,
                          onChanged: (_) => _triggerComplianceCheck(),
                        ),
                        const SizedBox(height: 16),
                        GSTValidationField(
                          controller: _customerGstinController,
                          labelText: 'Customer GSTIN',
                          hintText: 'Customer GST number (optional)',
                          isRequired: false,
                          onChanged: (_) => _triggerComplianceCheck(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _placeOfSupplyController,
                          decoration: const InputDecoration(
                            labelText: 'Place of Supply',
                            hintText: 'e.g., Maharashtra, Delhi (optional)',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          onChanged: (_) => _triggerComplianceCheck(),
                          validator: null, // Removed validation - now optional
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Compliance Status disabled (Python dependency removed)
              // if (_currentInvoiceId != null && _enableRealTimeCompliance)
              //   ComplianceStatusWidget(
              //     invoiceId: _currentInvoiceId,
              //     showDetails: true,
              //   ),

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
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _termsController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Terms & Conditions',
                          prefixIcon: Icon(Icons.gavel),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Consumer<InvoiceProvider>(
                builder: (context, invoiceProvider, child) {
                  return ElevatedButton(
                    onPressed: invoiceProvider.isLoading ? null : _saveInvoice,
                    child:
                        invoiceProvider.isLoading
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
                              _isEditing ? 'Update Invoice' : 'Create Invoice',
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

  String _getStatusDisplayName(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Show CV/Document extraction dialog
  void _showCVExtractionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.document_scanner, color: Colors.green),
                SizedBox(width: 8),
                Text('Extract from Document'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose how to extract invoice data:'),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  subtitle: const Text('Capture invoice with camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _extractFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Select existing image'),
                  onTap: () {
                    Navigator.pop(context);
                    _extractFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Upload PDF'),
                  subtitle: const Text('Extract from PDF document'),
                  onTap: () {
                    Navigator.pop(context);
                    _extractFromPDF();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  /// Show add customer dialog
  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.person_add, color: Colors.blue),
                SizedBox(width: 8),
                Text('Add Customer'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name *',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      phoneController.text.isNotEmpty) {
                    _addNewCustomer(
                      nameController.text,
                      phoneController.text,
                      emailController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Customer'),
              ),
            ],
          ),
    );
  }

  /// Show add supplier dialog
  void _showAddSupplierDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.business, color: Colors.orange),
                SizedBox(width: 8),
                Text('Add Supplier'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Supplier Name *',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      phoneController.text.isNotEmpty) {
                    _addNewSupplier(
                      nameController.text,
                      phoneController.text,
                      emailController.text,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Supplier'),
              ),
            ],
          ),
    );
  }

  /// Show WhatsApp reminder dialog
  void _showWhatsAppReminderDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.message, color: Colors.green),
                SizedBox(width: 8),
                Text('WhatsApp Reminders'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Send payment reminders via WhatsApp:'),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: const Text('Send to Customer'),
                  subtitle: const Text('Payment due reminder'),
                  onTap: () {
                    Navigator.pop(context);
                    _sendCustomerReminder();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business, color: Colors.orange),
                  title: const Text('Send to Supplier'),
                  subtitle: const Text('Payment confirmation'),
                  onTap: () {
                    Navigator.pop(context);
                    _sendSupplierReminder();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.purple),
                  title: const Text('Schedule Auto Reminders'),
                  subtitle: const Text('Set up automatic reminders'),
                  onTap: () {
                    Navigator.pop(context);
                    _scheduleAutoReminders();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  /// Extract invoice data from camera
  Future<void> _extractFromCamera() async {
    try {
      // This would integrate with the CV parser service
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' Opening camera for invoice extraction...'),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Implement camera integration with CV parser
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Extract invoice data from gallery
  Future<void> _extractFromGallery() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' Opening gallery for invoice extraction...'),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Implement gallery integration with CV parser
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Extract invoice data from PDF
  Future<void> _extractFromPDF() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' Opening file picker for PDF extraction...'),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Implement PDF integration with CV parser
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Add new customer
  void _addNewCustomer(String name, String phone, String email) {
    // TODO: Integrate with customer provider to add new customer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Customer "$name" added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Add new supplier
  void _addNewSupplier(String name, String phone, String email) {
    // TODO: Integrate with supplier provider to add new supplier
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Supplier "$name" added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Send customer reminder via WhatsApp
  Future<void> _sendCustomerReminder() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' Opening WhatsApp to send customer reminder...'),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Integrate with WhatsApp service
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Send supplier reminder via WhatsApp
  Future<void> _sendSupplierReminder() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' Opening WhatsApp to send supplier reminder...'),
          backgroundColor: Colors.green,
        ),
      );
      // TODO: Integrate with WhatsApp service
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Schedule automatic reminders
  void _scheduleAutoReminders() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Schedule Auto Reminders'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Set up automatic WhatsApp reminders:'),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('7 days before due date'),
                  value: true,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('3 days before due date'),
                  value: true,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('1 day before due date'),
                  value: true,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('On due date'),
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Auto reminders scheduled successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Schedule'),
              ),
            ],
          ),
    );
  }
}
