import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/supplier_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../suppliers/supplier_detail_screen.dart';
import '../suppliers/add_edit_supplier_screen.dart';

class PayablesTab extends StatelessWidget {
  const PayablesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Summary Card
        Consumer<SupplierProvider>(
          builder: (context, supplierProvider, child) {
            final totalPayables = supplierProvider.getTotalPayables();
            final suppliersWithBalance =
                supplierProvider.suppliers.where((s) => s.balance > 0).length;

            return Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Payables',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${AppConstants.defaultCurrency}${totalPayables.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You owe $suppliersWithBalance suppliers',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.payment,
                        size: 48,
                        color: AppTheme.errorColor,
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
              hintText: 'Search suppliers...',
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

        // Suppliers List
        Expanded(
          child: Consumer<SupplierProvider>(
            builder: (context, supplierProvider, child) {
              if (supplierProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (supplierProvider.suppliers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No suppliers yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add suppliers to track payables',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddEditSupplierScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Supplier'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: supplierProvider.suppliers.length,
                itemBuilder: (context, index) {
                  final supplier = supplierProvider.suppliers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            supplier.balance > 0
                                ? AppTheme.errorColor.withValues(alpha: 0.1)
                                : AppTheme.successColor.withValues(alpha: 0.1),
                        child: Text(
                          supplier.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                supplier.balance > 0
                                    ? AppTheme.errorColor
                                    : AppTheme.successColor,
                          ),
                        ),
                      ),
                      title: Text(
                        supplier.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (supplier.phone != null) Text(supplier.phone!),
                          if (supplier.lastTransactionDate != null)
                            Text(
                              'Last transaction: ${supplier.lastTransactionDate!.day}/${supplier.lastTransactionDate!.month}/${supplier.lastTransactionDate!.year}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${AppConstants.defaultCurrency}${supplier.balance.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  supplier.balance > 0
                                      ? AppTheme.errorColor
                                      : AppTheme.successColor,
                            ),
                          ),
                          Text(
                            supplier.balance > 0 ? 'You owe' : 'Owes you',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  supplier.balance > 0
                                      ? AppTheme.errorColor
                                      : AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => SupplierDetailScreen(supplier: supplier),
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
