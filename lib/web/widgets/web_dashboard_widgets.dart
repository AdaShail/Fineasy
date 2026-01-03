import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/business_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/invoice_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

/// Business header widget showing business info and status
class WebBusinessHeader extends StatelessWidget {
  const WebBusinessHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessProvider>(
      builder: (context, businessProvider, child) {
        final business = businessProvider.business;
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    business?.name.substring(0, 1).toUpperCase() ?? 'B',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business?.name ?? 'Your Business',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        business?.category ?? 'Business Category',
                        style: const TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi, size: 16, color: AppTheme.successColor),
                      SizedBox(width: 6),
                      Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

/// Financial overview cards showing key metrics
class WebFinancialOverviewCards extends StatelessWidget {
  const WebFinancialOverviewCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, InvoiceProvider>(
      builder: (context, transactionProvider, invoiceProvider, child) {
        final isLoading = transactionProvider.isLoading || invoiceProvider.isLoading;
        
        final transactionIncome = transactionProvider.totalIncome;
        final invoiceRevenue = invoiceProvider.totalRevenue;
        final totalIncome = transactionIncome + invoiceRevenue;
        final totalExpense = transactionProvider.totalExpense;
        final balance = transactionProvider.balance + invoiceRevenue;
        final receivables = invoiceProvider.totalReceivables;
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                  child: _buildMetricCard(
                    'Total Balance',
                    balance,
                    Icons.account_balance_wallet,
                    balance >= 0 ? AppTheme.successColor : AppTheme.errorColor,
                    isLoading: isLoading,
                  ),
                ),
                SizedBox(
                  width: isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                  child: _buildMetricCard(
                    'Total Income',
                    totalIncome,
                    Icons.trending_up,
                    AppTheme.successColor,
                    isLoading: isLoading,
                  ),
                ),
                SizedBox(
                  width: isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                  child: _buildMetricCard(
                    'Total Expenses',
                    totalExpense,
                    Icons.trending_down,
                    AppTheme.errorColor,
                    isLoading: isLoading,
                  ),
                ),
                SizedBox(
                  width: isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                  child: _buildMetricCard(
                    'Receivables',
                    receivables,
                    Icons.call_received,
                    AppTheme.accentColor,
                    isLoading: isLoading,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    double amount,
    IconData icon,
    Color color, {
    bool isLoading = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppConstants.defaultCurrency}${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 28,
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

/// Quick actions panel for common tasks
class WebQuickActionsPanel extends StatelessWidget {
  const WebQuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              icon: Icons.add_circle,
              label: 'Add Transaction',
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/add-transaction'),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.receipt_long,
              label: 'Create Invoice',
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/add-invoice'),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.payment,
              label: 'Record Payment',
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(context, '/add-payment'),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.person_add,
              label: 'Add Customer',
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/add-customer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Financial chart widget showing income vs expenses
class WebFinancialChart extends StatelessWidget {
  final bool isExpanded;
  
  const WebFinancialChart({super.key, this.isExpanded = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Income vs Expenses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/reports'),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View Reports'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: isExpanded ? 300 : 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (transactionProvider.totalIncome > transactionProvider.totalExpense
                          ? transactionProvider.totalIncome
                          : transactionProvider.totalExpense) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${AppConstants.defaultCurrency}${rod.toY.toStringAsFixed(2)}',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('Income', style: TextStyle(fontWeight: FontWeight.w600));
                                case 1:
                                  return const Text('Expenses', style: TextStyle(fontWeight: FontWeight.w600));
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: transactionProvider.totalIncome,
                              color: AppTheme.successColor,
                              width: isExpanded ? 60 : 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: transactionProvider.totalExpense,
                              color: AppTheme.errorColor,
                              width: isExpanded ? 60 : 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
    );
  }
}

/// Cash flow chart widget
class WebCashFlowChart extends StatelessWidget {
  const WebCashFlowChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        // Get last 7 days of data
        final now = DateTime.now();
        final last7Days = List.generate(7, (index) {
          return DateTime(now.year, now.month, now.day - (6 - index));
        });
        
        final dailyData = last7Days.map((date) {
          final dayTransactions = transactionProvider.transactions.where((t) {
            final tDate = DateTime(t.date.year, t.date.month, t.date.day);
            return tDate == date;
          }).toList();
          
          final income = dayTransactions
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (sum, t) => sum + t.amount);
          final expense = dayTransactions
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (sum, t) => sum + t.amount);
          
          return {'date': date, 'income': income, 'expense': expense};
        }).toList();
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cash Flow (Last 7 Days)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < dailyData.length) {
                                final date = dailyData[value.toInt()]['date'] as DateTime;
                                return Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10));
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: dailyData.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value['income'] as double);
                          }).toList(),
                          isCurved: true,
                          color: AppTheme.successColor,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: dailyData.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value['expense'] as double);
                          }).toList(),
                          isCurved: true,
                          color: AppTheme.errorColor,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Income', AppTheme.successColor),
                    const SizedBox(width: 24),
                    _buildLegendItem('Expenses', AppTheme.errorColor),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

/// Recent transactions widget
class WebRecentTransactions extends StatelessWidget {
  final int maxItems;
  
  const WebRecentTransactions({super.key, this.maxItems = 5});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final recentTransactions = transactionProvider.transactions
            .take(maxItems)
            .toList();
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/transactions'),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recentTransactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentTransactions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final transaction = recentTransactions[index];
                      final isIncome = transaction.type == TransactionType.income;
                      final color = isIncome ? AppTheme.successColor : AppTheme.errorColor;
                      
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isIncome ? Icons.trending_up : Icons.trending_down,
                            color: color,
                          ),
                        ),
                        title: Text(
                          transaction.description,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${transaction.paymentMode.toString().split('.').last.toUpperCase()} • ${_formatDate(transaction.date)}',
                        ),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}${AppConstants.defaultCurrency}${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: color,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Pending actions panel
class WebPendingActionsPanel extends StatelessWidget {
  const WebPendingActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        final overdueInvoices = invoiceProvider.invoices
            .where((inv) => 
                (inv.status == InvoiceStatus.sent || inv.status == InvoiceStatus.overdue) && 
                inv.dueDate != null && 
                inv.dueDate!.isBefore(DateTime.now()))
            .length;
        final pendingInvoices = invoiceProvider.invoices
            .where((inv) => inv.status == InvoiceStatus.sent || inv.status == InvoiceStatus.overdue)
            .length;
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pending_actions, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Pending Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (overdueInvoices > 0)
                  _buildPendingItem(
                    context,
                    icon: Icons.warning,
                    title: '$overdueInvoices Overdue Invoices',
                    subtitle: 'Require immediate attention',
                    color: Colors.red,
                    onTap: () => Navigator.pushNamed(context, '/invoices'),
                  ),
                if (pendingInvoices > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildPendingItem(
                      context,
                      icon: Icons.receipt_long,
                      title: '$pendingInvoices Pending Invoices',
                      subtitle: 'Awaiting payment',
                      color: Colors.orange,
                      onTap: () => Navigator.pushNamed(context, '/invoices'),
                    ),
                  ),
                if (overdueInvoices == 0 && pendingInvoices == 0)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'All caught up!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    );
  }

  Widget _buildPendingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w600, color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

/// Top customers widget
class WebTopCustomersWidget extends StatelessWidget {
  const WebTopCustomersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerProvider, InvoiceProvider>(
      builder: (context, customerProvider, invoiceProvider, child) {
        // Calculate top customers by total invoice amount
        final customerTotals = <String, double>{};
        
        for (final invoice in invoiceProvider.invoices) {
          if (invoice.customerId != null) {
            customerTotals[invoice.customerId!] = 
                (customerTotals[invoice.customerId!] ?? 0) + invoice.totalAmount;
          }
        }
        
        final topCustomers = customerTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, color: AppTheme.primaryColor, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Top Customers',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (topCustomers.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No customer data yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ...topCustomers.take(5).map((entry) {
                    final customer = customerProvider.customers
                        .firstWhere((c) => c.id == entry.key, orElse: () => customerProvider.customers.first);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: Text(
                              customer.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  customer.email ?? 'No email',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${AppConstants.defaultCurrency}${entry.value.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successColor),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Invoice status widget
class WebInvoiceStatusWidget extends StatelessWidget {
  const WebInvoiceStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        final paidCount = invoiceProvider.invoices.where((i) => i.status == InvoiceStatus.paid).length;
        final sentCount = invoiceProvider.invoices.where((i) => i.status == InvoiceStatus.sent).length;
        final partialCount = invoiceProvider.invoices.where((i) => i.status == InvoiceStatus.partiallyPaid).length;
        final draftCount = invoiceProvider.invoices.where((i) => i.status == InvoiceStatus.draft).length;
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt, color: AppTheme.primaryColor, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Invoice Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatusItem('Paid', paidCount, Colors.green),
                const SizedBox(height: 12),
                _buildStatusItem('Sent', sentCount, Colors.blue),
                const SizedBox(height: 12),
                _buildStatusItem('Partially Paid', partialCount, Colors.orange),
                const SizedBox(height: 12),
                _buildStatusItem('Draft', draftCount, Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

/// Upcoming payments widget
class WebUpcomingPaymentsWidget extends StatelessWidget {
  const WebUpcomingPaymentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
        final now = DateTime.now();
        final weekFromNow = now.add(const Duration(days: 7));
        
        final upcomingInvoices = invoiceProvider.invoices
            .where((inv) => 
                (inv.status == InvoiceStatus.sent || inv.status == InvoiceStatus.partiallyPaid) && 
                inv.dueDate != null &&
                inv.dueDate!.isAfter(now) &&
                inv.dueDate!.isBefore(weekFromNow))
            .toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: AppTheme.primaryColor, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Due This Week',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (upcomingInvoices.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No upcoming payments',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ...upcomingInvoices.take(3).map((invoice) {
                    final daysUntilDue = invoice.dueDate!.difference(DateTime.now()).inDays;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    invoice.invoiceNumber,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  '${AppConstants.defaultCurrency}${invoice.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Due in $daysUntilDue day${daysUntilDue != 1 ? 's' : ''}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Business insights widget
class WebBusinessInsightsWidget extends StatelessWidget {
  const WebBusinessInsightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, InvoiceProvider>(
      builder: (context, transactionProvider, invoiceProvider, child) {
        final avgTransactionValue = transactionProvider.transactions.isEmpty
            ? 0.0
            : transactionProvider.transactions.fold(0.0, (sum, t) => sum + t.amount) / 
              transactionProvider.transactions.length;
        
        final avgInvoiceValue = invoiceProvider.invoices.isEmpty
            ? 0.0
            : invoiceProvider.invoices.fold(0.0, (sum, i) => sum + i.totalAmount) / 
              invoiceProvider.invoices.length;
        
        final collectionRate = invoiceProvider.invoices.isEmpty
            ? 0.0
            : (invoiceProvider.invoices.where((i) => i.status == InvoiceStatus.paid).length / 
              invoiceProvider.invoices.length) * 100;
        
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.insights, color: AppTheme.primaryColor, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Business Insights',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInsightItem(
                  'Avg Transaction',
                  '${AppConstants.defaultCurrency}${avgTransactionValue.toStringAsFixed(0)}',
                  Icons.swap_horiz,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildInsightItem(
                  'Avg Invoice Value',
                  '${AppConstants.defaultCurrency}${avgInvoiceValue.toStringAsFixed(0)}',
                  Icons.receipt_long,
                  Colors.purple,
                ),
                const SizedBox(height: 16),
                _buildInsightItem(
                  'Collection Rate',
                  '${collectionRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.green,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ],
    );
  }
}
