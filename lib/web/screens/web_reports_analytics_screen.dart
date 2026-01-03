import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/business_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../services/pdf_service.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../models/transaction_model.dart';
import '../../models/invoice_model.dart';
import '../../screens/reports/reports_screen.dart';

/// Web-optimized reports and analytics screen with full-screen charts,
/// interactive dashboards, custom report builder, and export capabilities
class WebReportsAnalyticsScreen extends StatefulWidget {
  const WebReportsAnalyticsScreen({super.key});

  @override
  State<WebReportsAnalyticsScreen> createState() => _WebReportsAnalyticsScreenState();
}

class _WebReportsAnalyticsScreenState extends State<WebReportsAnalyticsScreen> {
  DateTimeRange? _selectedDateRange;
  bool _isGenerating = false;
  String _selectedReportType = 'overview';
  String _selectedChartView = 'bar';
  bool _isFullScreen = false;

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

  @override
  Widget build(BuildContext context) {
    // Use mobile reports screen for non-web platforms
    if (!kIsWeb) {
      return const ReportsScreen();
    }

    return ResponsiveLayout(
      mobile: _buildMobileReports(),
      tablet: _buildTabletReports(),
      desktop: _buildDesktopReports(),
    );
  }

  // Mobile web layout
  Widget _buildMobileReports() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const SizedBox(height: 16),
            _buildQuickStats(),
            const SizedBox(height: 16),
            _buildFinancialChart(),
            const SizedBox(height: 16),
            _buildReportTypeSelector(),
            const SizedBox(height: 16),
            _buildReportActions(),
          ],
        ),
      ),
    );
  }

  // Tablet layout
  Widget _buildTabletReports() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
          ),
        ],
      ),
      body: Row(
        children: [
          if (!_isFullScreen)
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(right: BorderSide(color: Colors.grey[300]!)),
              ),
              child: _buildSidebar(),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeSelector(),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildFinancialChart(),
                  const SizedBox(height: 24),
                  _buildReportActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Desktop layout with full features
  Widget _buildDesktopReports() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
            tooltip: _isFullScreen ? 'Exit Full Screen' : 'Full Screen',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Sidebar for report types and filters
          if (!_isFullScreen)
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(right: BorderSide(color: Colors.grey[300]!)),
              ),
              child: _buildSidebar(),
            ),
          
          // Main content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date range and export controls
                  Row(
                    children: [
                      Expanded(child: _buildDateRangeSelector()),
                      const SizedBox(width: 16),
                      _buildExportButton(),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Quick stats overview
                  _buildQuickStats(),
                  const SizedBox(height: 32),
                  
                  // Interactive charts section
                  _buildInteractiveCharts(),
                  const SizedBox(height: 32),
                  
                  // Detailed analytics
                  _buildDetailedAnalytics(),
                  const SizedBox(height: 32),
                  
                  // Report generation section
                  _buildReportActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sidebar with report types and filters
  Widget _buildSidebar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Types',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // const SizedBox(height: 16),
          // _buildReportTypeButton('overview', 'Overview', Icons.dashboard),
          // _buildReportTypeButton('transactions', 'Transactions', Icons.receipt_long),
          // _buildReportTypeButton('invoices', 'Invoices', Icons.description),
          // _buildReportTypeButton('customers', 'Customers', Icons.people),
          // _buildReportTypeButton('suppliers', 'Suppliers', Icons.business),
          // _buildReportTypeButton('cashflow', 'Cash Flow', Icons.trending_up),
          // _buildReportTypeButton('profitloss', 'Profit & Loss', Icons.analytics),
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          
          const Text(
            'Chart View',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildChartViewButton('bar', 'Bar Chart', Icons.bar_chart),
          _buildChartViewButton('line', 'Line Chart', Icons.show_chart),
          _buildChartViewButton('pie', 'Pie Chart', Icons.pie_chart),
          _buildChartViewButton('area', 'Area Chart', Icons.area_chart),
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          
          // Quick date range presets
          const Text(
            'Quick Ranges',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildQuickRangeButton('This Month', () => _setDateRange(0)),
          _buildQuickRangeButton('Last Month', () => _setDateRange(1)),
          _buildQuickRangeButton('This Quarter', () => _setQuarterRange(0)),
          _buildQuickRangeButton('Last Quarter', () => _setQuarterRange(1)),
          _buildQuickRangeButton('This Year', () => _setYearRange(0)),
          _buildQuickRangeButton('Last Year', () => _setYearRange(1)),
        ],
      ),
    );
  }

  Widget _buildReportTypeButton(String type, String label, IconData icon) {
    final isSelected = _selectedReportType == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedReportType = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? AppTheme.primaryColor : Colors.grey[700]),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartViewButton(String view, String label, IconData icon) {
    final isSelected = _selectedChartView == view;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedChartView = view),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.accentColor : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? AppTheme.accentColor : Colors.grey[700]),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.accentColor : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRangeButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 40),
          alignment: Alignment.centerLeft,
        ),
        child: Text(label),
      ),
    );
  }

  // Date range selector
  Widget _buildDateRangeSelector() {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _selectDateRange,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.date_range, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report Period',
                      style: TextStyle(fontSize: 14, color: AppTheme.secondaryTextColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDateRange != null
                          ? '${DateFormat('dd MMM yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}'
                          : 'Select date range',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: AppTheme.secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }

  // Quick stats overview
  Widget _buildQuickStats() {
    return Consumer3<TransactionProvider, InvoiceProvider, CustomerProvider>(
      builder: (context, transactionProvider, invoiceProvider, customerProvider, child) {
        // Filter data by date range
        final filteredTransactions = _selectedDateRange != null
            ? transactionProvider.transactions.where((t) =>
                t.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                t.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))).toList()
            : transactionProvider.transactions;

        final filteredInvoices = _selectedDateRange != null
            ? invoiceProvider.invoices.where((i) =>
                i.createdAt.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                i.createdAt.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))).toList()
            : invoiceProvider.invoices;

        final income = filteredTransactions
            .where((t) => t.type == TransactionType.income)
            .fold(0.0, (sum, t) => sum + t.amount);
        final expense = filteredTransactions
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.amount);
        final revenue = filteredInvoices.fold(0.0, (sum, i) => sum + i.totalAmount);
        final profit = income + revenue - expense;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;
            final cardWidth = isDesktop
                ? (constraints.maxWidth - 96) / 4
                : (constraints.maxWidth - 16) / 2;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard('Total Revenue', income + revenue, Icons.attach_money, AppTheme.successColor),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard('Total Expenses', expense, Icons.money_off, AppTheme.errorColor),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard('Net Profit', profit, Icons.trending_up, profit >= 0 ? AppTheme.successColor : AppTheme.errorColor),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard('Transactions', filteredTransactions.length.toDouble(), Icons.receipt, AppTheme.primaryColor),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, double value, IconData icon, Color color) {
    final isCount = title.contains('Transactions') || title.contains('Invoices') || title.contains('Customers');
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: AppTheme.secondaryTextColor),
            ),
            const SizedBox(height: 8),
            Text(
              isCount
                  ? value.toInt().toString()
                  : '${AppConstants.defaultCurrency}${value.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // Interactive charts section
  Widget _buildInteractiveCharts() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Financial Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'bar', label: Text('Bar'), icon: Icon(Icons.bar_chart, size: 16)),
                    ButtonSegment(value: 'line', label: Text('Line'), icon: Icon(Icons.show_chart, size: 16)),
                    ButtonSegment(value: 'pie', label: Text('Pie'), icon: Icon(Icons.pie_chart, size: 16)),
                  ],
                  selected: {_selectedChartView},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => _selectedChartView = newSelection.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: _isFullScreen ? 500 : 400,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (_selectedChartView) {
      case 'line':
        return _buildLineChart();
      case 'pie':
        return _buildPieChart();
      case 'area':
        return _buildAreaChart();
      default:
        return _buildBarChart();
    }
  }

  Widget _buildBarChart() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final filteredTransactions = _selectedDateRange != null
            ? transactionProvider.transactions.where((t) =>
                t.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                t.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))).toList()
            : transactionProvider.transactions;

        final income = filteredTransactions
            .where((t) => t.type == TransactionType.income)
            .fold(0.0, (sum, t) => sum + t.amount);
        final expense = filteredTransactions
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.amount);

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (income > expense ? income : expense) * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${AppConstants.defaultCurrency}${rod.toY.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('Income', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        );
                      case 1:
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('Expenses', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        );
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
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: income,
                    color: AppTheme.successColor,
                    width: 80,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: expense,
                    color: AppTheme.errorColor,
                    width: 80,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineChart() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        // Get daily data for the selected range
        final days = _selectedDateRange != null
            ? _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays + 1
            : 30;
        
        final startDate = _selectedDateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
        
        final dailyData = List.generate(days, (index) {
          final date = startDate.add(Duration(days: index));
          final dayTransactions = transactionProvider.transactions.where((t) {
            final tDate = DateTime(t.date.year, t.date.month, t.date.day);
            final checkDate = DateTime(date.year, date.month, date.day);
            return tDate == checkDate;
          }).toList();
          
          final income = dayTransactions
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (sum, t) => sum + t.amount);
          final expense = dayTransactions
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (sum, t) => sum + t.amount);
          
          return {'date': date, 'income': income, 'expense': expense};
        });

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: days > 15 ? (days / 7).ceilToDouble() : 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < dailyData.length) {
                      final date = dailyData[value.toInt()]['date'] as DateTime;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 12)),
                      );
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
                barWidth: 4,
                dotData: FlDotData(show: days <= 15),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: dailyData.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value['expense'] as double);
                }).toList(),
                isCurved: true,
                color: AppTheme.errorColor,
                barWidth: 4,
                dotData: FlDotData(show: days <= 15),
                belowBarData: BarAreaData(show: false),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${AppConstants.defaultCurrency}${spot.y.toStringAsFixed(2)}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieChart() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final filteredTransactions = _selectedDateRange != null
            ? transactionProvider.transactions.where((t) =>
                t.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                t.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))).toList()
            : transactionProvider.transactions;

        final income = filteredTransactions
            .where((t) => t.type == TransactionType.income)
            .fold(0.0, (sum, t) => sum + t.amount);
        final expense = filteredTransactions
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (sum, t) => sum + t.amount);

        final total = income + expense;
        if (total == 0) {
          return const Center(child: Text('No data available'));
        }

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 80,
                  sections: [
                    PieChartSectionData(
                      value: income,
                      title: '${(income / total * 100).toStringAsFixed(1)}%',
                      color: AppTheme.successColor,
                      radius: 120,
                      titleStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: expense,
                      title: '${(expense / total * 100).toStringAsFixed(1)}%',
                      color: AppTheme.errorColor,
                      radius: 120,
                      titleStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem('Income', income, AppTheme.successColor),
                  const SizedBox(height: 16),
                  _buildLegendItem('Expenses', expense, AppTheme.errorColor),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAreaChart() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final days = _selectedDateRange != null
            ? _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays + 1
            : 30;
        
        final startDate = _selectedDateRange?.start ?? DateTime.now().subtract(const Duration(days: 30));
        
        final dailyData = List.generate(days, (index) {
          final date = startDate.add(Duration(days: index));
          final dayTransactions = transactionProvider.transactions.where((t) {
            final tDate = DateTime(t.date.year, t.date.month, t.date.day);
            final checkDate = DateTime(date.year, date.month, date.day);
            return tDate == checkDate;
          }).toList();
          
          final income = dayTransactions
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (sum, t) => sum + t.amount);
          
          return {'date': date, 'income': income};
        });

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: days > 15 ? (days / 7).ceilToDouble() : 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < dailyData.length) {
                      final date = dailyData[value.toInt()]['date'] as DateTime;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 12)),
                      );
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
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppTheme.successColor.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(
                '${AppConstants.defaultCurrency}${value.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Detailed analytics section
  Widget _buildDetailedAnalytics() {
    return Consumer3<TransactionProvider, InvoiceProvider, CustomerProvider>(
      builder: (context, transactionProvider, invoiceProvider, customerProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'Transaction Analysis',
                    Icons.analytics,
                    AppTheme.primaryColor,
                    [
                      _buildAnalyticsRow('Total Transactions', transactionProvider.transactions.length.toString()),
                      _buildAnalyticsRow('Avg Transaction', '${AppConstants.defaultCurrency}${transactionProvider.transactions.isEmpty ? 0 : (transactionProvider.transactions.fold(0.0, (sum, t) => sum + t.amount) / transactionProvider.transactions.length).toStringAsFixed(2)}'),
                      _buildAnalyticsRow('Largest Transaction', '${AppConstants.defaultCurrency}${transactionProvider.transactions.isEmpty ? 0 : transactionProvider.transactions.map((t) => t.amount).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Invoice Analysis',
                    Icons.receipt_long,
                    AppTheme.accentColor,
                    [
                      _buildAnalyticsRow('Total Invoices', invoiceProvider.invoices.length.toString()),
                      _buildAnalyticsRow('Paid Invoices', invoiceProvider.invoices.where((i) => i.status == InvoiceStatus.paid).length.toString()),
                      _buildAnalyticsRow('Collection Rate', '${invoiceProvider.invoices.isEmpty ? 0 : ((invoiceProvider.invoices.where((i) => i.status == InvoiceStatus.paid).length / invoiceProvider.invoices.length) * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Customer Analysis',
                    Icons.people,
                    AppTheme.successColor,
                    [
                      _buildAnalyticsRow('Total Customers', customerProvider.customers.length.toString()),
                      _buildAnalyticsRow('Active Customers', customerProvider.customers.where((c) => c.balance > 0).length.toString()),
                      _buildAnalyticsRow('Avg Customer Value', '${AppConstants.defaultCurrency}${customerProvider.customers.isEmpty ? 0 : (customerProvider.customers.fold(0.0, (sum, c) => sum + c.balance) / customerProvider.customers.length).toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsCard(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.secondaryTextColor)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }

  // Report actions section
  Widget _buildReportActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildReportActionButton(
                  'Transaction Report',
                  'Detailed report of all income and expenses',
                  Icons.receipt_long,
                  AppTheme.primaryColor,
                  _generateTransactionReport,
                ),
                _buildReportActionButton(
                  'Customer Report',
                  'List of all customers with balances',
                  Icons.people,
                  AppTheme.accentColor,
                  _generateCustomerReport,
                ),
                _buildReportActionButton(
                  'Supplier Report',
                  'List of all suppliers with balances',
                  Icons.business,
                  AppTheme.errorColor,
                  _generateSupplierReport,
                ),
                _buildReportActionButton(
                  'Financial Summary',
                  'Complete financial overview',
                  Icons.summarize,
                  AppTheme.successColor,
                  _generateFinancialSummary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 1,
        child: InkWell(
          onTap: _isGenerating ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const Spacer(),
                    if (_isGenerating)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(Icons.arrow_forward, color: color),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: AppTheme.secondaryTextColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Overview'),
                  selected: _selectedReportType == 'overview',
                  onSelected: (selected) => setState(() => _selectedReportType = 'overview'),
                ),
                ChoiceChip(
                  label: const Text('Transactions'),
                  selected: _selectedReportType == 'transactions',
                  onSelected: (selected) => setState(() => _selectedReportType = 'transactions'),
                ),
                ChoiceChip(
                  label: const Text('Invoices'),
                  selected: _selectedReportType == 'invoices',
                  onSelected: (selected) => setState(() => _selectedReportType = 'invoices'),
                ),
                ChoiceChip(
                  label: const Text('Customers'),
                  selected: _selectedReportType == 'customers',
                  onSelected: (selected) => setState(() => _selectedReportType = 'customers'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.download),
      tooltip: 'Export Report',
      onSelected: (format) => _exportReport(format),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf), SizedBox(width: 8), Text('Export as PDF')])),
        const PopupMenuItem(value: 'csv', child: Row(children: [Icon(Icons.table_chart), SizedBox(width: 8), Text('Export as CSV')])),
        const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.grid_on), SizedBox(width: 8), Text('Export as Excel')])),
      ],
    );
  }

  // Helper methods
  Future<void> _selectDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );

    if (dateRange != null && mounted) {
      setState(() => _selectedDateRange = dateRange);
    }
  }

  void _setDateRange(int monthsAgo) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month - monthsAgo, 1);
    setState(() {
      _selectedDateRange = DateTimeRange(
        start: targetMonth,
        end: DateTime(targetMonth.year, targetMonth.month + 1, 0),
      );
    });
  }

  void _setQuarterRange(int quartersAgo) {
    final now = DateTime.now();
    final currentQuarter = ((now.month - 1) / 3).floor();
    final targetQuarter = currentQuarter - quartersAgo;
    final targetYear = now.year + (targetQuarter < 0 ? -1 : 0);
    final adjustedQuarter = targetQuarter < 0 ? targetQuarter + 4 : targetQuarter;
    
    final startMonth = adjustedQuarter * 3 + 1;
    setState(() {
      _selectedDateRange = DateTimeRange(
        start: DateTime(targetYear, startMonth, 1),
        end: DateTime(targetYear, startMonth + 3, 0),
      );
    });
  }

  void _setYearRange(int yearsAgo) {
    final now = DateTime.now();
    final targetYear = now.year - yearsAgo;
    setState(() {
      _selectedDateRange = DateTimeRange(
        start: DateTime(targetYear, 1, 1),
        end: DateTime(targetYear, 12, 31),
      );
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    
    if (businessProvider.business != null) {
      final businessId = businessProvider.business!.id;
      
      await Future.wait([
        Provider.of<TransactionProvider>(context, listen: false).refreshTransactions(businessId),
        Provider.of<InvoiceProvider>(context, listen: false).refreshInvoices(businessId),
        Provider.of<CustomerProvider>(context, listen: false).loadCustomers(businessId),
        Provider.of<SupplierProvider>(context, listen: false).loadSuppliers(businessId),
      ]);
    }
  }

  Future<void> _generateTransactionReport() async {
    if (_selectedDateRange == null) return;

    setState(() => _isGenerating = true);

    try {
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

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

      final fileName = 'transaction_report_${DateFormat('yyyyMMdd').format(_selectedDateRange!.start)}_${DateFormat('yyyyMMdd').format(_selectedDateRange!.end)}.pdf';

      if (mounted) {
        await _showReportOptions(pdfData, fileName);
      }
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
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _generateCustomerReport() async {
    setState(() => _isGenerating = true);

    try {
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);

      if (businessProvider.business == null) {
        throw Exception('Business information not found');
      }

      final pdfData = await PdfService.generateCustomerReport(
        business: businessProvider.business!,
        customers: customerProvider.customers,
      );

      final fileName = 'customer_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

      if (mounted) {
        await _showReportOptions(pdfData, fileName);
      }
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
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _generateSupplierReport() async {
    setState(() => _isGenerating = true);

    try {
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
      final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);

      if (businessProvider.business == null) {
        throw Exception('Business information not found');
      }

      final pdfData = await PdfService.generateSupplierReport(
        business: businessProvider.business!,
        suppliers: supplierProvider.suppliers,
      );

      final fileName = 'supplier_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

      if (mounted) {
        await _showReportOptions(pdfData, fileName);
      }
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
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _generateFinancialSummary() async {
    if (_selectedDateRange == null) return;

    setState(() => _isGenerating = true);

    try {
      final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

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

      final fileName = 'financial_summary_${DateFormat('yyyyMMdd').format(_selectedDateRange!.start)}_${DateFormat('yyyyMMdd').format(_selectedDateRange!.end)}.pdf';

      if (mounted) {
        await _showReportOptions(pdfData, fileName);
      }
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
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _exportReport(String format) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exporting as $format...'),
          backgroundColor: AppTheme.infoColor,
        ),
      );
    }
    
    // Export functionality would be implemented here
    // For now, just generate the appropriate report
    switch (format) {
      case 'pdf':
        await _generateTransactionReport();
        break;
      case 'csv':
      case 'excel':
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CSV/Excel export coming soon'),
              backgroundColor: AppTheme.infoColor,
            ),
          );
        }
        break;
    }
  }

  Future<void> _showReportOptions(Uint8List pdfData, String fileName) async {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppTheme.successColor, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Report Generated Successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                    ),
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
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
