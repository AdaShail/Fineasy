import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/customer_model.dart';
import '../../models/invoice_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../services/whatsapp_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/invoices/quick_invoice_dialog.dart';
import 'add_edit_customer_screen.dart';
import '../transactions/transaction_history_screen.dart';
import '../transactions/quick_transaction_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  late CustomerModel _customer;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
  }

  void _editCustomer() async {
    final result = await Navigator.of(context).push<CustomerModel>(
      MaterialPageRoute(
        builder: (_) => AddEditCustomerScreen(customer: _customer),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() => _customer = result);
    }
  }

  void _deleteCustomer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Customer'),
            content: Text('Are you sure you want to delete ${_customer.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final success = await customerProvider.deleteCustomer(_customer.id);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer deleted successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              customerProvider.error ?? 'Failed to delete customer',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _viewTransactionHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => TransactionHistoryScreen(
              title: '${_customer.name} Transactions',
              customerId: _customer.id,
            ),
      ),
    );
  }

  void _addPaymentReceived() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => QuickTransactionScreen(
              transactionType: QuickTransactionType.paymentReceived,
              customer: _customer,
            ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      // Refresh customer data
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      if (businessProvider.business != null) {
        await customerProvider.loadCustomers(businessProvider.business!.id);

        if (!mounted) return;

        // Update local customer data
        final updatedCustomer = customerProvider.customers.firstWhere(
          (c) => c.id == _customer.id,
          orElse: () => _customer,
        );
        setState(() {
          _customer = updatedCustomer;
        });
      }
    }
  }

  void _addSaleCredit() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => QuickTransactionScreen(
              transactionType: QuickTransactionType.saleCredit,
              customer: _customer,
            ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      // Refresh customer data
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      if (businessProvider.business != null) {
        await customerProvider.loadCustomers(businessProvider.business!.id);

        if (!mounted) return;

        // Update local customer data
        final updatedCustomer = customerProvider.customers.firstWhere(
          (c) => c.id == _customer.id,
          orElse: () => _customer,
        );
        setState(() {
          _customer = updatedCustomer;
        });
      }
    }
  }

  Future<void> _showQuickInvoiceDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => QuickInvoiceDialog(customer: _customer),
    );

    if (result != null) {
      await _createAndSendInvoice(result);
    }
  }

  Future<void> _createAndSendInvoice(Map<String, dynamic> data) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      final invoiceProvider = Provider.of<InvoiceProvider>(
        context,
        listen: false,
      );

      if (businessProvider.business == null) {
        throw Exception('No business selected');
      }

      // Generate invoice number
      final invoiceNumber = await invoiceProvider.generateInvoiceNumber(
        businessProvider.business!.id,
      );

      // Create invoice
      final invoice = InvoiceModel(
        id: const Uuid().v4(),
        businessId: businessProvider.business!.id,
        customerId: _customer.id,
        invoiceNumber: invoiceNumber,
        invoiceType: InvoiceType.customer,
        invoiceDate: DateTime.now(),
        dueDate: data['dueDate'],
        status: InvoiceStatus.sent,
        subtotal: data['amount'],
        totalAmount: data['amount'],
        paidAmount: 0.0,
        taxAmount: 0.0,
        discountAmount: 0.0,
        notes: data['description'],
        items: [
          InvoiceItemModel(
            id: const Uuid().v4(),
            invoiceId: '',
            name: data['description'],
            quantity: 1,
            unitPrice: data['amount'],
            totalAmount: data['amount'],
            taxRate: 0.0,
            discountRate: 0.0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await invoiceProvider.addInvoice(invoice);
      final createdInvoice = success ? invoice : null;

      if (mounted) {
        Navigator.pop(context); // Close loading

        if (createdInvoice != null) {
          // Send via WhatsApp if requested
          if (data['sendImmediately'] && data['phone'].isNotEmpty) {
            await _sendInvoiceViaWhatsApp(
              createdInvoice,
              _customer,
              data['phone'],
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh customer data
          final customerProvider = Provider.of<CustomerProvider>(
            context,
            listen: false,
          );
          if (businessProvider.business != null) {
            await customerProvider.loadCustomers(businessProvider.business!.id);

            if (!mounted) return;

            final updatedCustomer = customerProvider.customers.firstWhere(
              (c) => c.id == _customer.id,
              orElse: () => _customer,
            );
            setState(() {
              _customer = updatedCustomer;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create invoice'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendInvoiceViaWhatsApp(
    InvoiceModel invoice,
    CustomerModel customer,
    String phone,
  ) async {
    try {
      final message = '''
Hello ${customer.name},

Invoice: ${invoice.invoiceNumber}
Amount: ₹${invoice.totalAmount.toStringAsFixed(2)}
Due Date: ${DateFormat('dd MMM yyyy').format(invoice.dueDate!)}

${invoice.notes ?? ''}

Thank you for your business!
''';

      await WhatsAppService.sendCustomMessage(
        phoneNumber: phone,
        message: message,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice sent via WhatsApp'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send WhatsApp: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_customer.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editCustomer),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteCustomer();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppTheme.errorColor),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Customer Header Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            _customer.balance > 0
                                ? AppTheme.accentColor.withValues(alpha: 0.1)
                                : AppTheme.successColor.withValues(alpha: 0.1),
                        child: Text(
                          _customer.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color:
                                _customer.balance > 0
                                    ? AppTheme.accentColor
                                    : AppTheme.successColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _customer.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _customer.balance > 0
                                  ? AppTheme.accentColor.withValues(alpha: 0.1)
                                  : AppTheme.successColor.withValues(
                                    alpha: 0.1,
                                  ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _customer.balance > 0 ? 'Owes You' : 'You Owe',
                          style: TextStyle(
                            color:
                                _customer.balance > 0
                                    ? AppTheme.accentColor
                                    : AppTheme.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${AppConstants.defaultCurrency}${_customer.balance.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color:
                              _customer.balance > 0
                                  ? AppTheme.accentColor
                                  : AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Contact Information
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_customer.phone != null)
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Phone'),
                        subtitle: Text(_customer.phone!),
                        trailing: IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () {
                            // TODO: Implement phone call
                          },
                        ),
                      ),
                    if (_customer.email != null)
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(_customer.email!),
                        trailing: IconButton(
                          icon: const Icon(Icons.mail),
                          onPressed: () {
                            // TODO: Implement email
                          },
                        ),
                      ),
                    if (_customer.address != null)
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Address'),
                        subtitle: Text(_customer.address!),
                        trailing: IconButton(
                          icon: const Icon(Icons.directions),
                          onPressed: () {
                            // TODO: Implement directions
                          },
                        ),
                      ),
                    if (_customer.gstNumber != null)
                      ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: const Text('GST Number'),
                        subtitle: Text(_customer.gstNumber!),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Actions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.add_circle,
                        color: AppTheme.successColor,
                      ),
                      title: const Text('Add Payment Received'),
                      subtitle: const Text(
                        'Record money received from customer',
                      ),
                      onTap: () => _addPaymentReceived(),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.remove_circle,
                        color: AppTheme.errorColor,
                      ),
                      title: const Text('Add Sale/Credit'),
                      subtitle: const Text('Record sale or credit given'),
                      onTap: () => _addSaleCredit(),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.receipt,
                        color: AppTheme.primaryColor,
                      ),
                      title: const Text('Quick Invoice'),
                      subtitle: const Text('Create and send invoice instantly'),
                      onTap: _showQuickInvoiceDialog,
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('View Transaction History'),
                      subtitle: const Text(
                        'See all transactions with this customer',
                      ),
                      onTap: _viewTransactionHistory,
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Set Payment Reminder'),
                      subtitle: const Text(
                        'Get notified about pending payments',
                      ),
                      onTap: () {
                        // TODO: Implement payment reminder
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Transaction Summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryItem(
                              'Last Transaction',
                              _customer.lastTransactionDate != null
                                  ? '${_customer.lastTransactionDate!.day}/${_customer.lastTransactionDate!.month}/${_customer.lastTransactionDate!.year}'
                                  : 'No transactions',
                              Icons.schedule,
                            ),
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              'Customer Since',
                              '${_customer.createdAt.day}/${_customer.createdAt.month}/${_customer.createdAt.year}',
                              Icons.person_add,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
