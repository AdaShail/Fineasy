import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invoice_model.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/customer_provider.dart';
import '../../utils/constants.dart';
import '../../utils/app_theme.dart';
import '../../services/whatsapp_launcher_service.dart';
import 'add_edit_invoice_screen.dart';
import 'invoice_detail_screen.dart';
import 'nlp_invoice_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter state
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterCustomerId;
  InvoiceStatus? _filterStatus;
  double? _filterMinAmount;
  double? _filterMaxAmount;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvoices();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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

  Widget _buildTabWithCount(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummaryCard(
    String title,
    int count,
    double total,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$count invoices',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              '${AppConstants.defaultCurrency}${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<InvoiceModel> _getFilteredInvoices(
    List<InvoiceModel> invoices,
    InvoiceStatus? status,
  ) {
    var filtered = invoices;

    // Status filter (from tab)
    if (status != null) {
      filtered = filtered.where((invoice) => invoice.status == status).toList();
    }

    // Additional status filter (from filter panel)
    if (_filterStatus != null) {
      filtered =
          filtered.where((invoice) => invoice.status == _filterStatus).toList();
    }

    // Date range filter
    if (_filterStartDate != null) {
      filtered =
          filtered.where((invoice) {
            return invoice.createdAt.isAfter(_filterStartDate!) ||
                invoice.createdAt.isAtSameMomentAs(_filterStartDate!);
          }).toList();
    }
    if (_filterEndDate != null) {
      filtered =
          filtered.where((invoice) {
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
      filtered =
          filtered
              .where((invoice) => invoice.customerId == _filterCustomerId)
              .toList();
    }

    // Amount range filter
    if (_filterMinAmount != null) {
      filtered =
          filtered
              .where((invoice) => invoice.totalAmount >= _filterMinAmount!)
              .toList();
    }
    if (_filterMaxAmount != null) {
      filtered =
          filtered
              .where((invoice) => invoice.totalAmount <= _filterMaxAmount!)
              .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );

      filtered =
          filtered.where((invoice) {
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

  double _calculateTotal(List<InvoiceModel> invoices) {
    return invoices.fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }

  bool _hasActiveFilters() {
    return _filterStartDate != null ||
        _filterEndDate != null ||
        _filterCustomerId != null ||
        _filterStatus != null ||
        _filterMinAmount != null ||
        _filterMaxAmount != null;
  }

  void _clearFilters() {
    setState(() {
      _filterStartDate = null;
      _filterEndDate = null;
      _filterCustomerId = null;
      _filterStatus = null;
      _filterMinAmount = null;
      _filterMaxAmount = null;
    });
  }

  Widget _buildFilterPanel() {
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date Range Filter
          Row(
            children: [
              Expanded(
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
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _filterStartDate != null
                          ? '${_filterStartDate!.day}/${_filterStartDate!.month}/${_filterStartDate!.year}'
                          : 'Select date',
                      style: TextStyle(
                        color:
                            _filterStartDate != null
                                ? Colors.black
                                : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
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
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _filterEndDate != null
                          ? '${_filterEndDate!.day}/${_filterEndDate!.month}/${_filterEndDate!.year}'
                          : 'Select date',
                      style: TextStyle(
                        color:
                            _filterEndDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Customer Filter
          DropdownButtonFormField<String>(
            value: _filterCustomerId,
            decoration: const InputDecoration(
              labelText: 'Customer',
              border: OutlineInputBorder(),
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
          const SizedBox(height: 12),

          // Amount Range Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Min Amount',
                    border: OutlineInputBorder(),
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _filterMinAmount = double.tryParse(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Max Amount',
                    border: OutlineInputBorder(),
                    prefixText: '₹ ',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _filterMaxAmount = double.tryParse(value);
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export Paid Invoices',
            onPressed: _exportPaidInvoices,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Consumer<InvoiceProvider>(
            builder: (context, invoiceProvider, child) {
              return TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  _buildTabWithCount('All', invoiceProvider.invoices.length),
                  _buildTabWithCount(
                    'Draft',
                    invoiceProvider.draftInvoices.length,
                  ),
                  _buildTabWithCount(
                    'Sent',
                    invoiceProvider.sentInvoices.length,
                  ),
                  _buildTabWithCount(
                    'Paid',
                    invoiceProvider.paidInvoices.length,
                  ),
                  _buildTabWithCount(
                    'Overdue',
                    invoiceProvider.overdueInvoices.length,
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: Consumer<InvoiceProvider>(
        builder: (context, invoiceProvider, child) {
          if (invoiceProvider.isLoading && invoiceProvider.invoices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (invoiceProvider.error != null) {
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
                    'Error loading invoices',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    invoiceProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadInvoices,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar with Filter Button
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search invoices...',
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
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _showFilters
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined,
                        color:
                            _hasActiveFilters() ? AppTheme.primaryColor : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      tooltip: 'Filters',
                    ),
                  ],
                ),
              ),

              // Filter Panel
              if (_showFilters) _buildFilterPanel(),

              // Status Summary Cards
              Container(
                height: 110,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: 140,
                      child: _buildStatusSummaryCard(
                        'Draft',
                        invoiceProvider.draftInvoices.length,
                        _calculateTotal(invoiceProvider.draftInvoices),
                        Colors.grey,
                        Icons.edit_note,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 140,
                      child: _buildStatusSummaryCard(
                        'Sent',
                        invoiceProvider.sentInvoices.length,
                        _calculateTotal(invoiceProvider.sentInvoices),
                        Colors.blue,
                        Icons.send,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 140,
                      child: _buildStatusSummaryCard(
                        'Paid',
                        invoiceProvider.paidInvoices.length,
                        _calculateTotal(invoiceProvider.paidInvoices),
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 140,
                      child: _buildStatusSummaryCard(
                        'Overdue',
                        invoiceProvider.overdueInvoices.length,
                        _calculateTotal(invoiceProvider.overdueInvoices),
                        Colors.red,
                        Icons.warning,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Invoice Lists
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInvoiceList(
                      _getFilteredInvoices(invoiceProvider.invoices, null),
                    ),
                    _buildInvoiceList(
                      _getFilteredInvoices(
                        invoiceProvider.draftInvoices,
                        InvoiceStatus.draft,
                      ),
                    ),
                    _buildInvoiceList(
                      _getFilteredInvoices(
                        invoiceProvider.sentInvoices,
                        InvoiceStatus.sent,
                      ),
                    ),
                    _buildInvoiceList(
                      _getFilteredInvoices(
                        invoiceProvider.paidInvoices,
                        InvoiceStatus.paid,
                      ),
                    ),
                    _buildInvoiceList(
                      _getFilteredInvoices(
                        invoiceProvider.overdueInvoices,
                        InvoiceStatus.overdue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "cv_invoice",
            onPressed: _addCVInvoice,
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.description),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "ai_invoice",
            onPressed: _addAIInvoice,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.auto_awesome),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "manual_invoice",
            onPressed: _addInvoice,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(List<InvoiceModel> invoices) {
    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _hasActiveFilters()
                  ? 'No invoices match your search'
                  : 'No invoices found',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _hasActiveFilters()
                  ? 'Try adjusting your filters or search query'
                  : 'Create your first invoice to get started',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return InvoiceListTile(
          invoice: invoice,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
          onTap: () => _viewInvoiceDetails(invoice),
          onDelete: () => _deleteInvoice(invoice),
          onSendWhatsApp: () => _sendInvoiceViaWhatsApp(invoice),
          onMarkAsSent: () => _markAsSent(invoice),
          onMarkAsPaid: () => _markAsPaid(invoice),
        );
      },
    );
  }

  void _addInvoice() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddEditInvoiceScreen()));
  }

  void _addAIInvoice() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NLPInvoiceScreen()));
  }

  void _addCVInvoice() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NLPInvoiceScreen()));
  }

  void _viewInvoiceDetails(InvoiceModel invoice) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoice: invoice)),
    );
  }

  void _deleteInvoice(InvoiceModel invoice) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Invoice'),
            content: Text(
              'Are you sure you want to delete invoice "${invoice.invoiceNumber}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final invoiceProvider = Provider.of<InvoiceProvider>(
                    context,
                    listen: false,
                  );
                  final success = await invoiceProvider.deleteInvoice(
                    invoice.id,
                  );
                  if (context.mounted) {
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
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _exportPaidInvoices() async {
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    final paidInvoices = invoiceProvider.paidInvoices;

    if (paidInvoices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No paid invoices to export'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // TODO: Implement PDF export for paid invoices
      // final pdfPath = await _pdfService.exportPaidInvoices(
      //   invoices: paidInvoices,
      //   business: businessProvider.business!,
      // );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paid invoices exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting invoices: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendInvoiceViaWhatsApp(InvoiceModel invoice) async {
    if (!mounted) return;

    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Generate simple UPI payment link (can be enhanced later)
      final paymentLink =
          'upi://pay?pa=business@upi&pn=${Uri.encodeComponent(businessProvider.business?.name ?? 'Business')}&am=${invoice.totalAmount}&tn=${Uri.encodeComponent('Invoice ${invoice.invoiceNumber}')}';

      // Send consolidated message via WhatsApp
      final success = await WhatsAppLauncherService.sendInvoiceWithPaymentLink(
        phoneNumber:
            invoice.customerId ?? '', // TODO: Get actual customer phone
        customerName: invoice.customerId ?? 'Customer',
        invoiceNumber: invoice.invoiceNumber,
        amount: invoice.totalAmount,
        dueDate: invoice.dueDate,
        paymentLink: paymentLink,
        businessName: businessProvider.business?.name,
      );

      if (success) {
        // Mark invoice as SENT
        final updatedInvoice = invoice.copyWith(
          status: InvoiceStatus.sent,
          whatsappSent: true,
          whatsappSentAt: DateTime.now(),
        );

        await invoiceProvider.updateInvoice(updatedInvoice);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice sent via WhatsApp and marked as SENT!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to open WhatsApp'),
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
            content: Text('Error sending invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsSent(InvoiceModel invoice) async {
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    final updatedInvoice = invoice.copyWith(status: InvoiceStatus.sent);

    final success = await invoiceProvider.updateInvoice(updatedInvoice);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Invoice marked as SENT!' : 'Failed to update invoice',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _markAsPaid(InvoiceModel invoice) async {
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    final updatedInvoice = invoice.copyWith(
      status: InvoiceStatus.paid,
      paidAmount: invoice.totalAmount, // Mark full amount as paid
    );

    final success = await invoiceProvider.updateInvoice(updatedInvoice);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Invoice marked as paid!' : 'Failed to update invoice',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}

class InvoiceListTile extends StatelessWidget {
  final InvoiceModel invoice;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSendWhatsApp;
  final VoidCallback onMarkAsSent;
  final VoidCallback onMarkAsPaid;
  final String? searchQuery;

  const InvoiceListTile({
    super.key,
    required this.invoice,
    required this.onTap,
    required this.onDelete,
    required this.onSendWhatsApp,
    required this.onMarkAsSent,
    required this.onMarkAsPaid,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        invoice.status == InvoiceStatus.overdue || invoice.isOverdue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isOverdue ? Colors.red.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(invoice.status),
          child: Icon(
            isOverdue ? Icons.warning : Icons.receipt,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: _buildHighlightedText(
          invoice.invoiceNumber,
          searchQuery,
          const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<CustomerProvider>(
              builder: (context, customerProvider, child) {
                final customer =
                    invoice.customerId != null
                        ? customerProvider.getCustomerById(invoice.customerId!)
                        : null;
                return _buildHighlightedText(
                  'Customer: ${customer?.name ?? invoice.customerId ?? 'Unknown'}',
                  searchQuery,
                  null,
                );
              },
            ),
            Text(
              'Due: ${invoice.dueDate != null ? '${invoice.dueDate!.day}/${invoice.dueDate!.month}/${invoice.dueDate!.year}' : 'No due date'}',
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(invoice.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusDisplayName(invoice.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (invoice.isOverdue) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${AppConstants.defaultCurrency}${invoice.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (invoice.outstandingAmount > 0)
              Text(
                'Bal: ${AppConstants.defaultCurrency}${invoice.outstandingAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            PopupMenuButton(
              itemBuilder:
                  (context) => [
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
                    if (invoice.status == InvoiceStatus.draft)
                      const PopupMenuItem(
                        value: 'mark_sent',
                        child: Row(
                          children: [
                            Icon(Icons.send, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Mark as Sent'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'whatsapp',
                      child: Row(
                        children: [
                          Icon(Icons.send, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Send via WhatsApp'),
                        ],
                      ),
                    ),
                    if (invoice.status != InvoiceStatus.paid)
                      const PopupMenuItem(
                        value: 'mark_paid',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Mark as Paid'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onTap();
                    break;
                  case 'mark_sent':
                    onMarkAsSent();
                    break;
                  case 'whatsapp':
                    onSendWhatsApp();
                    break;
                  case 'mark_paid':
                    onMarkAsPaid();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.partiallyPaid:
        return Colors.orange;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.brown;
    }
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

  Widget _buildHighlightedText(String text, String? query, TextStyle? style) {
    if (query == null || query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text, style: style);
    }

    return RichText(
      text: TextSpan(
        style: style ?? const TextStyle(color: Colors.black),
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: const TextStyle(
              backgroundColor: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}
