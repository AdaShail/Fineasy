import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/constants.dart';
import '../../screens/invoices/add_edit_invoice_screen.dart';
import '../../screens/invoices/invoice_detail_screen.dart';
import '../widgets/web_data_table.dart';
import '../../core/responsive/responsive_layout.dart';

/// Web-optimized invoice management screen with split-view layout
/// Requirements: 3.2, 6.3
class WebInvoiceManagementScreen extends StatefulWidget {
  const WebInvoiceManagementScreen({super.key});

  @override
  State<WebInvoiceManagementScreen> createState() =>
      _WebInvoiceManagementScreenState();
}

class _WebInvoiceManagementScreenState
    extends State<WebInvoiceManagementScreen> {
  InvoiceModel? _selectedInvoice;
  final Set<InvoiceModel> _selectedInvoices = {};
  InvoiceStatus? _filterStatus;
  String? _filterCustomerId;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  double? _filterMinAmount;
  double? _filterMaxAmount;
  String _searchQuery = '';
  bool _showFilters = false;
  bool _showPdfPreview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvoices();
    });
  }

  void _loadInvoices() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      invoiceProvider.loadInvoices(businessProvider.business!.id);
    }
  }

  List<InvoiceModel> _getFilteredInvoices(List<InvoiceModel> invoices) {
    var filtered = invoices;

    // Status filter
    if (_filterStatus != null) {
      filtered =
          filtered.where((invoice) => invoice.status == _filterStatus).toList();
    }

    // Date range filter
    if (_filterStartDate != null) {
      filtered = filtered.where((invoice) {
        return invoice.createdAt.isAfter(_filterStartDate!) ||
            invoice.createdAt.isAtSameMomentAs(_filterStartDate!);
      }).toList();
    }
    if (_filterEndDate != null) {
      filtered = filtered.where((invoice) {
        final endOfDay = DateTime(
          _filterEndDate!.year,
          _filterEndDate!.month,
          _filterEndDate!.day,
          23,
          59,
          59,
        );
        return invoice.createdAt.isBefore(endOfDay) ||
            invoice.createdAt.isAtSameMomentAs(endOfDay);
      }).toList();
    }

    // Customer filter
    if (_filterCustomerId != null && _filterCustomerId!.isNotEmpty) {
      filtered = filtered
          .where((invoice) => invoice.customerId == _filterCustomerId)
          .toList();
    }

    // Amount range filter
    if (_filterMinAmount != null) {
      filtered = filtered
          .where((invoice) => invoice.totalAmount >= _filterMinAmount!)
          .toList();
    }
    if (_filterMaxAmount != null) {
      filtered = filtered
          .where((invoice) => invoice.totalAmount <= _filterMaxAmount!)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );

      filtered = filtered.where((invoice) {
        final query = _searchQuery.toLowerCase();

        // Search by invoice number
        if (invoice.invoiceNumber.toLowerCase().contains(query)) {
          return true;
        }

        // Search by customer name
        if (invoice.customerId != null) {
          final customer = customerProvider.getCustomerById(
            invoice.customerId!,
          );
          if (customer != null &&
              customer.name.toLowerCase().contains(query)) {
            return true;
          }
        }

        // Search by amount
        final amountStr = invoice.totalAmount.toStringAsFixed(2);
        if (amountStr.contains(query)) {
          return true;
        }

        return false;
      }).toList();
    }

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
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewInvoice,
          ),
        ],
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, invoiceProvider, child) {
          if (invoiceProvider.isLoading && invoiceProvider.invoices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredInvoices = _getFilteredInvoices(invoiceProvider.invoices);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search invoices...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              // Status filter chips
              if (_showFilters)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterStatus == null,
                        onSelected: (_) => setState(() => _filterStatus = null),
                      ),
                      const SizedBox(width: 8),
                      ...InvoiceStatus.values.map((status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getStatusDisplayName(status)),
                          selected: _filterStatus == status,
                          onSelected: (_) => setState(() => _filterStatus = status),
                        ),
                      )),
                    ],
                  ),
                ),
              if (_showFilters) const SizedBox(height: 8),
              // Invoice list
              Expanded(
                child: filteredInvoices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No invoices found', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredInvoices.length,
                        itemBuilder: (context, index) {
                          final invoice = filteredInvoices[index];
                          return _buildMobileInvoiceCard(invoice);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileInvoiceCard(InvoiceModel invoice) {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    final customer = invoice.customerId != null
        ? customerProvider.getCustomerById(invoice.customerId!)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoice: invoice)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  _buildStatusChip(invoice.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                customer?.name ?? 'Unknown Customer',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    '${AppConstants.defaultCurrency}${invoice.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Left side: Invoice list with filters
          Expanded(
            flex: _selectedInvoice == null ? 1 : 2,
            child: _buildInvoiceList(),
          ),

          // Right side: Invoice detail/preview
          if (_selectedInvoice != null)
            Expanded(
              flex: 3,
              child: _buildInvoiceDetail(),
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList() {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        if (invoiceProvider.isLoading && invoiceProvider.invoices.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (invoiceProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${invoiceProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadInvoices,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filteredInvoices = _getFilteredInvoices(invoiceProvider.invoices);

        return Column(
          children: [
            // Header with title and actions
            _buildListHeader(filteredInvoices.length),

            // Bulk operations toolbar
            if (_selectedInvoices.isNotEmpty) _buildBulkOperationsToolbar(),

            // Advanced filtering sidebar
            if (_showFilters) _buildAdvancedFilters(),

            // Invoice table
            Expanded(
              child: _buildInvoiceTable(filteredInvoices),
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
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Invoices',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Chip(
                label: Text('$totalCount'),
                backgroundColor: Colors.blue.shade100,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                tooltip: 'Toggle Filters',
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _createNewInvoice,
                icon: const Icon(Icons.add),
                label: const Text('New Invoice'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search bar
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search invoices...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
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
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedInvoices.length} selected',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: _bulkMarkAsSent,
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Mark as Sent'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _bulkMarkAsPaid,
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Mark as Paid'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _bulkDelete,
            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedInvoices.clear();
              });
            },
            child: const Text('Clear Selection'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    final customerProvider = Provider.of<CustomerProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Advanced Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Status filter
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<InvoiceStatus>(
                  value: _filterStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<InvoiceStatus>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...InvoiceStatus.values.map((status) {
                      return DropdownMenuItem<InvoiceStatus>(
                        value: status,
                        child: Text(_getStatusDisplayName(status)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                  },
                ),
              ),

              // Customer filter
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _filterCustomerId,
                  decoration: const InputDecoration(
                    labelText: 'Customer',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Customers'),
                    ),
                    ...customerProvider.customers.map((customer) {
                      return DropdownMenuItem<String>(
                        value: customer.id,
                        child: Text(customer.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterCustomerId = value;
                    });
                  },
                ),
              ),

              // Date range
              SizedBox(
                width: 150,
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _filterStartDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _filterStartDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'From Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      _filterStartDate != null
                          ? '${_filterStartDate!.day}/${_filterStartDate!.month}/${_filterStartDate!.year}'
                          : 'Select',
                      style: TextStyle(
                        color: _filterStartDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: 150,
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _filterEndDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _filterEndDate = date;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'To Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      _filterEndDate != null
                          ? '${_filterEndDate!.day}/${_filterEndDate!.month}/${_filterEndDate!.year}'
                          : 'Select',
                      style: TextStyle(
                        color: _filterEndDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTable(List<InvoiceModel> invoices) {
    final customerProvider = Provider.of<CustomerProvider>(context);

    return WebDataTable<InvoiceModel>(
      data: invoices,
      selectable: true,
      onSelectionChanged: (selected) {
        setState(() {
          _selectedInvoices.clear();
          _selectedInvoices.addAll(selected);
        });
      },
      onRowTap: (invoice) {
        setState(() {
          _selectedInvoice = invoice;
        });
      },
      columns: [
        WebDataColumn<InvoiceModel>(
          label: 'Invoice #',
          field: 'invoiceNumber',
          width: 150,
          valueGetter: (invoice) => invoice.invoiceNumber,
          cellBuilder: (invoice) => Text(
            invoice.invoiceNumber,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        WebDataColumn<InvoiceModel>(
          label: 'Customer',
          field: 'customer',
          width: 200,
          valueGetter: (invoice) {
            final customer = invoice.customerId != null
                ? customerProvider.getCustomerById(invoice.customerId!)
                : null;
            return customer?.name ?? 'Unknown';
          },
        ),
        WebDataColumn<InvoiceModel>(
          label: 'Date',
          field: 'invoiceDate',
          width: 120,
          valueGetter: (invoice) =>
              '${invoice.invoiceDate.day}/${invoice.invoiceDate.month}/${invoice.invoiceDate.year}',
        ),
        WebDataColumn<InvoiceModel>(
          label: 'Due Date',
          field: 'dueDate',
          width: 120,
          valueGetter: (invoice) => invoice.dueDate != null
              ? '${invoice.dueDate!.day}/${invoice.dueDate!.month}/${invoice.dueDate!.year}'
              : 'N/A',
        ),
        WebDataColumn<InvoiceModel>(
          label: 'Amount',
          field: 'totalAmount',
          width: 120,
          valueGetter: (invoice) => invoice.totalAmount.toStringAsFixed(2),
          cellBuilder: (invoice) => Text(
            '${AppConstants.defaultCurrency}${invoice.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        WebDataColumn<InvoiceModel>(
          label: 'Status',
          field: 'status',
          width: 120,
          valueGetter: (invoice) => _getStatusDisplayName(invoice.status),
          cellBuilder: (invoice) => _buildStatusChip(invoice.status),
        ),
        WebDataColumn<InvoiceModel>(
          label: 'Actions',
          field: 'actions',
          width: 100,
          sortable: false,
          cellBuilder: (invoice) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _editInvoice(invoice),
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => _deleteInvoice(invoice),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceDetail() {
    if (_selectedInvoice == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          // Detail header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Invoice ${_selectedInvoice!.invoiceNumber}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    setState(() {
                      _showPdfPreview = !_showPdfPreview;
                    });
                  },
                  tooltip: 'Toggle PDF Preview',
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editInvoice(_selectedInvoice!),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedInvoice = null;
                    });
                  },
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Detail content
          Expanded(
            child: _showPdfPreview
                ? _buildPdfPreview()
                : _buildInvoiceDetailContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetailContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: InvoiceDetailScreen(invoice: _selectedInvoice!),
    );
  }

  Widget _buildPdfPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'PDF Preview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'PDF preview functionality coming soon',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement PDF generation and download
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF generation coming soon'),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(InvoiceStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case InvoiceStatus.draft:
        color = Colors.grey;
        icon = Icons.edit_note;
        break;
      case InvoiceStatus.sent:
        color = Colors.blue;
        icon = Icons.send;
        break;
      case InvoiceStatus.partiallyPaid:
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case InvoiceStatus.paid:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case InvoiceStatus.overdue:
        color = Colors.red;
        icon = Icons.warning;
        break;
      case InvoiceStatus.cancelled:
        color = Colors.brown;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _getStatusDisplayName(status),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayName(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.partiallyPaid:
        return 'Partial';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _clearFilters() {
    setState(() {
      _filterStatus = null;
      _filterCustomerId = null;
      _filterStartDate = null;
      _filterEndDate = null;
      _filterMinAmount = null;
      _filterMaxAmount = null;
    });
  }

  void _createNewInvoice() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddEditInvoiceScreen(),
      ),
    ).then((_) => _loadInvoices());
  }

  void _editInvoice(InvoiceModel invoice) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditInvoiceScreen(invoice: invoice),
      ),
    ).then((_) => _loadInvoices());
  }

  Future<void> _deleteInvoice(InvoiceModel invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text(
          'Are you sure you want to delete invoice "${invoice.invoiceNumber}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    final success = await invoiceProvider.deleteInvoice(invoice.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Invoice deleted successfully'
                : 'Failed to delete invoice',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success && _selectedInvoice?.id == invoice.id) {
        setState(() {
          _selectedInvoice = null;
        });
      }
    }
  }

  Future<void> _bulkMarkAsSent() async {
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    int successCount = 0;
    for (final invoice in _selectedInvoices) {
      final updatedInvoice = invoice.copyWith(status: InvoiceStatus.sent);
      final success = await invoiceProvider.updateInvoice(updatedInvoice);
      if (success) successCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successCount invoices marked as sent'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedInvoices.clear();
      });
    }
  }

  Future<void> _bulkMarkAsPaid() async {
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    int successCount = 0;
    for (final invoice in _selectedInvoices) {
      final updatedInvoice = invoice.copyWith(
        status: InvoiceStatus.paid,
        paidAmount: invoice.totalAmount,
      );
      final success = await invoiceProvider.updateInvoice(updatedInvoice);
      if (success) successCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successCount invoices marked as paid'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedInvoices.clear();
      });
    }
  }

  Future<void> _bulkDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoices'),
        content: Text(
          'Are you sure you want to delete ${_selectedInvoices.length} invoices?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    int successCount = 0;
    for (final invoice in _selectedInvoices) {
      final success = await invoiceProvider.deleteInvoice(invoice.id);
      if (success) successCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successCount invoices deleted'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedInvoices.clear();
        if (_selectedInvoice != null &&
            _selectedInvoices.contains(_selectedInvoice)) {
          _selectedInvoice = null;
        }
      });
    }
  }
}
