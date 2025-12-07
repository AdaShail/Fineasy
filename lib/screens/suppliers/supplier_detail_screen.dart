import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/supplier_model.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'add_edit_supplier_screen.dart';
import '../transactions/transaction_history_screen.dart';
import '../transactions/quick_transaction_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final SupplierModel supplier;

  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  late SupplierModel _supplier;

  @override
  void initState() {
    super.initState();
    _supplier = widget.supplier;
  }

  void _editSupplier() async {
    final result = await Navigator.of(context).push<SupplierModel>(
      MaterialPageRoute(
        builder: (_) => AddEditSupplierScreen(supplier: _supplier),
      ),
    );

    if (result != null) {
      setState(() => _supplier = result);
    }
  }

  void _deleteSupplier() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Supplier'),
            content: Text('Are you sure you want to delete ${_supplier.name}?'),
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
      final supplierProvider = Provider.of<SupplierProvider>(
        context,
        listen: false,
      );
      final success = await supplierProvider.deleteSupplier(_supplier.id);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplier deleted successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              supplierProvider.error ?? 'Failed to delete supplier',
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
              title: '${_supplier.name} Transactions',
              supplierId: _supplier.id,
            ),
      ),
    );
  }

  void _addPurchaseDebit() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => QuickTransactionScreen(
              transactionType: QuickTransactionType.purchaseDebit,
              supplier: _supplier,
            ),
      ),
    );

    if (result == true) {
      // Refresh supplier data
      final supplierProvider = Provider.of<SupplierProvider>(
        context,
        listen: false,
      );
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      if (businessProvider.business != null) {
        await supplierProvider.loadSuppliers(businessProvider.business!.id);

        // Update local supplier data
        final updatedSupplier = supplierProvider.suppliers.firstWhere(
          (s) => s.id == _supplier.id,
          orElse: () => _supplier,
        );
        if (mounted) {
          setState(() {
            _supplier = updatedSupplier;
          });
        }
      }
    }
  }

  void _addPaymentMade() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => QuickTransactionScreen(
              transactionType: QuickTransactionType.paymentMade,
              supplier: _supplier,
            ),
      ),
    );

    if (result == true) {
      // Refresh supplier data
      final supplierProvider = Provider.of<SupplierProvider>(
        context,
        listen: false,
      );
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      if (businessProvider.business != null) {
        await supplierProvider.loadSuppliers(businessProvider.business!.id);

        // Update local supplier data
        final updatedSupplier = supplierProvider.suppliers.firstWhere(
          (s) => s.id == _supplier.id,
          orElse: () => _supplier,
        );
        if (mounted) {
          setState(() {
            _supplier = updatedSupplier;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_supplier.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editSupplier),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteSupplier();
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
            // Supplier Header Card
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
                            _supplier.balance > 0
                                ? AppTheme.errorColor.withValues(alpha: 0.1)
                                : AppTheme.successColor.withValues(alpha: 0.1),
                        child: Text(
                          _supplier.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color:
                                _supplier.balance > 0
                                    ? AppTheme.errorColor
                                    : AppTheme.successColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _supplier.name,
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
                              _supplier.balance > 0
                                  ? AppTheme.errorColor.withValues(alpha: 0.1)
                                  : AppTheme.successColor.withValues(
                                    alpha: 0.1,
                                  ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _supplier.balance > 0 ? 'You Owe' : 'Owes You',
                          style: TextStyle(
                            color:
                                _supplier.balance > 0
                                    ? AppTheme.errorColor
                                    : AppTheme.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${AppConstants.defaultCurrency}${_supplier.balance.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color:
                              _supplier.balance > 0
                                  ? AppTheme.errorColor
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
                    if (_supplier.phone != null)
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Phone'),
                        subtitle: Text(_supplier.phone!),
                        trailing: IconButton(
                          icon: const Icon(Icons.call),
                          onPressed: () {
                            // TODO: Implement phone call
                          },
                        ),
                      ),
                    if (_supplier.email != null)
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(_supplier.email!),
                        trailing: IconButton(
                          icon: const Icon(Icons.mail),
                          onPressed: () {
                            // TODO: Implement email
                          },
                        ),
                      ),
                    if (_supplier.address != null)
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Address'),
                        subtitle: Text(_supplier.address!),
                        trailing: IconButton(
                          icon: const Icon(Icons.directions),
                          onPressed: () {
                            // TODO: Implement directions
                          },
                        ),
                      ),
                    if (_supplier.gstNumber != null)
                      ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: const Text('GST Number'),
                        subtitle: Text(_supplier.gstNumber!),
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
                        color: AppTheme.errorColor,
                      ),
                      title: const Text('Add Purchase/Expense'),
                      subtitle: const Text(
                        'Record purchase or expense from supplier',
                      ),
                      onTap: () => _addPurchaseDebit(),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.remove_circle,
                        color: AppTheme.successColor,
                      ),
                      title: const Text('Add Payment Made'),
                      subtitle: const Text('Record payment made to supplier'),
                      onTap: () => _addPaymentMade(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('View Transaction History'),
                      subtitle: const Text(
                        'See all transactions with this supplier',
                      ),
                      onTap: _viewTransactionHistory,
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Set Payment Reminder'),
                      subtitle: const Text('Get notified about due payments'),
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
                              _supplier.lastTransactionDate != null
                                  ? '${_supplier.lastTransactionDate!.day}/${_supplier.lastTransactionDate!.month}/${_supplier.lastTransactionDate!.year}'
                                  : 'No transactions',
                              Icons.schedule,
                            ),
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              'Supplier Since',
                              '${_supplier.createdAt.day}/${_supplier.createdAt.month}/${_supplier.createdAt.year}',
                              Icons.business,
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
