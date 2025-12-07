import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/supplier_model.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'add_edit_supplier_screen.dart';
import 'supplier_detail_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSuppliers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSuppliers() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final supplierProvider = Provider.of<SupplierProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      supplierProvider.loadSuppliers(businessProvider.business!.id);
    }
  }

  List<SupplierModel> _getFilteredSuppliers(List<SupplierModel> suppliers) {
    if (_searchQuery.isEmpty) return suppliers;

    return suppliers
        .where(
          (supplier) =>
              supplier.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (supplier.email?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false) ||
              (supplier.phone?.contains(_searchQuery) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSuppliers,
          ),
        ],
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, supplierProvider, child) {
          if (supplierProvider.isLoading &&
              supplierProvider.suppliers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (supplierProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading suppliers',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    supplierProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSuppliers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredSuppliers = _getFilteredSuppliers(
            supplierProvider.suppliers,
          );

          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search suppliers...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Supplier Stats
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.business,
                                color: AppTheme.primaryColor,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${supplierProvider.suppliers.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Total Suppliers'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.payment,
                                color: AppTheme.errorColor,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${AppConstants.defaultCurrency}${supplierProvider.totalPayables.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.errorColor,
                                ),
                              ),
                              const Text('Total Payables'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Supplier List
              Expanded(
                child:
                    filteredSuppliers.isEmpty
                        ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.business_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No suppliers found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add your first supplier to get started',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: filteredSuppliers.length,
                          itemBuilder: (context, index) {
                            final supplier = filteredSuppliers[index];
                            return SupplierListTile(
                              supplier: supplier,
                              onTap: () => _viewSupplierDetail(supplier),
                              onEdit: () => _editSupplier(supplier),
                              onDelete: () => _deleteSupplier(supplier),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSupplier,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addSupplier() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddEditSupplierScreen()));
  }

  void _editSupplier(SupplierModel supplier) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditSupplierScreen(supplier: supplier),
      ),
    );
  }

  void _viewSupplierDetail(SupplierModel supplier) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SupplierDetailScreen(supplier: supplier),
      ),
    );
  }

  void _deleteSupplier(SupplierModel supplier) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Supplier'),
            content: Text(
              'Are you sure you want to delete "${supplier.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final supplierProvider = Provider.of<SupplierProvider>(
                    context,
                    listen: false,
                  );
                  final success = await supplierProvider.deleteSupplier(
                    supplier.id,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Supplier deleted successfully'
                              : 'Failed to delete supplier',
                        ),
                        backgroundColor:
                            success
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              ),
            ],
          ),
    );
  }
}

class SupplierListTile extends StatelessWidget {
  final SupplierModel supplier;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SupplierListTile({
    super.key,
    required this.supplier,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : 'S',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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
            if (supplier.email?.isNotEmpty ?? false) Text(supplier.email!),
            if (supplier.phone?.isNotEmpty ?? false) Text(supplier.phone!),
            if (supplier.balance != 0)
              Text(
                'Balance: ${AppConstants.defaultCurrency}${supplier.balance.toStringAsFixed(2)}',
                style: TextStyle(
                  color:
                      supplier.balance > 0
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
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
          onSelected: (value) {
            switch (value) {
              case 'view':
                onTap();
                break;
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
