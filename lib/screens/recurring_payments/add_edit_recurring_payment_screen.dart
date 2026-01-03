import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recurring_payment_model.dart';
import '../../providers/recurring_payment_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/business_provider.dart';

class AddEditRecurringPaymentScreen extends StatefulWidget {
  final RecurringPaymentModel? payment;

  const AddEditRecurringPaymentScreen({super.key, this.payment});

  @override
  State<AddEditRecurringPaymentScreen> createState() => _AddEditRecurringPaymentScreenState();
}

class _AddEditRecurringPaymentScreenState extends State<AddEditRecurringPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCustomerId;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  RecurringPaymentStatus _status = RecurringPaymentStatus.active;
  bool _autoGenerateInvoice = true;
  bool _autoSendReminder = true;
  int _reminderDaysBefore = 3;
  bool _isLoading = false;
  int? _dayOfMonth;
  int? _dayOfWeek;

  @override
  void initState() {
    super.initState();
    if (widget.payment != null) {
      _amountController.text = widget.payment!.amount.toString();
      _descriptionController.text = widget.payment!.description;
      _selectedCustomerId = widget.payment!.customerId;
      _frequency = widget.payment!.frequency;
      _startDate = widget.payment!.startDate;
      _endDate = widget.payment!.endDate;
      _status = widget.payment!.status;
      _autoGenerateInvoice = widget.payment!.autoGenerateInvoice;
      _autoSendReminder = widget.payment!.autoSendReminder;
      _reminderDaysBefore = widget.payment!.reminderDaysBefore;
      _dayOfMonth = widget.payment!.dayOfMonth;
      _dayOfWeek = widget.payment!.dayOfWeek;
    } else {
      // Set default day_of_month for monthly frequency
      _updateFrequencyDefaults();
    }
    
    // Load customers immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = context.read<CustomerProvider>();
      if (customerProvider.customers.isEmpty) {
        // Customers not loaded yet - trigger load
      }
    });
  }

  void _updateFrequencyDefaults() {
    // Set day_of_month or day_of_week based on frequency and start date
    if (_frequency == RecurringFrequency.monthly) {
      _dayOfMonth = _startDate.day;
      _dayOfWeek = null;
    } else if (_frequency == RecurringFrequency.weekly) {
      _dayOfWeek = _startDate.weekday; // 1 = Monday, 7 = Sunday
      _dayOfMonth = null;
    } else {
      _dayOfMonth = null;
      _dayOfWeek = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate customer selection
    if (_selectedCustomerId == null || _selectedCustomerId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get business ID
    final businessProvider = context.read<BusinessProvider>();
    if (businessProvider.business == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<RecurringPaymentProvider>();
      final payment = RecurringPaymentModel(
        id: widget.payment?.id ?? '',
        businessId: widget.payment?.businessId ?? businessProvider.business!.id,
        customerId: _selectedCustomerId!.trim(), // Ensure no empty strings
        amount: double.parse(_amountController.text),
        frequency: _frequency,
        dayOfMonth: _dayOfMonth,
        dayOfWeek: _dayOfWeek,
        startDate: _startDate,
        endDate: _endDate,
        description: _descriptionController.text,
        status: _status,
        occurrencesGenerated: widget.payment?.occurrencesGenerated ?? 0,
        autoGenerateInvoice: _autoGenerateInvoice,
        autoSendReminder: _autoSendReminder,
        reminderDaysBefore: _reminderDaysBefore,
        createdAt: widget.payment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.payment == null) {
        await provider.createRecurringPayment(payment);
      } else {
        await provider.updateRecurringPayment(payment);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
        title: Text(widget.payment == null ? 'New Recurring Payment' : 'Edit Recurring Payment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Consumer<CustomerProvider>(
              builder: (context, customerProvider, _) {
                final customers = customerProvider.customers;
                
                // Debug logging
                
                // Show loading state if customers are being loaded
                if (customerProvider.isLoading) {
                  return const InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Customer',
                      border: OutlineInputBorder(),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                
                // Show message if no customers
                if (customers.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Customer',
                          border: OutlineInputBorder(),
                          errorText: 'No customers available',
                        ),
                        child: Text('Please add customers first'),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          // Navigate to add customer screen
                          Navigator.pushNamed(context, '/add-customer');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Customer'),
                      ),
                    ],
                  );
                }
                
                // Validate selected customer exists in list
                if (_selectedCustomerId != null && 
                    !customers.any((c) => c.id == _selectedCustomerId)) {
                  _selectedCustomerId = null;
                }
                
                return DropdownButtonFormField<String>(
                  value: _selectedCustomerId,
                  decoration: InputDecoration(
                    labelText: 'Customer *',
                    border: const OutlineInputBorder(),
                    helperText: 'Select the customer for this recurring payment',
                    errorText: _selectedCustomerId == null ? 'Required' : null,
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please select a customer';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter amount';
                if (double.tryParse(value) == null) return 'Please enter valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RecurringFrequency>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: RecurringFrequency.daily, child: Text('Daily')),
                DropdownMenuItem(value: RecurringFrequency.weekly, child: Text('Weekly')),
                DropdownMenuItem(value: RecurringFrequency.monthly, child: Text('Monthly')),
                DropdownMenuItem(value: RecurringFrequency.yearly, child: Text('Yearly')),
              ],
              onChanged: (value) {
                setState(() {
                  _frequency = value!;
                  _updateFrequencyDefaults();
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Show day selector for monthly/weekly frequencies
            if (_frequency == RecurringFrequency.monthly)
              DropdownButtonFormField<int>(
                value: _dayOfMonth,
                decoration: const InputDecoration(
                  labelText: 'Day of Month',
                  border: OutlineInputBorder(),
                  helperText: 'Which day of the month to generate payment',
                ),
                items: List.generate(31, (index) => index + 1)
                    .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text('Day $day'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _dayOfMonth = value),
                validator: (value) {
                  if (_frequency == RecurringFrequency.monthly && value == null) {
                    return 'Please select a day of month';
                  }
                  return null;
                },
              ),
            
            if (_frequency == RecurringFrequency.weekly)
              DropdownButtonFormField<int>(
                value: _dayOfWeek,
                decoration: const InputDecoration(
                  labelText: 'Day of Week',
                  border: OutlineInputBorder(),
                  helperText: 'Which day of the week to generate payment',
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Monday')),
                  DropdownMenuItem(value: 2, child: Text('Tuesday')),
                  DropdownMenuItem(value: 3, child: Text('Wednesday')),
                  DropdownMenuItem(value: 4, child: Text('Thursday')),
                  DropdownMenuItem(value: 5, child: Text('Friday')),
                  DropdownMenuItem(value: 6, child: Text('Saturday')),
                  DropdownMenuItem(value: 7, child: Text('Sunday')),
                ],
                onChanged: (value) => setState(() => _dayOfWeek = value),
                validator: (value) {
                  if (_frequency == RecurringFrequency.weekly && value == null) {
                    return 'Please select a day of week';
                  }
                  return null;
                },
              ),
            
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(_startDate.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                    _updateFrequencyDefaults();
                  });
                }
              },
            ),
            ListTile(
              title: const Text('End Date (Optional)'),
              subtitle: Text(_endDate?.toString().split(' ')[0] ?? 'No end date'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
                  firstDate: _startDate,
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RecurringPaymentStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: RecurringPaymentStatus.active, child: Text('Active')),
                DropdownMenuItem(value: RecurringPaymentStatus.paused, child: Text('Paused')),
                DropdownMenuItem(value: RecurringPaymentStatus.cancelled, child: Text('Cancelled')),
                DropdownMenuItem(value: RecurringPaymentStatus.completed, child: Text('Completed')),
              ],
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto Generate Invoice'),
              value: _autoGenerateInvoice,
              onChanged: (value) => setState(() => _autoGenerateInvoice = value),
            ),
            SwitchListTile(
              title: const Text('Auto Send Reminder'),
              value: _autoSendReminder,
              onChanged: (value) => setState(() => _autoSendReminder = value),
            ),
            if (_autoSendReminder)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  initialValue: _reminderDaysBefore.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Reminder Days Before',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final days = int.tryParse(value);
                    if (days != null) {
                      _reminderDaysBefore = days;
                    }
                  },
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _savePayment,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.payment == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
