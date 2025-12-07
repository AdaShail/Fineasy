import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/transaction_widgets/quick_transaction_widget.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  Future<void> _refreshData(BuildContext context) async {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final supplierProvider = Provider.of<SupplierProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      final businessId = businessProvider.business!.id;
      await Future.wait([
        transactionProvider.refreshTransactions(businessId),
        invoiceProvider.refreshInvoices(businessId),
        customerProvider.loadCustomers(businessId),
        supplierProvider.loadSuppliers(businessId),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refreshData(context),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Header
            Consumer<BusinessProvider>(
              builder: (context, businessProvider, child) {
                final business = businessProvider.business;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            business?.name.substring(0, 1).toUpperCase() ?? 'B',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                business?.name ??
                                    'Your Business set up is incomplete',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                business?.category ?? 'Business Category',
                                style: const TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.wifi,
                                size: 12,
                                color: AppTheme.successColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Online',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Financial Overview Cards
            Consumer4<
              TransactionProvider,
              InvoiceProvider,
              CustomerProvider,
              SupplierProvider
            >(
              builder: (
                context,
                transactionProvider,
                invoiceProvider,
                customerProvider,
                supplierProvider,
                child,
              ) {
                // Show loading indicator if data is being loaded
                final isLoading =
                    transactionProvider.isLoading || invoiceProvider.isLoading;

                // Calculate total income including paid invoices (revenue)
                // Only paid invoices, excluding draft and cancelled
                final transactionIncome = transactionProvider.totalIncome;
                final invoiceRevenue = invoiceProvider.totalRevenue;
                final totalIncome = transactionIncome + invoiceRevenue;

                if (isLoading && transactionProvider.transactions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildFinancialCard(
                        'Total Balance',
                        transactionProvider.balance + invoiceRevenue,
                        Icons.account_balance_wallet,
                        (transactionProvider.balance + invoiceRevenue) >= 0
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        isLoading: isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFinancialCard(
                        'Income',
                        totalIncome,
                        Icons.trending_up,
                        AppTheme.successColor,
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            Consumer4<
              TransactionProvider,
              InvoiceProvider,
              CustomerProvider,
              SupplierProvider
            >(
              builder: (
                context,
                transactionProvider,
                invoiceProvider,
                customerProvider,
                supplierProvider,
                child,
              ) {
                // Calculate receivables from unpaid and partially paid invoices only
                final receivables = invoiceProvider.totalReceivables;
                final isLoadingReceivables = invoiceProvider.isLoading;

                return Row(
                  children: [
                    Expanded(
                      child: _buildFinancialCard(
                        'Expenses',
                        transactionProvider.totalExpense,
                        Icons.trending_down,
                        AppTheme.errorColor,
                        isLoading: transactionProvider.isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFinancialCard(
                        'Receivables',
                        receivables,
                        Icons.call_received,
                        AppTheme.accentColor,
                        isLoading: isLoadingReceivables,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Transaction Widget
            const QuickTransactionWidget(),

            const SizedBox(height: 24),

            // AI Insights Section
            // Consumer2<BusinessProvider, InsightsProvider>(
            //   builder: (context, businessProvider, insightsProvider, child) {
            //     return Column(
            //       children: [
            //         PredictiveInsightsWidget(
            //           insights: insightsProvider.insights,
            //           isLoading: insightsProvider.isLoading,
            //           error: insightsProvider.error,
            //           onRefresh:
            //               businessProvider.business != null
            //                   ? () => insightsProvider.refreshInsights(
            //                     businessProvider.business!.id,
            //                   )
            //                   : null,
            //           onInsightTap: (insight) {
            //             Navigator.of(context).push(
            //               MaterialPageRoute(
            //                 builder:
            //                     (_) => InsightsDetailScreen(insight: insight),
            //               ),
            //             );
            //           },
            //         ),
            //         if (insightsProvider.insights.isNotEmpty) ...[
            //           const SizedBox(height: 8),
            //           Align(
            //             alignment: Alignment.centerRight,
            //             child: TextButton.icon(
            //               onPressed: () {
            //                 Navigator.of(context).push(
            //                   MaterialPageRoute(
            //                     builder: (_) => const InsightsScreen(),
            //                   ),
            //                 );
            //               },
            //               icon: const Icon(Icons.arrow_forward, size: 16),
            //               label: const Text('View All Insights'),
            //             ),
            //           ),
            //         ],
            //       ],
            //     );
            //   },
            // ),
            const SizedBox(height: 24),

            // Chart Section
            const Text(
              'Financial Trends',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Income vs Expenses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY:
                                  (transactionProvider.totalIncome >
                                          transactionProvider.totalExpense
                                      ? transactionProvider.totalIncome
                                      : transactionProvider.totalExpense) *
                                  1.2,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text('Income');
                                        case 1:
                                          return const Text('Expenses');
                                        default:
                                          return const Text('');
                                      }
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: transactionProvider.totalIncome,
                                      color: AppTheme.successColor,
                                      width: 40,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: transactionProvider.totalExpense,
                                      color: AppTheme.errorColor,
                                      width: 40,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Recent Transactions
            const Text(
              'Today\'s Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                // Get today's transactions with real-time updates
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final todayTransactions =
                    transactionProvider.transactions.where((t) {
                        final transactionDate = DateTime(
                          t.date.year,
                          t.date.month,
                          t.date.day,
                        );
                        return transactionDate == today;
                      }).toList()
                      ..sort(
                        (a, b) => b.date.compareTo(a.date),
                      ); // Sort by newest first

                if (todayTransactions.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions today',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first transaction to get started',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        todayTransactions.length > 5
                            ? 5
                            : todayTransactions.length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final transaction = todayTransactions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              transaction.type.toString().contains('income')
                                  ? AppTheme.successColor.withValues(alpha: 0.1)
                                  : AppTheme.errorColor.withValues(alpha: 0.1),
                          child: Icon(
                            transaction.type.toString().contains('income')
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color:
                                transaction.type.toString().contains('income')
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                          ),
                        ),
                        title: Text(transaction.description),
                        subtitle: Text(
                          '${transaction.paymentMode.toString().split('.').last.toUpperCase()} • ${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: Text(
                          '${transaction.type.toString().contains('income') ? '+' : '-'}${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                transaction.type.toString().contains('income')
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(
    String title,
    double amount,
    IconData icon,
    Color color, {
    bool isLoading = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${AppConstants.defaultCurrency}${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
