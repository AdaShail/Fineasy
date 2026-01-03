import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/supplier_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';
import '../../screens/suppliers/add_edit_supplier_screen.dart';
import '../widgets/web_data_table.dart';
import '../../core/responsive/responsive_layout.dart';

/// Web-optimized supplier management screen with master-detail layout
/// Requirements: 3.3, 6.3
class WebSupplierManagementScreen extends StatefulWidget {
  const WebSupplierManagementScreen({super.key});

  @override
  State<WebSupplierManagementScreen> createState() =>
      _WebSupplierManagementScreenState();
}

class _WebSupplierManagementScreenState
    extends State<WebSupplierManagementScreen> {
  SupplierModel? _selectedSupplier;
  final Set<SupplierModel> _selectedSuppliers = {};
  String _searchQuery = '';
  bool _showFilters = false;
  double? _filterMinBalance;
  double? _filterMaxBalance;
  String _sortField = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSuppliers();
    });
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
    var filtered = suppliers;

    // Balance range filter
    if (_filterMinBalance != null) {
      filtered = filtered
          .where((supplier) => supplier.balance >= _filterMinBalance!)
          .toList();
    }
    if (_filterMaxBalance != null) {
      filtered = filtered
          .where((supplier) => supplier.balance <= _filterMaxBalance!)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((supplier) {
        final query = _searchQuery.toLowerCase();
        return supplier.name.toLowerCase().contains(query) ||
            (supplier.phone?.contains(query) ?? false) ||
            (supplier.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Sort
    filtered.sort((a, b) {
      int comparison;
      switch (_sortField) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'balance':
          comparison = a.balance.compareTo(b.balance);
          break;
        case 'lastTransaction':
          final aDate = a.lastTransactionDate ?? DateTime(1970);
          final bDate = b.lastTransactionDate ?? DateTime(1970);
          comparison = aDate.compareTo(bDate);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewSupplier,
          ),
        ],
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, supplierProvider, child) {
          if (supplierProvider.isLoading && supplierProvider.suppliers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredSuppliers = _getFilteredSuppliers(supplierProvider.suppliers);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search suppliers...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              // Supplier list
              Expanded(
                child: filteredSuppliers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No suppliers found', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredSuppliers.length,
                        itemBuilder: (context, index) {
                          final supplier = filteredSuppliers[index];
                          return _buildMobileSupplierCard(supplier);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileSupplierCard(SupplierModel supplier) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: supplier.balance > 0
              ? Colors.red.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          child: Text(
            supplier.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: supplier.balance > 0 ? Colors.red : Colors.grey,
            ),
          ),
        ),
        title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(supplier.phone ?? supplier.email ?? 'No contact'),
        trailing: Text(
          '${AppConstants.defaultCurrency}${supplier.balance.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: supplier.balance > 0 ? Colors.red : Colors.grey,
          ),
        ),
        onTap: () => _editSupplier(supplier),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Left side: Supplier list with filters
          Expanded(
            flex: _selectedSupplier == null ? 1 : 2,
            child: _buildSupplierList(),
          ),

          // Right side: Supplier detail
          if (_selectedSupplier != null)
            Expanded(
              flex: 3,
              child: _buildSupplierDetail(),
            ),
        ],
      ),
    );
  }

  Widget _buildSupplierList() {
    return Consumer<SupplierProvider>(
      builder: (context, supplierProvider, child) {
        if (supplierProvider.isLoading && supplierProvider.suppliers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (supplierProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${supplierProvider.error}'),
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
            _buildListHeader(filteredSuppliers.length),
            if (_selectedSuppliers.isNotEmpty) _buildBulkOperationsToolbar(),
            if (_showFilters) _buildAdvancedFilters(),
            Expanded(
              child: _buildSupplierTable(filteredSuppliers),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListHeader(int totalCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Suppliers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Chip(label: Text('$totalCount'), backgroundColor: Colors.blue.shade100),
              const Spacer(),
              IconButton(
                icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
                onPressed: () => setState(() => _showFilters = !_showFilters),
                tooltip: 'Toggle Filters',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _createNewSupplier,
                icon: const Icon(Icons.add),
                label: const Text('New Supplier'),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'export') _exportSuppliers();
                  else if (value == 'import') _importSuppliers();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'export', child: Row(children: [Icon(Icons.download), SizedBox(width: 8), Text('Export CSV')])),
                  PopupMenuItem(value: 'import', child: Row(children: [Icon(Icons.upload), SizedBox(width: 8), Text('Import CSV')])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search suppliers by name, phone, or email...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkOperationsToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Text('${_selectedSuppliers.length} selected', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          TextButton.icon(onPressed: _bulkExport, icon: const Icon(Icons.download, size: 18), label: const Text('Export Selected')),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _bulkDelete,
            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          const Spacer(),
          TextButton(onPressed: () => setState(() => _selectedSuppliers.clear()), child: const Text('Clear Selection')),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Advanced Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(onPressed: _clearFilters, child: const Text('Clear All')),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 150,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Min Balance',
                    border: const OutlineInputBorder(),
                    prefixText: AppConstants.defaultCurrency,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() => _filterMinBalance = double.tryParse(value)),
                ),
              ),
              SizedBox(
                width: 150,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Max Balance',
                    border: const OutlineInputBorder(),
                    prefixText: AppConstants.defaultCurrency,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() => _filterMaxBalance = double.tryParse(value)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierTable(List<SupplierModel> suppliers) {
    return WebDataTable<SupplierModel>(
      data: suppliers,
      selectable: true,
      onSelectionChanged: (selected) => setState(() {
        _selectedSuppliers.clear();
        _selectedSuppliers.addAll(selected);
      }),
      onRowTap: (supplier) => setState(() => _selectedSupplier = supplier),
      columns: [
        WebDataColumn<SupplierModel>(
          label: 'Name',
          field: 'name',
          width: 200,
          valueGetter: (supplier) => supplier.name,
          cellBuilder: (supplier) => Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: supplier.balance > 0 ? Colors.red.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                child: Text(
                  supplier.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: supplier.balance > 0 ? Colors.red : Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        WebDataColumn<SupplierModel>(label: 'Phone', field: 'phone', width: 150, valueGetter: (supplier) => supplier.phone ?? 'N/A'),
        WebDataColumn<SupplierModel>(label: 'Email', field: 'email', width: 200, valueGetter: (supplier) => supplier.email ?? 'N/A'),
        WebDataColumn<SupplierModel>(
          label: 'Balance',
          field: 'balance',
          width: 150,
          valueGetter: (supplier) => supplier.balance.toStringAsFixed(2),
          cellBuilder: (supplier) => Text(
            '${AppConstants.defaultCurrency}${supplier.balance.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.w600, color: supplier.balance > 0 ? Colors.red : Colors.grey),
          ),
        ),
        WebDataColumn<SupplierModel>(
          label: 'Last Transaction',
          field: 'lastTransaction',
          width: 150,
          valueGetter: (supplier) => supplier.lastTransactionDate != null ? DateFormat('dd MMM yyyy').format(supplier.lastTransactionDate!) : 'Never',
        ),
        WebDataColumn<SupplierModel>(
          label: 'Actions',
          field: 'actions',
          width: 100,
          sortable: false,
          cellBuilder: (supplier) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editSupplier(supplier), tooltip: 'Edit'),
              IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deleteSupplier(supplier), tooltip: 'Delete'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierDetail() {
    if (_selectedSupplier == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: Colors.grey.shade300))),
      child: Column(
        children: [
          _buildDetailHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSupplierInfo(),
                  const SizedBox(height: 24),
                  _buildContactInfo(),
                  const SizedBox(height: 24),
                  _buildRelationshipVisualization(),
                  const SizedBox(height: 24),
                  _buildActivityTimeline(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _selectedSupplier!.balance > 0 ? Colors.red.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
            child: Text(
              _selectedSupplier!.name.substring(0, 1).toUpperCase(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _selectedSupplier!.balance > 0 ? Colors.red : Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedSupplier!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(_selectedSupplier!.phone ?? 'No phone', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: () => _editSupplier(_selectedSupplier!), tooltip: 'Edit'),
          IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedSupplier = null), tooltip: 'Close'),
        ],
      ),
    );
  }

  Widget _buildSupplierInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Supplier Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInfoItem('Balance', '${AppConstants.defaultCurrency}${_selectedSupplier!.balance.toStringAsFixed(2)}', Icons.account_balance_wallet, _selectedSupplier!.balance > 0 ? Colors.red : Colors.grey)),
                Expanded(child: _buildInfoItem('Supplier Since', DateFormat('dd MMM yyyy').format(_selectedSupplier!.createdAt), Icons.calendar_today, Colors.blue)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInfoItem('Last Transaction', _selectedSupplier!.lastTransactionDate != null ? DateFormat('dd MMM yyyy').format(_selectedSupplier!.lastTransactionDate!) : 'Never', Icons.history, Colors.orange)),
                Expanded(child: _buildInfoItem('GST Number', _selectedSupplier!.gstNumber ?? 'Not provided', Icons.receipt_long, Colors.purple)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_selectedSupplier!.phone != null)
              ListTile(leading: const Icon(Icons.phone), title: const Text('Phone'), subtitle: Text(_selectedSupplier!.phone!)),
            if (_selectedSupplier!.email != null)
              ListTile(leading: const Icon(Icons.email), title: const Text('Email'), subtitle: Text(_selectedSupplier!.email!)),
            if (_selectedSupplier!.address != null)
              ListTile(leading: const Icon(Icons.location_on), title: const Text('Address'), subtitle: Text(_selectedSupplier!.address!)),
            if (_selectedSupplier!.upiId != null)
              ListTile(leading: const Icon(Icons.payment), title: const Text('UPI ID'), subtitle: Text(_selectedSupplier!.upiId!)),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipVisualization() {
    final supplierProvider = Provider.of<SupplierProvider>(context);
    final totalPayables = supplierProvider.totalPayables;
    final supplierPercentage = totalPayables > 0 ? (_selectedSupplier!.balance / totalPayables * 100) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Relationship Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Share of Total Payables', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: supplierPercentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 4),
                      Text('${supplierPercentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatChip('Total Payables', '${AppConstants.defaultCurrency}${totalPayables.toStringAsFixed(2)}', Colors.blue),
                _buildStatChip('Supplier Balance', '${AppConstants.defaultCurrency}${_selectedSupplier!.balance.toStringAsFixed(2)}', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Activity Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: _viewFullHistory, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                final transactions = transactionProvider.transactions.where((t) => t.supplierId == _selectedSupplier!.id).take(5).toList();
                if (transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('No recent activity', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) => _buildTimelineItem(transactions[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(TransactionModel transaction) {
    IconData icon;
    Color color;
    String title;
    switch (transaction.type) {
      case TransactionType.paymentOut:
      case TransactionType.expense:
        icon = Icons.arrow_upward;
        color = Colors.red;
        title = 'Payment Made';
        break;
      case TransactionType.purchase:
      case TransactionType.debit:
        icon = Icons.shopping_bag;
        color = Colors.orange;
        title = 'Purchase/Debit';
        break;
      case TransactionType.paymentIn:
      case TransactionType.income:
        icon = Icons.arrow_downward;
        color = Colors.green;
        title = 'Payment Received';
        break;
      case TransactionType.sale:
      case TransactionType.credit:
        icon = Icons.shopping_cart;
        color = Colors.blue;
        title = 'Sale/Credit';
        break;
    }
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.2), child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(transaction.date)),
      trailing: Text('${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    );
  }

  void _clearFilters() => setState(() {
    _filterMinBalance = null;
    _filterMaxBalance = null;
  });

  void _createNewSupplier() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditSupplierScreen())).then((_) => _loadSuppliers());
  }

  void _editSupplier(SupplierModel supplier) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditSupplierScreen(supplier: supplier))).then((_) {
      _loadSuppliers();
      if (_selectedSupplier?.id == supplier.id) {
        final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
        setState(() => _selectedSupplier = supplierProvider.getSupplierById(supplier.id));
      }
    });
  }

  Future<void> _deleteSupplier(SupplierModel supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to delete "${supplier.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final success = await supplierProvider.deleteSupplier(supplier.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Supplier deleted successfully' : 'Failed to delete supplier'), backgroundColor: success ? Colors.green : Colors.red),
      );
      if (success && _selectedSupplier?.id == supplier.id) setState(() => _selectedSupplier = null);
    }
  }

  Future<void> _bulkDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Suppliers'),
        content: Text('Are you sure you want to delete ${_selectedSuppliers.length} suppliers?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    int successCount = 0;
    for (final supplier in _selectedSuppliers) {
      if (await supplierProvider.deleteSupplier(supplier.id)) successCount++;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$successCount suppliers deleted'), backgroundColor: Colors.green));
      setState(() {
        _selectedSuppliers.clear();
        if (_selectedSupplier != null && _selectedSuppliers.contains(_selectedSupplier)) _selectedSupplier = null;
      });
    }
  }

  void _exportSuppliers() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export functionality coming soon')));
  void _importSuppliers() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import functionality coming soon')));
  void _bulkExport() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exporting ${_selectedSuppliers.length} suppliers...')));
  void _viewFullHistory() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Full history view coming soon')));
}
