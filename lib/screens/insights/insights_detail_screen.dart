import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/ai_models.dart';
import '../../utils/constants.dart';

class InsightsDetailScreen extends StatelessWidget {
  final BusinessInsight insight;

  const InsightsDetailScreen({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insight Details'),
        backgroundColor: _getInsightColor(insight.type),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInsightHeader(),
            const SizedBox(height: 24),
            _buildInsightDescription(),
            const SizedBox(height: 24),
            _buildRecommendations(),
            const SizedBox(height: 24),
            _buildVisualization(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getInsightColor(
                      insight.type,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getInsightIcon(insight.type),
                    color: _getInsightColor(insight.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getInsightTypeLabel(insight.type),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMetricCard(
                  'Impact Score',
                  '${((insight.impactScore ?? 0.0) * 100).toInt()}%',
                ),
                const SizedBox(width: 12),
                _buildMetricCard(
                  'Valid Until',
                  insight.validUntil != null
                      ? _formatDate(insight.validUntil!)
                      : 'N/A',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              insight.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    if (insight.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...insight.recommendations.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getInsightColor(
                          insight.type,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getInsightColor(insight.type),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14, height: 1.4),
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

  Widget _buildVisualization() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trend Visualization',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    // Generate sample data based on insight type
    List<FlSpot> spots = _generateChartData();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                switch (value.toInt()) {
                  case 0:
                    return const Text('Jan', style: style);
                  case 1:
                    return const Text('Feb', style: style);
                  case 2:
                    return const Text('Mar', style: style);
                  case 3:
                    return const Text('Apr', style: style);
                  case 4:
                    return const Text('May', style: style);
                  case 5:
                    return const Text('Jun', style: style);
                  default:
                    return const Text('', style: style);
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${AppConstants.defaultCurrency}${value.toInt()}k',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _getInsightColor(insight.type),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: _getInsightColor(insight.type).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateChartData() {
    // Generate sample data based on insight type
    switch (insight.type) {
      case InsightType.cashFlowPrediction:
        return [
          const FlSpot(0, 3),
          const FlSpot(1, 4),
          const FlSpot(2, 3.5),
          const FlSpot(3, 5),
          const FlSpot(4, 4),
          const FlSpot(5, 6),
        ];
      case InsightType.customerAnalysis:
        return [
          const FlSpot(0, 2),
          const FlSpot(1, 3),
          const FlSpot(2, 5),
          const FlSpot(3, 7),
          const FlSpot(4, 6),
          const FlSpot(5, 8),
        ];
      case InsightType.workingCapital:
        return [
          const FlSpot(0, 5),
          const FlSpot(1, 4),
          const FlSpot(2, 3),
          const FlSpot(3, 2),
          const FlSpot(4, 1.5),
          const FlSpot(5, 1),
        ];
      case InsightType.expenseTrend:
        return [
          const FlSpot(0, 2),
          const FlSpot(1, 3),
          const FlSpot(2, 4),
          const FlSpot(3, 6),
          const FlSpot(4, 7),
          const FlSpot(5, 9),
        ];
      case InsightType.revenueForecast:
        return [
          const FlSpot(0, 3),
          const FlSpot(1, 5),
          const FlSpot(2, 7),
          const FlSpot(3, 6),
          const FlSpot(4, 8),
          const FlSpot(5, 10),
        ];
      case InsightType.general:
        return [
          const FlSpot(0, 1),
          const FlSpot(1, 2),
          const FlSpot(2, 3),
          const FlSpot(3, 4),
          const FlSpot(4, 5),
          const FlSpot(5, 6),
        ];
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share functionality coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement export functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Export functionality coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.cashFlowPrediction:
        return Colors.blue;
      case InsightType.customerAnalysis:
        return Colors.green;
      case InsightType.workingCapital:
        return Colors.orange;
      case InsightType.expenseTrend:
        return Colors.red;
      case InsightType.revenueForecast:
        return Colors.purple;
      case InsightType.general:
        return Colors.grey;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.cashFlowPrediction:
        return Icons.trending_up;
      case InsightType.customerAnalysis:
        return Icons.people;
      case InsightType.workingCapital:
        return Icons.account_balance;
      case InsightType.expenseTrend:
        return Icons.warning;
      case InsightType.revenueForecast:
        return Icons.trending_up;
      case InsightType.general:
        return Icons.lightbulb;
    }
  }

  String _getInsightTypeLabel(InsightType type) {
    switch (type) {
      case InsightType.cashFlowPrediction:
        return 'Cash Flow Prediction';
      case InsightType.customerAnalysis:
        return 'Customer Analysis';
      case InsightType.workingCapital:
        return 'Working Capital';
      case InsightType.expenseTrend:
        return 'Expense Trend';
      case InsightType.revenueForecast:
        return 'Revenue Forecast';
      case InsightType.general:
        return 'General Insight';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
