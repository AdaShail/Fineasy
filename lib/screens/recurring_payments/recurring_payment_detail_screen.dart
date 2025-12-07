import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recurring_payment_model.dart';
import '../../providers/recurring_payment_provider.dart';
import '../../providers/customer_provider.dart';
import 'add_edit_recurring_payment_screen.dart';

class RecurringPaymentDetailScreen extends StatelessWidget {
  final RecurringPaymentModel payment;

  const RecurringPaymentDetailScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditRecurringPaymentScreen(payment: payment),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deletePayment(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${payment.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Consumer<CustomerProvider>(
                    builder: (context, customerProvider, _) {
                      final customer = customerProvider.customers
                          .where((c) => c.id == payment.customerId)
                          .firstOrNull;
                      return Text(
                        customer?.name ?? 'Unknown Customer',
                        style: Theme.of(context).textTheme.titleMedium,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(context, 'Frequency', payment.frequencyDescription),
          _buildInfoCard(context, 'Start Date', _formatDate(payment.startDate)),
          if (payment.endDate != null)
            _buildInfoCard(context, 'End Date', _formatDate(payment.endDate!)),
          _buildInfoCard(context, 'Status', _formatStatus(payment.status)),
          _buildInfoCard(context, 'Occurrences Generated', payment.occurrencesGenerated.toString()),
          if (payment.description.isNotEmpty)
            _buildInfoCard(context, 'Description', payment.description),
          const SizedBox(height: 16),
          const Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Auto Generate Invoice'),
                  trailing: Icon(
                    payment.autoGenerateInvoice ? Icons.check_circle : Icons.cancel,
                    color: payment.autoGenerateInvoice ? Colors.green : Colors.grey,
                  ),
                ),
                ListTile(
                  title: const Text('Auto Send Reminder'),
                  trailing: Icon(
                    payment.autoSendReminder ? Icons.check_circle : Icons.cancel,
                    color: payment.autoSendReminder ? Colors.green : Colors.grey,
                  ),
                ),
                if (payment.autoSendReminder)
                  ListTile(
                    title: const Text('Reminder Days Before'),
                    trailing: Text(payment.reminderDaysBefore.toString()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _formatStatus(RecurringPaymentStatus status) {
    switch (status) {
      case RecurringPaymentStatus.active:
        return 'Active';
      case RecurringPaymentStatus.paused:
        return 'Paused';
      case RecurringPaymentStatus.cancelled:
        return 'Cancelled';
      case RecurringPaymentStatus.completed:
        return 'Completed';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _deletePayment(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text('Are you sure you want to delete this recurring payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<RecurringPaymentProvider>().deleteRecurringPayment(payment.id);
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
