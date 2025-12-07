import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/business_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../services/pdf_service.dart';
import '../../utils/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? _selectedDateRange;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Default to current month
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
  }

  Future<void> _selectDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );

    if (dateRange != null) {
      setState(() {
        _selectedDateRange = dateRange;
      });
    }
  }

  Future<void> _generateTransactionReport() async {
    if (_selectedDateRange == null) return;

    setState(() => _isGenerating = true);

    try {
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      if (businessProvider.business == null) {
        throw Exception('Business information not found');
      }

      final transactions = transactionProvider.getTransactionsByDateRange(
        _selectedDateRange!.start,
        _selectedDateRange!.end,
      );

      final pdfData = await PdfService.generateTransactionReport(
        business: businessProvider.business!,
        transactions: transactions,
        startDate: _selectedDateRange!.start,
        endDate: _selectedDateRange!.end,
      );

      final fileName =
          'transaction_report_${DateFormat('yyyyMMdd').format(_selectedDateRange!.start)}_${DateFormat('yyyyMMdd').format(_selectedDateRange!.end)}.pdf';

      await _showReportOptions(pdfData, fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateCustomerReport() async {
    setState(() => _isGenerating = true);

    try {
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      final customerProvider = Provider.of<CustomerProvider>(
        context,
        listen: false,
      );

      if (businessProvider.business == null) {
        throw Exception('Business information not found');
      }

      final pdfData = await PdfService.generateCustomerReport(
        business: businessProvider.business!,
        customers: customerProvider.customers,
      );

      final fileName =
          'customer_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

      await _showReportOptions(pdfData, fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateSupplierReport() async {
    setState(() => _isGenerating = true);

    try {
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      final supplierProvider = Provider.of<SupplierProvider>(
        context,
        listen: false,
      );

      if (businessProvider.business == null) {
        throw Exception('Business information not found');
      }

      final pdfData = await PdfService.generateSupplierReport(
        business: businessProvider.business!,
        suppliers: supplierProvider.suppliers,
      );

      final fileName =
          'supplier_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

      await _showReportOptions(pdfData, fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _showReportOptions(Uint8List pdfData, String fileName) async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Report Generated Successfully!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await PdfService.printPdf(pdfData, fileName);
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Print'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await PdfService.sharePdf(pdfData, fileName);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final file = await PdfService.savePdf(pdfData, fileName);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Report saved to ${file.path}'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Save to Device'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Period',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.date_range,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDateRange != null
                                    ? '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'
                                    : 'Select date range',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Report Types
            const Text(
              'Available Reports',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Transaction Report
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppTheme.primaryColor,
                  ),
                ),
                title: const Text(
                  'Transaction Report',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Detailed report of all income and expenses',
                ),
                trailing:
                    _isGenerating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.arrow_forward_ios),
                onTap: _isGenerating ? null : _generateTransactionReport,
              ),
            ),

            const SizedBox(height: 8),

            // Customer Report
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people, color: AppTheme.accentColor),
                ),
                title: const Text(
                  'Customer Report',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'List of all customers with outstanding balances',
                ),
                trailing:
                    _isGenerating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.arrow_forward_ios),
                onTap: _isGenerating ? null : _generateCustomerReport,
              ),
            ),

            const SizedBox(height: 8),

            // Supplier Report
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business, color: AppTheme.errorColor),
                ),
                title: const Text(
                  'Supplier Report',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'List of all suppliers with outstanding balances',
                ),
                trailing:
                    _isGenerating
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.arrow_forward_ios),
                onTap: _isGenerating ? null : _generateSupplierReport,
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats
            Consumer3<TransactionProvider, CustomerProvider, SupplierProvider>(
              builder: (
                context,
                transactionProvider,
                customerProvider,
                supplierProvider,
                child,
              ) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Statistics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                'Total Transactions',
                                transactionProvider.transactions.length
                                    .toString(),
                                Icons.receipt,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                'Total Customers',
                                customerProvider.customers.length.toString(),
                                Icons.people,
                              ),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                'Total Suppliers',
                                supplierProvider.suppliers.length.toString(),
                                Icons.business,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: AppTheme.infoColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.infoColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Report Features',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.infoColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• Generate professional PDF reports\n• Print or share reports instantly\n• Filter by custom date ranges\n• Export for accounting purposes',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.infoColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
