import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/business_provider.dart';
import '../../services/whatsapp_service.dart';
import '../../services/whatsapp_launcher_service.dart';
import '../../services/upi_service.dart';
import '../../widgets/upi_link_test_widget.dart';
import '../../services/reminder_service.dart';
import '../../utils/app_theme.dart';
import '../../models/customer_model.dart';
import '../../models/supplier_model.dart';

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() =>
      _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Management'),
        actions: [
          // Debug UPI Link Tester (only show in debug mode)
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: 'Test UPI Links',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpiLinkTestWidget(),
                  ),
                );
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Receivables', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Payables', icon: Icon(Icons.payment)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ReceivablesTab(), PayablesTab()],
      ),
    );
  }
}

class ReceivablesTab extends StatelessWidget {
  const ReceivablesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        final customers = customerProvider.customers;

        if (customers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No customers found'),
                Text('Add customers to track receivables'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            return CustomerPaymentCard(customer: customer);
          },
        );
      },
    );
  }
}

class PayablesTab extends StatelessWidget {
  const PayablesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SupplierProvider>(
      builder: (context, supplierProvider, child) {
        final suppliers = supplierProvider.suppliers;

        if (suppliers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No suppliers found'),
                Text('Add suppliers to track payables'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final supplier = suppliers[index];
            return SupplierPaymentCard(supplier: supplier);
          },
        );
      },
    );
  }
}

class CustomerPaymentCard extends StatelessWidget {
  final CustomerModel customer;

  const CustomerPaymentCard({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    // Use actual customer balance instead of mock data
    final outstandingAmount = customer.balance > 0 ? customer.balance : 0.0;
    // Calculate due date based on last transaction + 30 days, or default to 7 days from now
    final dueDate =
        customer.lastTransactionDate?.add(const Duration(days: 30)) ??
        DateTime.now().add(const Duration(days: 7));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    customer.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (customer.phone != null)
                        Text(
                          customer.phone!,
                          style: const TextStyle(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${outstandingAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      'Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        () => _sendWhatsAppReminder(
                          context,
                          customer,
                          outstandingAmount,
                          dueDate,
                        ),
                    icon: const Icon(Icons.message, size: 16),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => _showScheduleReminderDialog(
                          context,
                          customer,
                          outstandingAmount,
                          dueDate,
                        ),
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('Schedule'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        () => _showUpiPaymentDialog(
                          context,
                          customer,
                          outstandingAmount,
                        ),
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('UPI'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendWhatsAppReminder(
    BuildContext context,
    CustomerModel customer,
    double amount,
    DateTime dueDate,
  ) async {
    try {
      final success = await WhatsAppService.sendPaymentReminderWithDetails(
        phoneNumber: customer.phone ?? '',
        customerName: customer.name,
        amount: amount,
        invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        dueDate: dueDate,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp reminder sent successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send WhatsApp reminder'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showScheduleReminderDialog(
    BuildContext context,
    CustomerModel customer,
    double amount,
    DateTime defaultDueDate,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => ScheduleReminderDialog(
            customer: customer,
            amount: amount,
            defaultDueDate: defaultDueDate,
          ),
    );
  }

  void _showUpiPaymentDialog(
    BuildContext context,
    CustomerModel customer,
    double amount,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => UpiPaymentRequestDialog(
            customerName: customer.name,
            customerPhone: customer.phone,
            amount: amount,
          ),
    );
  }
}

class SupplierPaymentCard extends StatelessWidget {
  final SupplierModel supplier;

  const SupplierPaymentCard({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    // Use actual supplier balance instead of mock data
    final payableAmount = supplier.balance > 0 ? supplier.balance : 0.0;
    // Calculate due date based on last transaction + 30 days, or default to 3 days from now
    final dueDate =
        supplier.lastTransactionDate?.add(const Duration(days: 30)) ??
        DateTime.now().add(const Duration(days: 3));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.errorColor,
                  child: Text(
                    supplier.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (supplier.phone != null)
                        Text(
                          supplier.phone!,
                          style: const TextStyle(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${payableAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    Text(
                      'Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        () => _sendWhatsAppMessage(
                          context,
                          supplier,
                          payableAmount,
                          dueDate,
                        ),
                    icon: const Icon(Icons.message, size: 16),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        () => _showUpiPaymentDialog(
                          context,
                          supplier,
                          payableAmount,
                        ),
                    icon: const Icon(Icons.payment, size: 16),
                    label: const Text('Pay Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendWhatsAppMessage(
    BuildContext context,
    SupplierModel supplier,
    double amount,
    DateTime dueDate,
  ) async {
    try {
      final success = await WhatsAppService.sendPaymentRequest(
        phoneNumber: supplier.phone ?? '',
        customerName: supplier.name,
        amount: amount,
        description: 'Payment due for services',
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp message sent successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send WhatsApp message'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showUpiPaymentDialog(
    BuildContext context,
    SupplierModel supplier,
    double amount,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => UpiPaymentDialog(
            payeeName: supplier.name,
            amount: amount,
            isReceivable: false,
            supplierUpiId: supplier.upiId,
          ),
    );
  }
}

class UpiPaymentDialog extends StatefulWidget {
  final String payeeName;
  final double amount;
  final bool isReceivable;
  final String? supplierUpiId;

  const UpiPaymentDialog({
    super.key,
    required this.payeeName,
    required this.amount,
    required this.isReceivable,
    this.supplierUpiId,
  });

  @override
  State<UpiPaymentDialog> createState() => _UpiPaymentDialogState();
}

class _UpiPaymentDialogState extends State<UpiPaymentDialog> {
  final _upiIdController = TextEditingController();
  final _noteController = TextEditingController();
  UpiApp? _selectedApp;
  List<UpiApp> _availableApps = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableApps();
    if (widget.supplierUpiId != null) {
      _upiIdController.text = widget.supplierUpiId!;
    }
  }

  void _loadAvailableApps() async {
    final apps = await UpiService.getAvailableUpiApps();
    setState(() {
      _availableApps = apps;
      if (apps.isNotEmpty) {
        _selectedApp = apps.first;
      }
    });
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isReceivable ? 'Request Payment' : 'Make Payment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.isReceivable ? 'Request' : 'Pay'} ₹${widget.amount.toStringAsFixed(2)} ${widget.isReceivable ? 'from' : 'to'} ${widget.payeeName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _upiIdController,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                hintText: 'example@upi',
                prefixIcon: Icon(Icons.account_balance),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter UPI ID';
                }
                if (!UpiService.isValidUpiId(value)) {
                  return 'Please enter a valid UPI ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Transaction Note (Optional)',
                hintText: 'Payment for...',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            if (_availableApps.isNotEmpty) ...[
              const Text(
                'Select UPI App:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    _availableApps.map((app) {
                      return ChoiceChip(
                        label: Text(app.displayName),
                        selected: _selectedApp == app,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedApp = app);
                          }
                        },
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _processPayment,
          child: Text(widget.isReceivable ? 'Generate Link' : 'Pay Now'),
        ),
      ],
    );
  }

  void _processPayment() async {
    if (_upiIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter UPI ID'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (!UpiService.isValidUpiId(_upiIdController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid UPI ID'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      bool success = false;

      if (_selectedApp != null) {
        success = await UpiService.makePaymentWithApp(
          upiId: _upiIdController.text,
          payeeName: widget.payeeName,
          amount: widget.amount,
          app: _selectedApp!,
          transactionNote:
              _noteController.text.isEmpty ? null : _noteController.text,
        );
      } else {
        success = await UpiService.makePayment(
          upiId: _upiIdController.text,
          payeeName: widget.payeeName,
          amount: widget.amount,
          transactionNote:
              _noteController.text.isEmpty ? null : _noteController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isReceivable
                    ? 'Payment request sent successfully!'
                    : 'Payment initiated successfully!',
              ),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to process payment'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}

// Schedule Reminder Dialog
class ScheduleReminderDialog extends StatefulWidget {
  final CustomerModel customer;
  final double amount;
  final DateTime defaultDueDate;

  const ScheduleReminderDialog({
    super.key,
    required this.customer,
    required this.amount,
    required this.defaultDueDate,
  });

  @override
  State<ScheduleReminderDialog> createState() => _ScheduleReminderDialogState();
}

class _ScheduleReminderDialogState extends State<ScheduleReminderDialog> {
  late DateTime _dueDate;
  late DateTime _reminderDate;
  late TimeOfDay _reminderTime;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.defaultDueDate;
    _reminderDate = _dueDate.subtract(const Duration(days: 1));
    _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Payment Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer: ${widget.customer.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Amount: ₹${widget.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),

            // Due Date Selection
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Due Date'),
              subtitle: Text(
                '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _dueDate = date;
                    // Adjust reminder date if it's after due date
                    if (_reminderDate.isAfter(_dueDate)) {
                      _reminderDate = _dueDate.subtract(
                        const Duration(days: 1),
                      );
                    }
                  });
                }
              },
            ),

            // Reminder Date Selection
            ListTile(
              leading: const Icon(Icons.notification_important),
              title: const Text('Reminder Date'),
              subtitle: Text(
                '${_reminderDate.day}/${_reminderDate.month}/${_reminderDate.year}',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _reminderDate,
                  firstDate: DateTime.now(),
                  lastDate: _dueDate,
                );
                if (date != null) {
                  setState(() {
                    _reminderDate = date;
                  });
                }
              },
            ),

            // Reminder Time Selection
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Reminder Time'),
              subtitle: Text(_reminderTime.format(context)),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                );
                if (time != null) {
                  setState(() {
                    _reminderTime = time;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final reminderDateTime = DateTime(
              _reminderDate.year,
              _reminderDate.month,
              _reminderDate.day,
              _reminderTime.hour,
              _reminderTime.minute,
            );

            Navigator.of(context).pop();

            // Call the schedule reminder function
            _scheduleReminderFromDialog(
              context,
              widget.customer,
              widget.amount,
              _dueDate,
              reminderDateTime,
            );
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}

// UPI Payment Request Dialog for Receivables
class UpiPaymentRequestDialog extends StatefulWidget {
  final String customerName;
  final String? customerPhone;
  final double amount;

  const UpiPaymentRequestDialog({
    super.key,
    required this.customerName,
    this.customerPhone,
    required this.amount,
  });

  @override
  State<UpiPaymentRequestDialog> createState() =>
      _UpiPaymentRequestDialogState();
}

class _UpiPaymentRequestDialogState extends State<UpiPaymentRequestDialog> {
  final _businessUpiController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = 'Payment from ${widget.customerName}';
  }

  @override
  void dispose() {
    _businessUpiController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate Payment Request'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Request ₹${widget.amount.toStringAsFixed(2)} from ${widget.customerName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _businessUpiController,
              decoration: const InputDecoration(
                labelText: 'Your Business UPI ID',
                hintText: 'yourbusiness@upi',
                prefixIcon: Icon(Icons.account_balance),
                helperText: 'Enter your UPI ID to receive payment',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your UPI ID';
                }
                if (!UpiService.isValidUpiId(value)) {
                  return 'Please enter a valid UPI ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Payment Note',
                hintText: 'Payment for...',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _generatePaymentRequest,
          child: const Text('Generate Request'),
        ),
      ],
    );
  }

  void _generatePaymentRequest() async {
    // Simple validation
    if (_businessUpiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your business UPI ID'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (!UpiService.isValidUpiId(_businessUpiController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid UPI ID'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      // Generate UPI payment link
      final upiLink = UpiService.generateUpiLink(
        upiId: _businessUpiController.text,
        payeeName: 'Your Business',
        amount: widget.amount,
        transactionNote: _noteController.text,
      );

      // Create WhatsApp message
      final message = '''
Hello ${widget.customerName},

Payment Request:
Amount: ₹${widget.amount.toStringAsFixed(2)}
Note: ${_noteController.text}

Click this link to pay instantly:
$upiLink

Thank you!
''';

      // Send via WhatsApp if phone number is available
      if (widget.customerPhone != null && widget.customerPhone!.isNotEmpty) {
        final success = await WhatsAppLauncherService.sendMessageWithFeedback(
          context: context,
          phoneNumber: widget.customerPhone!,
          message: message,
          successMessage: 'Payment request sent via WhatsApp!',
        );

        if (success && mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // Copy to clipboard if no phone number
        await Clipboard.setData(ClipboardData(text: upiLink));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment URL copied to clipboard!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}

// Helper function to schedule reminder from dialog
Future<void> _scheduleReminderFromDialog(
  BuildContext context,
  CustomerModel customer,
  double amount,
  DateTime dueDate,
  DateTime reminderTime,
) async {
  final businessProvider = Provider.of<BusinessProvider>(
    context,
    listen: false,
  );
  final businessName = businessProvider.business?.name ?? 'Your Business';

  try {
    await ReminderService.schedulePaymentReminder(
      customerId: customer.id,
      customerName: customer.name,
      customerPhone: customer.phone ?? '',
      amount: amount,
      currency: '₹',
      scheduledTime: reminderTime,
      dueDate: dueDate,
      businessName: businessName,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment reminder scheduled successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scheduling reminder: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
