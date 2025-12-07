import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../customers/customer_detail_screen.dart';
import '../customers/add_edit_customer_screen.dart';

class ReceivablesTab extends StatelessWidget {
  const ReceivablesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Summary Card
        Consumer<CustomerProvider>(
          builder: (context, customerProvider, child) {
            final totalReceivables = customerProvider.getTotalReceivables();
            final customersWithBalance =
                customerProvider.customers.where((c) => c.balance > 0).length;

            return Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Receivables',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${AppConstants.defaultCurrency}${totalReceivables.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$customersWithBalance customers owe you money',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.call_received,
                        size: 48,
                        color: AppTheme.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search customers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              // TODO: Implement search functionality
            },
          ),
        ),

        const SizedBox(height: 16),

        // Customers List
        Expanded(
          child: Consumer<CustomerProvider>(
            builder: (context, customerProvider, child) {
              if (customerProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (customerProvider.customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No customers yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add customers to track receivables',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddEditCustomerScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Customer'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: customerProvider.customers.length,
                itemBuilder: (context, index) {
                  final customer = customerProvider.customers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            customer.balance > 0
                                ? AppTheme.accentColor.withValues(alpha: 0.1)
                                : AppTheme.successColor.withValues(alpha: 0.1),
                        child: Text(
                          customer.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                customer.balance > 0
                                    ? AppTheme.accentColor
                                    : AppTheme.successColor,
                          ),
                        ),
                      ),
                      title: Text(
                        customer.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (customer.phone != null) Text(customer.phone!),
                          if (customer.lastTransactionDate != null)
                            Text(
                              'Last transaction: ${customer.lastTransactionDate!.day}/${customer.lastTransactionDate!.month}/${customer.lastTransactionDate!.year}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${AppConstants.defaultCurrency}${customer.balance.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  customer.balance > 0
                                      ? AppTheme.accentColor
                                      : AppTheme.successColor,
                            ),
                          ),
                          Text(
                            customer.balance > 0 ? 'Owes you' : 'You owe',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  customer.balance > 0
                                      ? AppTheme.accentColor
                                      : AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => CustomerDetailScreen(customer: customer),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
